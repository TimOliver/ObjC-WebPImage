//
//  ViewController.m
//  WebPImage
//
//  Created by Tim Oliver on 29/12/2021.
//

#import "ViewController.h"
#import "WebPImage.h"

@interface ViewController ()

// Image view to display the WebP image
@property (nonatomic, strong) UIImageView *imageView;

// Container view to add a white background in dark mode
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set appropriate background color
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }

    // Load and display the WebP image
    NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"image" withExtension:@"webp"];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:NSDataReadingMappedIfSafe error:nil];
    UIImage *image = [WebPImage imageWithData:imageData scale:UIScreen.mainScreen.scale error:nil];

    // Create an image view to display the image
    self.imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:self.imageView];

    // In dark mode, add a white background to properly show the image on black
    if (@available(iOS 13.0, *)) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.backgroundView.layer.cornerRadius = 65.0f;
        self.backgroundView.layer.cornerCurve = kCACornerCurveContinuous;
        [self.view insertSubview:self.backgroundView atIndex:0];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // Calculate the size of the image, expand it slightly, and apply to background
    CGRect imageFrame = self.imageView.frame;
    imageFrame.size = [self.imageView sizeThatFits:self.view.frame.size];
    self.backgroundView.frame = CGRectInset(imageFrame, -32, -32);

    // Align the image to fit inside the background
    self.imageView.frame = imageFrame;

    // Position the image and background in the center of the screen
    self.backgroundView.center = self.view.center;
    self.imageView.center = self.view.center;
}

@end
