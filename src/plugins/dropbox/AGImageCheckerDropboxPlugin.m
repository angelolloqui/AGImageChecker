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
#import "UIImageView+AGImageCheckerDropbox.h"
#import "AGDBSession.h"
#import "AGImageDetailViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import <QuartzCore/QuartzCore.h>

@interface AGImageCheckerDropboxPlugin () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *dbClient;
@property (nonatomic, assign) AGImageDetailViewController *detailController;
@property (nonatomic, strong) UIImageView *targetImageView;
@end

@implementation AGImageCheckerDropboxPlugin

@synthesize dbClient;
@synthesize detailController;
@synthesize targetImageView;

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
        if (![[DBSession sharedSession] isLinked]) {
            NSLog(@"Problem login with Dropbox!");
        }
        
        [pluginInstance.detailController refreshContentView];
        return YES;
    }
    
    return NO;
}

- (id)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret {
    self = [super init];
    
    if (self) {
        DBSession *dbSession = [[AGDBSession alloc] initWithAppKey:appKey
                                                         appSecret:appSecret
                                                              root:kDBRootAppFolder];
        [DBSession setSharedSession:dbSession];
    }
    
    return self;
}

#pragma mark AGImageCheckerPluginProtocol

- (void)didFinishCalculatingIssues:(UIImageView *)imageView {
//    if (imageView.originalImage && ![imageView.originalImage.name isEqualToString:imageView.image.name]) {
//        imageView.originalImage = nil;
//    }
    
    if ([imageView localDropboxImageExists]) {
        if (imageView.originalImage == nil) {
            UIImage *image = [UIImage imageWithContentsOfFile:[imageView localDropboxImagePath]];
            
            if (image) {
                imageView.originalImage = imageView.image;
                imageView.image = image;
            }
        }
        else {
            imageView.layer.borderWidth = 1;
            
            if (imageView.issues) {
                imageView.layer.borderColor = [UIColor colorWithRed:0.5 green:0 blue:1 alpha:1].CGColor;
            }
            else {
                imageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5].CGColor;
            }
        }
    }
    else {
        if (imageView.originalImage) {
            UIImage *original = imageView.originalImage;
            imageView.originalImage = nil;
            imageView.image = original;
        }
    }
}

- (UIView *)detailForViewController:(AGImageDetailViewController *)viewController
                      withImageView:(UIImageView *)imageView
                         withIssues:(AGImageCheckerIssue)issues {
    AGImageCheckerDropboxView *detailView = [[AGImageCheckerDropboxView alloc] initWithImageView:imageView
                                                                                       andIssues:issues
                                                                                        andWidth:viewController.view.frame.size.width];
    
    detailView.uploadOriginalHandler = ^(UIImageView *imageView) {
        [self uploadToDropbox:imageView original:YES];
    };
    detailView.uploadRenderedHandler = ^(UIImageView *imageView) {
        [self uploadToDropbox:imageView original:NO];
    };
    
    detailView.downloadHandler = ^(UIImageView *imageView) {
        [self downloadFromDropbox:imageView];
    };
    detailView.removeHandler = ^(UIImageView *imageView) {
        [self removeFromLocalStorage:imageView];
    };
    detailView.loginHandler = ^{
        [self loginToDropbox];
    };
    detailView.logoutHandler = ^{
        [self logoutFromDropbox];
    };
    
    [detailView updateStatusWithLogin:[[DBSession sharedSession] isLinked]];
    
    self.targetImageView = imageView;
    self.detailController = viewController;
    return detailView;
}


#pragma mark DropBox Sync

- (void)uploadToDropbox:(UIImageView *)imageView original:(BOOL)original {
    NSString *remotePath = [imageView dropboxImagePath];
    
    if (remotePath) {
        [detailController.indicator startAnimating];
        detailController.view.userInteractionEnabled = NO;
        UIImage *image = nil;
        
        if (original) {
            image = imageView.image;
        }
        else {
            UIImageView *renderedImageView = [[UIImageView alloc] initWithFrame:imageView.bounds];
            renderedImageView.image = imageView.image;
            renderedImageView.contentMode = imageView.contentMode;
            renderedImageView.clipsToBounds = YES;
            image = [self imageWithView:renderedImageView];
        }
        
        NSString *tempImagePath = [self saveImageIntoTemporaryLocation:image];
        NSString *destDir = @"/";
        [self.dbClient uploadFile:remotePath toPath:destDir
                    withParentRev:nil fromPath:tempImagePath];
    }
}

- (void)downloadFromDropbox:(UIImageView *)imageView {
    NSString *remotePath = [imageView dropboxImagePath];
    
    if (remotePath) {
        [detailController.indicator startAnimating];
        detailController.view.userInteractionEnabled = NO;
        remotePath = [NSString stringWithFormat:@"/%@", remotePath];
        NSString *localPath = [imageView localDropboxImagePath];
        NSString *directory = [localPath stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        [self.dbClient loadFile:remotePath intoPath:localPath];
    }
}

- (void)removeFromLocalStorage:(UIImageView *)imageView {
    NSString *localImagePath = [imageView localDropboxImagePath];
    
    [[NSFileManager defaultManager] removeItemAtPath:localImagePath error:nil];
    [self didFinishCalculatingIssues:imageView];
    [detailController refreshContentView];
}

- (void)loginToDropbox {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:detailController];
    }
}

- (void)logoutFromDropbox {
    [[DBSession sharedSession] unlinkAll];
    dbClient.delegate = nil;
    dbClient = nil;
    [detailController refreshContentView];
}

#pragma mark Image Utils

- (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (NSString *)saveImageIntoTemporaryLocation:(UIImage *)image {
    NSString *randomPath = [NSString stringWithFormat:@"%@%d.png", NSTemporaryDirectory(), rand()];
    NSData *binaryImageData = UIImagePNGRepresentation(image);
    
    [binaryImageData writeToFile:randomPath atomically:YES];
    return randomPath;
}

#pragma mark Properties

- (DBRestClient *)dbClient {
    if (!dbClient) {
        dbClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        dbClient.delegate = self;
    }
    
    return dbClient;
}

#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
    [self didFinishCalculatingIssues:targetImageView];
    [detailController refreshContentView];
    [detailController.indicator stopAnimating];
    detailController.view.userInteractionEnabled = YES;
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    [detailController.indicator stopAnimating];
    detailController.view.userInteractionEnabled = YES;
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath
          metadata:(DBMetadata *)metadata {
    [detailController.indicator stopAnimating];
    detailController.view.userInteractionEnabled = YES;
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    [detailController.indicator stopAnimating];
    detailController.view.userInteractionEnabled = YES;
}

@end