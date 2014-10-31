//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Richie Austerberry on 20/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"
#import "DataSource.h"
#import "LikeButton.h"
#import "ComposeCommentView.h"

//We declare that we confirm to the gesture recogniser delegate protocol...

@interface MediaTableViewCell () <UIGestureRecognizerDelegate, ComposeCommentViewDelegate>

@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *usernameAndCaptionLabel;
@property (nonatomic, strong) UILabel *commentLabel;

@property (nonatomic, strong) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *usernameAndCaptionLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *commentLabelHeightConstraint;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *twoFingerTapGestureRecognizer;

@property (nonatomic, strong) UILabel* likesCountLabel;
@property (nonatomic, strong) LikeButton *likeButton;

@property (nonatomic, strong) ComposeCommentView *commentView;

@end


static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *usernameLabelGray;
static UIColor *commentLabelGray;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;

@implementation MediaTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        self.mediaImageView = [[UIImageView alloc] init];
        
        //Here we add the gesture recognizer to the image view...
        
        self.mediaImageView.userInteractionEnabled = YES;
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        //Initialise long tap gesture recogniser and add it to the image view...
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        //Initialise two finger tap gesture recogniser and add it to the image view...
        
        self.twoFingerTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(twoFingerTap:)];
        self.twoFingerTapGestureRecognizer.numberOfTouchesRequired = 2;
        self.twoFingerTapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.twoFingerTapGestureRecognizer];
        
        self.usernameAndCaptionLabel = [[UILabel alloc]init];
        self.commentLabel = [[UILabel alloc]init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGray;
        
        self.likeButton = [[LikeButton alloc]init];
        [self.likeButton addTarget:self action:@selector(likePressed:) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = usernameLabelGray;
        
        self.commentView = [[ComposeCommentView alloc]init];
        self.commentView.delegate = self;

        
        for (UIView *view in @[self.mediaImageView, self.usernameAndCaptionLabel, self.commentLabel, self.likeButton, self.commentView])
        {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
    
        [self createConstraints];
        
    }
    return self;
}

-(void) createConstraints
{
    if (isPhone) {
        [self createPhoneConstraints];
    } else
    {
        [self createPadConstraints];
    }
    
    [self createCommonConstraints];
}

-(void) createCommonConstraints
{
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _commentView);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_usernameAndCaptionLabel][_likeButton(==38)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|" options: kNilOptions metrics:nil views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentView]|" options:kNilOptions metrics:nil views:viewDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaImageView][_usernameAndCaptionLabel][_commentLabel][_commentView(==100)]" options:kNilOptions metrics:nil views:viewDictionary]];
    
    self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    
    self.usernameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_usernameAndCaptionLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    
    self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    
    [self.contentView addConstraints:@[self.imageHeightConstraint, self.imageHeightConstraint, self.usernameAndCaptionLabelHeightConstraint, self.commentLabelHeightConstraint]];
}

-(void) createPadConstraints
{
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _commentView);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_mediaImageView(==320)]" options:kNilOptions metrics:nil views:viewDictionary]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:_mediaImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}

-(void) createPhoneConstraints
{
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _usernameAndCaptionLabel, _commentLabel, _likeButton, _commentView);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|" options:kNilOptions metrics:nil views:viewDictionary]];
}

#pragma mark - Image View

//Here we inform the delegate when the gesture recogniser fires...

-(void) tapFired:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}

//and we do the same for the long press recogniser...

-(void) longPressFired:(UILongPressGestureRecognizer *)sender {
   
    // if we don't specify the 'StateBegan' condition, the method will get called twice - once when the user presses and once when they releaase. By the same token, we could specify 'UIGestureRecognizerStateRecognized' so that the method gets called when the finger is lifter instead..
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}

-(void) twoFingerTap:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self didTapWithTwoFingers:self.mediaImageView];
}

-(void) likePressed:(UIButton *)sender {
    [self.delegate cellDidPressLikeButton:self];
}

#pragma mark = ComposeCommentViewDelegate


// Here, the cell tells it's delegate (which is ImagesTableController) that a comment was composed
-(void) commentViewDidPressCommentButton:(ComposeCommentView *)sender
{
    [self.delegate cell:self didComposeComment:self.mediaitem.temporaryComment];
}

// This stores any text written so far in temporaryComment - so the user can scroll up or down without losing the text

-(void) commentView:(ComposeCommentView *)sender textDidChange:(NSString *)text
{
    self.mediaitem.temporaryComment = text;
}

//Tells ti ImageTableViewController that the user began editing

-(void) commentViewWillStartEditing:(ComposeCommentView *)sender
{
    [self.delegate cellWillStartComposingComment:self];
}

//If another object tells the cell to stopComposingComment, the cell passes that message along to the comment view...

-(void) stopComposingComment
{
    [self.commentView stopComposingComment];
}


# pragma mark - UIGestureRecognizerDelegate

// Here we ensure that the gesture recognizer only fires when the cell isn't in editing mode...

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.isEditing == NO;
}

+(void)load {

    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    usernameLabelGray = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
    commentLabelGray = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
    linkColor = [UIColor colorWithRed:0.345 green:0.314 blue:0.427 alpha:1];
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc]init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    paragraphStyle = mutableParagraphStyle;

}

-(NSAttributedString *) commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc]init];
    
    for (Comment *comment in self.mediaitem.comments) {
    
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc]initWithString:baseString attributes:@{NSFontAttributeName : lightFont, NSParagraphStyleAttributeName : paragraphStyle}];
        
        NSRange usernameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:usernameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
        
        [commentString appendAttributedString:oneCommentString];
    }
    return commentString;
}


-(NSAttributedString *) usernameAndCaptionString {
    CGFloat usernameFontSize = 15;
    
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaitem.user.userName, self.mediaitem.caption];
    
    NSMutableAttributedString *mutableUsernameAndCaptionString = [[NSMutableAttributedString alloc]initWithString:baseString attributes:@{NSFontAttributeName : [lightFont fontWithSize:usernameFontSize], NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSRange usernameRange = [baseString rangeOfString:self.mediaitem.user.userName];
    [mutableUsernameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:usernameFontSize] range:usernameRange];
    [mutableUsernameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:usernameRange];
    
    return mutableUsernameAndCaptionString;
                                                                                                                                
}


-(void) layoutSubviews {
    [super layoutSubviews];
    
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.usernameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];
    
    self.usernameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height + 20;
    
    // We removed the calculation of image height constraint from 'setMediaItem' and placed it in 'layoutSubviews' to avoid redrawing the cells if the user rotates the device wihilst in full-screen mode...
    
    if (_mediaitem.image) {
        if (isPhone)
        {
            self.imageHeightConstraint.constant = self.mediaitem.image.size.height / self.mediaitem.image.size.width * CGRectGetWidth(self.contentView.bounds);
        } else
        {
            self.imageHeightConstraint.constant = 320;
        }
    } else {
        self.imageHeightConstraint.constant = 0;
    }
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
}

-(void) setMediaitem:(Media *)mediaitem {
    _mediaitem = mediaitem;
    self.mediaImageView.image = _mediaitem.image;
    self.usernameAndCaptionLabel.attributedText = [self usernameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    self.likeButton.likeButtonState = mediaitem.likeState;
    self.commentView.text = mediaitem.temporaryComment;

}

+ (CGFloat) heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {

    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"layoutCell"];
    
    
    layoutCell.mediaitem = mediaItem;
    
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    return CGRectGetMaxY(layoutCell.commentView.frame);
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:NO animated:animated];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}
/*
-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
    if (item.image) {
        return 450;
    } else {
        return 250;
    }
}
*/
@end
