//
//  UIImageView+AGImageCheckerDropbox.h
//  AGImageChecker
//
//  Created by Angel Garcia on 9/18/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (AGImageCheckerDropbox)

@property (nonatomic, strong) UIImage *originalImage;

- (NSString *)dropboxImagePath;
- (NSString *)localDropboxImagePath;
- (BOOL)localDropboxImageExists;

@end
