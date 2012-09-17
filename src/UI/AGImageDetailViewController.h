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

+ (AGImageDetailViewController *)presentModalForImageView:(UIImageView *)imageView inViewController:(UIViewController *)viewController;

@end
