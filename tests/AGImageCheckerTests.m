//
//  AGImageCheckerTests.m
//  AGImageChecker
//
//  Created by Angel on 9/4/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageCheckerTests.h"
#import "AGImageChecker.h"

@implementation AGImageCheckerTests

- (void)setUp {
    [UIApplication resetApplication];
}

- (void)testImageCheckerIsInstanciated {
    STAssertNotNil([AGImageChecker sharedInstance], @"Can not instanciate the AGImageChecker");
}

- (void)testImageCheckerIsSingleton {
    STAssertEquals([AGImageChecker sharedInstance], [AGImageChecker sharedInstance], @"Can not instanciate the AGImageChecker");
}

- (void)testImageCheckerCanStartMonitoring {
    STAssertNoThrow([[AGImageChecker sharedInstance] start], @"Can not instanciate the AGImageChecker");
}

- (void)testImageCheckerCanStopMonitoring {
    STAssertNoThrow([[AGImageChecker sharedInstance] stop], @"Can not instanciate the AGImageChecker");
}

- (void)testImageCheckerCorrectlySetGesturesInWindow {    
    id keyWindow = (id)[[UIApplication sharedApplication] keyWindow];
    
    [[keyWindow expect] addGestureRecognizer:[OCMArg any]];
    [[AGImageChecker sharedInstance] start];
    [keyWindow verify];
    
    [[keyWindow expect] removeGestureRecognizer:[OCMArg any]];
    [[AGImageChecker sharedInstance] stop];    
    [keyWindow verify];    
}


@end
