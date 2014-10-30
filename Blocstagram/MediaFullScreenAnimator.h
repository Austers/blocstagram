//
//  MediaFullScreenAnimator.h
//  Blocstagram
//
//  Created by Richie Austerberry on 24/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MediaFullScreenAnimator : NSObject <UIViewControllerAnimatedTransitioning>

//This property will let us know if the animation is a presenting animation (if not, its a dismissing animation)

@property (nonatomic, assign) BOOL presenting;

//This property will reference the image view from the media table view cell (which the user taps on)

@property (nonatomic, weak) UIImageView *cellImageView;


@end
