//
//  ShiftTableViewCell.m
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 5/20/15.
//  Copyright (c) 2015 DrR3d. All rights reserved.
//

#import "ShiftTableViewCell.h"

@implementation ShiftTableViewCell

@synthesize dateLabel = _dateLabel;
@synthesize startLabel = _startLabel;
@synthesize endLabel = _endLabel;
@synthesize hoursLabel = _hoursLabel;
@synthesize monDateLabel= _monDateLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
