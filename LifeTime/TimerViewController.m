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
    
    _categoryPicker.dataSource = self;
    _categoryPicker.delegate = self;
    
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

- (IBAction)startBtn:(id)sender {
    if([[(UIButton *)sender currentTitle]isEqualToString:@"S T A R T"]) {
        
        // same codes are required when reset button was pressed and when the timer is initially started
        
        // THIS IS WHEN START BUTTON IS PRESSED WHILE RESET OR FIRST TIME PRESSING
        if (_resetPressed || !_firstStartBtnPressed) {
            _firstStartBtnPressed = true;
            _resetPressed = false;
            _stopPressed = false;
            [_timer resetTimer];
            [_timer startTimer];

        }
        // THIS IS WHEN START BUTTON IS PRESSED WITHOUT RESET OR FIRST TIME PRESSING
        if (_stopPressed && !_resetPressed) {
            _stopPressed = false;
            [_timer resumeTimer];
            
            // resetBtn disappeared
            [_resetBtn setEnabled:NO];
            [_resetBtn setTitle:@"" forState:UIControlStateNormal];
            
            [_saveBtn setEnabled: NO];
            [_saveBtn setTitle:@"" forState:UIControlStateNormal];

        }
        
        // change the button text to STOP
        [sender setTitle:@"S T O P" forState:UIControlStateNormal];
        
        
    }
    
    // THIS IS WHEN STOP BUTTON IS PRESSED
    else if([[(UIButton *)sender currentTitle]isEqualToString:@"S T O P"]){
        _stopPressed = true;
        
        [_timer pauseTimer];
        
        // resetBtn appear
        [_resetBtn setEnabled:YES];
        [_resetBtn setTitle:@"R E S E T" forState:UIControlStateNormal];

        [_saveBtn setEnabled:YES];
        [_saveBtn setTitle:@"S A V E" forState:UIControlStateNormal];

        // change the button text to START
        [sender setTitle:@"S T A R T" forState:UIControlStateNormal];
    }
}

- (IBAction)resetBtn:(id)sender {
    _resetPressed = true;
    [_timer resetTimer]; // redundant??????????????????????????????????????????????????????????????????????
//    _timerLbl.text = @"00:00";
    
    
    // resetBtn disappeared
    [_resetBtn setEnabled:NO];
    [_resetBtn setTitle:@"" forState:UIControlStateNormal];
    
    [_saveBtn setEnabled: NO];
    [_saveBtn setTitle:@"" forState:UIControlStateNormal];
}

- (IBAction)categorySelectBtn:(id)sender {
    int row;
    row = [_categoryPicker selectedRowInComponent:0];
    NSString *selectedCategory = [_activityCategories objectAtIndex:row];
    [_activity setCategory: selectedCategory];
    
    NSLog (@"selected activity: %@", selectedCategory);
    
//    [_activityCategoryPicker setUserInteractionEnabled:false];
    [_categoryPicker setAlpha:0]; // if ok button is pressed, picker "dissappears" = transparent
    [_categoryLbl setEnabled:true];
    [_categoryLbl setAlpha:1];
    _categoryLbl.text = selectedCategory;
    
}

- (IBAction)saveBt:(id)sender {
    NSLog(@"save button clicked!");

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EffView"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:NULL];
    
    NSLog(@"save button process complete!");
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
