//
//  Media.m
//  Blocstagram
//
//  Created by Richie Austerberry on 19/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "Media.h"
#import "User.h"
#import "Comment.h"

@implementation Media

-(instancetype) initWithDictionary:(NSDictionary *)mediaDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = mediaDictionary[@"id"];
        self.user = [[User alloc]initWithDictionary:mediaDictionary[@"user"]];
        NSString *standardResolutionImageURLString = mediaDictionary[@"images"][@"standard_resolution"][@"url"];
        NSURL *standardResultionImageURL = [NSURL URLWithString:standardResolutionImageURLString];
        
        if (standardResultionImageURL) {
            self.mediaURL = standardResultionImageURL;
        }
    
        NSDictionary *captionDictionary = mediaDictionary[@"caption"];
        
        if([captionDictionary isKindOfClass:[NSDictionary class]]) {
        
            self.caption = captionDictionary[@"text"];
        } else {
        self.caption = @"";
        }
        
        NSMutableArray *commentsArray = [NSMutableArray array];
        
        for (NSDictionary *commentDictionary in mediaDictionary[@"comments"][@"data"]) {
            Comment *comments = [[Comment alloc]initWithDictionary:commentDictionary];
            [commentsArray addObject:comments] ;
        
        }
        
        self.comments = commentsArray;
    }
    return self;
}

@end
