//
//  UIImageView+AGImageChecker.m
//  Ziggo TV
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "UIImageView+AGImageChecker.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define CGSizeIsBiggerThan(size1, size2) ((size1.width > size2.width) && (size1.height > size2.height))
#define CGSizeIsProportionalTo(size1, size2) ((size1.width / size2.width) == (size1.height / size2.height))

@implementation UIImageView (AGImageChecker)
@dynamic issues;

+ (void)startCheckingImages {
    [self swizzle];
}

+ (void)stopCheckingImages {
    [self swizzle];
}

+ (void)swizzle {
    //Swizzle the original setImage method to add our own calls
    Method setImageOriginal = class_getInstanceMethod(self, @selector(setImage:));
    Method setImageCustom = class_getInstanceMethod(self, @selector(setImageCustom:));
    method_exchangeImplementations(setImageOriginal, setImageCustom);    
    
    //Swizzle the original setFrame method to add our own calls
    Method setFrameOriginal = class_getInstanceMethod(self, @selector(setFrame:));
    Method setFrameCustom = class_getInstanceMethod(self, @selector(setFrameCustom:));
    method_exchangeImplementations(setFrameOriginal, setFrameCustom);    
    
    //Swizzle the original setFrame method to add our own calls
    Method setContentModeOriginal = class_getInstanceMethod(self, @selector(setContentMode:));
    Method setContentModeCustom = class_getInstanceMethod(self, @selector(setContentModeCustom:));
    method_exchangeImplementations(setContentModeOriginal, setContentModeCustom);    
}

#pragma mark Swizzled methods

- (void)setImageCustom:(UIImage *)image {
    //Call the original method (was swizzled)
    [self setImageCustom:image];        
    [self checkImage];
}

- (void)setFrameCustom:(CGRect)frame {
    //Call the original method (was swizzled)
    [self setFrameCustom:frame];    
    [self checkImage];
}

- (void)setContentModeCustom:(UIViewContentMode)mode {
    //Call the original method (was swizzled)
    [self setContentModeCustom:mode];    
    [self checkImage];
}


#pragma mark Checking and drawing

- (void)checkImage {
    AGImageCheckerIssue issues = AGImageCheckerIssueNone;
    CGSize imgSize = self.image.size;
    CGSize viewSize = self.bounds.size;

    if (self.contentMode == UIViewContentModeScaleAspectFill) {        
        if ((imgSize.width != viewSize.width) && (imgSize.height != viewSize.height)) {
            issues |= AGImageCheckerIssueResized;
        }
        if (CGSizeIsBiggerThan(viewSize, imgSize)) {
            issues |= AGImageCheckerIssueBlurry;
        }        
        if (!CGSizeIsProportionalTo(viewSize, imgSize)){
            issues |= AGImageCheckerIssuePartiallyHidden;
        }
    }
    else if (self.contentMode == UIViewContentModeScaleAspectFit) {
        if (CGSizeIsBiggerThan(viewSize, imgSize)) {
            issues |= AGImageCheckerIssueResized;
            issues |= AGImageCheckerIssueBlurry;
        }        
        else if (CGSizeIsBiggerThan(imgSize, viewSize)) {
            issues |= AGImageCheckerIssueResized;
        }        
    }
    else if (self.contentMode == UIViewContentModeScaleToFill) {
        if (CGSizeIsBiggerThan(viewSize, imgSize)) {
            issues |= AGImageCheckerIssueResized;
            issues |= AGImageCheckerIssueBlurry;
        }        
        else if (CGSizeIsBiggerThan(imgSize, viewSize)) {
            issues |= AGImageCheckerIssueResized;
        }
        if (!CGSizeIsProportionalTo(viewSize, imgSize)){
            issues |= AGImageCheckerIssueStretched;
        }
    }
    else {
        if (CGSizeIsBiggerThan(imgSize, viewSize)) {
            issues |= AGImageCheckerIssuePartiallyHidden;
        }        
        
        //When setting to center the image can be aligned to 0.5. Check it returns blurry
        if (self.contentMode == UIViewContentModeCenter) {
            CGFloat deltaX = (imgSize.width - viewSize.width) / 2.0;
            CGFloat deltaY = (imgSize.height - viewSize.height) / 2.0;
            if ((deltaX != round(deltaX)) || (deltaY != round(deltaY))) {
                issues |= AGImageCheckerIssueBlurry;
            }
        }
    }

    self.issues = issues;
    [self drawIssues];    
}

- (void)drawIssues {
    AGImageCheckerIssue issues = self.issues;
    if (issues & AGImageCheckerIssueResized) {
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor yellowColor].CGColor;
    }
    
    if (issues & AGImageCheckerIssueBlurry) {
        self.layer.borderWidth = 3;
        self.layer.borderColor = [UIColor orangeColor].CGColor;
    }
    
    if (issues & AGImageCheckerIssueStretched) {
        self.layer.borderWidth = 3;
        self.layer.borderColor = [UIColor redColor].CGColor;
    }

    
    
    //        
    //    UIGraphicsBeginImageContext(self.bounds.size);
    //	CGContextRef context = UIGraphicsGetCurrentContext();
    //	[[UIColor redColor] set];
    //    CGContextSetLineWidth(context, 5);
    //	CGContextStrokePath(context);
    //    CGContextAddRect(context, self.bounds);
    //    UIGraphicsEndImageContext();
}


#pragma mark Properties

static void * const kMyAssociatedIssuesKey = (void*)&kMyAssociatedIssuesKey; 
- (AGImageCheckerIssue)issues {
    return (AGImageCheckerIssue)[(NSNumber *)objc_getAssociatedObject(self, kMyAssociatedIssuesKey) intValue];
}

- (void)setIssues:(AGImageCheckerIssue)issues {
    objc_setAssociatedObject(self, kMyAssociatedIssuesKey, [NSNumber numberWithInt:issues], OBJC_ASSOCIATION_RETAIN);
}

@end
