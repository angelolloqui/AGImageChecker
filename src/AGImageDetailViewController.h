//
//  AGImageDetailViewController.h
//  AGImageChecker
//
//  Created by Angel on 9/7/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGImageDetailViewController : UIViewController

@property (readonly, strong) UIScrollView *contentScrollView;
@property (readonly, strong) UIImageView *targetImageView;
@property (readonly, strong) UILabel *imageViewSizeLabel;
@property (readonly, strong) UILabel *imageSizeLabel;
@property (readonly, strong) UILabel *contentModeLabel;
@property (readonly, strong) UILabel *issuesLabel;
@property (readonly, strong) UILabel *imageNameLabel;
@property (readonly, strong) UILabel *controllerNameLabel;
@property (readonly, strong) UIImageView *orginalImageView;
@property (readonly, strong) UIImageView *renderedImageView;

+ (AGImageDetailViewController *)presentModalForImageView:(UIImageView *)imageView inViewController:(UIViewController *)viewController;

@end
