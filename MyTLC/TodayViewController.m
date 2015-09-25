//
//  TodayViewController.m
//  MyTLC
//
//  Created by Christian Turkoanje on 9/2/15.
//  Copyright © 2015 DrR3d. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.preferredContentSize = CGSizeMake(0, 80);
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.ctthosting.bby.shifts"];
    _shifts = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentSavedShifts"]];
    
    NSLog(@"loaded display shifts: \n%@", _shifts);
    
    if([_shifts count] == 0)
    {
        NSLog(@"No Shifts to View");
        
        _dateLabel.text = @"?";
        _startLabel.text = @"?";
        _endLabel.text = @"?";
        _monDateLabel.text = @"?";
        
        _hoursLabel.text = @"?";
        
        [_pageTitle setTitle:@"Open App to Sync" forState:UIControlStateNormal];
        return;
    }
    
    [self generateSections:_shifts];
    
    
    
    NSDictionary *cShift = [[NSDictionary alloc] init];
    
    if([_thisWeek count] > 0)
       cShift = (_thisWeek)[0];
    else if([_nextWeek count] > 0)
        cShift = (_nextWeek)[0];
    else if([_twoWeek count] > 0)
        cShift = (_twoWeek)[0];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"EEE"];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"h:mm a"];
    
    NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
    [formatter3 setDateFormat:@"MMM d"];
    
    NSString *dateShift = [formatter stringFromDate:[cShift objectForKey:@"startDate"]];
    NSString *startShift = [formatter2 stringFromDate:[cShift objectForKey:@"startDate"]];
    NSString *endShift = [formatter2 stringFromDate:[cShift objectForKey:@"endDate"]];
    NSString *dateLabel = [formatter3 stringFromDate:[cShift objectForKey:@"startDate"]];
    
    NSDate* date1 = [cShift objectForKey:@"startDate"];
    NSDate* date2 = [cShift objectForKey:@"endDate"];
    NSTimeInterval distanceBetweenDates = [date2 timeIntervalSinceDate:date1];
    double secondsInAnHour = 3600;
    double hoursBetweenDates = (double)distanceBetweenDates / secondsInAnHour;
    
    
    
    // NSLog(@"cShift: %@\nStart: %@", cShift, startShift);
    
    
    _startLabel.text = startShift;
    _endLabel.text = endShift;
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    
    _dateLabel.text = dateShift;
    _startLabel.text = startShift;
    _endLabel.text = endShift;
    _monDateLabel.text = dateLabel;
    
    _hoursLabel.text = [NSString stringWithFormat:@"%@", [fmt stringFromNumber:[NSNumber numberWithDouble:hoursBetweenDates]]];

    [_pageTitle setTitle:@"Next Shift" forState:UIControlStateNormal];
    

}


-(void)generateSections:(NSArray *)shifts {
    
    _thisWeek = [[NSMutableArray alloc] init];
    _nextWeek = [[NSMutableArray alloc] init];
    _twoWeek = [[NSMutableArray alloc] init];
    
    for(NSDictionary *shift in shifts)
    {
        /*
         NSDateFormatter *dateFormatter  =   [[NSDateFormatter alloc]init];
         [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
         // NSDate *startDate                =   [dateFormatter dateFromString:[shift objectForKey:@"startDate"]];
         
         */
        
        NSDate *startDate = [shift objectForKey:@"startDate"];
        NSDate *endDate = [shift objectForKey:@"endDate"];
        
        if ([endDate timeIntervalSinceNow] > 0.0)
        {
            
            NSInteger isThisWeek = [self isSameWeekAsDate:startDate];
            if(isThisWeek == 0)
                [_thisWeek addObject:shift];
            else if(isThisWeek == 1)
                [_nextWeek addObject:shift];
            else if(isThisWeek == 2)
                [_twoWeek addObject:shift];
        }
        else{
            NSLog(@"Found outdated shift: \n%@\nEnded: %f", shift, [endDate timeIntervalSinceNow]);
        }
        
    }
    
    //NSLog(@"Generate sections:\n%@\nThis Week:\n%@\nNext Week:\n%@", shifts, _thisWeek, _nextWeek);
    
}

- (NSInteger) isSameWeekAsDate: (NSDate *) anotherDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian setFirstWeekday:1];
    NSDate *today = [NSDate date];
    
    NSDateComponents *todaysComponents = [gregorian components:NSCalendarUnitWeekOfYear fromDate:today];
    
    NSUInteger todaysWeek = [todaysComponents weekOfYear];
    
    NSDateComponents *otherComponents = [gregorian components:NSCalendarUnitWeekOfYear fromDate:anotherDate];
    
    NSUInteger anotherWeek = [otherComponents weekOfYear];
    
    if(todaysWeek==anotherWeek)
        return 0;
    else if(todaysWeek+1==anotherWeek)
        return 1;
    else if(todaysWeek+2==anotherWeek)
        return 2;
    
    return -1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (IBAction) goToApp: (id)sender {
    NSURL *url = [NSURL URLWithString:@"bbytlc://"];
    [self.extensionContext openURL:url completionHandler:nil];
}

@end
