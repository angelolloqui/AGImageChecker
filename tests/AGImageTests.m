//
//  AGImageTests.m
//  AGImageChecker
//
//  Created by Angel on 9/12/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageTests.h"
#import "UIImage+AGImageChecker.h"

static NSString *kImageName = @"square_small_image";
static NSString *kIncorrectName = @"incorrect_image";
static NSString *kIncorrectPath = @"path_to/incorrect_image.png";

@implementation AGImageTests
@synthesize bundle;
@synthesize image;
@synthesize emptyImage;
@synthesize incorrectNamedImage;
@synthesize incorrectPathImage;
@synthesize resizableImage;

- (void)setUp {
    [UIImage startSavingNames];
    self.bundle = [NSBundle bundleForClass:[self class]];
    self.image = [UIImage imageWithContentsOfFile:[bundle pathForResource:kImageName ofType:@"png"]];
    self.emptyImage = [[UIImage alloc] init];
    self.incorrectNamedImage = [UIImage imageNamed:kIncorrectName];
    self.incorrectPathImage = [UIImage imageWithContentsOfFile:kIncorrectPath];
    self.resizableImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
}

-(void)tearDown{
    [UIImage stopSavingNames];
}

- (void)testImagesAreCorrectlyLoaded {
    STAssertNotNil(self.image, @"Image loaded with correct name should exists");
    STAssertNotNil(self.incorrectNamedImage, @"Image loaded with incorrect name should exists but empty");
    STAssertNotNil(self.incorrectPathImage, @"Image loaded with incorrect path should exists but empty");
    STAssertNotNil(self.resizableImage, @"Image loaded with incorrect path should exists but empty");
    
    STAssertTrue([self.image isKindOfClass:[UIImage class]], @"Returned image should be of kind UIImage");
    STAssertTrue([self.incorrectNamedImage isKindOfClass:[UIImage class]], @"Returned empty image should be of kind UIImage");
    STAssertTrue([self.incorrectPathImage isKindOfClass:[UIImage class]], @"Returned empty image should be of kind UIImage");
    STAssertTrue([self.resizableImage isKindOfClass:[UIImage class]], @"Returned resizable image should be of kind UIImage");
}

- (void)testCorrectImageIsNotEmpty {
    STAssertFalse([self.image isEmptyImage], @"Image should not be empty");
    STAssertFalse([self.resizableImage isEmptyImage], @"Resizable image should not be empty");
}

- (void)testIncorrectLoadingReturnEmptyImages {
    STAssertTrue([self.incorrectNamedImage isEmptyImage], @"Returned incorrect image by name should be empty");
    STAssertTrue([self.incorrectPathImage isEmptyImage], @"Returned incorrect image by path should be empty");
}

- (void)testImageStoreCorrectNames {
    STAssertNotNil(self.image.name, @"Image should have a name");
    STAssertNotNil(self.incorrectNamedImage.name, @"Image should have a name");
    STAssertNotNil(self.incorrectPathImage.name, @"Image should have a name");
    STAssertNotNil(self.resizableImage.name, @"Image should have a name");
    
    STAssertTrue([self.image.name rangeOfString:kImageName].location != NSNotFound, @"Image does not have the proper name");
    STAssertTrue([self.incorrectNamedImage.name rangeOfString:kIncorrectName].location != NSNotFound, @"Image does not have the proper name");
    STAssertTrue([self.incorrectPathImage.name rangeOfString:kIncorrectName].location != NSNotFound, @"Image does not have the proper name");
    STAssertTrue([self.resizableImage.name rangeOfString:kImageName].location != NSNotFound, @"Resizable Image does not have the proper name");
}



@end
