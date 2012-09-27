//
//  AGImageDetailTests.h
//  AGImageChecker
//
//  Created by Angel on 9/7/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AGImageDetailViewController.h"

@interface AGImageDetailTests : SenTestCase

@property (strong) AGImageDetailViewController *imageDetailVC;
@property (strong) UIImageView *imageView;
@property (strong) UIImage *image;
@property (strong) UIViewController *viewController;
@property (strong) id mockImageChecker;

@end
