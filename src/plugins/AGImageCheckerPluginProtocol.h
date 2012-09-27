//
//  AGImageCheckerPluginProtocol.h
//  AGImageChecker
//
//  Created by Angel Garcia on 9/14/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+AGImageChecker.h"
@class AGImageDetailViewController;

@protocol AGImageCheckerPluginProtocol <NSObject>

@optional

// Call to check for new issues in the imageView
- (AGImageCheckerIssue)calculateIssues:(UIImageView *)imageView withIssues:(AGImageCheckerIssue)issues;

// Notifies about the results of issues. Usually draw operations performed here
- (void)didFinishCalculatingIssues:(UIImageView *)imageView;

// Returns a view for the detail popover with the plugin options
- (UIView *)detailForViewController:(AGImageDetailViewController *)viewController withImageView:(UIImageView *)imageView withIssues:(AGImageCheckerIssue)issues;


@end