//
//  CircleSpinnerView.m
//  Blocstagram
//
//  Created by Richie Austerberry on 27/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "CircleSpinnerView.h"

@interface CircleSpinnerView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end

@implementation CircleSpinnerView

-(id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        self.strokeThickness = 1;
        self.radius = 12;
        self.strokeColor = [UIColor purpleColor];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

-(CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        
        //calculate a CGPoint representing the center of the arc (which is an entire circle)
        // The CGRect rect will house the spinning circle
        
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        CGRect rect = CGRectMake(0, 0, arcCenter.x*2, arcCenter.y*2);
        
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:self.radius startAngle:M_PI*3/2 endAngle:M_PI/2+M_PI*5 clockwise:YES];
        
        //create a CAShapeLayer - a core animation layer made from a bezier path...
        
        _circleLayer = [CAShapeLayer layer];
       
        // scale is 1.0 for regular screen and 2.0 for retina displays
        _circleLayer.contentsScale = [[UIScreen mainScreen]scale];
        _circleLayer.frame = rect;
       
        // need to convert UIcolors to CGColorRefs using CGColor property...
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = self.strokeColor.CGColor;
        _circleLayer.lineWidth = self.strokeThickness;
        _circleLayer.lineCap = kCALineCapRound;
        _circleLayer.lineJoin = kCALineJoinBevel;
        _circleLayer.path = smoothedPath.CGPath;
        
        //A mask layer is an image or other layer that changes the opacity of its layer content - in this case, it allows our circle to have a gradient to it
        
        CALayer *maskLayer = [CALayer layer];
        maskLayer.contents = (id)[[UIImage imageNamed:@"angle-mask"]CGImage];
        maskLayer.frame = _circleLayer.bounds;
        _circleLayer.mask = maskLayer;
        
        CFTimeInterval animationDuration = 1;
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = @0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
       
        // fillMode specifies what happens when the animation is complete - kCAFillModeForwards leaves our layer on screen after the animation
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [_circleLayer.mask addAnimation:animation forKey:@"rotate"];
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = linearCurve;
        
        // We make two seperate a
        
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0.015;
        strokeStartAnimation.toValue = @0.515;
        
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @0.485;
        strokeEndAnimation.toValue = @0.985;
        
        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        [_circleLayer addAnimation:animationGroup forKey:@"progress"];
        
    }

    return _circleLayer;

}

-(void) layoutAnimatedLayer {
    [self.layer addSublayer:self.circleLayer];
    
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

//update the position whenever a subview is added to another view

-(void)willMoveToSuperview:(UIView *)newSuperview {
    if(newSuperview !=nil) {
        [self layoutAnimatedLayer];
    }
    else {
        [self.circleLayer removeFromSuperlayer];
        self.circleLayer = nil;
    }
}

//update the position if the frame changes

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.superview !=nil) {
        [self layoutAnimatedLayer];
    }
}

//Recreate the circle if we change the radius

-(void)setRadius:(CGFloat)radius {
    _radius = radius;
    
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    
    [self layoutAnimatedLayer];
}

//.. and inform self.circleLayer if the stroke width and color properties change as well

-(void) setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    _circleLayer.strokeColor = strokeColor.CGColor;
}

-(void) setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;
    _circleLayer.lineWidth = _strokeThickness;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
