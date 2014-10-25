//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Richie Austerberry on 20/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Media, MediaTableViewCell;

// Add a delegate protocol

@protocol MediaTableViewCellDelegate <NSObject>

// The delegate method will inform the cell's controller when a user taps on an image...

-(void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;

// This delegate method will inform the cell's controller when the user long presses on an image...

-(void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;

@end


@interface MediaTableViewCell : UITableViewCell

@property (nonatomic, strong) Media *mediaitem;
@property (nonatomic, weak) id <MediaTableViewCellDelegate> delegate;

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
