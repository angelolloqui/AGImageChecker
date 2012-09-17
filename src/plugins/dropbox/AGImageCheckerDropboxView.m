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
@synthesize downloadHandler;
@synthesize imageView;

- (id)initWithImageView:(UIImageView *)targetImageView andIssues:(AGImageCheckerIssue)targetIssues andWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0, 0, width, 80)];
    
    if (self) {
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        sendButton.frame = CGRectMake(10, 5, 250, 30);
        [sendButton setTitle:@"Upload To Dropbox" forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(uploadToDropbox) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButton];
        
        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        downloadButton.frame = CGRectMake(10, 40, 250, 30);
        [downloadButton setTitle:@"Download From Dropbox" forState:UIControlStateNormal];
        [downloadButton addTarget:self action:@selector(downloadFromDropbox) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:downloadButton];        
        
        self.imageView = targetImageView;
    }
    
    return self;
}


- (void)uploadToDropbox {
    if (uploadHandler) {
        uploadHandler(imageView);
    }
}


- (void)downloadFromDropbox {
    if (downloadHandler) {
        downloadHandler(imageView);
    }
}



@end
