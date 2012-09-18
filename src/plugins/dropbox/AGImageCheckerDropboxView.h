//
//  AGImageCheckerDropboxView.h
//  AGImageChecker
//
//  Created by Angel Garcia on 9/17/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AGImageChecker.h"


@interface AGImageCheckerDropboxView : UIView

@property (nonatomic, copy) AGImageViewHandler uploadHandler;
@property (nonatomic, copy) AGImageViewHandler downloadHandler;
@property (nonatomic, copy) AGImageViewHandler removeHandler;
@property (readonly, strong) UIButton *uploadButton;
@property (readonly, strong) UIButton *downloadButton;
@property (readonly, strong) UIButton *removeButton;

- (id)initWithImageView:(UIImageView *)targetImageView andIssues:(AGImageCheckerIssue)targetIssues andWidth:(CGFloat)width;

@end
