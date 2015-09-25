//
//  TodayViewController.h
//  MyTLC
//
//  Created by Christian Turkoanje on 9/2/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController

@property (nonatomic, strong) NSArray *shifts;
@property (nonatomic, strong) NSMutableArray *thisWeek;
@property (nonatomic, strong) NSMutableArray *nextWeek;
@property (nonatomic, strong) NSMutableArray *twoWeek;

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *startLabel;
@property (nonatomic, weak) IBOutlet UILabel *endLabel;
@property (nonatomic, weak) IBOutlet UILabel *hoursLabel;
@property (nonatomic, weak) IBOutlet UILabel *monDateLabel;

@property (nonatomic, weak) IBOutlet UIButton *pageTitle;


@end
