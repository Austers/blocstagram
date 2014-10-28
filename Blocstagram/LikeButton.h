//
//  LikeButton.h
//  Blocstagram
//
//  Created by Richie Austerberry on 28/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LikeState) {
    LikeStateNotLiked = 0,
    LikeStateLiking = 1,
    LikeStateLiked = 2,
    LikeStateUnliking = 3
};

@interface LikeButton : UIButton

@property (nonatomic, assign) LikeState likeButtonState;

@end
