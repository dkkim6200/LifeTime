//
//  TimerViewController.m
//  LifeTime
//
//  Created by Danny Lee on 2016-12-27.
//  Copyright © 2016 DaekunKim. All rights reserved.
//

#import "TimerViewController.h"

@interface TimerViewController () {

}
@property (strong, nonatomic) NSTimer *timer; // Store the timer that fires after a certain time

@end

@implementation TimerViewController {
    NSArray *activityCategories;
    
    //----------------------------------------------------------------------
    // timer related
    //----------------------------------------------------------------------
    BOOL resetPressed;
    BOOL firstStartBtnPressed;
    BOOL stopPressed;
    NSTimeInterval pauseResumeInterval;
    NSDate *pausedTime, *resumedTime, *initialStartTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    firstStartBtnPressed = false;
    resetPressed = false;
    stopPressed = false;
    
    activityCategories = @[@"Work",
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
    
    self.activityCategoryPicker.dataSource = self;
    self.activityCategoryPicker.delegate = self;
    
    [_startBtn addTarget:self action:@selector(startBtn) forControlEvents:UIControlEventTouchUpInside];

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
    return activityCategories.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return activityCategories[row];
}

// timer를 그리는 아이
- (void)updateTimer {
    // Create date from the elapsed time
    NSDate *currentDate = [NSDate date];
    
    // Timer time = current time - intial time - pausedInterval
    NSTimeInterval timeInterval =
    [currentDate timeIntervalSinceDate:[initialStartTime dateByAddingTimeInterval: pauseResumeInterval]];
//    NSLog(@"timeInterval: %f", timeInterval);
    
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"]; // minute과 second로 이루어져있음
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Format the elapsed time and set it to the timerLbl
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    self.timerLbl.text = timeString;
}

-(void) pauseTimer {
    // save the time where the timer was paused
    pausedTime = [NSDate date];
    
    // actually pause the timer
    [self.timer setFireDate:[NSDate distantFuture]];
}

-(void) resumeTimer {
    // save the time where the timer was resumed
    resumedTime = [NSDate date];
    
    // calculate the amount of total time the timer was paused
    pauseResumeInterval += [resumedTime timeIntervalSinceDate:pausedTime];
    
    [self initTimer];
}

-(void) initTimer {
    [self.timer invalidate];
    self.timer = nil;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];
}

- (IBAction)startBtn:(id)sender {
    if([[(UIButton *)sender currentTitle]isEqualToString:@"START"]) {
        
        // same codes are required when reset button was pressed and when the timer is initially started
        if (resetPressed || !firstStartBtnPressed) {
            firstStartBtnPressed = true;
            resetPressed = false;
            stopPressed = false;
            
            initialStartTime = [NSDate date];
            pauseResumeInterval = 0;
            
            [self initTimer];
        }
        
        if (stopPressed && !resetPressed) {
            stopPressed = false;
            [self resumeTimer];
            
            // resetBtn disappeared
            [_resetBtn setEnabled:NO];
            [_resetBtn setTitle:@"" forState:UIControlStateNormal];
        }
        
        // change the button text to STOP
        [sender setTitle:@"STOP" forState:UIControlStateNormal];
        
        
    }
    
    else if([[(UIButton *)sender currentTitle]isEqualToString:@"STOP"]){
        stopPressed = true;
        
        [self pauseTimer];
        
        // resetBtn appear
        [_resetBtn setEnabled:YES];
        [_resetBtn setTitle:@"RESET" forState:UIControlStateNormal];

        // change the button text to START
        [sender setTitle:@"START" forState:UIControlStateNormal];
    }
}

- (IBAction)resetBtn:(id)sender {
    resetPressed = true;
    self.timerLbl.text = @"00:00";
    
    // resetBtn disappeared
    [_resetBtn setEnabled:NO];
    [_resetBtn setTitle:@"" forState:UIControlStateNormal];
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
