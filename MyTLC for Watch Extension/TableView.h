//
//  TableView.h
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 9/3/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface TableView : NSObject

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *startShiftDate;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *endShiftDate;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *hoursWorked;

@end
