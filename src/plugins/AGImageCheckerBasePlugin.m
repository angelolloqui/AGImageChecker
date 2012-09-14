//
//  AGImageCheckerBasePlugin.m
//  AGImageChecker
//
//  Created by Angel Garcia on 9/14/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageCheckerBasePlugin.h"
#import "UIImageView+AGImageChecker.h"
#import "UIImage+AGImageChecker.h"
#import <QuartzCore/QuartzCore.h>

#define CGSizeIsBiggerThan(size1, size2) ((size1.width > size2.width) || (size1.height > size2.height))
#define CGSizeIsStrictlyBiggerThan(size1, size2) ((size1.width > size2.width) && (size1.height > size2.height))
#define CGSizeIsProportionalTo(size1, size2) ((size1.width / size2.width) == (size1.height / size2.height))
#define floatIsDecimal(num) (num - ((int) num) != 0.0f)


@implementation AGImageCheckerBasePlugin

- (AGImageCheckerIssue)calculateIssues:(UIImageView *)imageView withIssues:(AGImageCheckerIssue)issues {
    
    //Check Missing images
    if (imageView.image == nil || [imageView.image isEmptyImage]) {
        issues = AGImageCheckerIssueMissing;
    }
    //If image not missing, check if it is stretchable
    else if (UIEdgeInsetsEqualToEdgeInsets(imageView.image.capInsets, UIEdgeInsetsZero)) {
        CGSize imgSize = imageView.image.size;
        CGSize viewSize = imageView.bounds.size;
        
        //Retina image and view resizing
        CGFloat imgScale = imageView.image.scale;
        imgSize = CGSizeMake(imgSize.width * imgScale, imgSize.height * imgScale);
        CGFloat viewScale = [UIScreen mainScreen].scale;
        viewSize = CGSizeMake(viewSize.width * viewScale, viewSize.height * viewScale);
        
        if (imageView.contentMode == UIViewContentModeScaleAspectFill) {
            if ((imgSize.width != viewSize.width) || (imgSize.height != viewSize.height)) {
                issues |= AGImageCheckerIssueResized;
            }
            if (CGSizeIsBiggerThan(viewSize, imgSize)) {
                issues |= AGImageCheckerIssueBlurry;
            }
            if (!CGSizeIsProportionalTo(viewSize, imgSize)){
                issues |= AGImageCheckerIssuePartiallyHidden;
            }
        }
        else if (imageView.contentMode == UIViewContentModeScaleAspectFit) {
            if (CGSizeIsStrictlyBiggerThan(viewSize, imgSize)) {
                issues |= AGImageCheckerIssueResized;
                issues |= AGImageCheckerIssueBlurry;
            }
            else if (CGSizeIsStrictlyBiggerThan(imgSize, viewSize)) {
                issues |= AGImageCheckerIssueResized;
            }
        }
        else if (imageView.contentMode == UIViewContentModeScaleToFill) {
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
            if (imageView.contentMode == UIViewContentModeCenter) {
                CGFloat deltaX = (imgSize.width - viewSize.width) / 2.0;
                CGFloat deltaY = (imgSize.height - viewSize.height) / 2.0;
                if ((floatIsDecimal(deltaX)) || (floatIsDecimal(deltaY))) {
                    issues |= AGImageCheckerIssueBlurry;
                    issues |= AGImageCheckerIssueMissaligned;
                }
            }
        }
    }
    
    
    //If the image seems not to be missaligned, check the parents agains their own parents.
    //Note: we can not check the image against the window because it may be in a scrollview, animating, with a float contentOffset, but that is correct if the image is correctly aligned within the scroll
    if (!(issues & AGImageCheckerIssueMissaligned)) {
        UIView *view = imageView;
        while (view) {
            //Check if the view is correctly aligned
            CGPoint viewPosition = view.frame.origin;
            if ((floatIsDecimal(viewPosition.x)) || (floatIsDecimal(viewPosition.y))) {
                issues |= AGImageCheckerIssueBlurry;
                issues |= AGImageCheckerIssueMissaligned;
                break;
            }
            view = view.superview;
        }
    }
    
    return issues;
}

- (void)didFinishCalculatingIssues:(UIImageView *)imageView {
    AGImageCheckerIssue issues = imageView.issues;
    imageView.layer.borderWidth = 0;
    imageView.layer.borderColor = nil;
    
    if (!imageView.hidden && imageView.alpha > 0) {
        if (issues != AGImageCheckerIssueNone) {
            imageView.layer.borderWidth = 1;
            imageView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.1 alpha:0.5].CGColor;
        }
        
        if (issues & AGImageCheckerIssueBlurry) {
            imageView.layer.borderWidth = 2;
            imageView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.1 alpha:0.8].CGColor;
        }
        
        if (issues & AGImageCheckerIssueStretched) {
            imageView.layer.borderWidth = 2;
            imageView.layer.borderColor = [UIColor orangeColor].CGColor;
        }
        
        if (issues & AGImageCheckerIssueMissing) {
            imageView.layer.borderWidth = 4;
            imageView.layer.borderColor = [UIColor redColor].CGColor;
            if (imageView.image.name) {
                NSLog(@"[AGImageChecker] Could not load the image named \"%@\"", imageView.image.name);
            }
        }
    }
}

@end
