//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by Richie Austerberry on 15/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"
#import "MediaTableViewCell.h"
#import "MediaFullScreenViewController.h"
#import "MediaFullScreenAnimator.h"
#import "CameraViewController.h"
#import "ImageLibraryViewController.h"
#import "PostToInstagramViewController.h"

@interface ImagesTableViewController () <MediaTableViewCellDelegate, UIViewControllerTransitioningDelegate, CameraViewControllerDelegate,ImageLibraryViewControllerDelegate>

@property (nonatomic, weak) UIImageView *lastTappedImageView;
//@property(nonatomic, readonly, getter=isDragging) BOOL dragging;

@property (nonatomic, weak) UIView *lastSelectedCommentView;
@property (nonatomic, assign) CGFloat lastKeyboardAdjustments;

@end

@implementation ImagesTableViewController

- (void)viewDidLoad {

    self.title = @"Images from instagram";
    
    [super viewDidLoad];
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];

  //  Here, we request notifications of the keyboard appearing and dissappearing. This will call the respective methods just before the keyboard shows or hides
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraPressed:)];
        self.navigationItem.rightBarButtonItem = cameraButton;
    }
    
    
    
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

//viewWillAppear has built in functionality for handling keyboards. But it's no good for out custom cell, so we'll make our own by over-riding the default functionality - we do this by NOT calling super

-(void)viewWillAppear:(BOOL)animated {
   //we choose to keep this functionality - making sure the cells aren't selected when the view appears...
    
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    
}

-(void) refreshControlDidFire:(UIRefreshControl *) sender {
[[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
    [sender endRefreshing];
}];

}

-(void) infiniteScrollIfNecessary {
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    if (bottomIndexPath && bottomIndexPath.row == [DataSource sharedInstance].mediaItems.count - 1) {
        NSLog(@"Hello");
        [[DataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self infiniteScrollIfNecessary];
}


-(void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
        
            [self.tableView reloadData];
            
        } else if (kindOfChange == NSKeyValueChangeInsertion || kindOfChange == NSKeyValueChangeRemoval || kindOfChange == NSKeyValueChangeReplacement) {
        
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            NSMutableArray *indexpathsThatChanged = [NSMutableArray array];
            
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexpathsThatChanged addObject:newIndexPath];
            }];
        
            [self.tableView beginUpdates];
            
            if (kindOfChange == NSKeyValueChangeInsertion ) {
                [self.tableView insertRowsAtIndexPaths:indexpathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths:indexpathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement){
                [self.tableView reloadRowsAtIndexPaths:indexpathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        
            [self.tableView endUpdates];
    }
}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [DataSource sharedInstance].mediaItems.count;
}

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
       
    
    }
    return self;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    
    //When we create (or dequeue) a cell, we now need to set its delegate (for gesture code to work (see delegate method)...
    
    cell.delegate = self;
    
    cell.mediaitem = [DataSource sharedInstance].mediaItems[indexPath.row];
    
    
    return cell;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];

    return [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Media *item = [DataSource sharedInstance].mediaItems[indexPath.row];
        [[DataSource sharedInstance] deleteMediaItems:item];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
    
}

//If a row is tapped - let's assume the user doesn't want the keyboard..

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MediaTableViewCell *cell = (MediaTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopComposingComment];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

//Here we implement the delegate method...

#pragma mark - MediaTableViewCellDelegate

-(void) cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
    
    // we need to set the properrty lastTappedImageView when the image is tapped...
    
    MediaFullScreenViewController *fullScreenVC = [[MediaFullScreenViewController alloc]initWithMedia:cell.mediaitem];
    
    //and let iOS know that the transition uses a delegate...
    
    fullScreenVC.transitioningDelegate = self;
    fullScreenVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:fullScreenVC animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitionDelegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {

    MediaFullScreenAnimator *animator = [MediaFullScreenAnimator new];
    animator.presenting = YES;
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    MediaFullScreenAnimator *animator = [MediaFullScreenAnimator new];
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}

-(void) cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
    NSMutableArray *itemsToShare = [NSMutableArray array];

    if (cell.mediaitem.caption.length > 0) {
        [itemsToShare addObject:cell.mediaitem.caption];
    }
    
    if (cell.mediaitem.image) {
        [itemsToShare addObject:cell.mediaitem.image];
    }
    
    if (itemsToShare.count > 0) {
        
        // code to present Activity View controller to allow sharing
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:itemsToShare applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

-(void) cell:(MediaTableViewCell *)cell didTapWithTwoFingers:(UIImageView *)imageView
{
    NSLog(@"Two finger tap");
    
    [[DataSource sharedInstance] downloadImageForMediaItem:cell.mediaitem];
}

-(void) cellDidPressLikeButton:(MediaTableViewCell *)cell {
    [[DataSource sharedInstance] toggleLikeOnMediaItem:cell.mediaitem];
}

-(void) cellWillStartComposingComment:(MediaTableViewCell *)cell
{
    self.lastSelectedCommentView = (UIView *)cell.commentView;
}

-(void) cell:(MediaTableViewCell *)cell didComposeComment:(NSString *)comment
{
    [[DataSource sharedInstance]commentOnMediaItem:cell.mediaitem withCommentText:comment];
}

#pragma mark - Keyboard Handling

-(void)keyboardWillShow:(NSNotification *)notification
{
    //get the frame of the keyboard
    
    NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameInScreenCoordinates = frameValue.CGRectValue;
    CGRect keyboardFrameInViewCoordinates = [self.navigationController.view convertRect:keyboardFrameInScreenCoordinates fromView:nil];
    
    //get the frame from the comment view
    
    CGRect commentViewFrameInViewCoordinates = [self.navigationController.view convertRect:self.lastSelectedCommentView.bounds fromView:self.lastSelectedCommentView];
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    CGFloat heightToScroll = 0;
    
    CGFloat keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates);
    CGFloat commentViewY = CGRectGetMinY(commentViewFrameInViewCoordinates);
    CGFloat difference = commentViewY = keyboardY;
    
    if (difference > 0)
    {
        heightToScroll += difference;
    }
    
    if (CGRectIntersectsRect(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates)) {
        CGRect intersectionRect = CGRectIntersection(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates);
        heightToScroll += CGRectGetHeight(intersectionRect);
    }
    
    if (heightToScroll > 0) {
        contentInsets.bottom += heightToScroll;
        scrollIndicatorInsets.bottom += heightToScroll;
        contentOffset.y += heightToScroll;
        
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
            self.tableView.contentOffset = contentOffset;
        } completion:nil];
    }
    
    self.lastKeyboardAdjustments = heightToScroll;
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    contentInsets.bottom -= self.lastKeyboardAdjustments;
    
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom -= self.lastKeyboardAdjustments;
    
    NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    NSTimeInterval duration = durationNumber.doubleValue;
    UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
    UIViewAnimationOptions options = curve << 16;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    } completion:nil];
    
}

#pragma mark - Camera and CameraViewControllerDelegate, and ImageLibraryViewControllerDelegate

-(void) cameraPressed:(UIBarButtonItem *)sender
{
    
    UIViewController *imageVC;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
    CameraViewController *cameraVC = [[CameraViewController alloc]init];
    cameraVC.delegate = self;
        
        imageVC = cameraVC;
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        ImageLibraryViewController *imageLibraryVC = [[ImageLibraryViewController alloc] init];
        imageLibraryVC.delegate = self;
        imageVC = imageLibraryVC;
    }
    
    if (imageVC) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
    return;
}

-(void) cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image
{
    [self handleImage:image withNavigationController:cameraViewController.navigationController];
}

- (void) imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image {
    [self handleImage:image withNavigationController:imageLibraryViewController.navigationController];
}

-(void) handleImage:(UIImage *)image withNavigationController:(UINavigationController *)nav
{
    if (image) {
        PostToInstagramViewController *postVC = [[PostToInstagramViewController alloc]initWithImage:image];
        
        [nav pushViewController:postVC animated:YES];
    } else
    {
        [nav dismissViewControllerAnimated:YES completion:nil];
    }
}

/*
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
        [[DataSource sharedInstance]downloadImageForMediaItem:mediaItem];
    }
}


-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSArray *visibleCells = [self.tableView indexPathsForVisibleRows];
    NSInteger tmprowOne = [[visibleCells objectAtIndex:0] row];
    NSInteger tmprowTwo = [[visibleCells objectAtIndex:1] row];
    Media *mediaItemOne = [DataSource sharedInstance].mediaItems[tmprowOne];
    Media *mediaItemTwo = [DataSource sharedInstance].mediaItems[tmprowTwo];
    if (mediaItemOne.downloadState == MediaDownloadStateNeedsImage) && {
        [[DataSource sharedInstance]downloadImageForMediaItem:mediaItemOne];
        NSLog(@"MediaItemOne");
    } if (mediaItemTwo.downloadState == MediaDownloadStateNeedsImage) {
        [[DataSource sharedInstance]downloadImageForMediaItem:mediaItemTwo];
    NSLog(@"MediaItemTwo");
    }
}
*/
@end
