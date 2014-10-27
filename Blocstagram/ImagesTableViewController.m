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

@interface ImagesTableViewController () <MediaTableViewCellDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIImageView *lastTappedImageView;

@end

@implementation ImagesTableViewController

- (void)viewDidLoad {

    self.title = @"Images from instagram";
    
    [super viewDidLoad];
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];



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

-(void) cell:(MediaTableViewCell *)cell didTapWithTwoFingers:(UIImageView *)imageView {
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        NSLog(@"It worked");
    }];
}
/*
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
        [[DataSource sharedInstance]downloadImageForMediaItem:mediaItem];
    }
}
*/

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSArray *visibleCells = [self.tableView indexPathsForVisibleRows];
    NSInteger tmprowOne = [[visibleCells objectAtIndex:0] row];
    NSInteger tmprowTwo = [[visibleCells objectAtIndex:1] row];
    Media *mediaItemOne = [DataSource sharedInstance].mediaItems[tmprowOne];
    Media *mediaItemTwo = [DataSource sharedInstance].mediaItems[tmprowTwo];
    if (mediaItemOne.downloadState == MediaDownloadStateNeedsImage) {
        [[DataSource sharedInstance]downloadImageForMediaItem:mediaItemOne];
        NSLog(@"MediaItemOne");
    } if (mediaItemTwo.downloadState == MediaDownloadStateNeedsImage) {
        [[DataSource sharedInstance]downloadImageForMediaItem:mediaItemTwo];
    NSLog(@"MediaItemTwo");
    }
}

@end
