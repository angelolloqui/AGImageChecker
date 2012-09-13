//
//  AGImageTests.h
//  AGImageChecker
//
//  Created by Angel on 9/12/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface AGImageTests : SenTestCase
@property(strong) NSBundle *bundle;
@property(strong) UIImage *image;
@property(strong) UIImage *emptyImage;
@property(strong) UIImage *incorrectNamedImage;
@property(strong) UIImage *incorrectPathImage;
@property(strong) UIImage *resizableImage;

@end
