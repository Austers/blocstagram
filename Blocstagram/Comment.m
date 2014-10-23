//
//  Comment.m
//  Blocstagram
//
//  Created by Richie Austerberry on 19/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "Comment.h"
#import "User.h"

@implementation Comment

-(instancetype) initWithDictionary:(NSDictionary *)commentDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = commentDictionary[@"id"];
        self.text = commentDictionary[@"text"];
        self.from = [[User alloc]initWithDictionary:commentDictionary[@"from"]];
    }

    return self;
    
}

@end
