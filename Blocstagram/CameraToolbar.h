//
//  CameraToolbar.h
//  Blocstagram
//
//  Created by Richie Austerberry on 29/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraToolbar;

@protocol CameraToolbarDelegate <NSObject>

-(void) leftbuttonPressedOnToolbar:(CameraToolbar *)toolbar;
-(void) rightButtonPressedOnToolbar:(CameraToolbar *)toolbar;
-(void) cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar;

@end

@interface CameraToolbar : UIView

-(instancetype) initWithImageNames:(NSArray *)imageNames;

@property (nonatomic, weak) NSObject <CameraToolbarDelegate> *delegate;

@end
