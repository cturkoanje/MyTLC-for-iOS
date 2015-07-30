//
//  mytlcShiftViewController.m
//  MyTLC Sync
//
//  Created by Christian Turkoanje on 5/18/15.
//  Copyright (c) 2015 DrR3d. All rights reserved.
//

#import "mytlcShiftViewController.h"
#import "mytlcShift.h"
#import "ShiftTableViewCell.h"

@interface mytlcShiftViewController ()

@end

@implementation mytlcShiftViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated
{
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"Attempting get the last saved shifts");

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _shifts = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"currentSavedShifts"]];
    
    NSLog(@"loaded display shifts: \n%@", _shifts);
    
    if([_shifts count] == 0)
    {
        [_syncButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        return;
    }

    NSDate *lastUpdated = [defaults objectForKey:@"lastUpdated"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, MMM d '@' hh:mm a"];
    
    NSString *updateString = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:lastUpdated]];
    [_lblLastUpdated setText:updateString];
    
    [self generateSections:_shifts];
    [self.tableView reloadData];
    
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

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"This Week";
    if(section == 1)
        return @"Next Week";
    if(section == 2)
        return @"Two Weeks";
    
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([_twoWeek count] == 0)
        return 2;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //NSLog(@"Request sections : %ld\nThis Week: %lu\nNext Week: %lu", (long)section, (unsigned long)[_thisWeek count], (unsigned long)[_nextWeek count]);
    if(section == 0)
        return [_thisWeek count];
    if(section == 1)
        return [_nextWeek count];
    if(section == 2)
        return [_twoWeek count];
    
    return 0;
}

- (IBAction)closeView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"Requesting cell data for \nindexPath.row: %d\nindexPath.section: %d", indexPath.row, indexPath.section);
    
    ShiftTableViewCell *newCell = (ShiftTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"myShift"];
    if(!newCell)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShiftCell" owner:self options:nil];
        newCell = [nib objectAtIndex:0];
    }
    
    
    
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"myShift"];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"myShift"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ////
    cell.textLabel.text = @"aaa";
    //return cell;
    
    cell.backgroundColor = [UIColor colorWithRed:28.0 green:28.0 blue:28.0 alpha:0.03];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    ////
    
        
    NSDictionary *cShift = [[NSDictionary alloc] init];
    
    if(indexPath.section == 0)
    {
        cShift = (_thisWeek)[indexPath.row];
    }
    else if(indexPath.section == 1)
    {
       cShift = (_nextWeek)[indexPath.row];
    }
    else if(indexPath.section == 2)
    {
        cShift = (_twoWeek)[indexPath.row];
    }
    
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
    
    
    cell.textLabel.text = startShift;
    cell.detailTextLabel.text = endShift;
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    
    newCell.dateLabel.text = dateShift;
    newCell.startLabel.text = startShift;
    newCell.endLabel.text = endShift;
    newCell.monDateLabel.text = dateLabel;
    
    newCell.hoursLabel.text = [NSString stringWithFormat:@"%@", [fmt stringFromNumber:[NSNumber numberWithDouble:hoursBetweenDates]]];
    
    
    return newCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
