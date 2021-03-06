//
//  AGImageCheckerTests.h
//  AGImageChecker
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "AGImageChecker.h"

@interface AGImageCheckerTests : SenTestCase

@property (strong) UIViewController *rootViewController;
@property (strong) AGImageChecker *imageChecker;
@property (strong) id mockRootViewController;
@property (strong) id mockRootView;
@property (strong) UIImageView *imageView;

@end
