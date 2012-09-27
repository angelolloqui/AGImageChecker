//
//  AGDropboxPluginTests.m
//  AGImageChecker
//
//  Created by Angel Garcia on 9/26/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGDropboxPluginTests.h"
#import "UIImageView+AGImageCheckerDropbox.h"
#import "UIImage+AGImageChecker.h"

#import <DropboxSDK/DropboxSDK.h>


@interface AGImageCheckerDropboxPlugin(private)<DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *dbClient;

- (void)uploadToDropbox:(UIImageView *)imageView original:(BOOL)original;
- (void)downloadFromDropbox:(UIImageView *)imageView;
- (void)removeFromLocalStorage:(UIImageView *)imageView;
- (void)loginToDropbox;
- (void)logoutFromDropbox;
- (NSString *)saveImageIntoTemporaryLocation:(UIImage *)image;

@end


@implementation AGDropboxPluginTests
@synthesize mockImageChecker;
@synthesize mockDBSession;
@synthesize mockDBClient;
@synthesize plugin;
@synthesize mockDBPlugin;
@synthesize imageView;
@synthesize mockImageView;
@synthesize bundle;

static AGImageChecker *originalInstance = nil;

- (void)setUp {
    
    originalInstance = [AGImageChecker sharedInstance];
    self.mockImageChecker = [OCMockObject niceMockForClass:[AGImageChecker class]];
    [AGImageChecker setSharedInstance:mockImageChecker];
    
    self.mockDBSession = [OCMockObject niceMockForClass:[DBSession class]];
    [DBSession setSharedSession:mockDBSession];
    
    self.plugin = [[AGImageCheckerDropboxPlugin alloc] init];
    self.mockDBPlugin = [OCMockObject partialMockForObject:plugin];
    self.mockDBClient = [OCMockObject niceMockForClass:[DBRestClient class]];
    plugin.dbClient = mockDBClient;

    self.bundle = [NSBundle bundleForClass:[self class]];
    self.imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"square_small_image" ofType:@"png"]];
    [(id) imageView.image setName:@"imageName"];
    
    self.mockImageView = [OCMockObject partialMockForObject:imageView];
}

- (void)tearDown {
   [AGImageChecker setSharedInstance:originalInstance];
}


- (void)testDropboxIsAddedToImageCheckerPlugins {
    [[mockImageChecker expect] addPlugin:[OCMArg checkWithBlock:^(id arg) {
        return [arg isKindOfClass:[AGImageCheckerDropboxPlugin class]];
    }]];
    [AGImageCheckerDropboxPlugin addPluginWithAppKey:@"key" appSecret:@"secret"];
    [mockImageChecker verify];
}

- (void)testDelegateHandlesDropboxURL {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *dropboxUrl = [NSURL URLWithString:@""];
    
    STAssertNotNil([application delegate], @"Application deledate should not be null");
    [AGImageCheckerDropboxPlugin addPluginWithAppKey:@"key" appSecret:@"secret"];
    [DBSession setSharedSession:mockDBSession];
    [[mockDBSession expect] handleOpenURL:dropboxUrl];
    [[application delegate] application:application openURL:dropboxUrl sourceApplication:nil annotation:nil];
    [mockDBSession verify];
}

- (void)testImageViewAddDropboxMethods {
    
    STAssertTrue([imageView respondsToSelector:@selector(originalImage)], @"ImageView should respond to originalImage method");
    STAssertTrue([imageView respondsToSelector:@selector(dropboxImagePath)], @"ImageView should respond to dropboxImagePath method");
    STAssertTrue([imageView respondsToSelector:@selector(localDropboxImagePath)], @"ImageView should respond to localDropboxImagePath method");
    STAssertTrue([imageView respondsToSelector:@selector(localDropboxImageExists)], @"ImageView should respond to localDropboxImageExists method");    
}

- (void)testImageViewSetsOriginalImage {
    STAssertNil(imageView.originalImage, @"Original image should be nil by default");
    UIImage *image = [[UIImage alloc] init];
    imageView.originalImage = image;
    STAssertEquals(imageView.originalImage, image, @"The original image has not been set correctly");
    imageView.originalImage = nil;
    STAssertNil(imageView.originalImage, @"Original image should allow nullifying");
}

- (void)testImageViewReturnsDropboxImagePaths {
    STAssertNotNil([imageView dropboxImagePath], @"Dropbox image path should be set");
    STAssertTrue([[imageView dropboxImagePath] rangeOfString:@"imageName"].location != NSNotFound, @"Dropbox image path should contain the image name");
    
    STAssertNotNil([imageView localDropboxImagePath], @"Local Dropbox image path should be set");
    STAssertTrue([[imageView localDropboxImagePath] rangeOfString:@"imageName"].location != NSNotFound, @"Local Dropbox image path should contain the image name");
}

- (void)testPluginChecksImageIsInLocalDropbox {
    [[mockImageView expect] localDropboxImageExists];
    [plugin didFinishCalculatingIssues:mockImageView];
    [mockImageView verify];
}

- (void)testPluginUsesLocalDropboxImage {
    BOOL ret = YES;
    [[[mockImageView stub] andReturnValue:OCMOCK_VALUE(ret)] localDropboxImageExists];
    [[[mockImageView stub] andReturn:[bundle pathForResource:@"square_small_image" ofType:@"png"]] localDropboxImagePath];
    UIImage *originalImage = [mockImageView image];
    [plugin didFinishCalculatingIssues:mockImageView];
    STAssertNotNil([mockImageView image], @"The local Dropbox image should be loaded correctly");
    STAssertEqualObjects([mockImageView originalImage], originalImage, @"The original image should be saved");
    
    [plugin didFinishCalculatingIssues:mockImageView];
    STAssertNotNil([mockImageView image], @"The local Dropbox image should be loaded correctly");
    STAssertEqualObjects([mockImageView originalImage], originalImage, @"The original image should be preserved in next requests");    
}

- (void)testPluginRemovesLocalDropboxImage {
    BOOL ret = NO;
    [[[mockImageView stub] andReturnValue:OCMOCK_VALUE(ret)] localDropboxImageExists];
    UIImage *originalImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"square_small_image" ofType:@"png"]];
    [mockImageView setOriginalImage:originalImage];
    
    [plugin didFinishCalculatingIssues:mockImageView];
    STAssertNotNil([mockImageView image], @"The image should be set correctly");
    STAssertNil([mockImageView originalImage], @"The original image should be removed");
    STAssertEqualObjects([mockImageView image], originalImage, @"The original image should be reset to the main image");
}

- (void)testUploadToDropboxIsCalled {
    [[mockDBClient expect] uploadFile:[OCMArg any] toPath:[OCMArg any] withParentRev:nil fromPath:[OCMArg any]];
    [plugin uploadToDropbox:imageView original:YES];
    [mockDBClient verify];
}

- (void)testDownloadFromDropboxIsCalled {
    [[mockDBClient expect] loadFile:[OCMArg any] intoPath:[OCMArg any]];
    [plugin downloadFromDropbox:imageView];
    [mockDBClient verify];
}

- (void)testLinkToDropboxIsCalled {
    BOOL linked = NO;
    [[[mockDBSession stub] andReturnValue:OCMOCK_VALUE(linked)] isLinked];
    [[mockDBSession expect] linkFromController:[OCMArg any]];
    [plugin loginToDropbox];
    [mockDBSession verify];
}

- (void)testUnLinkToDropboxIsCalled {
    [[mockDBSession expect] unlinkAll];
    [plugin logoutFromDropbox];
    [mockDBSession verify];
}

- (void)testRemoveLocalStorageCallsRefresh{
    [[mockDBPlugin expect] didFinishCalculatingIssues:[OCMArg any]];
    [mockDBPlugin removeFromLocalStorage:imageView];
    [mockDBPlugin verify];
}

- (void)testPluginRespondsToMainDelegateMethods {
    STAssertNoThrow([plugin restClient:mockDBClient loadedFile:@"file"], @"Plugin should respond to restClient:loadedFile:");
    STAssertNoThrow([plugin restClient:mockDBClient loadFileFailedWithError:nil], @"Plugin should respond to restClient:loadFileFailedWithError");
    STAssertNoThrow([plugin restClient:mockDBClient uploadedFile:@"file" from:@"from" metadata:nil], @"Plugin should respond to restClient:uploadedFile:from:metadata:");
    STAssertNoThrow([plugin restClient:mockDBClient uploadFileFailedWithError:nil], @"Plugin should respond to restClient:uploadFileFailedWithError:");
}

- (void)testDownloadDelegateCallsRefresh{
    [[mockDBPlugin expect] didFinishCalculatingIssues:[OCMArg any]];
    [mockDBPlugin restClient:mockDBClient loadedFile:@"file"];
    [mockDBPlugin verify];
}

- (void)testImageToUploadIsCorrectlyChoosen {
    __block UIImage *savedImage = nil;
    [[[mockDBPlugin stub] andDo:^(NSInvocation *inv) {
        __unsafe_unretained UIImage *image = nil;
        [inv getArgument:&image atIndex:2];
        savedImage = image;
    }] saveImageIntoTemporaryLocation:[OCMArg any]];
    
    [mockDBPlugin uploadToDropbox:imageView original:YES];
    
    STAssertEqualObjects(savedImage, imageView.image, @"The saved image should be the original image");
    
    savedImage = nil;
    [mockDBPlugin uploadToDropbox:imageView original:NO];
    STAssertFalse(savedImage == imageView.image, @"The saved image should be a new one with the rendered image");
    
}

@end
