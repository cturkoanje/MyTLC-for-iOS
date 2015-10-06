//
//  mytlcShiftViewController.h
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 5/18/15.
//  Copyright (c) 2015 DrR3d. All rights reserved.
//

#import <UIKit/UIKit.h>


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface mytlcShiftViewController : UITableViewController

@property (nonatomic, strong) NSArray *shifts;

@property (nonatomic, strong) NSMutableArray *thisWeek;
@property (nonatomic, strong) NSMutableArray *nextWeek;
@property (nonatomic, strong) NSMutableArray *twoWeek;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rssButton;

@property (strong, nonatomic) IBOutlet UIButton *syncButton;
@property (strong, nonatomic) IBOutlet UILabel *lblLastUpdated;

- (IBAction)closeView:(id)sender;
-(void)resumeDataFromBackground;

-(IBAction)openSyncPage:(id)sender;

@end
