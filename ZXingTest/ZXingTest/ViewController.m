//
//  ViewController.m
//  ZXingTest
//
//  Created by justin on 2015/10/14.
//  Copyright © 2015年 justin. All rights reserved.
//

#import "ViewController.h"

@interface UIPasteboard(Line)

+ (UIPasteboard *)generatePasteLineBoard;

@end

@implementation UIPasteboard(Line)

+ (UIPasteboard *)generatePasteLineBoard
{
    UIPasteboard *pasteboard;
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 7.0) {
        pasteboard = [UIPasteboard pasteboardWithName:@"jp.naver.linecamera.pasteboard" create:YES];
    } else {
        pasteboard = [UIPasteboard generalPasteboard];
    }
    return pasteboard;
}

@end

@interface ViewController ()
<UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) ZXCapture *capture;
@property (nonatomic, weak) IBOutlet UIView *topContainerView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *scanAreaView;
@property (nonatomic, weak) IBOutlet UIView *botomContainerView;
@property (nonatomic, assign) BOOL alreadyShowAlertView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControler;
@property (nonatomic, weak) IBOutlet UIButton *bottomBtn;
@property (nonatomic, strong) UIImageView *codeImageView;
@property (nonatomic, strong) ZXImage *zxImage;
@property (nonatomic, weak) IBOutlet UIButton *addLogoBtn;

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


    self.codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 35, 280.0f, 280.0f)];
    ZXMultiFormatWriter *writer = [[ZXMultiFormatWriter alloc] init];
    ZXBitMatrix *result = [writer encode:@"7533967"
                                  format:kBarcodeFormatQRCode
                                   width:self.view.bounds.size.width
                                  height:self.view.bounds.size.width
                                   error:nil];

    self.zxImage = [ZXImage imageWithMatrix:result];
    self.codeImageView.image = [UIImage imageWithCGImage:self.zxImage.cgimage];

    [self.view.layer addSublayer:self.capture.layer];
    [self.view bringSubviewToFront:self.topContainerView];
    [self.view bringSubviewToFront:self.titleLabel];
    [self.view bringSubviewToFront:self.scanAreaView];
    [self.view bringSubviewToFront:self.botomContainerView];

    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:14.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self.segmentedControler addTarget:self action:@selector(chooseWhichSegment:) forControlEvents:UIControlEventValueChanged];
    [[self.bottomBtn layer] setBorderWidth:1.0f];
    [self chooseWhichSegment:0];

    [self.addLogoBtn addTarget:self action:@selector(addLogoTOQrCode:) forControlEvents:UIControlEventTouchUpInside];
    self.addLogoBtn.layer.borderWidth = 1.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.capture.delegate = self;
    self.capture.layer.frame = CGRectMake(0.0f, 20.0f, self.view.bounds.size.width, self.view.bounds.size.height - 20.0f);

    self.capture.scanRect = CGRectMake(0.0f, 20.0f, self.view.bounds.size.width, self.view.bounds.size.height - 20.0f);
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
        [self.bottomBtn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.bottomBtn addTarget:self action:@selector(selectFromPhotos) forControlEvents:UIControlEventTouchUpInside];
        [[self.bottomBtn layer] setBorderColor:[UIColor whiteColor].CGColor];
        self.addLogoBtn.hidden = YES;
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
        [self.bottomBtn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.bottomBtn addTarget:self action:@selector(shareYourQRCode) forControlEvents:UIControlEventTouchUpInside];
        [[self.bottomBtn layer] setBorderColor:[UIColor colorWithRed:68.0f / 255.0f green:115.0f / 255.0f blue:113.0f / 255.0f alpha:1.0f].CGColor];
        self.addLogoBtn.hidden = NO;
        self.codeImageView.image = [UIImage imageWithCGImage:self.zxImage.cgimage];
        [self.codeImageView setNeedsDisplay];
    }
}

- (IBAction)addLogoTOQrCode:(id)sender {
    //Combind image
    UIImage *bottomImage = [UIImage imageWithCGImage:self.zxImage.cgimage]; //background image
    UIImage *logoImage    = [UIImage imageNamed:@"logo"]; //foreground image

    CGSize newSize = CGSizeMake(280.0f, 280.0f);
    UIGraphicsBeginImageContext( newSize );

    // Use existing opacity as is
    [bottomImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];

    // Apply supplied opacity if applicable
    [logoImage drawInRect:CGRectMake(self.view.bounds.size.width / 2 - 48.0f, self.scanAreaView.bounds.origin.y + (self.scanAreaView.bounds.size.height / 2 - 30.0f) , 48.0f, 60.0f) blendMode:kCGBlendModeNormal alpha:0.8];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    self.codeImageView.image = newImage;
    [self.codeImageView setNeedsDisplay];
}

- (void)shareYourQRCode {
    [self shareLineWithImage:self.codeImageView.image];
}

- (void)selectFromPhotos {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)shareLineWithImage:(UIImage *)image {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]]) {
        UIPasteboard *pasteboard = [UIPasteboard generatePasteLineBoard];
        [pasteboard setData:UIImageJPEGRepresentation(image, 1.0f) forPasteboardType:@"public.jpeg"];

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"line://msg/image/%@", pasteboard.name]]];
    } else {
        NSURL *itunesURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id443904275"];
        [[UIApplication sharedApplication] openURL:itunesURL];
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
    [self.capture start];
    self.alreadyShowAlertView = NO;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self shareLineWithImage:img];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
