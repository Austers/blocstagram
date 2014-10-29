//
//  UIImage+ImageUtilities.h
//  Blocstagram
//
//  Created by Richie Austerberry on 30/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageUtilities)

-(UIImage *) imageWithFixedOrientation;
-(UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size;
-(UIImage *) imageCroppedToRect:(CGRect)cropRect;
-(UIImage *) imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;

@end
