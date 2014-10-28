//
//  LikeButton.m
//  Blocstagram
//
//  Created by Richie Austerberry on 28/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "LikeButton.h"
#import "CircleSpinnerView.h"

#define kLikedStateImage @"heart-full"
#define kUnlikedStateImage @"heart-empty"

@interface LikeButton ()

@property (nonatomic, strong) CircleSpinnerView *spinnerView;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

@implementation LikeButton

-(instancetype) init {
    self = [super init];
    
    if (self) {
        self.spinnerView = [[CircleSpinnerView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [self addSubview:self.spinnerView];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        //provides a buffer between the edge of the button and the content
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        //specifies alignment of button's content
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        
        self.likeButtonState = LikeStateNotLiked;
    }
    return self;
}

//Spinners view 's frame should be updated whenever the button's frtame changes..

-(void) layoutSubviews {
    [super layoutSubviews];
    self.spinnerView.frame = self.imageView.frame;
}

//This setter changes the buttons image and shows the spinner based on the likeState...

-(void) setLikeButtonState:(LikeState)likeState {
    _likeButtonState = likeState;
    
    NSString *imageName;
    
    switch (_likeButtonState) {
        case LikeStateLiked:
        case LikeStateUnliking:
            imageName = kLikedStateImage;
            break;
            
        case LikeStateNotLiked:
        case LikeStateLiking:
            imageName = kUnlikedStateImage;
    }
    
    switch (_likeButtonState) {
        case LikeStateLiking:
            case LikeStateUnliking:
            self.spinnerView.hidden = NO;
            self.userInteractionEnabled = NO;
            break;
            
        case LikeStateLiked:
            case LikeStateNotLiked:
            self.spinnerView.hidden = YES;
            self.userInteractionEnabled = YES;
    }
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
}





@end