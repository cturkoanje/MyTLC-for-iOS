//
//  InventoryWebViewController.h
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 10/7/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDKeychainBindings.h"

@import WebKit;

@interface InventoryWebViewController : UIViewController<WKScriptMessageHandler>

@property (weak, nonatomic) NSString *sku;
@property (weak, nonatomic) NSString *store;

@property (strong, nonatomic) WKWebViewConfiguration *theConfiguration;
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) WKUserContentController *controller;


@end
