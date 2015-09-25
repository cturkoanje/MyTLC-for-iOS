//
//  InterfaceController.h
//  MyTLC for Watch Extension
//
//  Created by Christian Turkoanje on 9/3/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
@import WatchConnectivity;

@interface InterfaceController : WKInterfaceController <WCSessionDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *mainTable;

@property (nonatomic, strong) NSArray *shifts;

@end
