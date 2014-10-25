//
//  MediaFullScreenAnimator.m
//  Blocstagram
//
//  Created by Richie Austerberry on 24/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "MediaFullScreenAnimator.h"
#import "MediaFullScreenViewController.h"

@implementation MediaFullScreenAnimator

//This method specifies how many seconds long the animation will be (An NSInterval can be any double number - always specified in seconds)...

-(NSTimeInterval) transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

-(void) animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    //'transition context' is the name of an object
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting) {
        
        //we make a new variable (casting) to refer to the toViewController controller...
        
        MediaFullScreenViewController *fullScreenVC = (MediaFullScreenViewController *)toViewController;
        
        //disable user interaction on table vieew controller so users can't scroll while animation is happening...
        
        fromViewController.view.userInteractionEnabled = NO;
        
        //We add the views of both view controllers to the transition context's container view...
        
        //[transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        //calculate frames (a frame describes a view's position and size with respect to its superview)...
        
        // because our start frame (self.cellimageview) is in a the coordinate system of another view controller (in a table in a cell), we use convertRect:fromView to convert the frame and bounds from that other coordinate system into the receivers coordinate system...
        
        CGRect startFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];
        
        CGRect endFrame = fromViewController.view.frame;
        
        toViewController.view.frame = startFrame;
        fullScreenVC.imageView.frame = toViewController.view.bounds;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fullScreenVC.view.frame = endFrame;
            [fullScreenVC centerScrollView];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    
} else
    [transitionContext.containerView addSubview:toViewController.view];
    [transitionContext.containerView addSubview:fromViewController.view];
    
    MediaFullScreenViewController *fullScreenVC = (MediaFullScreenViewController *)fromViewController;
    
    CGRect endFrame = [transitionContext.containerView convertRect:self.cellImageView.bounds fromView:self.cellImageView];
    CGRect imageStartFrame = [fullScreenVC.view convertRect:fullScreenVC.imageView.frame fromView:fullScreenVC.scrollView];
    CGRect imageEndFrame = [transitionContext.containerView convertRect:endFrame toView:fullScreenVC.view];
    
    [fullScreenVC.view addSubview:fullScreenVC.imageView];
    fullScreenVC.imageView.frame = imageStartFrame;
    fullScreenVC.imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    toViewController.view.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fullScreenVC.view.frame = endFrame;
        fullScreenVC.imageView.frame = imageEndFrame;
        
        toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
}

@end
