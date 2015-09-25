//
//  ComplicationController.h
//  MyTLC for Watch Extension
//
//  Created by Christian Turkoanje on 9/3/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import <ClockKit/ClockKit.h>

@interface ComplicationController : NSObject <CLKComplicationDataSource>

@property (nonatomic, strong) NSArray *shifts;

@property (nonatomic, strong) NSMutableArray *thisWeek;
@property (nonatomic, strong) NSMutableArray *nextWeek;
@property (nonatomic, strong) NSMutableArray *twoWeek;

@end
