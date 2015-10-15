//
//  ViewController.m
//  ZXingTest
//
//  Created by justin on 2015/10/14.
//  Copyright © 2015年 justin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) ZXCapture *capture;
@property (nonatomic, weak) IBOutlet UIView *topContainerView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *scanAreaView;
@property (nonatomic, weak) IBOutlet UIView *botomContainerView;
@property (nonatomic, assign) BOOL alreadyShowAlertView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControler;
@property (nonatomic, weak) IBOutlet UIButton *bottomBtn;
@property (nonatomic, strong) UIImageView *codeImageView;

@end

@implementation ViewController

- (void)dealloc {
    [self.capture.layer removeFromSuperlayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.capture = [[ZXCapture alloc] init];
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.rotation = 90.0f;
    self.capture.layer.frame = CGRectMake(0.0f, 20.0f, self.view.bounds.size.width, self.view.bounds.size.height - 20.0f);

    self.codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 280.0f, 280.0f)];
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *result = [writer encode:@"7533967"
                                  format:kBarcodeFormatQRCode
                                   width:self.view.bounds.size.width
                                  height:self.view.bounds.size.width
                                   error:nil];
    ZXImage *image = [ZXImage imageWithMatrix:result];
    self.codeImageView.image = [UIImage imageWithCGImage:image.cgimage];

    [self.view.layer addSublayer:self.capture.layer];
    [self.view bringSubviewToFront:self.topContainerView];
    [self.view bringSubviewToFront:self.titleLabel];
    [self.view bringSubviewToFront:self.scanAreaView];
    [self.view bringSubviewToFront:self.botomContainerView];

    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:14.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self.segmentedControler addTarget:self action:@selector(chooseWhichSegment:) forControlEvents:UIControlEventValueChanged];
    [[self.bottomBtn layer] setBorderWidth:1.0f];
    [self chooseWhichSegment:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.capture.delegate = self;
    self.capture.layer.frame = CGRectMake(0.0f, 20.0f, self.view.bounds.size.width, self.view.bounds.size.height - 20.0f);

    self.capture.scanRect = CGRectMake(0.0f, 100.0f, self.view.bounds.size.width, self.view.bounds.size.height - 100.0f);
    self.alreadyShowAlertView = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.capture stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - Private Methods

- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
    switch (format) {
        case kBarcodeFormatAztec:
            return @"Aztec";

        case kBarcodeFormatCodabar:
            return @"CODABAR";

        case kBarcodeFormatCode39:
            return @"Code 39";

        case kBarcodeFormatCode93:
            return @"Code 93";

        case kBarcodeFormatCode128:
            return @"Code 128";

        case kBarcodeFormatDataMatrix:
            return @"Data Matrix";

        case kBarcodeFormatEan8:
            return @"EAN-8";

        case kBarcodeFormatEan13:
            return @"EAN-13";

        case kBarcodeFormatITF:
            return @"ITF";

        case kBarcodeFormatPDF417:
            return @"PDF417";

        case kBarcodeFormatQRCode:
            return @"QR Code";

        case kBarcodeFormatRSS14:
            return @"RSS 14";

        case kBarcodeFormatRSSExpanded:
            return @"RSS Expanded";
            
        case kBarcodeFormatUPCA:
            return @"UPCA";
            
        case kBarcodeFormatUPCE:
            return @"UPCE";
            
        case kBarcodeFormatUPCEANExtension:
            return @"UPC/EAN extension";
            
        default:
            return @"Unknown";
    }
}

- (void)chooseWhichSegment:(id)sender {
    if ([sender selectedSegmentIndex] == 0) {
        [self.codeImageView removeFromSuperview];
        [self.capture start];

        self.titleLabel.backgroundColor = [UIColor blackColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = @"Scan their QR code to add them as partners";
        self.scanAreaView.backgroundColor = [UIColor clearColor];
        self.botomContainerView.backgroundColor = [UIColor blackColor];
        self.bottomBtn.backgroundColor = [UIColor blackColor];
        [self.bottomBtn setTitle:@"Select from Photos" forState:UIControlStateNormal];
        [self.bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[self.bottomBtn layer] setBorderColor:[UIColor whiteColor].CGColor];
    } else {
        [self.capture stop];

        [self.scanAreaView addSubview:self.codeImageView];

        self.titleLabel.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.text = @"Show your QR code to others and they can become your partner";
        self.scanAreaView.backgroundColor = [UIColor whiteColor];
        self.botomContainerView.backgroundColor = [UIColor whiteColor];
        self.bottomBtn.backgroundColor = [UIColor colorWithRed:249.0f / 255.0f green:247.0f / 255.0f blue:247.0f / 255.0f alpha:1.0f];
        [self.bottomBtn setTitle:@"Share Your QR Code" forState:UIControlStateNormal];
        [self.bottomBtn setTitleColor:[UIColor colorWithRed:68.0f / 255.0f green:115.0f / 255.0f blue:113.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
        [[self.bottomBtn layer] setBorderColor:[UIColor colorWithRed:68.0f / 255.0f green:115.0f / 255.0f blue:113.0f / 255.0f alpha:1.0f].CGColor];
    }
}

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (!result || self.alreadyShowAlertView) {
        return;
    } else {
        [self.capture stop];
        NSLog(@"result from format:%@", [self barcodeFormatToString:result.barcodeFormat]);

        // Vibrate
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

        // We got a result. Display information about the result onscreen.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:result.text delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
        self.alreadyShowAlertView = YES;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.capture start];
        self.alreadyShowAlertView = NO;
    });
}

@end
