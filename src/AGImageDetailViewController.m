//
//  AGImageDetailViewController.m
//  AGImageChecker
//
//  Created by Angel on 9/7/12.
//  Copyright (c) 2012 angelolloqui.com. All rights reserved.
//

#import "AGImageDetailViewController.h"


static NSInteger titleWidth = 120;
static NSInteger lineHeight = 25;

@interface AGImageDetailViewController ()

@property (readwrite, strong) UIImageView *targetImageView;
@property (readwrite, strong) UILabel *imageViewFrameLabel;
@property (readwrite, strong) UILabel *imageSizeLabel;
@property (readwrite, strong) UILabel *issuesLabel;
@property (readwrite, strong) UILabel *imageNameLabel;
@property (assign) NSInteger posY;

@end

@implementation AGImageDetailViewController
@synthesize targetImageView;
@synthesize imageViewFrameLabel;
@synthesize imageSizeLabel;
@synthesize issuesLabel;
@synthesize imageNameLabel;
@synthesize posY;

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

    self.posY = 10;
    self.imageViewFrameLabel = [self addLabelWithTitle:@"View frame:"];
    self.imageSizeLabel = [self addLabelWithTitle:@"Image size:"];
    self.issuesLabel = [self addLabelWithTitle:@"Issues:"];
    self.imageNameLabel = [self addLabelWithTitle:@"Image name:"];
    
    [self configureFromImageData];
}

- (void) dismissView {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)configureFromImageData {
    self.imageViewFrameLabel.text = NSStringFromCGRect(targetImageView.frame);
    self.imageSizeLabel.text = NSStringFromCGSize(targetImageView.image.size);
    self.issuesLabel.text = @"To be implemented";
    self.imageNameLabel.text = @"To be implemented";
}

- (UILabel *) addLabelWithTitle:(NSString *)title {  
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, posY, titleWidth, lineHeight)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    [self.view addSubview:titleLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(titleWidth, posY, self.view.frame.size.width - titleWidth, lineHeight)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    posY += lineHeight;
    return label;
}

@end
