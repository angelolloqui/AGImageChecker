//
//  AGDropboxPluginTests.h
//  AGImageChecker
//
//  Created by Angel Garcia on 9/26/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AGImageChecker.h"
#import "AGImageCheckerDropboxPlugin.h"

@interface AGDropboxPluginTests : SenTestCase

@property (strong) id mockDBSession;
@property (strong) id mockDBClient;
@property (strong) id mockImageChecker;

@property (strong) AGImageCheckerDropboxPlugin *plugin;
@property (strong) id mockDBPlugin;

@property (strong) UIImageView *imageView;
@property (strong) id mockImageView;
@property (strong) NSBundle *bundle;
@end
