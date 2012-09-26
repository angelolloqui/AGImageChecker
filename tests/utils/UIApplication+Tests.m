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
static id mockWindow = nil;
static id delegate = nil;

+ (UIApplication *)sharedApplication {
    if (!application) {
        application = [OCMockObject niceMockForClass:[UIApplication class]];
        UIWindow *wnd = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [wnd makeKeyWindow];
        mockWindow = [OCMockObject niceMockForClass:[UIWindow class]];
        [[[(id) [UIApplication sharedApplication] stub] andReturn:[NSArray arrayWithObjects:wnd, mockWindow, nil]] windows];
        
        delegate = [OCMockObject niceMockForClass:[NSObject class]];
        [[[(id) [UIApplication sharedApplication] stub] andReturn:delegate] delegate];
    }
    return application;
}

+ (void) resetApplication {
    application = nil;
}

+ (id)mockWindow {
    return mockWindow;
}

@end
