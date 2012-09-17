//
//  AGImageCheckerDropboxPlugin.m
//  AGImageChecker
//
//  Created by Angel Garcia on 9/17/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageCheckerDropboxPlugin.h"
#import "AGImageChecker.h"
#import "AGImageCheckerDropboxView.h"
#import "UIImage+AGImageChecker.h"
#import <DropboxSDK/DropboxSDK.h>
#import <QuartzCore/QuartzCore.h>

@interface AGImageCheckerDropboxPlugin () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *dbClient;
@property (nonatomic, assign) UIViewController *detailController;

@end

@implementation AGImageCheckerDropboxPlugin

@synthesize dbClient;
@synthesize detailController;

static AGImageCheckerDropboxPlugin *pluginInstance = nil;
+ (void)addPluginWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret {        
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pluginInstance = [[self alloc] initWithAppKey:appKey appSecret:appSecret];
    });    
    [[AGImageChecker sharedInstance] addPlugin:pluginInstance];
}


+ (BOOL)handleOpenURL:(NSURL *)url {    
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        return YES;
    }
    return NO;
}

- (id)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret {
    self = [super init];
    if (self) {
        DBSession* dbSession = [[DBSession alloc] initWithAppKey:appKey
                                                       appSecret:appSecret
                                                            root:kDBRootAppFolder];
        [DBSession setSharedSession:dbSession];
        dbClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        dbClient.delegate = self;
        srand(time(NULL));
    }
    return self;
}

- (UIView *)detailForViewController:(UIViewController *)viewController
                      withImageView:(UIImageView *)imageView
                         withIssues:(AGImageCheckerIssue)issues {
    AGImageCheckerDropboxView *detailView = [[AGImageCheckerDropboxView alloc] initWithImageView:imageView
                                                                                       andIssues:issues
                                                                                        andWidth:viewController.view.frame.size.width];
    detailView.uploadHandler = ^(UIImageView *imageView) {
        [self uploadToDropbox:imageView];
    };
    self.detailController = viewController;
    return detailView;
}


#pragma mark DropBox Sync

- (void)uploadToDropbox:(UIImageView *)imageView {
    
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:detailController];
    }
    else {
        NSString *filename = imageView.accessibilityLabel;
        if ([filename length] <= 0) {
            filename = imageView.image.name;
        }
        if (filename) {
            UIImageView *renderedImageView = [[UIImageView alloc] initWithFrame:imageView.bounds];
            renderedImageView.image = imageView.image;
            renderedImageView.contentMode = imageView.contentMode;
            renderedImageView.clipsToBounds = YES;

            UIImage *image = [self imageWithView:renderedImageView];
            NSString *tempImagePath = [self saveImageIntoTemporaryLocation:image];            
            NSString *destDir = @"/";
            [dbClient uploadFile:filename toPath:destDir
                   withParentRev:nil fromPath:tempImagePath];
        }
    }
}


- (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (NSString *)saveImageIntoTemporaryLocation:(UIImage *)image {
    NSString *randomPath = [NSString stringWithFormat:@"%@%d.png", NSTemporaryDirectory(), rand()];
    NSData *binaryImageData = UIImagePNGRepresentation(image);
    [binaryImageData writeToFile:randomPath atomically:YES];
    return randomPath;
}


@end
