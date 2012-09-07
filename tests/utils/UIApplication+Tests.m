//
//  UIApplication+Tests.m
//  AGImageChecker
//
//  Created by Angel on 9/7/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "UIApplication+Tests.h"

@implementation UIApplication (Tests)

static id application = nil;
+ (UIApplication *)sharedApplication {
    if (!application) {
        application = [OCMockObject niceMockForClass:[UIApplication class]];
        id wnd = [OCMockObject niceMockForClass:[UIWindow class]];
        [wnd makeKeyWindow];
        [[[(id) [UIApplication sharedApplication] stub] andReturn:wnd] keyWindow];    
    }
    return application;
}

+ (void) resetApplication {
    application = nil;
}

@end
