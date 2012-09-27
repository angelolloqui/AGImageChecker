//
//  UIImageView+AGImageChecker.m
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "UIImageView+AGImageChecker.h"
#import "AGImageChecker.h"
#import <objc/runtime.h>

@implementation UIImageView (AGImageChecker)

@dynamic issues;

#pragma mark Public API

static BOOL methodsAlreadySwizzled = NO;
+ (void)startCheckingImages {
    if (!methodsAlreadySwizzled) {
        methodsAlreadySwizzled = YES;
        [self swizzle];
    }
}

+ (void)stopCheckingImages {
    if (methodsAlreadySwizzled) {
        methodsAlreadySwizzled = NO;
        [self swizzle];
    }
}

static AGImageViewHandler sIssuesHandler = nil;
+ (void)setImageIssuesHandler:(AGImageViewHandler)handler {
    sIssuesHandler = [handler copy];
}

static AGImageViewHandler sCheckHandler = nil;
+ (void)setImageCheckHandler:(AGImageViewHandler)handler {
    sCheckHandler = [handler copy];
}

#pragma mark Swizzling methods

+ (void)swizzle {
#if AGIMAGECHECKER
    //Swizzle the original setImage method to add our own calls
    Method setImageOriginal = class_getInstanceMethod(self, @selector(setImage:));
    Method setImageCustom = class_getInstanceMethod(self, @selector(setImageCustom:));
    method_exchangeImplementations(setImageOriginal, setImageCustom);

    //Swizzle the original setFrame method to add our own calls
    Method setFrameOriginal = class_getInstanceMethod(self, @selector(setFrame:));
    Method setFrameCustom = class_getInstanceMethod(self, @selector(setFrameCustom:));
    method_exchangeImplementations(setFrameOriginal, setFrameCustom);

    //Swizzle the original setContentMode method to add our own calls
    Method setContentModeOriginal = class_getInstanceMethod(self, @selector(setContentMode:));
    Method setContentModeCustom = class_getInstanceMethod(self, @selector(setContentModeCustom:));
    method_exchangeImplementations(setContentModeOriginal, setContentModeCustom);

    //Swizzle the original initWithCoder method to add our own calls
    Method initWithCoderOriginal = class_getInstanceMethod(self, @selector(initWithCoder:));
    Method initWithCoderCustom = class_getInstanceMethod(self, @selector(initWithCoderCustom:));
    method_exchangeImplementations(initWithCoderOriginal, initWithCoderCustom);

    //Swizzle the original layoutSubviews method to add our own calls
    Method setLayoutSubviewsOriginal = class_getInstanceMethod(self, @selector(layoutSubviews));
    Method setLayoutSubviewsCustom = class_getInstanceMethod(self, @selector(layoutSubviewsCustom));
    method_exchangeImplementations(setLayoutSubviewsOriginal, setLayoutSubviewsCustom);
#endif
}

#if AGIMAGECHECKER
- (void)setImageCustom:(UIImage *)image {
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImage *oldImage = self.image;
        //Call the original method (was swizzled)
        [self setImageCustom:image];

        if (image != oldImage) {
            if (sCheckHandler) {
                sCheckHandler(self);
            }
        }
    }
}

- (void)setFrameCustom:(CGRect)frame {
    if ([self isKindOfClass:[UIImageView class]]) {
        CGRect oldFrame = self.frame;
        //Call the original method (was swizzled)
        [self setFrameCustom:frame];

        if (!CGRectEqualToRect(frame, oldFrame)) {
            if (sCheckHandler) {
                sCheckHandler(self);
            }
        }
    }
}

- (void)setContentModeCustom:(UIViewContentMode)mode {
    if ([self isKindOfClass:[UIImageView class]]) {
        UIViewContentMode oldMode = self.contentMode;
        //Call the original method (was swizzled)
        [self setContentModeCustom:mode];

        if (mode != oldMode) {
            if (sCheckHandler) {
                sCheckHandler(self);
            }
        }
    }
}

- (id)initWithCoderCustom:(NSCoder *)aDecoder {
    if ([self isKindOfClass:[UIImageView class]]) {
        //Call the original method (was swizzled)
        self = [self initWithCoderCustom:aDecoder];

        if (sCheckHandler) {
            sCheckHandler(self);
        }
    }

    return self;
}

- (void)layoutSubviewsCustom {
    if ([self isKindOfClass:[UIImageView class]]) {
        //Call the original method (was swizzled)
        [self layoutSubviewsCustom];

        if (sCheckHandler) {
            sCheckHandler(self);
        }
    }
}

#endif

#pragma mark Properties

static void *const kMyAssociatedIssuesKey = (void *)&kMyAssociatedIssuesKey;
- (AGImageCheckerIssue)issues {
    return (AGImageCheckerIssue)[(NSNumber *)objc_getAssociatedObject(self, kMyAssociatedIssuesKey) intValue];
}

- (void)setIssues:(AGImageCheckerIssue)issues {
    [self willChangeValueForKey:@"issues"];
    objc_setAssociatedObject(self, kMyAssociatedIssuesKey, [NSNumber numberWithInt:issues], OBJC_ASSOCIATION_RETAIN);

    if (sIssuesHandler) {
        sIssuesHandler(self);
    }

    [self didChangeValueForKey:@"issues"];
}

@end