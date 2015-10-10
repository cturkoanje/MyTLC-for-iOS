//
//  BarcodeViewController.m
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 10/5/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import "BarcodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface BarcodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    UIButton *_label;
}

@end

@implementation BarcodeViewController

- (void)viewDidLayoutSubviews {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSLog(@"viewDidLayoutSubviews Screen Size: %f, %f", screenRect.size.width, screenRect.size.height);
    NSLog(@"viewDidLayoutSubviews View Size: %f, %f", self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"viewDidLayoutSubviews SuperView Size: %f, %f", self.view.superview.frame.size.width, self.view.superview.frame.size.height);
    NSLog(@"viewDidLayoutSubviews View Bounds Size: %f, %f", self.view.bounds.size.width, self.view.bounds.size.height);
    
    CGRect size = self.view.bounds;
    
    if(self.view.bounds.size.width/self.view.bounds.size.height < 0.55)
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            size.size.height = size.size.width;
        }

    
    _prevLayer.frame = size;
    
    NSLog(@"Frame size: %f, %f", _prevLayer.frame.size.width, _prevLayer.frame.size.height);
    
    
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    NSLog(@"Screen Size: %f, %f", screenRect.size.width, screenRect.size.height);
    NSLog(@"View Size: %f, %f", self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"SuperView Size: %f, %f", self.view.superview.frame.size.width, self.view.superview.frame.size.height);
    NSLog(@"View Bounds Size: %f, %f", self.view.bounds.size.width, self.view.bounds.size.height);
 

    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    
    _label = [[UIButton alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height - 40, screenRect.size.width, 40);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    [_label setTitle:@"(Close Scanner)" forState:UIControlStateNormal];
    [_label addTarget:self action:@selector(closeView:) forControlEvents:UIControlEventTouchUpInside];
    //_label.textColor = [UIColor whiteColor];
    //_label.textAlignment = NSTextAlignmentCenter;
    //_label.text = @"(Close Scanner)";
    [self.view addSubview:_label];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = screenRect;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];

}

-(void)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)closeViewWithData:(NSString *)data {
    
    NSString *storeNumber = nil;
    NSString *sku = nil;
    
    if([data hasPrefix:@"http://bby.us/"])
    {
        NSString *prefix = @"http://bby.us/?c=BB0";
        NSRange needleRange = NSMakeRange(prefix.length, data.length - prefix.length);
        NSString *barcodeData = [data substringWithRange:needleRange];
        storeNumber = [barcodeData substringWithRange:NSMakeRange(0, 4)];
        sku = [barcodeData substringWithRange:NSMakeRange(4, 7)];
    }
    else {
        sku = data;
        storeNumber = @"";
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"barcodeDismiss"
     object:@{@"sku" : sku,
              @"store" : storeNumber}];
    

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeITF14Code, AVMetadataObjectTypeInterleaved2of5Code, AVMetadataObjectTypeDataMatrixCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                
                if (detectionString != nil)
                {
                    //_label.text = detectionString;
                    
                    [_label setTitle:detectionString forState:UIControlStateNormal];
                    NSLog(@"Scan: %@", detectionString);
                    [self closeViewWithData:detectionString];
                    [_session stopRunning];
                 /*   [[NSNotificationCenter defaultCenter] postNotificationName:@"barcodeScanned" object:@{
                                                                                                          @"barcodeData" : detectionString,
                                                                                                          @"barcodeType" : type,
                                                                                                          }]; */
                }
                else
                    [_label setTitle:@"(Close Scanner)" forState:UIControlStateNormal];
                
                break;
            }
        }
        
            //_label.text = @"(Close Scanner)";
    }
    
    _highlightView.frame = highlightViewRect;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
