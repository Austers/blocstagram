//
//  DataSource.h
//  Blocstagram
//
//  Created by Richie Austerberry on 19/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

//Setup notification - used to dismiss popover when user is done

extern NSString *const ImageFinishedNotification;

+(instancetype) sharedInstance;
+(NSString *) instagramClientID;

@property (nonatomic, strong, readonly) NSArray *mediaItems;
@property (nonatomic, strong, readonly) NSString *accessToken;

-(void) deleteMediaItems:(Media *)item;
-(void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;
-(void) requestOldItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler;

-(void) downloadImageForMediaItem:(Media *)mediaItem;
-(void) toggleLikeOnMediaItem:(Media *)mediaItem;

//Method to handle comments

-(void) commentOnMediaItem:(Media *)mediaItem withCommentText:(NSString *)commentText;

@end
