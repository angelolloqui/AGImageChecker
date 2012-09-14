//
//  UIImage+AGImageChecker.h
//  AGImageChecker
//
//  Created by Angel on 9/12/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AGImageChecker)

@property (readonly) NSString *name;


+ (void)startSavingNames;
+ (void)stopSavingNames;

- (BOOL)isEmptyImage;

@end
