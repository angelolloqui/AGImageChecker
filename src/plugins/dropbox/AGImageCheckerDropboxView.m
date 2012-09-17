//
//  AGImageCheckerDropboxView.m
//  AGImageChecker
//
//  Created by Angel Garcia on 9/17/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageCheckerDropboxView.h"

@interface AGImageCheckerDropboxView ()

@property(nonatomic, strong) UIImageView *imageView;

@end


@implementation AGImageCheckerDropboxView

@synthesize uploadHandler;
@synthesize imageView;

- (id)initWithImageView:(UIImageView *)targetImageView andIssues:(AGImageCheckerIssue)targetIssues andWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0, 0, width, 50)];
    
    if (self) {
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendButton.frame = CGRectMake(10, 5, 150, 40);
        [sendButton setTitle:@"Upload To Dropbox" forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(uploadToDropbox) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButton];
        
        self.imageView = targetImageView;
    }
    
    return self;
}


- (void)uploadToDropbox {
    if (uploadHandler) {
        uploadHandler(imageView);
    }
}



@end
