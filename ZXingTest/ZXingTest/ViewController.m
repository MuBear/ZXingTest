//
//  ViewController.m
//  ZXingTest
//
//  Created by justin on 2015/10/14.
//  Copyright © 2015年 justin. All rights reserved.
//

#import "ViewController.h"
#import "LXActivity.h"
#import <MessageUI/MessageUI.h>
#import "Social/Social.h"

@interface UIPasteboard(Line)

+ (UIPasteboard *)generatePasteLineBoard;

@end

@implementation UIPasteboard(Line)

+ (UIPasteboard *)generatePasteLineBoard {
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
<UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, LXActivityDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate>

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
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, weak) IBOutlet UIView *topScannerView;
@property (nonatomic, weak) IBOutlet UIImageView *scannerImageVIew;
@property (nonatomic, weak) IBOutlet UIView *leadingScannerVIew;
@property (nonatomic, weak) IBOutlet UIView *trailingScannerVIew;
@property (nonatomic, weak) IBOutlet UIView *bottomScannerView;

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

        self.titleLabel.backgroundColor = [UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.8f];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = @"Scan their QR code to add them as partners";
        self.scanAreaView.backgroundColor = [UIColor clearColor];
        self.botomContainerView.backgroundColor = [UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.8f];
        self.bottomBtn.backgroundColor = [UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.8f];
        [self.bottomBtn setTitle:@"Select from Photos" forState:UIControlStateNormal];
        [self.bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.bottomBtn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [self.bottomBtn addTarget:self action:@selector(selectFromPhotos) forControlEvents:UIControlEventTouchUpInside];
        [[self.bottomBtn layer] setBorderColor:[UIColor whiteColor].CGColor];
        self.scannerImageVIew.hidden = NO;
        self.topScannerView.hidden = NO;
        self.leadingScannerVIew.hidden = NO;
        self.trailingScannerVIew.hidden = NO;
        self.bottomScannerView.hidden = NO;
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
        self.scannerImageVIew.hidden = YES;
        self.topScannerView.hidden = YES;
        self.leadingScannerVIew.hidden = YES;
        self.trailingScannerVIew.hidden = YES;
        self.bottomScannerView.hidden = YES;
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
    LXActivity *lxActivity = [[LXActivity alloc] initWithTitle:@"Share this QRcode" delegate:self cancelButtonTitle:@"Cancel" ShareButtonTitles:@[@"Mail", @"Facebook", @"Line", @"Whatsapp"] withShareButtonImagesName:@[@"mailshare_icon", @"fbshare_icon", @"lineshare_icon", @"whatsappshare_icon"]];
    [lxActivity showInView:self.view];
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

- (UIImage *)drawText:(NSString *)text
             inImage:(UIImage *)image
             atPoint:(CGPoint)point {

    NSMutableAttributedString *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", text]];

    // text color
    [textStyle addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, textStyle.length)];

    // text font
    [textStyle addAttribute:NSFontAttributeName  value:[UIFont systemFontOfSize:20.0] range:NSMakeRange(0, textStyle.length)];

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];

    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [textStyle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, textStyle.length)];

    CGSize textSize = [self findHeightForText:text havingWidth:image.size.width - (point.x * 2) andFont:[UIFont systemFontOfSize:20.0]];

    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake((image.size.width - (image.size.height - textSize.height)) / 2 , textSize.height , image.size.height - textSize.height, image.size.height - textSize.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width - (point.x * 2), image.size.height);

    [[UIColor whiteColor] set];

    [textStyle drawInRect:CGRectIntegral(rect)];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    CGSize size = CGSizeZero;

    if (text) {
        //iOS 7
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    return size;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    [self dismissViewControllerAnimated:YES completion:^ {
        CGImageRef imageToDecode = img.CGImage;  // Given a CGImage in which we are looking for barcodes

        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
        ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];

        NSError *error = nil;

        // There are a number of hints we can give to the reader, including
        // possible formats, allowed lengths, and the string encoding.
        ZXDecodeHints *hints = [ZXDecodeHints hints];

        ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
        ZXResult *result = [reader decode:bitmap
                                    hints:hints
                                    error:&error];
        
        if (result) {
            // The coded result as a string. The raw data can be accessed with
            // result.rawBytes and result.length.
            NSString *contents = result.text;

            // The barcode format, such as a QR code or UPC-A
            //        ZXBarcodeFormat format = result.barcodeFormat;

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:contents delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alert show];
        } else {
            // Use error to determine why we didn't get a result, such as a barcode
            // not being found, an invalid checksum, or a format inconsistency.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"not qrcode image" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alert show];
        }
    }];
}

#pragma mark - LXActivityDelegate

- (void)didClickOnImageIndex:(NSInteger *)imageIndex {
    NSString *emailTitle = @"My QR Code";
    NSString *messageBody = @"Hello!  This is my QR Code.  You can scan this with the scan QRCode App";
    NSString *shareUrl = @"https://tw.yahoo.com";

    UIImage *textMixQrcodeImage = [self drawText:messageBody inImage:[UIImage imageWithCGImage:self.zxImage.cgimage] atPoint:CGPointMake(16.0f, 0.0f)];

    if ((int)imageIndex == 0) {
        // Present mail view controller on screen
        if ([MFMailComposeViewController canSendMail]) {
            // Email Subject
            messageBody = [messageBody stringByAppendingString:[NSString stringWithFormat:@"\n%@", shareUrl]];
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];

            NSData *data = UIImagePNGRepresentation(self.codeImageView.image);
            [mc addAttachmentData:data mimeType:@"image/png" fileName:@"qrcode.png"];
            [mc setMessageBody:messageBody isHTML:NO];
            [self presentViewController:mc animated:YES completion:NULL];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Mail Accounts" message:@"Please go to \"Settings\" > \"Mail, Contacts, Calendars \" > \"Add Account\" to set your email account" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
        }
    } else if ((int)imageIndex == 1) {
        SLComposeViewController *fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];

        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewControllerCompletionHandler __block completionHandler = ^(SLComposeViewControllerResult result){
                [fbController dismissViewControllerAnimated:YES completion:nil];

                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                    default: {
                        NSLog(@"Cancelled.....");
                    }
                        break;
                    case SLComposeViewControllerResultDone: {
                        NSLog(@"Posted....");
                    }
                        break;
                }};

            [fbController addImage:textMixQrcodeImage];
            [fbController setCompletionHandler:completionHandler];
            [self presentViewController:fbController animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No FaceBook Accounts" message:@"Please go to \"Settings\" > \"Facebook\" to set your Facebook account" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
        }
    } else if ((int)imageIndex == 2) {
        [self shareLineWithImage:textMixQrcodeImage];
    } else if ((int)imageIndex == 3) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whatsapp://app"]]) {

            NSString *savePath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.wai"];
            [UIImageJPEGRepresentation(textMixQrcodeImage, 1.0) writeToFile:savePath atomically:YES];
            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
            self.documentInteractionController.UTI = @"net.whatsapp.image";
            self.documentInteractionController.delegate = self;
            [self.documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated: YES];
        } else {
            NSURL *itunesURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id310633997"];
            [[UIApplication sharedApplication] openURL:itunesURL];
        }
    }
}

#pragma mark - Orientation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
