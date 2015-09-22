//
//  TTSwipeTabBarViewController.h
//  AbisinApp
//
//  Created by tenten on 2014/12/26.
//  Copyright (c) 2014年 Victoria Sun. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString *const TTsegmentBarItemID;


@interface TTSegmentBarItem : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@class TTSwipeTabBarViewController;

/**
 *  Need to be implemented this methods for custom UI of segment button
 */
@protocol TTSwipeTabBarDataSource <NSObject>
@required

- (NSInteger)slideSegment:(UICollectionView *)segmentBar
   numberOfItemsInSection:(NSInteger)section;

- (UICollectionViewCell *)slideSegment:(UICollectionView *)segmentBar
                cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInslideSegment:(UICollectionView *)segmentBar;

@end

@protocol TTSwipeTabBarDelegate <NSObject>
@optional
- (void)slideSegment:(UICollectionView *)segmentBar didSelectedViewController:(UIViewController *)viewController;

- (BOOL)slideSegment:(UICollectionView *)segmentBar shouldSelectViewController:(UIViewController *)viewController;
@end


@interface TTSwipeTabBarViewController : UIViewController
/**
 *  Child viewControllers of SlideSegmentController
 */
@property (nonatomic, copy) NSArray *viewControllers;

@property (nonatomic, strong, readonly)  UICollectionView *segmentBar;
@property (nonatomic, strong, readonly)  UIScrollView *slideView;
@property (nonatomic, strong, readonly)  UIView *indicator;

@property (nonatomic, assign) UIEdgeInsets indicatorInsets;

@property (nonatomic, weak, readonly) UIViewController *selectedViewController;
@property (nonatomic, assign, readonly) NSInteger selectedIndex;


/**
 *  By default segmentBar use viewController's title for segment's button title
 *  You should implement JYSlideSegmentDataSource & JYSlideSegmentDelegate instead of segmentBar delegate & datasource
 */
@property (nonatomic, assign) id <TTSwipeTabBarDelegate> delegate;
@property (nonatomic, assign) id <TTSwipeTabBarDataSource> dataSource;

- (void)setTabViewControllers:(NSArray *)viewControllers;

- (void)scrollToViewWithIndex:(NSInteger)index animated:(BOOL)animated;
@end
