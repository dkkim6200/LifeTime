//
//  TimerViewController.m
//  LifeTime
//
//  Created by Danny Lee on 2016-12-27.
//  Copyright © 2016 DaekunKim. All rights reserved.
//

#import "Timer.h"
#import "TimerViewController.h"
#import "Activity.h"

@interface TimerViewController ()

@property (strong, nonatomic) Timer *timer; // Store the timer that fires after a certain time
@property (strong, nonatomic) NSTimer *painter; // updates the timer with the time received from Timer.m

@property (strong, nonatomic) Activity *activity;

@property NSArray *activityCategories;

//----------------------------------------------------------------------
// timer related
//----------------------------------------------------------------------
@property BOOL resetPressed;
@property BOOL firstStartBtnPressed;
@property BOOL stopPressed;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _firstStartBtnPressed = false;
    _resetPressed = false;
    _stopPressed = false;
    _timer = [[Timer alloc] init];

    _activityCategories = @[@"Work",
                           @"Study",
                           @"Exercise",
                           @"Rest",
                           @"Eat",
                           @"Fun",
                           @"Social",
                           @"Food",
                           @"Shopping",
                           @"Religious",
                           @"Etc"];
    
    _activityCategoryPicker.dataSource = self;
    _activityCategoryPicker.delegate = self;
    
    [_startBtn addTarget:self action:@selector(startBtn) forControlEvents:UIControlEventTouchUpInside];
    
    _painter = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self
                                                                    selector:@selector(paintTimer)
                                                                  userInfo:nil
                                                                   repeats:YES];
    
    _activity = [[Activity alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Number of columns in the
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (int)pickerView:(UIPickerView *) pickerView numberOfRowsInComponent:(NSInteger)component {
    return _activityCategories.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _activityCategories[row];
}

-(void) paintTimer {
    NSDate *currentTime = [_timer getTime];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"]; // minute과 second로 이루어져있음
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Format the elapsed time and set it to the timerLbl
    NSString *timeString = [dateFormatter stringFromDate:currentTime];
    _timerLbl.text = timeString;
}
//// timer를 그리는 아이
//- (void)updateTimer {
//    // Create date from the elapsed time
//    NSDate *currentDate = [NSDate date];
//    
//    // Timer time = current time - intial time - pausedInterval
//    NSTimeInterval timeInterval =
//    [currentDate timeIntervalSinceDate:[initialStartTime dateByAddingTimeInterval: pauseResumeInterval]];
////    NSLog(@"timeInterval: %f", timeInterval);
//    
//    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
//    
//    // Create a date formatter
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"mm:ss"]; // minute과 second로 이루어져있음
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
//    
//    // Format the elapsed time and set it to the timerLbl
//    NSString *timeString = [dateFormatter stringFromDate:timerDate];
//    _timerLbl.text = timeString;
//}
//
//-(void) pauseTimer {
//    // save the time where the timer was paused
//    pausedTime = [NSDate date];
//    
//    // actually pause the timer
//    [_timer setFireDate:[NSDate distantFuture]];
//}
//
//-(void) resumeTimer {
//    // save the time where the timer was resumed
//    resumedTime = [NSDate date];
//    
//    // calculate the amount of total time the timer was paused
//    pauseResumeInterval += [resumedTime timeIntervalSinceDate:pausedTime];
//    
//    [self initTimer];
//}
//
//-(void) initTimer {
//    [_timer invalidate];s
//    _timer = nil;
//    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
//                                                  target:self
//                                                selector:@selector(updateTimer)
//                                                userInfo:nil
//                                                 repeats:YES];
//}

- (IBAction)startBtn:(id)sender {
    if([[(UIButton *)sender currentTitle]isEqualToString:@"START"]) {
        
        // same codes are required when reset button was pressed and when the timer is initially started
        if (_resetPressed || !_firstStartBtnPressed) {
            _firstStartBtnPressed = true;
            _resetPressed = false;
            _stopPressed = false;
            [_timer resetTimer];
            [_timer startTimer];

        }
        
        if (_stopPressed && !_resetPressed) {
            _stopPressed = false;
            [_timer resumeTimer];
            
            // resetBtn disappeared
            [_resetBtn setEnabled:NO];
            [_resetBtn setTitle:@"" forState:UIControlStateNormal];
        }
        
        // change the button text to STOP
        [sender setTitle:@"STOP" forState:UIControlStateNormal];
        
        
    }
    
    else if([[(UIButton *)sender currentTitle]isEqualToString:@"STOP"]){
        _stopPressed = true;
        
        [_timer pauseTimer];
        
        // resetBtn appear
        [_resetBtn setEnabled:YES];
        [_resetBtn setTitle:@"RESET" forState:UIControlStateNormal];

        // change the button text to START
        [sender setTitle:@"START" forState:UIControlStateNormal];
    }
}

- (IBAction)resetBtn:(id)sender {
    _resetPressed = true;
    [_timer resetTimer]; // redundant??????????????????????????????????????????????????????????????????????
//    _timerLbl.text = @"00:00";
    
    
    // resetBtn disappeared
    [_resetBtn setEnabled:NO];
    [_resetBtn setTitle:@"" forState:UIControlStateNormal];
}

- (IBAction)categorySelectBtn:(id)sender {
    int row;
    row = [_activityCategoryPicker selectedRowInComponent:0];
    NSString *selectedCategory = [_activityCategories objectAtIndex:row];
    [_activity setCategory: selectedCategory];
    
    NSLog (@"selected activity: %@", selectedCategory);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
