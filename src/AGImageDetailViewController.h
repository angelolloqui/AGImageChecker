//
//  AGImageDetailViewController.h
//  AGImageChecker
//
//  Created by Angel on 9/7/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGImageDetailViewController : UIViewController

@property (readonly, strong) UIImageView *targetImageView;
@property (readonly, strong) UILabel *imageViewFrameLabel;
@property (readonly, strong) UILabel *imageSizeLabel;
@property (readonly, strong) UILabel *issuesLabel;
@property (readonly, strong) UILabel *imageNameLabel;

+ (AGImageDetailViewController *)presentModalForImageView:(UIImageView *)imageView inViewController:(UIViewController *)viewController;

@end
