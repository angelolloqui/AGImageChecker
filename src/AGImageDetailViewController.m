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

@property (assign) NSInteger posY;
@end

@implementation AGImageDetailViewController
@synthesize contentScrollView;
@synthesize targetImageView;
@synthesize imageViewPositionLabel;
@synthesize imageViewSizeLabel;
@synthesize imageSizeLabel;
@synthesize imageRetinaLabel;
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
    
    self.imageViewSizeLabel = [self addLabelWithTitle:@"View position:" andText:NSStringFromCGPoint(targetImageView.frame.origin)];
    self.imageViewSizeLabel = [self addLabelWithTitle:@"View size:" andText:NSStringFromCGSize(targetImageView.frame.size)];
    self.imageSizeLabel = [self addLabelWithTitle:@"Image size:" andText:NSStringFromCGSize(targetImageView.image.size)];
    self.imageRetinaLabel = [self addLabelWithTitle:@"Using retina:" andText:(targetImageView.image.scale > 1)? @"YES" : @"NO"];
    self.contentModeLabel = [self addLabelWithTitle:@"Content Mode:" andText:[self contentModeToString:targetImageView.contentMode]];
    self.issuesLabel = [self addLabelWithTitle:@"Issues:" andText:[[self descriptionsForIssues:targetImageView.issues] componentsJoinedByString:@",\n"]];
    self.imageNameLabel = [self addLabelWithTitle:@"Image name:" andText:targetImageView.accessibilityLabel];
    self.controllerNameLabel = [self addLabelWithTitle:@"Controller:" andText:NSStringFromClass([[self controllerForView:targetImageView] class])];    
    self.orginalImageView = [self addImageViewWithTitle:@"Original" andImage:targetImageView.image andSize:targetImageView.image.size];
    self.renderedImageView = [self addImageViewWithTitle:@"Rendered" andImage:targetImageView.image andSize:targetImageView.frame.size];
    self.renderedImageView.contentMode = targetImageView.contentMode;
    self.renderedImageView.issues = AGImageCheckerIssueNone;    

    self.contentScrollView.contentSize = CGSizeMake(MAX(renderedImageView.frame.size.width, orginalImageView.frame.size.width) + padding * 2, posY + padding);
}

- (void)dismissView {
    [self dismissModalViewControllerAnimated:YES];
}

- (UILabel *)addLabelWithTitle:(NSString *)title andText:(NSString *)text {  
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


- (UIImageView *)addImageViewWithTitle:(NSString *)title andImage:(UIImage *)image andSize:(CGSize)size{  
    [self addLabelWithTitle:title andText:@""];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, posY, size.width, size.height)];
    imageView.image = image;
    imageView.clipsToBounds = YES;
    UIView *backView = [[UIView alloc] initWithFrame:imageView.frame];
    backView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AGTileBackground"]];
    [self.contentScrollView addSubview:backView];
    [self.contentScrollView addSubview:imageView];
    posY += size.height + (int)(padding / 2);
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
