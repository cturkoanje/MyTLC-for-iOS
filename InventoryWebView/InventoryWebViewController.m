//
//  InventoryWebViewController.m
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 10/7/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import "InventoryWebViewController.h"
#import "BarcodeViewController.h"


@interface InventoryWebViewController ()

@end

@implementation InventoryWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    self.title = @"Inventory Lookup";
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(closeView:)];
    UIBarButtonItem *scanButton = [[UIBarButtonItem alloc] initWithTitle:@"Scan"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(openBarcodeScanner:)];
    
    [self.navigationItem setRightBarButtonItem:closeButton animated:YES];
    [self.navigationItem setLeftBarButtonItem:scanButton animated:YES];
    
    
    _theConfiguration = [[WKWebViewConfiguration alloc] init];
    _controller = [[WKUserContentController alloc]
                                           init];
    [_controller addScriptMessageHandler:self name:@"observe"];
    _theConfiguration.userContentController = _controller;
    
    _webView = [[WKWebView alloc] initWithFrame:screenRect configuration:_theConfiguration];
    _webView.navigationDelegate = self;
    [_webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    
    //NSURL *nsurl=[NSURL URLWithString:@"http://beta.ctthosting.com/rss/InventoryView.html"];
    NSURL *nsurl=[NSURL URLWithString:@"https://retailapps.bestbuy.com/"];
    
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [_webView loadRequest:nsrequest];
    [self.view addSubview:_webView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotBarcodeData:)
                                                 name:@"barcodeDismiss" object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqual:@"loading"]) {
        NSString *email = @"christian.turkoanje@bestbuy.com";
        NSString *password = @"Android7";
        
        NSString *jslogin = [NSString stringWithFormat:@"if($(\"#EmailId\")){$(\"#EmailId\").val(\"%@\");$(\"#Password\").val(\"%@\");$('input[type=\"submit\"]').click();}", email, password];
        
        NSLog(@"Did finish loading 2");
        
        [_webView evaluateJavaScript:jslogin completionHandler:^(NSString *result, NSError *error)
         {
             NSLog(@"Error %@",error);
             NSLog(@"Result %@",result);
         }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)openBarcodeScanner:(id)sender {
    BarcodeViewController * bc = [[BarcodeViewController alloc] init];
    [self presentViewController:bc animated:YES completion:nil];
}

-(void)gotBarcodeData:(NSNotification *)notice{
    NSDictionary *data = [notice object];
    
    NSString *js = [NSString stringWithFormat:@"$(\"#SkuForCurrentStore\").val(\"%@\");$(\"#StoreNoForCurrentStore\").val(\"%@\");", [data objectForKey:@"sku"], [data objectForKey:@"store"]];
    
    NSLog(@"JS String: %@", js);
    
    [_webView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error)
     {
         NSLog(@"Error %@",error);
         NSLog(@"Result %@",result);
     }];
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:[NSString stringWithFormat:@"Data Retrieved:\n%@", data] delegate:self cancelButtonTitle:@"Calncel" otherButtonTitles:nil, nil];
    //[alert show];
    
}

-(BOOL)isLoggedIn {
    
    NSString *email = @"christian.turkoanje@bestbuy.com";
    NSString *password = @"Android7";
    
    NSString *jslogin = [NSString stringWithFormat:@"$(\"#EmailId\").val(\"%@\");$(\"#Password\").val(\"%@\");$('input[type=\"submit\"]').click();", email, password];
    
    return false;
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
