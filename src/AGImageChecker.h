//
//  AGImageChecker.h
//  Ziggo TV
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGImageChecker : NSObject

@property(readonly) BOOL running;
@property(readonly, strong) UILongPressGestureRecognizer *tapGesture;
@property(nonatomic, strong) UIViewController *rootViewController;

+ (AGImageChecker *)sharedInstance;
- (void)start;
- (void)stop;
- (void)openImageDetail:(UIImageView *)imageView;

@end
