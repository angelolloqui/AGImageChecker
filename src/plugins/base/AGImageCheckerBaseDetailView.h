//
//  AGImageCheckerBaseDetailView.h
//  AGImageChecker
//
//  Created by Angel Garcia on 9/17/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AGImageChecker.h"

@interface AGImageCheckerBaseDetailView : UIView

@property (readonly, strong) UILabel *imageViewPositionLabel;
@property (readonly, strong) UILabel *imageViewSizeLabel;
@property (readonly, strong) UILabel *imageSizeLabel;
@property (readonly, strong) UILabel *imageRetinaLabel;
@property (readonly, strong) UILabel *contentModeLabel;
@property (readonly, strong) UILabel *issuesLabel;
@property (readonly, strong) UILabel *imageNameLabel;
@property (readonly, strong) UILabel *controllerNameLabel;
@property (readonly, strong) UIImageView *orginalImageView;
@property (readonly, strong) UIImageView *renderedImageView;

- (id)initWithImageView:(UIImageView *)targetImageView andIssues:(AGImageCheckerIssue)targetIssues andWidth:(CGFloat)width;

@end
