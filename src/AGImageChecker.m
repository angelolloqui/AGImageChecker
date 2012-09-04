//
//  AGImageChecker.m
//  Ziggo TV
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "AGImageChecker.h"
#import "UIImageView+AGImageChecker.h"

@implementation AGImageChecker

static AGImageChecker *sharedInstance = nil;
+ (AGImageChecker *)sharedInstance
{
#ifdef DEBUG
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
#endif
	return sharedInstance;
}

- (void)start {
    [UIImageView startCheckingImages];
}

- (void)stop {
    [UIImageView stopCheckingImages];
}


@end
