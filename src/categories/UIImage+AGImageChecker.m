//
//  UIImage+AGImageChecker.m
//  AGImageChecker
//
//  Created by Angel on 9/12/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "UIImage+AGImageChecker.h"
#import "AGImageChecker.h"
#import <objc/runtime.h>

@implementation UIImage (AGImageChecker)
@dynamic name;

#pragma mark Public API

static BOOL methodsAlreadySwizzled = NO;
+ (void)startSavingNames {
    if (!methodsAlreadySwizzled) {
        methodsAlreadySwizzled = YES;
        [self swizzle];
    }
}

+ (void)stopSavingNames {
    if (methodsAlreadySwizzled) {
        methodsAlreadySwizzled = NO;
        [self swizzle];
    }
}

//Code based on http://stackoverflow.com/questions/3284185/get-pixel-color-of-uiimage
- (BOOL)isEmptyImage {
    if (CGSizeEqualToSize(self.size, CGSizeZero)) return YES;

    //Interface Builder sets a 1x1 image when no image found. 0 for every component (RGBA)
    if (CGSizeEqualToSize(self.size, CGSizeMake(1, 1))) {
        CGImageRef image = [self CGImage];

        if (image == NULL) return NO;

        CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(image));

        if (data == NULL) return NO;

        CFIndex length = CFDataGetLength(data);

        if (length < 4) return NO;

        const UInt32 *buffer = (UInt32 *)CFDataGetBytePtr(data);
        return *buffer == 0;
    }

    return NO;
}

#pragma mark Swizzling methods

+ (void)swizzle {
#if AGIMAGECHECKER
    //Swizzle the original imageNamed method to add our own calls
    Method imagedNamedOriginal = class_getClassMethod(self, @selector(imageNamed:));
    Method imagedNamedCustom = class_getClassMethod(self, @selector(imageNamedCustom:));
    method_exchangeImplementations(imagedNamedOriginal, imagedNamedCustom);

    //Swizzle the original imageWithContentsOfFile method to add our own calls
    Method imageWithContentsOfFileOriginal = class_getClassMethod(self, @selector(imageWithContentsOfFile:));
    Method imageWithContentsOfFileCustom = class_getClassMethod(self, @selector(imageWithContentsOfFileCustom:));
    method_exchangeImplementations(imageWithContentsOfFileOriginal, imageWithContentsOfFileCustom);

    //Swizzle the original resizableImageWithCapInsetsCustom method to add our own calls
    Method resizableImageWithCapInsetsOriginal = class_getInstanceMethod(self, @selector(resizableImageWithCapInsets:));
    Method resizableImageWithCapInsetsCustom = class_getInstanceMethod(self, @selector(resizableImageWithCapInsetsCustom:));
    method_exchangeImplementations(resizableImageWithCapInsetsOriginal, resizableImageWithCapInsetsCustom);

    //Swizzle the original resizableImageWithCapInsetsCustom method to add our own calls
    Method stretchableImageWithLeftCapWidthOriginal = class_getInstanceMethod(self, @selector(stretchableImageWithLeftCapWidth:topCapHeight:));
    Method stretchableImageWithLeftCapWidthCustom = class_getInstanceMethod(self, @selector(stretchableImageWithLeftCapWidthCustom:topCapHeight:));
    method_exchangeImplementations(stretchableImageWithLeftCapWidthOriginal, stretchableImageWithLeftCapWidthCustom);
#endif
}

#if AGIMAGECHECKER
+ (UIImage *)imageNamedCustom:(NSString *)name {
    UIImage *image = [self imageNamedCustom:name];

    if (image == nil) {
        image = [[UIImage alloc] init];
    }

    image.name = name;
    return image;
}

+ (UIImage *)imageWithContentsOfFileCustom:(NSString *)path {
    UIImage *image = [self imageWithContentsOfFileCustom:path];

    if (image == nil) {
        image = [[UIImage alloc] init];
    }

    image.name = path;
    return image;
}

- (UIImage *)resizableImageWithCapInsetsCustom:(UIEdgeInsets)capInsets {
    UIImage *image = [self resizableImageWithCapInsetsCustom:capInsets];

    image.name = self.name;
    return image;
}

- (UIImage *)stretchableImageWithLeftCapWidthCustom:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight {
    UIImage *image = [self stretchableImageWithLeftCapWidthCustom:leftCapWidth topCapHeight:topCapHeight];

    image.name = self.name;
    return image;
}

#endif

#pragma mark Properties

static void *const kMyAssociatedNameKey = (void *)&kMyAssociatedNameKey;
- (NSString *)name {
    return (NSString *)objc_getAssociatedObject(self, kMyAssociatedNameKey);
}

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];
    objc_setAssociatedObject(self, kMyAssociatedNameKey, name, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"name"];
}

@end