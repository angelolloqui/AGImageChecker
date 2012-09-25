//
//  AGImageCheckerDropboxView.h
//  AGImageChecker
//
//  Created by Angel Garcia on 9/17/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AGImageChecker.h"


@interface AGImageCheckerDropboxView : UIView

@property (nonatomic, copy) AGImageViewHandler uploadOriginalHandler;
@property (nonatomic, copy) AGImageViewHandler uploadRenderedHandler;
@property (nonatomic, copy) AGImageViewHandler downloadHandler;
@property (nonatomic, copy) AGImageViewHandler removeHandler;
@property (nonatomic, copy) dispatch_block_t loginHandler;
@property (nonatomic, copy) dispatch_block_t logoutHandler;
@property (readonly, strong) UIButton *uploadOriginalButton;
@property (readonly, strong) UIButton *uploadRenderButton;
@property (readonly, strong) UIButton *downloadButton;
@property (readonly, strong) UIButton *removeButton;
@property (readonly, strong) UIButton *loginButton;
@property (readonly, strong) UIButton *logoutButton;

- (id)initWithImageView:(UIImageView *)targetImageView andIssues:(AGImageCheckerIssue)targetIssues andWidth:(CGFloat)width;
- (void)updateStatusWithLogin:(BOOL)logged;

@end
