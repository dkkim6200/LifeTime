//
//  TimerViewController.m
//  LifeTime
//
//  Created by Danny Lee on 2016-12-27.
//  Copyright © 2016 DaekunKim. All rights reserved.
//

#import "TimerViewController.h"

@interface TimerViewController () {
    NSArray *activityCategories;
    BOOL resetPressed;
}
@property (strong, nonatomic) NSTimer *timer; // Store the timer that fires after a certain time
@property (strong, nonatomic) NSDate *startDate; // Stores the date of the click on the start button

@end

@implementation TimerViewController

//@synthesize startBtn = _startBtn;
//@synthesize startStopButtonIsActive = _startStopButtonIsActive;

- (void)viewDidLoad {
    [super viewDidLoad];
//    [_startBtn setExclusiveTouch:YES];
//    [_resetBtn setExclusiveTouch:YES];

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

- (void)updateTimer
{
    // Create date from the elapsed time
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"]; // minute과 second로 이루어져있음
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Format the elapsed time and set it to the timerLbl
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    self.timerLbl.text = timeString;
}
- (IBAction)startBtn:(id)sender {
    NSLog(@"startBtn Pressed!");
    resetPressed = false;
    
    if([[(UIButton *)sender currentTitle]isEqualToString:@"START"]) {
        NSLog(@"equalToString: start!");
        if (!resetPressed) {
            NSLog(@"!resetPressed");
            //start the action here
            self.startDate = [NSDate date];
            // Create a stopwatch timer that fires every 100 ms
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                          target:self
                                                        selector:@selector(updateTimer)
                                                        userInfo:nil
                                                         repeats:YES];
        }
        else {
            NSLog(@"resetPressed!");
            resetPressed = false;
            [_resetBtn setEnabled:NO];
            [_resetBtn setTitle:@"" forState:UIControlStateNormal];

            [self updateTimer];
        }
        
        
        // change the button text to STOP
        [sender setTitle:@"STOP" forState:UIControlStateNormal];
    }
    else if([[(UIButton *)sender currentTitle]isEqualToString:@"STOP"]){
        NSLog(@"equalToString: stop!");
        
        [_resetBtn setEnabled:YES];
        [_resetBtn setTitle:@"RESET" forState:UIControlStateNormal];
        
        // stop the action here
        [self.timer invalidate];
        //        self.timer = nil;
        //        [self updateTimer];
        
        // change the button text to START
        [sender setTitle:@"START" forState:UIControlStateNormal];
    }
}

- (IBAction)resetBtn:(id)sender {
    NSLog(@"resetBtn");
    
    [self.timer invalidate];
    self.timer = nil;
    self.startDate = [NSDate date];
    [self updateTimer];
    resetPressed = true;
    
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
