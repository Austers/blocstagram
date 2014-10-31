//
//  DataSource.m
//  Blocstagram
//
//  Created by Richie Austerberry on 19/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"
#import "LoginViewController.h"
#import <UICKeyChainStore.h> //<> used when importing external files
#import <AFNetworking/AFNetworking.h>

@interface DataSource () {
    NSMutableArray *_mediaItems;
}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSArray *mediaItems;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;
@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;

@end

@implementation DataSource

//Set up the notification that dismisses the popover when the user is done

NSString *const ImageFinishedNotification = @"ImageFinishedNotification";


+(NSString *) instagramClientID {
    return @"ce5d64cb11c54196a874ff3f0a1a8c98";
}

// ? What is going on here?


- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
        [[NSNotificationCenter defaultCenter] postNotificationName:ImageFinishedNotification object:self];
}


-(void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {

    if (self.accessToken) {
    
        //We create a parameters dictionary for the access token and add in any other parameters that might be passed in (like min_id or max_id). We then tell the request operation manager to get the resource and if it is successful - send it to parseDataFromFeedDictionary:fromRequestWithParameters: for parsin....
        
        
        NSMutableDictionary *mutableParameters = [@{@"access_token":self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/feed" parameters:mutableParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                
                
            }
            if (completionHandler) {
                completionHandler(nil);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}


-(void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem];
        }
        
    }
    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
    }else if (parameters[@"max_id"]) {
        if (tmpMediaItems.count == 0) {
            self.thereAreNoMoreOlderMessages = YES;
        }
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
    
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
}
    
    //Write the file to the disk when we have just got the new data...
    
    if (tmpMediaItems.count > 0) {
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            
            // Number up to 50 (so we don't flood the user's hard drive)
            
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
           
            // convert the array into an NSData
            
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            
            NSError *dataError;
           
            //Save it to disk
            //NSDataWritingAtomic ensures a complete file is saved. Without it, we might corrupt the file if the app crahses whilst writing to disk
            //NSDataWritingFileProtectionCompleteUnlessOpen encrypts the data
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
            
        });
    }
}

-(void) downloadImageForMediaItem:(Media *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        
        mediaItem.downloadState = MediaDownloadStateDownloadInProgress;

        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[UIImage class]]) {
                mediaItem.image = responseObject;
                
                mediaItem.downloadState = MediaDownloadStateHasImage;
                
                NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                
            } else {
                mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error downloading image: %@", error);
            
            mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
            
            if ([error.domain isEqualToString:NSURLErrorDomain]) {
                if (error.code == NSURLErrorTimedOut ||
                    error.code == NSURLErrorCancelled ||
                    error.code == NSURLErrorCannotConnectToHost ||
                    error.code == NSURLErrorNetworkConnectionLost ||
                    error.code == NSURLErrorNotConnectedToInternet ||
                    error.code == kCFURLErrorInternationalRoamingOff ||
                    error.code == kCFURLErrorCallIsActive ||
                    error.code == kCFURLErrorDataNotAllowed ||
                    error.code == kCFURLErrorRequestBodyStreamExhausted) {
                
                    mediaItem.downloadState = MediaDownloadStateNeedsImage;
                }
            }
        }];
    }
}

-(void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {

    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
        self.isLoadingOlderItems = YES;
        
        
        NSString *maxID = [[self.mediaItems lastObject]idNumber];
        NSDictionary *parameters = @{@"max_id": maxID};
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
        
        self.isLoadingOlderItems = NO;
        
        if (completionHandler) {
            completionHandler(error);
        }
        }];
        }
}


-(void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler {
    
    self.thereAreNoMoreOlderMessages = NO;
    
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;

        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        if (minID.length > 0)
        {
            parameters[@"min_id"] = minID;
        }
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error){
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }

}

-(void) deleteMediaItems:(Media *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

#pragma mark = Key/Value Observing;

-(NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

-(id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

-(NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

-(void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems insertObject:object atIndex:index];
}

-(void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

-(void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

+(instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype) init {
    self = [super init];
    
    if (self) {
        
        //here we initialise the operation manager...
        
        NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:baseURL];
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        imageSerializer.imageScale = 1.0;
        
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
        self.instagramOperationManager.responseSerializer = serializer;
        
        
        //on init, we will look in the KeyChainStore for access token. If it is already stored (because we have logged in already and done so in the process -see'registerForAccessTokenNotification) - then the sharedInstance will be presented. If it is not stored then the method 'registerForAccessTokenNotification' will be called to get the access token and it will be stored in the chain once recovered
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
            [self registerForAccessTokenNotification];
        } else {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        
                        //We make a mutable copy as the copy stored to disk is immutable
                        
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                         self.mediaItems = mutableMediaItems;
                         [self didChangeValueForKey:@"mediaItems"];
                          } else {
                              [self populateDataWithParameters:nil completionHandler:nil];
                          }
                          });
                          });
        }
        
        [self requestNewItemsWithCompletionHandler:nil];
    }
    return self;
}

-(void) registerForAccessTokenNotification {
[[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
    self.accessToken = note.object;
    
    [UICKeyChainStore setString:self.accessToken forKey:@"access token"]; //save the token
    
    [self populateDataWithParameters:nil completionHandler:nil];
    
}];

}

#pragma mark - Comments

// This method will post the method to Instagram's comments endpoint. If it succeeds, it'll refetch the media item with the new comment. If not, it simply reloads the row..

-(void) commentOnMediaItem:(Media *)mediaItem withCommentText:(NSString *)commentText
{
    if (!commentText || commentText.length == 0) {
        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"media/%@/comments", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token":self.accessToken, @"text":commentText};
    
    [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        mediaItem.temporaryComment = nil;
        
        NSString *refreshMediaURLString = [NSString stringWithFormat:@"media/%@", mediaItem.idNumber];
        NSDictionary *parameters = @{@"access_token":self.accessToken};
        [self.instagramOperationManager GET:refreshMediaURLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            Media *newMediaItem = [[Media alloc]initWithDictionary:responseObject];
            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:newMediaItem];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self reloadMediaItem:mediaItem];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", operation.responseString);
        [self reloadMediaItem:mediaItem];
    }];
}


#pragma mark - Liking Media Items

-(void) toggleLikeOnMediaItem:(Media *)mediaItem {
    NSString *urlString = [NSString stringWithFormat:@"media?%@/likes", mediaItem.idNumber];
    
    NSDictionary *parameters = @{@"access_token":self.accessToken};
    
    if (mediaItem.likeState == LikeStateNotLiked) {
        mediaItem.likeState = LikeStateLiking;
        
        [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = LikeStateLiked;
            [self reloadMediaItem:mediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = LikeStateNotLiked;
         [self reloadMediaItem:mediaItem];
         }];
    }else if (mediaItem.likeState == LikeStateLiked) {
        mediaItem.likeState = LikeStateNotLiked;
        [self.instagramOperationManager DELETE:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = LikeStateNotLiked;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = LikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        }];
    }
    
    [self reloadMediaItem:mediaItem];
}
-(void)reloadMediaItem:(Media *)mediaItem {
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
    }
    
// This method creates a string that contains an absolute path to the user's documents directory

-(NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentaryDirectory = [paths firstObject];
    NSString *dataPath = [documentaryDirectory stringByAppendingPathComponent:filename];
    return dataPath;

}


@end
