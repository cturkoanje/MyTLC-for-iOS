//
//  mytlcShiftViewController.h
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 5/18/15.
//  Copyright (c) 2015 DrR3d. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface mytlcShiftViewController : UITableViewController

@property (nonatomic, strong) NSArray *shifts;

@property (nonatomic, strong) NSMutableArray *thisWeek;
@property (nonatomic, strong) NSMutableArray *nextWeek;
@property (nonatomic, strong) NSMutableArray *twoWeek;

@property (strong, nonatomic) IBOutlet UIButton *syncButton;
@property (strong, nonatomic) IBOutlet UILabel *lblLastUpdated;

- (IBAction)closeView:(id)sender;

@end
