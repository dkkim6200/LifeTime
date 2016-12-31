//
//  TimerViewController.m
//  LifeTime
//
//  Created by Danny Lee on 2016-12-27.
//  Copyright © 2016 DaekunKim. All rights reserved.
//

#import "Timer.h"
#import "TimerViewController.h"

@interface TimerViewController () {

}
@property (strong, nonatomic) Timer *timer; // Store the timer that fires after a certain time

@property (strong, nonatomic) NSTimer *painter; // updates the timer with the time received from Timer.m
@end

@implementation TimerViewController {
    NSArray *activityCategories;
    
    //----------------------------------------------------------------------
    // timer related
    //----------------------------------------------------------------------
    BOOL resetPressed;
    BOOL firstStartBtnPressed;
    BOOL stopPressed;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    firstStartBtnPressed = false;
    resetPressed = false;
    stopPressed = false;
    self.timer = [[Timer alloc] init];

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
    
    self.painter = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self
                                                                    selector:@selector(paintTimer)
                                                                  userInfo:nil
                                                                   repeats:YES];
    
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

-(void) paintTimer {
    NSDate *currentTime = [self.timer getTime];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"]; // minute과 second로 이루어져있음
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Format the elapsed time and set it to the timerLbl
    NSString *timeString = [dateFormatter stringFromDate:currentTime];
    self.timerLbl.text = timeString;
}

- (IBAction)startBtn:(id)sender {
    if([[(UIButton *)sender currentTitle]isEqualToString:@"START"]) {
        
        // same codes are required when reset button was pressed and when the timer is initially started
        if (resetPressed || !firstStartBtnPressed) {
            firstStartBtnPressed = true;
            resetPressed = false;
            stopPressed = false;
            [self.timer resetTimer];
            [self.timer startTimer];

        }
        
        if (stopPressed && !resetPressed) {
            stopPressed = false;
            [self.timer resumeTimer];
            
            // resetBtn disappeared
            [_resetBtn setEnabled:NO];
            [_resetBtn setTitle:@"" forState:UIControlStateNormal];
        }
        
        // change the button text to STOP
        [sender setTitle:@"STOP" forState:UIControlStateNormal];
        
        
    }
    
    else if([[(UIButton *)sender currentTitle]isEqualToString:@"STOP"]){
        stopPressed = true;
        
        [self.timer pauseTimer];
        
        // resetBtn appear
        [_resetBtn setEnabled:YES];
        [_resetBtn setTitle:@"RESET" forState:UIControlStateNormal];

        // change the button text to START
        [sender setTitle:@"START" forState:UIControlStateNormal];
    }
}

- (IBAction)resetBtn:(id)sender {
    resetPressed = true;
    [self.timer resetTimer]; // redundant??????????????????????????????????????????????????????????????????????
//    self.timerLbl.text = @"00:00";
    
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
