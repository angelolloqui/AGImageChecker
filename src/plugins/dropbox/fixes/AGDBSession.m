//
//  AGDBSession.m
//  AGImageChecker
//
//  Created by Angel Garcia on 9/21/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGDBSession.h"
#import "AGImageCheckerDropboxPlugin.h"
#include <objc/runtime.h>
#include <objc/message.h>

@interface DBSession(private)
- (BOOL)appConformsToScheme;
@end

@implementation AGDBSession

- (id) initWithAppKey:(NSString *)key appSecret:(NSString *)secret root:(NSString *)rootParam {
    self = [super initWithAppKey:key appSecret:secret root:rootParam];
    if (self) {
        NSAssert([super respondsToSelector:@selector(appConformsToScheme)], @"The Dropbox version used is not compatible with AGImageChecker");

        // Swizzled UIApplication delegate methods to allow opening Dropbox urls in the app even if the Info.plist is not configured
        if (![super appConformsToScheme]) {
            
            Method method = class_getInstanceMethod([[UIApplication sharedApplication] class], @selector(canOpenURL:));
            UIApplication_canOpenURL_original = method_getImplementation(method);
            method_setImplementation(method, (IMP)UIApplication_canOpenURL);            
        }
        
        //Handle OpenURL automatically
        id appDelegate = [[UIApplication sharedApplication] delegate];
        Method method = class_getInstanceMethod([appDelegate class], @selector(application:openURL:sourceApplication:annotation:));
        if (method) {
            UIApplicationDelegate_handleOpenURL_original = method_getImplementation(method);
            method_setImplementation(method, (IMP)UIApplicationDelegate_handleOpenURL);
        }
        else {
            class_addMethod([appDelegate class], @selector(application:openURL:sourceApplication:annotation:), (IMP)UIApplicationDelegate_handleOpenURL, "c24@0:4@8@12@16@20");
        }
        
    }
    return self;
}

// Do not check the URL identifiers in the Info.plist
// This way it is easier to integrate but we can not use Dropbox app
- (BOOL)appConformsToScheme {
    return YES;
}

static IMP UIApplication_canOpenURL_original;
static BOOL UIApplication_canOpenURL(id self, SEL _cmd, NSURL *url) {
    if ([[url scheme] isEqualToString:@"dbapi-1"]) {
        return NO;
    }
    return (BOOL) UIApplication_canOpenURL_original(self, _cmd, url);
}

static IMP UIApplicationDelegate_handleOpenURL_original;
static BOOL UIApplicationDelegate_handleOpenURL(id self, SEL _cmd, UIApplication *application, NSURL *url, NSString *sourceApplication, id annotation) {
    BOOL handled = NO;
    if (UIApplicationDelegate_handleOpenURL_original) {
        handled = (BOOL) UIApplicationDelegate_handleOpenURL_original(self, _cmd, application, url, sourceApplication, annotation);
    }
    return [AGImageCheckerDropboxPlugin handleOpenURL:url] || handled;
}


@end
