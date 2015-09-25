//
//  WatchShiftDetailViewController.h
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 9/18/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface WatchShiftDetailViewController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *shiftDay;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *startShiftTime;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *endShiftTime;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *hoursWorked;

@end
