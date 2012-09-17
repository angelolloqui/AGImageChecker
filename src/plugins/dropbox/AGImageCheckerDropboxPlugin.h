//
//  AGImageCheckerDropboxPlugin.h
//  AGImageChecker
//
//  Created by Angel Garcia on 9/17/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGImageCheckerPluginProtocol.h"

@interface AGImageCheckerDropboxPlugin : NSObject <AGImageCheckerPluginProtocol>

+ (void)addPluginWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;
+ (BOOL)handleOpenURL:(NSURL *)url;

@end
