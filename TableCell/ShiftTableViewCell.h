//
//  ShiftTableViewCell.h
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 5/20/15.
//  Copyright (c) 2015 DrR3d. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShiftTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *startLabel;
@property (nonatomic, weak) IBOutlet UILabel *endLabel;
@property (nonatomic, weak) IBOutlet UILabel *hoursLabel;
@property (nonatomic, weak) IBOutlet UILabel *monDateLabel;

@end
