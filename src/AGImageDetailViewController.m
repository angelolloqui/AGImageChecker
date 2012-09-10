//
//  AGImageDetailViewController.m
//  AGImageChecker
//
//  Created by Angel on 9/7/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageDetailViewController.h"
#import "UIImageView+AGImageChecker.h"

static NSInteger titleWidth = 120;
static NSInteger padding = 10;

@interface AGImageDetailViewController ()

@property (readwrite, strong) UIScrollView *contentScrollView;
@property (readwrite, strong) UIImageView *targetImageView;
@property (readwrite, strong) UILabel *imageViewSizeLabel;
@property (readwrite, strong) UILabel *imageSizeLabel;
@property (readwrite, strong) UILabel *contentModeLabel;
@property (readwrite, strong) UILabel *issuesLabel;
@property (readwrite, strong) UILabel *imageNameLabel;
@property (readwrite, strong) UILabel *controllerNameLabel;
@property (readwrite, strong) UIImageView *orginalImageView;
@property (readwrite, strong) UIImageView *renderedImageView;

@property (assign) NSInteger posY;
@end

@implementation AGImageDetailViewController
@synthesize contentScrollView;
@synthesize targetImageView;
@synthesize imageViewSizeLabel;
@synthesize imageSizeLabel;
@synthesize contentModeLabel;
@synthesize issuesLabel;
@synthesize imageNameLabel;
@synthesize controllerNameLabel;
@synthesize posY;
@synthesize orginalImageView;
@synthesize renderedImageView;


#pragma mark Class methods
+ (AGImageDetailViewController *)presentModalForImageView:(UIImageView *)imageView inViewController:(UIViewController *)viewController {
    NSAssert(imageView, @"imageView not set");
    NSAssert(viewController, @"viewController not set");
    
    AGImageDetailViewController *vc = [[self alloc] init];    
    vc.targetImageView = imageView;
    [viewController presentModalViewController:vc animated:YES];
    return vc;    
}

#pragma mark Instance methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [self.view addGestureRecognizer:tapGesture];

    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentScrollView];
    
    self.posY = padding;
    self.imageViewSizeLabel = [self addLabelWithTitle:@"View size:" andText:NSStringFromCGSize(targetImageView.frame.size)];
    self.imageSizeLabel = [self addLabelWithTitle:@"Image size:" andText:NSStringFromCGSize(targetImageView.image.size)];
    self.contentModeLabel = [self addLabelWithTitle:@"Content Mode:" andText:[self contentModeToString:targetImageView.contentMode]];
    self.issuesLabel = [self addLabelWithTitle:@"Issues:" andText:[[self descriptionsForIssues:targetImageView.issues] componentsJoinedByString:@",\n"]];
    self.imageNameLabel = [self addLabelWithTitle:@"Image name:" andText:targetImageView.accessibilityLabel];
    self.controllerNameLabel = [self addLabelWithTitle:@"Controller:" andText:NSStringFromClass([[self controllerForView:targetImageView] class])];
    
    [self addLabelWithTitle:@"Original" andText:@""];
    self.orginalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, posY, targetImageView.image.size.width, targetImageView.image.size.height)];
    self.orginalImageView.image = targetImageView.image;
    self.orginalImageView.issues = AGImageCheckerIssueNone;
    [self.contentScrollView addSubview:orginalImageView];
    posY += orginalImageView.frame.size.height + (int)(padding / 2);

    [self addLabelWithTitle:@"Rendered" andText:@""];
    self.renderedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, posY, targetImageView.frame.size.width, targetImageView.frame.size.height)];
    self.renderedImageView.image = targetImageView.image;
    self.renderedImageView.contentMode = targetImageView.contentMode;
    self.renderedImageView.clipsToBounds = YES;
    self.renderedImageView.issues = AGImageCheckerIssueNone;    
    [self.contentScrollView addSubview:renderedImageView];
    posY += renderedImageView.frame.size.height + (int)(padding / 2);

    self.contentScrollView.contentSize = CGSizeMake(MAX(renderedImageView.frame.size.width, orginalImageView.frame.size.width) + padding * 2, posY + padding);
}

- (void) dismissView {
    [self dismissModalViewControllerAnimated:YES];
}

- (UILabel *) addLabelWithTitle:(NSString *)title andText:(NSString *)text {  
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, posY, titleWidth, 22)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    [self.contentScrollView addSubview:titleLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(titleWidth + padding * 2, posY, self.view.frame.size.width - titleWidth - padding * 2, 9999)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;    
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.text = text;
    [label sizeToFit];
    [self.contentScrollView addSubview:label];    
    
    posY += MAX(22, label.frame.size.height) + (int) (padding / 2);

    return label;
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
