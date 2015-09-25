//
//  NewTableView.h
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 9/18/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface NewTableView : NSObject

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *shiftDay;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *startShiftTime;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *endShiftTime;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *hoursWorked;

@end
