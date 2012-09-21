//
//  AGImageCheckerBaseDetailView.m
//  AGImageChecker
//
//  Created by Angel Garcia on 9/17/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageCheckerBaseDetailView.h"
#import "UIImageView+AGImageChecker.h"
#import "UIImage+AGImageChecker.h"

static NSInteger titleWidth = 120;
static NSInteger padding = 10;

@interface AGImageCheckerBaseDetailView()

@property (readwrite, strong) UILabel *imageViewPositionLabel;
@property (readwrite, strong) UILabel *imageViewSizeLabel;
@property (readwrite, strong) UILabel *imageSizeLabel;
@property (readwrite, strong) UILabel *imageRetinaLabel;
@property (readwrite, strong) UILabel *contentModeLabel;
@property (readwrite, strong) UILabel *issuesLabel;
@property (readwrite, strong) UILabel *imageNameLabel;
@property (readwrite, strong) UILabel *controllerNameLabel;
@property (readwrite, strong) UIImageView *orginalImageView;
@property (readwrite, strong) UIImageView *renderedImageView;
@property (assign) CGPoint maxPoint;
@end

@implementation AGImageCheckerBaseDetailView
@synthesize imageViewPositionLabel;
@synthesize imageViewSizeLabel;
@synthesize imageSizeLabel;
@synthesize imageRetinaLabel;
@synthesize contentModeLabel;
@synthesize issuesLabel;
@synthesize imageNameLabel;
@synthesize controllerNameLabel;
@synthesize maxPoint;
@synthesize orginalImageView;
@synthesize renderedImageView;


- (id)initWithImageView:(UIImageView *)targetImageView andIssues:(AGImageCheckerIssue)targetIssues andWidth:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    
    if (self) {
        self.maxPoint = CGPointMake(padding, padding);
        NSString *imageName = targetImageView.accessibilityLabel;
        if ([imageName length] <= 0) {
            imageName = targetImageView.image.name;
        }
        
        self.imageViewSizeLabel = [self addLabelWithTitle:@"View position:" andText:NSStringFromCGPoint(targetImageView.frame.origin)];
        self.imageViewSizeLabel = [self addLabelWithTitle:@"View size:" andText:NSStringFromCGSize(targetImageView.frame.size)];
        self.imageSizeLabel = [self addLabelWithTitle:@"Image size:" andText:NSStringFromCGSize(targetImageView.image.size)];
        self.imageRetinaLabel = [self addLabelWithTitle:@"Using retina:" andText:(targetImageView.image.scale > 1)? @"YES" : @"NO"];
        self.contentModeLabel = [self addLabelWithTitle:@"Content Mode:" andText:[self contentModeToString:targetImageView.contentMode]];
        self.issuesLabel = [self addLabelWithTitle:@"Issues:" andText:[[self descriptionsForIssues:targetIssues] componentsJoinedByString:@",\n"]];
        self.imageNameLabel = [self addLabelWithTitle:@"Image name:" andText:imageName];
        self.controllerNameLabel = [self addLabelWithTitle:@"Controller:" andText:NSStringFromClass([[self controllerForView:targetImageView] class])];
        self.orginalImageView = [self addImageViewWithTitle:@"Original" andImage:targetImageView.image andSize:targetImageView.image.size andMode:targetImageView.contentMode];
        self.renderedImageView = [self addImageViewWithTitle:@"Rendered" andImage:targetImageView.image andSize:targetImageView.frame.size andMode:targetImageView.contentMode];
        self.renderedImageView.contentMode = targetImageView.contentMode;
        
        self.frame = CGRectMake(0, 0, maxPoint.x, maxPoint.y + padding);
    }
    
    return self;
}

- (UILabel *)addLabelWithTitle:(NSString *)title andText:(NSString *)text {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, maxPoint.y, titleWidth, 22)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    [self addSubview:titleLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(titleWidth + padding * 2, maxPoint.y, self.frame.size.width - titleWidth - padding * 3, 9999)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.text = text;
    [label sizeToFit];
    [self addSubview:label];
    
    maxPoint.y += MAX(22, label.frame.size.height) + (int) (padding / 2);
    maxPoint.x = MAX(maxPoint.x, CGRectGetMaxX(label.frame) + padding);
    return label;
}


- (UIImageView *)addImageViewWithTitle:(NSString *)title andImage:(UIImage *)image andSize:(CGSize)size andMode:(UIViewContentMode)mode {
    [self addLabelWithTitle:title andText:@""];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, maxPoint.y, size.width, size.height)];
    imageView.image = image;
    imageView.clipsToBounds = YES;
    imageView.contentMode = mode;
    UIView *backView = [[UIView alloc] initWithFrame:imageView.frame];
    backView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AGTileBackground"]];
    [self addSubview:backView];
    [self addSubview:imageView];
    maxPoint.y += size.height + (int)(padding / 2);
    maxPoint.x = MAX(maxPoint.x, size.width + padding * 2);
    return imageView;
}


- (NSArray *)descriptionsForIssues:(AGImageCheckerIssue)issues {
    NSMutableArray *issuesDescriptions = [[NSMutableArray alloc] initWithCapacity:6];
    
    if (issues == AGImageCheckerIssueNone) {
        [issuesDescriptions addObject:@"None"];
    }
    else {
        if (issues & AGImageCheckerIssueResized) {
            [issuesDescriptions addObject:@"Image resized"];
        }
        if (issues & AGImageCheckerIssueBlurry) {
            [issuesDescriptions addObject:@"Image may be blurry"];
        }
        if (issues & AGImageCheckerIssueStretched) {
            [issuesDescriptions addObject:@"Image is streteched"];
        }
        if (issues & AGImageCheckerIssuePartiallyHidden) {
            [issuesDescriptions addObject:@"Image may be partially hidden"];
        }
        if (issues & AGImageCheckerIssueMissaligned) {
            [issuesDescriptions addObject:@"Image is missaligned"];
        }
        if (issues & AGImageCheckerIssueMissing) {
            [issuesDescriptions addObject:@"Image not found"];
        }
    }
    return issuesDescriptions;
}

- (id)controllerForView:(UIView *)view {
    id responder = view;
    UIView *superview = view.superview;
    while ((responder = [responder nextResponder])) {
        if (responder != superview){
            return responder;
        }
        superview = [responder superview];
    }
    return responder;
}

- (NSString *)contentModeToString:(UIViewContentMode)mode {
    static NSArray *modes = nil;
    static dispatch_once_t modesToken;
    dispatch_once(&modesToken, ^{
        modes = [NSArray arrayWithObjects:
                 @"UIViewContentModeScaleToFill",
                 @"UIViewContentModeScaleAspectFit",
                 @"UIViewContentModeScaleAspectFill",
                 @"UIViewContentModeRedraw",
                 @"UIViewContentModeCenter",
                 @"UIViewContentModeTop",
                 @"UIViewContentModeBottom",
                 @"UIViewContentModeLeft",
                 @"UIViewContentModeRight",
                 @"UIViewContentModeTopLeft",
                 @"UIViewContentModeTopRight",
                 @"UIViewContentModeBottomLeft",
                 @"UIViewContentModeBottomRight", nil];
    });
    
    return [modes objectAtIndex:mode];
}

@end
