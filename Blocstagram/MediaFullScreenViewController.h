//
//  MediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Richie Austerberry on 24/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media;

@interface MediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

//this is a custom initialiser into which we will pass a media object to display...

-(instancetype) initWithMedia:(Media *)media;

-(void) centerScrollView;

@end
