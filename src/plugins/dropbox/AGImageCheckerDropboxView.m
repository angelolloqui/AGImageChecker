//
//  AGImageCheckerDropboxView.m
//  AGImageChecker
//
//  Created by Angel Garcia on 9/17/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageCheckerDropboxView.h"
#import "UIImageView+AGImageCheckerDropbox.h"

@interface AGImageCheckerDropboxView ()

@property(nonatomic, strong) UIImageView *imageView;

@end


@implementation AGImageCheckerDropboxView

@synthesize uploadHandler;
@synthesize downloadHandler;
@synthesize removeHandler;
@synthesize uploadButton;
@synthesize downloadButton;
@synthesize removeButton;
@synthesize imageView;

- (id)initWithImageView:(UIImageView *)targetImageView andIssues:(AGImageCheckerIssue)targetIssues andWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0, 0, width, 80)];
    
    if (self) {
        self.imageView = targetImageView;
        
        uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        uploadButton.frame = CGRectMake(10, 5, 250, 30);
        [uploadButton setTitle:@"Upload To Dropbox" forState:UIControlStateNormal];
        [uploadButton addTarget:self action:@selector(uploadToDropbox) forControlEvents:UIControlEventTouchUpInside];
        [uploadButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateDisabled];
        [self addSubview:uploadButton];
        
        downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        downloadButton.frame = CGRectMake(10, 40, 250, 30);
        [downloadButton setTitle:@"Download From Dropbox" forState:UIControlStateNormal];
        [downloadButton addTarget:self action:@selector(downloadFromDropbox) forControlEvents:UIControlEventTouchUpInside];
        [downloadButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateDisabled];
        [self addSubview:downloadButton];
        
        removeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        removeButton.frame = CGRectMake(10, 40, 250, 30);
        [removeButton setTitle:@"Remove from app" forState:UIControlStateNormal];
        [removeButton addTarget:self action:@selector(removeFromLocalFolder) forControlEvents:UIControlEventTouchUpInside];
        [removeButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateDisabled];
        [self addSubview:removeButton];
        
        downloadButton.hidden = [imageView localDropboxImageExists];
        removeButton.hidden = !downloadButton.hidden;
        
        if (![imageView dropboxImagePath]) {
            uploadButton.enabled = NO;
            downloadButton.enabled = NO;
            removeButton.enabled = NO;
        }
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

- (void)removeFromLocalFolder {
    if (removeHandler) {
        removeHandler(imageView);
    }
}



@end
