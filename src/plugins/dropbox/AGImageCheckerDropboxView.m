//
//  AGImageCheckerDropboxView.m
//  AGImageChecker
//
//  Created by Angel Garcia on 9/17/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageCheckerDropboxView.h"
#import "UIImageView+AGImageCheckerDropbox.h"
#import <QuartzCore/QuartzCore.h>

@interface AGImageCheckerDropboxView ()

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation AGImageCheckerDropboxView

@synthesize uploadOriginalHandler;
@synthesize uploadRenderedHandler;
@synthesize downloadHandler;
@synthesize removeHandler;
@synthesize loginHandler;
@synthesize logoutHandler;
@synthesize uploadOriginalButton;
@synthesize uploadRenderButton;
@synthesize downloadButton;
@synthesize removeButton;
@synthesize logoutButton;
@synthesize loginButton;
@synthesize imageView;

- (id)initWithImageView:(UIImageView *)targetImageView andIssues:(AGImageCheckerIssue)targetIssues andWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0, 0, width, 180)];
    
    if (self) {
        self.imageView = targetImageView;
        UIColor *color = [UIColor colorWithRed:15 / 255.0f green:102 / 255.0f blue:162 / 255.0f alpha:1];
        UIColor *redColor = [UIColor colorWithRed:126 / 255.0f green:0 / 255.0f blue:6 / 255.0f alpha:1];
        UIColor *grayColor = [UIColor colorWithRed:60 / 255.0f green:60 / 255.0f blue:60 / 255.0f alpha:1];
        
        loginButton = [self buttonWithFrame:CGRectMake(10, 5, 200, 30) title:@"Login To Dropbox" andColor:color];
        [loginButton addTarget:self action:@selector(loginToDropbox) forControlEvents:UIControlEventTouchUpInside];
        
        uploadOriginalButton = [self buttonWithFrame:CGRectMake(10, 5, 200, 30) title:@"Upload original To Dropbox" andColor:color];
        [uploadOriginalButton addTarget:self action:@selector(uploadOriginalToDropbox) forControlEvents:UIControlEventTouchUpInside];
        
        uploadRenderButton = [self buttonWithFrame:CGRectMake(10, 45, 200, 30) title:@"Upload rendered To Dropbox" andColor:color];
        [uploadRenderButton addTarget:self action:@selector(uploadRenderToDropbox) forControlEvents:UIControlEventTouchUpInside];
        
        downloadButton = [self buttonWithFrame:CGRectMake(10, 85, 200, 30) title:@"Download From Dropbox" andColor:color];
        [downloadButton addTarget:self action:@selector(downloadFromDropbox) forControlEvents:UIControlEventTouchUpInside];
        
        removeButton = [self buttonWithFrame:CGRectMake(10, 85, 200, 30) title:@"Remove DB image from app" andColor:redColor];
        [removeButton addTarget:self action:@selector(removeFromLocalFolder) forControlEvents:UIControlEventTouchUpInside];
        
        logoutButton = [self buttonWithFrame:CGRectMake(10, 130, 200, 30) title:@"Logout from Dropbox" andColor:grayColor];
        [logoutButton addTarget:self action:@selector(logoutFromDropbox) forControlEvents:UIControlEventTouchUpInside];
        
        if (![imageView dropboxImagePath]) {
            uploadOriginalButton.enabled = NO;
            uploadRenderButton.enabled = NO;
            downloadButton.enabled = NO;
            removeButton.enabled = NO;
        }
    }
    
    return self;
}

- (UIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title andColor:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.85 alpha:1] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateDisabled];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [button.titleLabel setShadowColor:[UIColor lightGrayColor]];
    [button.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    button.layer.cornerRadius = 5.0f;
    button.layer.masksToBounds = YES;
    button.layer.backgroundColor = [color CGColor];
    [self addSubview:button];
    return button;
}

- (void)uploadOriginalToDropbox {
    if (uploadOriginalHandler) {
        uploadOriginalHandler(imageView);
    }
}

- (void)uploadRenderToDropbox {
    if (uploadRenderedHandler) {
        uploadRenderedHandler(imageView);
    }
}

- (void)downloadFromDropbox {
    if (downloadHandler) {
        downloadHandler(imageView);
    }
}

- (void)removeFromLocalFolder {
    if (removeHandler) {
        removeHandler(imageView);
    }
}

- (void)loginToDropbox {
    if (loginHandler) {
        loginHandler();
    }
}

- (void)logoutFromDropbox {
    if (logoutHandler) {
        logoutHandler();
    }
}

- (void)updateStatusWithLogin:(BOOL)logged {
    removeButton.hidden = ![imageView localDropboxImageExists];
    loginButton.hidden = logged;
    logoutButton.hidden = !logged;
    uploadOriginalButton.hidden = !logged;
    uploadRenderButton.hidden = !logged;
    downloadButton.hidden = !removeButton.hidden || !logged;
}

@end