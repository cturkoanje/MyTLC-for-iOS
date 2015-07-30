/*
 * Copyright 2013 Devin Collins <devin@imdevinc.com>
 * Copyright 2014 Mike Wohlrab <Mike@NeoNet.me>
 *
 * This file is part of MyTLC Sync.
 *
 * MyTLC Sync is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyTLC Sync is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyTLC Sync.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "mytlcCalendarHandler.h"
#import "mytlcShift.h"
#import <EventKit/EventKit.h>

@implementation mytlcCalendarHandler

BOOL done = NO;
BOOL newMessageExists = NO;
EKEventStore* eventStore = nil;
NSString* message = nil;

- (void) displayAllShifts:(NSMutableArray*) shifts
{
    NSLog(@"Displaying all shifts....");
    NSMutableArray *shitArray = [[NSMutableArray alloc] init];
    for (mytlcShift* shift in shifts)
    {
        NSLog(@"Creating Shift:\n%@\n%@", shift, [shift department]);
        
        NSMutableDictionary *newShift = [[NSMutableDictionary alloc] init];
        
        NSArray *keys = @[@"department", @"location", @"startDate", @"endDate"];
        NSArray *values = @[[shift department], @"0000", [shift startDate], [shift endDate]];
        
        newShift = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
        
        
        NSLog(@"\nConverted:\n%@", newShift);
        [shitArray addObject:newShift];
    }
    
    NSLog(@"Attempting to save the current shifts to NSDefaults: \n\n%@", shitArray);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:shitArray];
    [userDefaults setObject:data forKey:@"currentSavedShifts"];
    [userDefaults setObject:[NSDate date] forKey:@"lastUpdated"];
    [userDefaults synchronize];
}


// Makes sure that we have permission to access the Calendars
- (void) checkCalendarAccess:(NSMutableArray*) shifts
{
    eventStore = [[EKEventStore alloc] init];
    
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError* err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (err || !granted)
                {
                    [self updateProgress:@"Couldn't get access to the calendar, please check calendar permissions in Settings.app > Privacy > Calendar"];
                    
                    done = YES;
                }
                else
                {
                    [self updateProgress:@"Deleting old entries"];
                    NSMutableArray* shiftsToAdd = [self removeDuplicatesFromShifts:shifts];
                    
                    [self updateProgress:@"Adding shifts to calendar"];

                    [self createCalendarEntries:shiftsToAdd];
                }
            });
        }];
    }
}

- (NSMutableArray*) removeDuplicatesFromShifts:(NSMutableArray*) newShifts
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    
    NSDate* date = [NSDate date];
    
    NSDateComponents* components = [cal components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    
    [components setHour:0];
    
    [components setMinute:0];
    
    [components setSecond:0];
    
    NSDate* startDate = [cal dateFromComponents:components];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* shifts = [NSMutableArray arrayWithArray:[defaults arrayForKey:@"shifts"]];
    
    if ([shifts count] == 0)
    {
        return newShifts;
    }
    
    for (unsigned long x = shifts.count - 1; x > 0; x--)
    {
        EKEvent* event = [eventStore eventWithIdentifier:shifts[x]];
        
        if ([event endDate] == [startDate earlierDate:[event endDate]])
        {
            [shifts removeObjectAtIndex:x];
            continue;
        }
        
        BOOL shiftFound = NO;
        
        for (long y = newShifts.count - 1; y >= 0; y--)
        {
            if ([[event startDate] isEqualToDate:[newShifts[y] startDate]] && [[event endDate] isEqualToDate:[newShifts[y] endDate]])
            {
                shiftFound = YES;
                [newShifts removeObjectAtIndex:y];
            }
        }
        
        if (shiftFound == NO)
        {
            NSError* err;
            [eventStore removeEvent:event span:EKSpanThisEvent error:&err];
            [shifts removeObjectAtIndex:x];
        }
    }
    
    [defaults setObject:shifts forKey:@"shifts"];
    
    [defaults synchronize];
    
    return newShifts;
}

// Creates the shifts to add to the Calendar
- (void) createCalendarEntries:(NSMutableArray*) shifts
{
    int count = 0;
    
    NSString* calendar_id = [self getSelectedCalendarId];
    
    NSInteger alarm_time = -1 * ([self getAlarmSettings] * 60);
    
    NSString* address = [self getAddress];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* saveShifts = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"shifts"]];
    
    NSString* title = [self getTitle];
    
    for (mytlcShift* shift in shifts)
    {
        EKEvent* event = [EKEvent eventWithEventStore:eventStore];
        
        event.notes = shift.department;
        
        event.title = title;
        
        event.startDate = shift.startDate;
        
        event.endDate = shift.endDate;
        
        if (alarm_time != 0)
        {
            EKAlarm* alarm = [EKAlarm alarmWithRelativeOffset:alarm_time];
            
            event.alarms = [NSArray arrayWithObject:alarm];
        }
        
        if ([address length] > 0)
        {
            event.location = address;
        }
        
        [event setCalendar:[eventStore calendarWithIdentifier:calendar_id]];
        
        NSError *err = nil;
        
        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        
        if (!err)
        {
            [saveShifts addObject:[event eventIdentifier]];
            count++;
        }

    }
    
    [defaults setObject:saveShifts forKey:@"shifts"];
    
    [defaults synchronize];
    
    [self getData:@"https://mytlc.bestbuy.com/etm/etmMenu.jsp?pageAction=logout"];
    
    done = YES;
    
    [self updateProgress:[NSString stringWithFormat:@"Added %d shifts to your calendar", count]];
}

- (NSString*) createParams:(NSMutableDictionary*) dictionary
{
    NSString* result = nil;
    
    for (NSString* key in dictionary)
    {
        result = [NSString stringWithFormat:@"%@&%@=%@", result, key, [dictionary objectForKey:key]];
    }
    
    return result;
}

// Gets the Store Address via Address Lookup in Settings
- (NSString*) getAddress
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* address = [[NSString alloc] initWithFormat:@"%@ %@, %@ %@", [defaults valueForKey:@"address-street"], [defaults valueForKey:@"address-city"], [defaults valueForKey:@"address-state"], [defaults valueForKey:@"address-zip"]];
    
    if ([address isEqualToString:@"(null) (null), (null) (null)"])
    {
        return @"";
    }
    
    return address;
}

// Gets alarm settings
- (NSUInteger) getAlarmSettings
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    return [defaults integerForKey:@"alarm"];
}

// Gets Event Title
- (NSString*) getTitle
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults stringForKey:@"title"];
}

- (NSString*) getData:(NSString*) url
{
    NSURL* urlRequest = [NSURL URLWithString:url];

    NSError* err = nil;
    
    NSString* result = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&err];

    if (!err)
    {
        return result;
    }
    
    return nil;
}

- (NSString*) getMessage
{
    return message;
}

- (NSInteger) getOffsetSettings
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger offset = [defaults integerForKey:@"hour_offset"] * 60 * 60;
    
    return offset;
}

// Gets the ID associated with the Calendar
- (NSString*) getSelectedCalendarId
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* calendar_id = [defaults objectForKey:@"calendar_id"];
    
    if (calendar_id == nil || [calendar_id isEqualToString:@"default"])
    {
        return [[eventStore defaultCalendarForNewEvents] calendarIdentifier];
    }
    
    return calendar_id;
}

- (BOOL) hasCompleted
{
    return done;
}

- (BOOL) hasNewMessage
{
    return newMessageExists;
}


/* Handles the parsing of the schedule data */
- (NSMutableArray*) parseSchedule:(NSString*) data
{
    if ([data rangeOfString:@"pageTitle"].location == NSNotFound)
    {
        return nil;
    }
    
    /* Gets the Previous Month and Year data*/
    
    NSRange begin = [data rangeOfString:@"Details of "];
    
    NSString* sMonth = [data substringFromIndex:begin.location + 11];
    
    NSRange end = [sMonth rangeOfString:@"/"];
    
    sMonth = [sMonth substringToIndex:end.location];
    

    // Gets the info for the Previous Month, Year
    if ([data rangeOfString:@"pageTitle"].location == NSNotFound)
    {
        return nil;
    }
    
    // Captures the Year from MyTLC
    begin = [data rangeOfString:@"Details of "];
    
    NSString* sYear = [data substringFromIndex:begin.location + 17];
    
    end = [sYear rangeOfString:@"'"];
    
    sYear = [sYear substringToIndex:end.location];

    
        
    if ([data rangeOfString:@"calWeekDayHeader"].location == NSNotFound)
    {
        return nil;
    }
    
    data = [data substringFromIndex:[data rangeOfString:@"calWeekDayHeader"].location];
    
    if ([data rangeOfString:@"document.forms[0].NEW_MONTH_YEAR"].location == NSNotFound)
    {
        return nil;
    }
    
    data = [data substringToIndex:[data rangeOfString:@"document.forms[0].NEW_MONTH_YEAR"].location];
    
    if (!data)
    {
        return nil;
    }
    
    NSArray* schedules = [data componentsSeparatedByString:@"</tr>"];
    
    
    if (!schedules)
    {
        return nil;
    }
    
    NSMutableArray* workDays = [NSMutableArray array];

    for (NSString* schedule in schedules)
    {
        if ([schedule rangeOfString:@"OFF"].location != NSNotFound)
        {
            continue;
        }
        
        if ([schedule rangeOfString:@"calendarCellRegularCurrent"].location == NSNotFound && [schedule rangeOfString:@"calendarCellRegularFuture"].location == NSNotFound)
        {
            continue;
        }
        
        NSString* date = nil;
        
        if ([schedule rangeOfString:@"calendarCellRegularCurrent"].location == NSNotFound)
        {
            begin = [schedule rangeOfString:@"calendarDateNormal"];
            
            date = [schedule substringFromIndex:begin.location + 22];
        } else {
            begin = [schedule rangeOfString:@"calendarDateCurrent"];
            
            date = [schedule substringFromIndex:begin.location + 23];
        }
        
        
        
        if (!date)
        {
            continue;
        }
        
        end = [date rangeOfString:@"</span>"];
        
        date = [date substringToIndex:end.location];
        
        NSCharacterSet* replace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        date = [date stringByTrimmingCharactersInSet:replace];
        
        NSArray* shifts = [schedule componentsSeparatedByString:@"<br>"];
        
        NSInteger offset = [self getOffsetSettings];
        
        for (int i = 0; i < [shifts count]; i++)
        {
            if (([shifts[i] rangeOfString:@"AM"].location != NSNotFound && [shifts[i] rangeOfString:@"<td>"].location == NSNotFound) || ([shifts[i] rangeOfString:@"PM"].location != NSNotFound && [shifts[i] rangeOfString:@"<td>"].location == NSNotFound))
            {
                NSString* dept = @"";
                
                if (i != shifts.count - 1)
                {
                    if ([shifts[i + 1] rangeOfString:@"L-"].location != NSNotFound)
                    {
                        dept = [shifts[i + 1] stringByTrimmingCharactersInSet:replace];
                    }
                }
                
                mytlcShift* shift = [[mytlcShift alloc] init];
                
                shift.department = dept;
                
                // Splits the shift for StartTime (StartDate) and EndTime (EndDate)
                NSRange split = [shifts[i] rangeOfString:@" - "];
                
                // StartTime (StartDate)
                NSString* time = [shifts[i] substringToIndex:split.location];
                time = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                
                shift.startDate = [self parseTime:[NSString stringWithFormat:@"%@ %@, %@ %@", sMonth, date, sYear, time]];
                
                shift.startDate = [shift.startDate dateByAddingTimeInterval:offset];
                
                // EndTime (EndDate)
                time = [shifts[i] substringFromIndex:split.location + 3];
                
                shift.endDate = [self parseTime:[NSString stringWithFormat:@"%@ %@, %@ %@", sMonth, date, sYear, time]];
                
                shift.endDate = [shift.endDate dateByAddingTimeInterval:offset];
                
                if (shift.endDate == [shift.endDate earlierDate:shift.startDate])
                {
                    shift.endDate = [shift.endDate dateByAddingTimeInterval:60 * 60 * 24];
                }
                
                [workDays addObject:shift];
            }
        }
        
    }
    
    return workDays;
}


- (NSDate*) parseTime:(NSString*) time
{
    
    // Checks to see if user is on a 24 Hour clcok or 12 Hour clock system. Returns YES/TRUE if on 24 Hour clock
    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    BOOL is24Hour = ([format rangeOfString:@"a"].location == NSNotFound);
    // NSLog(@"%@\n",(is24Hour ? @"YES" : @"NO"));
    
    
    if (is24Hour == TRUE)
    {

        // Initialized DateFormatter
        NSDateFormatter* df = [[NSDateFormatter alloc]init];
        // Sets Locale to en_US for proper formatting
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        
        // May be able to use setTimeZone to shorten the TimeZone conversion using just a single step here. Leaving off for future debugging and testing
        //    [df setTimeZone:[NSTimeZone systemTimeZone]];
        
        // Sets the input format which includes the 12 hour clock and AM/PM
        [df setDateFormat:@"MM dd, yyyy hh:mm a"];
        // Sets the output format for 24 hour clock, then converts to string
        NSDate* date = [df dateFromString:time];
        [df setDateFormat:@"MM dd, yyyy HH:mm"];
        NSString *stringFromDate = [df stringFromDate:date];
        
    
        // Reconverting from proper format of a String to proper format of a Date value
        // as we return a Date value and not a String
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM dd, yyyy HH:mm"];
        NSDate* date2 = [dateFormatter dateFromString:stringFromDate];
        
        return date2;
        
        
        // Otherwise if on 12 Hour clock system continue as normal
    } else {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"MM dd, yyyy hh:mm a"];
            
        time = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
        NSDate* date = [dateFormatter dateFromString:time];
            
        return date;
    }

}


// Parses the login token used to authenticate
- (NSString*) parseToken:(NSString*) data
{
    if ([data rangeOfString:@"End Hotkey for submit"].location == NSNotFound)
    {
        return nil;
    }
    
    NSRange end = [data rangeOfString:@"End Hotkey for submit"];
    
    data = [data substringFromIndex:end.location];
    
    if (([data rangeOfString:@"hidden"].location == NSNotFound) || ([data rangeOfString:@"url_login_token"].location == NSNotFound))
        {
            return nil;
        }
    
    NSRange begin = [data rangeOfString:@"hidden"];
    
    data = [data substringFromIndex:begin.location + 14];
    
    end = [data rangeOfString:@"url_login_token"];
    
    data = [data substringToIndex:end.location - 7];
    
    return data;
}

// Parses the login token used to authenticate. 2nd instance so we can check 2nd month scheduled for events.
- (NSString*) parseToken2:(NSString*) data
{
    if ([data rangeOfString:@"secureToken"].location == NSNotFound)
    {
        return nil;
    }
    
    NSRange begin = [data rangeOfString:@"secureToken"];
    
    data = [data substringFromIndex:begin.location + 20];
    
    if ([data rangeOfString:@"'/>"].location == NSNotFound)
    {
        return nil;
    }
    
    NSRange end = [data rangeOfString:@"'/>"];
    
    data = [data substringToIndex:end.location];
    
    return data;
}

// Parses the wbat used for authentication.
- (NSString*) parseWbat:(NSString*) data
{
    if ([data rangeOfString:@"wbat"].location == NSNotFound)
    {
        return nil;
    }
    
    NSRange begin = [data rangeOfString:@"wbat"];
    
    data = [data substringFromIndex:begin.location + 23];
    
    if ([data rangeOfString:@"'>"].location == NSNotFound)
    {
        return nil;
    }
    
    NSRange end = [data rangeOfString:@"'>"];
    
    data = [data substringToIndex:end.location];
    
    return data;
}

// Configuring the PostData used for submitting the Schedule Checking
- (NSString*) postData:(NSString*) url params:(NSString*) params
{
    NSURL* urlRequest = [NSURL URLWithString:url];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[urlRequest standardizedURL]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError* err = nil;
    
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
   
    if (!err) {
        return [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];;
    }
    
    return nil;
}

// Login System Handler for getting the schedule of events.
- (BOOL) runEvents:(NSDictionary*)login
{
    done = NO;
    
    [self updateProgress:@"Checking for calendar access"];
    
    EKEventStore* eventStore = [[EKEventStore alloc] init];
    
    if (![eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }];
    }
    
    [self updateProgress:@"Getting login credentials"];
    
    NSString* params = nil;

    NSString* loginToken = nil;

    NSString* wbat = nil;
    
    NSString* username = [login valueForKey:@"username"];
    
    NSString* password = [login valueForKey:@"password"];
    
    [self updateProgress:@"Checking for network connection"];
    
    NSString* data = [self getData:@"https://mytlc.bestbuy.com/etm/login.jsp"];
    
    if (!data) {
        [self updateProgress:@"Error connecting to MyTLC, do you have a network connection?"];
        
        done = YES;
        
        return NO;
    }
    
    [self updateProgress:@"Getting login token"];
    
    loginToken = [self parseToken:data];
    
    wbat = [self parseWbat:data];
    
    if (!loginToken)
    {
        [self updateProgress:@"Couldn't get login token, do you have a valid network connection?"];
        
        done = YES;
        
        return NO;
    }
    
    // Creating the initial parameters used for checking the schedule
    params = [self createParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"login", @"pageAction", loginToken, @"url_login_token", wbat, @"wbat", username, @"login", password, @"password", @"DEFAULT", @"client", @"false", @"localeSelected", @"", @"STATUS_MESSAGE_HIDDEN", @"0", @"wbXpos", @"0", @"wbYpos" , nil]];
    
    if (!params)
    {
        [self updateProgress:@"Couldn't create logon credentials, please try again"];
        
        return NO;
    }
    
    // Logging in to the MyTLC System
    [self updateProgress:@"Logging in..."];
    
    data = [self postData:@"https://mytlc.bestbuy.com/etm/login.jsp" params:params];
    
    if ([data rangeOfString:@"etmMenu.jsp"].location == NSNotFound)
    {
        [self updateProgress:@"Incorrect username and password, please try again"];
        
        done = YES;
        
        return NO;
    }
    
    
    [self updateProgress:@"Getting schedule"];
    
    data = [self getData:@"https://mytlc.bestbuy.com/etm/time/timesheet/etmTnsMonth.jsp"];
    
    if (!data)
    {
        [self updateProgress:@"Couldn't get schedule, please try again later"];
        
        done = YES;
        
        return NO;
    }
    
    // Performs first parsing of the Schedule
    [self updateProgress:@"Parsing shifts"];
    
    NSMutableArray* shifts = [self parseSchedule:data];
    
    NSLog(@"\n\nShifts:\n\n%@\n\n", shifts);
    
    // Starts the Second Parsing
    [self updateProgress:@"Getting next security token"];
    
    NSString* securityToken = [self parseToken2:data];
    
    wbat = [self parseWbat:data];
    
    if (!securityToken && !wbat)
    {
        [self updateProgress:@"Couldn't get security token, please try logging in again"];
        
        done = YES;
        
        return NO;
    }
    
    [self updateProgress:@"Formatting shifts"];
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents* dateComponents = [calendar components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:[NSDate date]];
    
    // Checks Next Month for shifts
    NSString* month = [NSString stringWithFormat:@"%ld", (long) [dateComponents month] +1];
    
    NSString* year = [NSString stringWithFormat:@"%ld", (long) [dateComponents year]];
    
    // Adjusting month and year used used for setting the second month we will check for scheduled shifts
    if ([month isEqualToString:@"13"])
    {
        month = @"01";
        
        year = [NSString stringWithFormat:@"%ld", (long) [dateComponents year] + 1];
    } else if ([month length] == 1) {
        month = [NSString stringWithFormat:@"0%@", month];
    }
    
    // Formatting the date we will be telling the PostData and caldendar page on MyTLC to get the second month of shifts.
    NSString* date = [NSString stringWithFormat:@"%@/%@", month, year];
    
    [self updateProgress:@"Creating parameters for second schedule"];
    
    // Creates the parameters needed to check the next month for a schedule
    params = [self createParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"pageAction", date, @"NEW_MONTH_YEAR", securityToken, @"secureToken", wbat, @"wbat", @"0", @"selectedTocId", @"0", @"parentID", @"false", @"homePageButtonWasSelected", @"", @"bid1_action", @"0", @"bid1_current_row", @"", @"STATUS_MESSAGE_HIDDEN", @"0", @"wbXpos", @"0", @"wbYpos", nil]];
    
    if (!params)
    {
        [self updateProgress:@"Couldn't create second parameters, please try again"];
        
        done = YES;
        
        return NO;
    }
    
    [self updateProgress:@"Checking for more shifts..."];
    
    // Gets the data results back from retreiving the second months schedule
    data = [self postData:@"https://mytlc.bestbuy.com/etm/time/timesheet/etmTnsMonth.jsp" params:params];
    
    if (!data)
    {
        [self updateProgress:@"Couldn't get second schedule, please try again later"];
        
        done = YES;
        
        return NO;
    }
    
    [self updateProgress:@"Parsing second schedule"];
    
    NSMutableArray* shifts2 = [self parseSchedule:data];
    
    
    // Counts how many shifts are in the Second Month
    if ([shifts2 count] > 0)
    {
        [shifts addObjectsFromArray:shifts2];
    }
    
    // Counts how many shifts are in the Current Month
    if ([shifts count] > 0)
    {
        [self updateProgress:@"Adding shifts to calendar"];
        
        
        [self checkCalendarAccess:shifts];
        [self displayAllShifts:shifts];
    }
    else
    {
        [self updateProgress:@"No shifts to update"];
        
        done = YES;
    }
    
    // Logs out as to not keep the Scheduled System logged in, not needed anymore
    [self getData:@"https://mytlc.bestbuy.com/etm/etmMenu.jsp?pageAction=logout"];
    
    // Clears the Username and Password strings after checking the schedule to make sure all credentials are cleared when not needed
    //username = @"";
    password = @"";
    
    return YES;
}

- (void) setMessageRead
{
    newMessageExists = NO;
}


// Updates the Progress Notification Label on Home Screen of the App
- (void) updateProgress:(NSString*) newMessage
{
    message = newMessage;
    
    newMessageExists = YES;
}

@end
