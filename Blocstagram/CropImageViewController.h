//
//  CropImageViewController.h
//  Blocstagram
//
//  Created by Richie Austerberry on 30/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "MediaFullScreenViewController.h"
#import <UIKit/UIKit.h>

@class CropImageViewController;

@protocol CropImageViewControllerDelegate <NSObject>

-(void) cropControllerFinishedWithImage:(UIImage *)croppedImage;

@end

@interface CropImageViewController : MediaFullScreenViewController

-(instancetype) initWithImage:(UIImage *)sourceImage;

@property (nonatomic, weak) NSObject <CropImageViewControllerDelegate> *delegate;

@end
