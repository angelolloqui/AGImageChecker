//
//  UIImageView+AGImageCheckerDropbox.m
//  AGImageChecker
//
//  Created by Angel Garcia on 9/18/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "UIImageView+AGImageCheckerDropbox.h"
#import "UIImage+AGImageChecker.h"
#import <objc/runtime.h>

@implementation UIImageView (AGImageCheckerDropbox)
@dynamic originalImage;

- (NSString *)dropboxBasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [basePath stringByAppendingPathComponent:@"AGImageChekerDropbox" isDirectory:YES];
}

- (NSString *)dropboxImagePath {
    NSString *filename = self.accessibilityLabel;
    if ([filename length] <= 0) {
        filename = self.originalImage.name;
        if (!filename)
            filename = self.image.name;
    }
    NSString *basePath = [self dropboxBasePath];
    filename = [filename stringByReplacingOccurrencesOfString:basePath withString:@""];
    return [[filename stringByReplacingOccurrencesOfString:@"//" withString:@"/"] stringByReplacingOccurrencesOfString:@":" withString:@""];
}

- (NSString *)localDropboxImagePath {
    NSString *filename = [self dropboxImagePath];
    if (!filename)
        return nil;
    return [[self dropboxBasePath] stringByAppendingString:filename];
}

- (BOOL)localDropboxImageExists {
    NSString *localImagePath = [self localDropboxImagePath];
    if (!localImagePath) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:localImagePath];
}


#pragma mark Properties

static void * const kMyAssociatedDropboxKey = (void*)&kMyAssociatedDropboxKey;
- (UIImage *)originalImage {
    return objc_getAssociatedObject(self, kMyAssociatedDropboxKey);
}

- (void)setOriginalImage:(UIImage *)originalImage {
    objc_setAssociatedObject(self, kMyAssociatedDropboxKey, originalImage, OBJC_ASSOCIATION_RETAIN);
}

@end
