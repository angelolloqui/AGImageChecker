//
//  AGImageChecker.h
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGImageCheckerPluginProtocol.h"

#ifndef AGIMAGECHECKER
#ifdef DEBUG
#define AGIMAGECHECKER 1
#else
#define AGIMAGECHECKER 0
#endif
#endif

@interface AGImageChecker : NSObject

@property(readonly) BOOL running;
@property(readonly, strong) UILongPressGestureRecognizer *tapGesture;
@property(nonatomic, strong) UIViewController *rootViewController;
@property(readonly, strong) NSArray *plugins;

+ (AGImageChecker *)sharedInstance;
+ (void)setSharedInstance:(AGImageChecker *)instance;
- (void)start;
- (void)stop;
- (void)openImageDetail:(UIImageView *)imageView;
- (void)addPlugin:(id<AGImageCheckerPluginProtocol>)plugin;
- (void)removePlugin:(id<AGImageCheckerPluginProtocol>)plugin;

@end
