//
//  LikeCount.m
//  Blocstagram
//
//  Created by Richie Austerberry on 30/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "LikeCount.h"

@implementation LikeCount

-(instancetype) init
{
    self = [super init];
    
    if (self) {
        self.likeCountLabel = [[UILabel alloc]init];
        [self addSubview:self.likeCountLabel];
        
    
    }
    
    return self;
}

//-(void)viewDidLoad

@end
