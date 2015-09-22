//
//  TTSwipeTabBarViewController.m
//  AbisinApp
//
//  Created by tenten on 2014/12/26.
//  Copyright (c) 2014年 Victoria Sun. All rights reserved.
//

#import "TTSwipeTabBarViewController.h"

#define SEGMENT_BAR_HEIGHT 44
#define SEGMENT_BAR_Y 64
#define INDICATOR_HEIGHT 3

NSString * const TTsegmentBarItemID = @"JYSegmentBarItem";

@implementation TTSegmentBarItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //    [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.iconImageView];
    }
    return self;
}
- (UIImageView *)iconImageView
{
    if (!_iconImageView) {
        
        _iconImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _iconImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _iconImageView.contentMode = UIViewContentModeCenter;
    }
    return _iconImageView;
}


- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end


@interface TTSwipeTabBarViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) UICollectionView *segmentBar;
@property (nonatomic, strong, readwrite) UIScrollView *slideView;
@property (nonatomic, assign, readwrite) NSInteger selectedIndex;
@property (nonatomic, strong, readwrite) UIView *indicator;
@property (nonatomic, strong) UIView *indicatorBgView;

@property (nonatomic, strong) UICollectionViewFlowLayout *segmentBarLayout;


@end

@implementation TTSwipeTabBarViewController

- (void)setTabViewControllers:(NSArray *)viewControllers{
    self.viewControllers = [viewControllers copy];
    _selectedIndex = NSNotFound;
}
- (void) awakeFromNib{

    
}

- (void)viewDidLoad {
    [self setupSubviews];
    [self reset];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated
{
    
    CGSize conentSize = CGSizeMake(self.view.frame.size.width * self.viewControllers.count, 0);
    [self.slideView setContentSize:conentSize];
    [self resetSubViewFrame];

    [super viewDidAppear:animated];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:self.segmentBar];

}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubviews
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.automaticallyAdjustsScrollViewInsets = NO;
            self.edgesForExtendedLayout = UIRectEdgeAll;
    }

    
    [self.view addSubview:self.segmentBar];
    [self.view addSubview:self.slideView];
    [self.segmentBar registerClass:[TTSegmentBarItem class] forCellWithReuseIdentifier:TTsegmentBarItemID];
    [self.segmentBar addSubview:self.indicatorBgView];
}
- (void)resetSubViewFrame{
    [self resetSlideView];
    [self resetSegmentBar];
    [self resetIndicator];
    [self resetIndicatorBgView];
    for (int i = 0; i < self.viewControllers.count; i ++) {
        UIViewController *vc = self.viewControllers[i];
        if (vc.parentViewController) {
            CGRect frame = self.view.frame;
            frame.origin.x = i*frame.size.width;
            vc.view.frame = frame;
        }
        vc = nil;
    }
    [self.segmentBar reloadData];
    [self scrollToViewWithIndex:self.selectedIndex animated:NO];
}
- (void)resetSlideView{
    self.slideView.frame = self.view.bounds;
    CGSize conentSize = CGSizeMake(self.view.frame.size.width * self.viewControllers.count, 0);
    [self.slideView setContentSize:conentSize];
}
- (UIScrollView *)slideView
{
    if (!_slideView) {

        _slideView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [_slideView setShowsHorizontalScrollIndicator:NO];
        [_slideView setShowsVerticalScrollIndicator:NO];
        [_slideView setPagingEnabled:YES];
        [_slideView setBounces:NO];
        [_slideView setDelegate:self];
    }
    return _slideView;
}
- (void)resetSegmentBar{
    CGRect frame = self.view.bounds;
    frame.size.height = SEGMENT_BAR_HEIGHT;
    frame.origin.y = SEGMENT_BAR_Y;
    _segmentBar.frame = frame;
}
- (UICollectionView *)segmentBar
{
    if (!_segmentBar) {
        CGRect frame = self.view.bounds;
        frame.size.height = SEGMENT_BAR_HEIGHT;
        frame.origin.y = SEGMENT_BAR_Y;
        _segmentBar = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:self.segmentBarLayout];
        _segmentBar.backgroundColor = [UIColor whiteColor];
        //        _segmentBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleTopMargin ;
        _segmentBar.delegate = self;
        _segmentBar.dataSource = self;
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
        //        [separator setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [separator setBackgroundColor:UIColorFromRGB(0xdcdcdc)];
        [_segmentBar addSubview:separator];
    }
    return _segmentBar;
}
- (void)resetIndicatorBgView{
    CGRect frame = CGRectMake(0, self.segmentBar.frame.size.height - INDICATOR_HEIGHT - 1,
                              self.view.frame.size.width / self.viewControllers.count, INDICATOR_HEIGHT);
    CGFloat percent = self.slideView.contentOffset.x / self.slideView.contentSize.width;
    frame.origin.x = self.slideView.frame.size.width * percent;
    self.indicatorBgView.frame = frame;

}
- (UIView *)indicatorBgView
{
    if (!_indicatorBgView) {
        CGRect frame = CGRectMake(0, self.segmentBar.frame.size.height - INDICATOR_HEIGHT - 1,
                                  self.view.frame.size.width / self.viewControllers.count, INDICATOR_HEIGHT);
        _indicatorBgView = [[UIView alloc] initWithFrame:frame];
        _indicatorBgView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _indicatorBgView.backgroundColor = [UIColor clearColor];
        [_indicatorBgView addSubview:self.indicator];
    }
    return _indicatorBgView;
}
- (void)resetIndicator{
    CGFloat width = self.view.frame.size.width / self.viewControllers.count - self.indicatorInsets.left - self.indicatorInsets.right;
    CGRect frame = CGRectMake(self.indicatorInsets.left, 0, width, INDICATOR_HEIGHT);
    self.indicator.frame = frame;
}
- (UIView *)indicator
{
    if (!_indicator) {
        CGFloat width = self.view.frame.size.width / self.viewControllers.count - self.indicatorInsets.left - self.indicatorInsets.right;
        CGRect frame = CGRectMake(self.indicatorInsets.left, 0, width, INDICATOR_HEIGHT);
        _indicator = [[UIView alloc] initWithFrame:frame];
        _indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _indicator.backgroundColor = [UIColor yellowColor];
    }
    return _indicator;
}

- (void)setIndicatorInsets:(UIEdgeInsets)indicatorInsets
{
    _indicatorInsets = indicatorInsets;
    CGRect frame = _indicator.frame;
    frame.origin.x = _indicatorInsets.left;
    CGFloat width = self.view.frame.size.width / self.viewControllers.count - _indicatorInsets.left - _indicatorInsets.right;
    frame.size.width = width;
    frame.size.height = INDICATOR_HEIGHT;
    _indicator.frame = frame;
}

- (UICollectionViewFlowLayout *)segmentBarLayout
{
    if (!_segmentBarLayout) {
        _segmentBarLayout = [[UICollectionViewFlowLayout alloc] init];
//        _segmentBarLayout.itemSize = CGSizeMake(self.view.frame.size.width / self.viewControllers.count, SEGMENT_BAR_HEIGHT);
        _segmentBarLayout.sectionInset = UIEdgeInsetsZero;
        _segmentBarLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _segmentBarLayout.minimumLineSpacing = 0;
        _segmentBarLayout.minimumInteritemSpacing = 0;
    }
    return _segmentBarLayout;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (_selectedIndex == selectedIndex) {
        return;
    }
    
    NSParameterAssert(selectedIndex >= 0 && selectedIndex < self.viewControllers.count);
    
    UIViewController *toSelectController = [self.viewControllers objectAtIndex:selectedIndex];


    // Add selected view controller as child view controller
    if (!toSelectController.parentViewController) {
        [self addChildViewController:toSelectController];
        CGRect rect = self.slideView.bounds;
        rect.origin.x = rect.size.width * selectedIndex;
        toSelectController.view.frame = rect;
        [self.slideView addSubview:toSelectController.view];
        [toSelectController didMoveToParentViewController:self];
        
        
    }
    _selectedIndex = selectedIndex;
    
    if ([_delegate respondsToSelector:@selector(slideSegment:didSelectedViewController:)]) {
        [_delegate slideSegment:self.segmentBar didSelectedViewController:toSelectController];
    }
    
}

- (void)resetViewControllers:(NSArray *)viewControllers
{
    // Need remove previous viewControllers
    for (UIViewController *vc in self.viewControllers) {
        [vc removeFromParentViewController];
    }
    self.viewControllers = [viewControllers copy];
    [self reset];
}

//- (NSArray *)viewControllers
//{
//    return [self.viewControllers copy];
//}

- (UIViewController *)selectedViewController
{
    
    return self.viewControllers[self.selectedIndex];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([_dataSource respondsToSelector:@selector(numberOfSectionsInslideSegment:)]) {
        return [_dataSource numberOfSectionsInslideSegment:collectionView];
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([_dataSource respondsToSelector:@selector(slideSegment:numberOfItemsInSection:)]) {
        return [_dataSource slideSegment:collectionView numberOfItemsInSection:section];
    }
    return self.viewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_dataSource respondsToSelector:@selector(slideSegment:cellForItemAtIndexPath:)]) {
        return [_dataSource slideSegment:collectionView cellForItemAtIndexPath:indexPath];
    }
    
    TTSegmentBarItem *segmentBarItem = [collectionView dequeueReusableCellWithReuseIdentifier:TTsegmentBarItemID
                                                                                 forIndexPath:indexPath];
    //  UIViewController *vc = self.viewControllers[indexPath.row];
    //    NSArray *iconNameArray =  @[@"follow",@"bd",@"shop",@"AD",@"DM"];
    //    segmentBarItem.iconImageView.image = [UIImage imageNamed:iconNameArray[indexPath.row]];
    
    //  segmentBarItem.titleLabel.text = vc.title;
    return segmentBarItem;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 0 || indexPath.row >= self.viewControllers.count) {
        return;
    }
    

    [self setSelectedIndex:indexPath.row];
    [self scrollToViewWithIndex:self.selectedIndex animated:YES];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 0 || indexPath.row >= self.viewControllers.count) {
        return NO;
    }
    
    BOOL flag = YES;
    UIViewController *vc = self.viewControllers[indexPath.row];
    if ([_delegate respondsToSelector:@selector(slideSegment:shouldSelectViewController:)]) {
        flag = [_delegate slideSegment:collectionView shouldSelectViewController:vc];
    }
    return flag;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width / self.viewControllers.count, SEGMENT_BAR_HEIGHT);
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.slideView && !CGSizeEqualToSize(scrollView.contentSize, CGSizeZero)  ) {
        // set indicator frame
        CGRect frame = self.indicatorBgView.frame;
        CGFloat percent = scrollView.contentOffset.x / scrollView.contentSize.width;
        frame.origin.x = scrollView.frame.size.width * percent;
        self.indicatorBgView.frame = frame;
        
        NSInteger index = roundf(percent * self.viewControllers.count);
        if (index >= 0 && index < self.viewControllers.count) {
            [self setSelectedIndex:index];
            [self.segmentBar reloadData];
        }
    }
}

#pragma mark - Action
- (void)scrollToViewWithIndex:(NSInteger)index animated:(BOOL)animated
{
    CGRect rect = self.slideView.bounds;
    rect.origin.x = rect.size.width * index;
    [self.slideView setContentOffset:CGPointMake(rect.origin.x, rect.origin.y) animated:animated];
}

- (void)reset
{
    _selectedIndex = NSNotFound;
    [self setSelectedIndex:0];
    [self scrollToViewWithIndex:0 animated:NO];
    [self.segmentBar reloadData];
}
#pragma mark - o
- (void)deviceOrientationDidChange:(NSNotification *)notification{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self resetSubViewFrame];

    });
}
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self resetSubViewFrame];
//        [self.segmentBar reloadData];
//        for (int i = 0; i < self.viewControllers.count; i ++) {
//            UIViewController *vc = self.viewControllers[i];
//            CGRect frame = self.view.frame;
//            frame.origin.x = i*frame.size.width;
//            vc.view.frame = frame;
//        }
//        [self scrollToViewWithIndex:self.selectedIndex animated:NO];
//    });
//    
//    
//}
@end
