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
@property (strong, nonatomic) NSTimer *painter; // updates the timer with the time received from TimerViewController::timer

@property NSArray *activityCategories;
@property (strong, nonatomic) Activity *activity;

//----------------------------------------------------------------------
// timer related
//----------------------------------------------------------------------
@property BOOL resetPressed;
@property BOOL firstStartButtonPressed;
@property BOOL stopPressed;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _firstStartButtonPressed = false;
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
    
    [_startButton addTarget:self action:@selector(startButton) forControlEvents:UIControlEventTouchUpInside];
    
    _painter = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self
                                                                    selector:@selector(paintTimer)
                                                                  userInfo:nil
                                                                   repeats:YES];
    
    _activity = [[Activity alloc] init];
    
    _descriptionTextField.delegate = self;
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
    
    // Format the elapsed time and set it to the timerLable
    NSString *timeString = [dateFormatter stringFromDate:currentTime];
    _timerLabel.text = timeString;
}

- (IBAction)categorySelectButton:(id)sender {
    
    int row;
    row = [_categoryPicker selectedRowInComponent:0];
    NSString *selectedCategory = [_activityCategories objectAtIndex:row];
    [_activity setCategory: selectedCategory];
    NSLog (@"selected activity: %@", selectedCategory);
    
    [_categoryPicker setAlpha:0]; // if ok button is pressed, picker "dissappears" = transparent
    [_categoryLabel setEnabled:true];
    [_categoryLabel setAlpha:1];
    _categoryLabel.text = selectedCategory;
    
    NSLog(@"_categoryLabel.text length %lu",[_categoryLabel.text length]);
    if ([_categoryLabel.text length] != 0) {
        [_categorySelectButton setAlpha:0];
    }
}

- (IBAction)startButton:(id)sender {
    NSLog(@"categoryLabel.text length %lu",[_categoryLabel.text length]);
    NSLog(@"_descriptionTextField.text length %lu",[_descriptionTextField.text length]);

    if ([_categoryLabel.text length] != 0 && [_descriptionTextField.text length] != 0) {
        if([[(UIButton *)sender currentTitle]isEqualToString:@"S T A R T"]) {
            
            // same codes are required when reset button was pressed and when the timer is initially started
            
            // THIS IS WHEN START BUTTON IS PRESSED WHILE RESET OR FIRST TIME STARTING THE TIMER
            if (_resetPressed || !_firstStartButtonPressed) {
                _firstStartButtonPressed = true;
                _resetPressed = false;
                _stopPressed = false;
                [_timer resetTimer];
                [_timer startTimer];
                
            }
            // THIS IS WHEN START BUTTON IS PRESSED WITHOUT RESET OR WHEN IT'S NOT FIRST TIME STARTING
            if (_stopPressed && !_resetPressed) {
                _stopPressed = false;
                [_timer resumeTimer];
                
                // resetButton disappeared
                [_resetButton setEnabled:NO];
                [_resetButton setTitle:@"" forState:UIControlStateNormal];
                
                [_finishButton setEnabled: NO];
                [_finishButton setTitle:@"" forState:UIControlStateNormal];
                
                [_descriptionTextField setEnabled:true];
                
                
            }
            
            // change the button text to STOP
            [sender setTitle:@"S T O P" forState:UIControlStateNormal];
        }
        
        // THIS IS WHEN STOP BUTTON IS PRESSED
        else if([[(UIButton *)sender currentTitle]isEqualToString:@"S T O P"]){
            _stopPressed = true;
            
            [_timer pauseTimer];
            
            // resetButton appear
            [_resetButton setEnabled:YES];
            [_resetButton setTitle:@"R E S E T" forState:UIControlStateNormal];
            
            [_finishButton setEnabled:YES];
            [_finishButton setTitle:@"F I N I S H" forState:UIControlStateNormal];
            
            // change the button text to START
            [sender setTitle:@"S T A R T" forState:UIControlStateNormal];
        }
    }
    else {
        NSLog(@"Must fill the category or the description to start timer!!");
        return;
    }
}

- (IBAction)resetButton:(id)sender {
    _resetPressed = true;
    [_timer resetTimer]; // redundant??????????????????????????????????????????????????????????????????????
//    _timerLabel.text = @"00:00";
    
    
    // resetButton disappeared
    [_resetButton setEnabled:NO];
    [_resetButton setTitle:@"" forState:UIControlStateNormal];
    
    [_finishButton setEnabled: NO];
    [_finishButton setTitle:@"" forState:UIControlStateNormal];
    
    
    // emptying the category Lable and the description field
    _categoryLabel.text = @"";
    _descriptionTextField.text = @"";
    
    // make everything visible
    
    [_categoryPicker reloadAllComponents];
    [_categoryPicker selectRow:0 inComponent:0 animated:YES];
    [_categoryPicker setAlpha:1];
    
    [_categorySelectButton setAlpha:1];
    [_descriptionTextField setAlpha:1];
}

- (IBAction)finishButton:(id)sender {
    NSLog(@"finish button clicked!");
    
    [self resetButton:NULL];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EfficiencyView"];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:vc animated:YES completion:NULL];
    
    NSLog(@"finish button process complete!");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.accessibilityLabel isEqual: @"Desc"]) {
        NSLog(@"description done button clicked!");
        
        if ([_descriptionTextField.text length] != 0) {
            NSString *description = _descriptionTextField.text;
            NSLog(@"description: %@", description);
            
            [_activity setDesc: description];
//            [_descTxtField setAlpha:0];
            
            NSLog(@"description done process complete!");
        }
    }
    
    [textField resignFirstResponder];
    return YES;
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
