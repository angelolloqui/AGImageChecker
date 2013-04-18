//
//  AGImageCheckerBasePlugin.h
//  AGImageChecker
//
//  Created by Angel Garcia on 9/14/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGImageCheckerPluginProtocol.h"

@interface AGImageCheckerBasePlugin : NSObject <AGImageCheckerPluginProtocol>

- (UIColor *)colorForIssueType:(AGImageCheckerIssue)issue;
- (void)setColor:(UIColor *)color forIssueType:(AGImageCheckerIssue)issue;

@end