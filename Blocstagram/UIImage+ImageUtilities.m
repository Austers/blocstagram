//
//  UIImage+ImageUtilities.m
//  Blocstagram
//
//  Created by Richie Austerberry on 30/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "UIImage+ImageUtilities.h"

@implementation UIImage (ImageUtilities)

-(UIImage *)imageWithFixedOrientation
{
    //If the image is correct, then do nothing...
    
    if (self.imageOrientation == UIImageOrientationUp) return [self copy];
    
    //We make the image upright by first rotating it and then flipping it appropriately...
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
            
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    
    }
    
    //Then we apply the transform and create the correct image
    
    CGFloat scaleFactor = self.scale;
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width * scaleFactor, self.size.height * scaleFactor, CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage));
    
    CGContextScaleCTM(ctx, scaleFactor, scaleFactor);
    
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    //Create a new UIImage from the drawing context
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg scale:scaleFactor orientation:UIImageOrientationUp];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;

}

// The camera aspect ratio differs from the screen aspect ratio so we need to resize the image to the aspect ratio of the screen

-(UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size
{
    CGFloat horizontalRatio = size.width / self.size.width;
    CGFloat verticalRatio = size.height / self.size.height;
    CGFloat ratio = MAX(horizontalRatio, verticalRatio);
    CGSize newSize = CGSizeMake(self.size.width * ratio * self.scale, self.size.height * ratio * self.scale);
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = self.CGImage;
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, newRect.size.width, newRect.size.height, CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage));

    CGContextDrawImage(ctx, newRect, imageRef);
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(ctx);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:UIImageOrientationUp];
    
    CGContextRelease(ctx);
    CGImageRelease(newImageRef);
    
    return newImage;
}

//Cropping

-(UIImage *) imageCroppedToRect:(CGRect)cropRect
{
    cropRect.size.width *= self.scale;
    cropRect.size.height *= self.scale;
    cropRect.origin.x *= self.scale;
    cropRect.origin.y *= self.scale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
}
/*
-(UIImage *)imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect
{
    
    CGFloat horizontalRatio = size.width / self.size.width;
    CGFloat verticalRatio = size.height / self.size.height;
    CGFloat ratio = MAX(horizontalRatio, verticalRatio);
    CGSize newSize = CGSizeMake(self.size.width * ratio * self.scale, self.size.height * ratio * self.scale);
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = self.CGImage;
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, newRect.size.width, newRect.size.height, CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage));
    
    CGContextDrawImage(ctx, newRect, imageRef);
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(ctx);
   // UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:UIImageOrientationUp];
    
    CGContextRelease(ctx);
    CGImageRelease(newImageRef);
    
    rect.size.width *= self.scale;
    rect.size.height *= self.scale;
    rect.origin.x *= self.scale;
    rect.origin.y *= self.scale;
    
    CGImageRef otherImageRef = CGImageCreateWithImageInRect(newImageRef, rect);
    
    UIImage *image = [UIImage imageWithCGImage:otherImageRef scale:self.scale orientation:self.imageOrientation];
    
    CGImageRelease(otherImageRef);

    return image;
}
*/
@end
