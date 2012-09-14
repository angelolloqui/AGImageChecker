//
//  AGBasePluginTests.h
//  AGImageChecker
//
//  Created by Angel Garcia on 9/14/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AGImageCheckerBasePlugin.h"

@interface AGBasePluginTests : SenTestCase

@property(strong) NSBundle *bundle;
@property(strong) UIImage *squareBigImage;
@property(strong) UIImage *squareSmallImage;
@property(strong) UIImage *rectImage;
@property(strong) UIImageView *squareBigView;
@property(strong) UIImageView *squareSmallView;
@property(strong) UIImageView *rectView;
@property(strong) AGImageCheckerBasePlugin *plugin;

@end
