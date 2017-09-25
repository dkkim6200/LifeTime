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
#import "EfficiencyViewController.h"
#import "DBManager.h"

@interface TimerViewController ()

@property (strong, nonatomic) Timer *timer; // Store the timer that fires after a certain time
@property (strong, nonatomic) NSTimer *painter; // updates the timer with the time received from TimerViewController::timer

@property NSMutableArray *activityCategories;

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
    
    [_startButton addTarget:self action:@selector(startButton) forControlEvents:UIControlEventTouchUpInside];
    
    _painter = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self
                                                                    selector:@selector(paintTimer)
                                                                  userInfo:nil
                                                                   repeats:YES];
    
    _descriptionTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    DBManager *dbManager1 = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
    NSString *query = [NSString stringWithFormat:@"%@", @"SELECT * FROM categories"];
    NSArray *result = [[NSArray alloc] initWithArray:[dbManager1 loadDataFromDB:query]];
    
    _activityCategories = [[NSMutableArray alloc] initWithCapacity:result.count];
    for (int i = 0; i < result.count; i++) {
        [_activityCategories addObject:[[result objectAtIndex:i] objectAtIndex:1]];
    }
    
    _categoryPicker.dataSource = self;
    _categoryPicker.delegate = self;
    
    [self.view setNeedsDisplay];
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
    NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:[_timer getInterval]];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"]; // minute과 second로 이루어져있음
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Format the elapsed time and set it to the timerLable
    NSString *timeString = [dateFormatter stringFromDate:currentTime];
    _timerLabel.text = timeString;
}

- (IBAction)categorySelectButton:(id)sender {
    int row = [_categoryPicker selectedRowInComponent:0];
    NSString *selectedCategory = [_activityCategories objectAtIndex:row];
    NSLog (@"*INFO*: selected activity: %@", selectedCategory);
    
    [_categoryPicker setAlpha:0]; // if ok button is pressed, picker "dissappears" = transparent
    [_categoryLabel setEnabled:true];
    [_categoryLabel setAlpha:1];
    _categoryLabel.text = selectedCategory;
    
//    NSLog(@"_categoryLabel.text %@",_categoryLabel.text);
//    NSLog(@"_categoryLabel.text length %lu",[_categoryLabel.text length]);
    
    if ([_categoryLabel.text length] != 0) {
        [_categorySelectButton setAlpha:0];
    }
}
- (IBAction)startButton:(id)sender {
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
            NSLog(@"*INFO*: stop button clicked!");
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
        NSLog(@"*WARNING*: Must fill the category or the description to start timer!!");
        return;
    }
}

- (IBAction)resetButton:(id)sender {
    [self resetEverything];
}

- (IBAction)finishButton:(id)sender {
    NSLog(@"*INFO*: finish button clicked!");
    
//    [self resetButton:NULL]; --> 나쁜 놈
    [self performSegueWithIdentifier:@"showEfficiencySegue" sender:self];
    
    // 지금은 일단 finish 누르면 reset되게 해놨는데 보기에는 그닥 안좋음..
    // save button 누를때 reset하려면 public method 만들어야 될거 같아서 그렇게 좋은 방법은 아닌듯?? 모르겠다.. further discussion is required
    [self resetEverything];
}

// send data to EVC
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showEfficiencySegue"]){
        EfficiencyViewController *efficiencyViewController = (EfficiencyViewController *)segue.destinationViewController;
        efficiencyViewController.category = self.categoryLabel.text;
        efficiencyViewController.desc = self.descriptionTextField.text;
        efficiencyViewController.duration = [self.timer getInterval];
    }
}

- (void)resetEverything {
    _resetPressed = true;
    [_timer resetTimer]; // redundant??????????????????????????????????????????????????????????????????????
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.accessibilityLabel isEqual: @"Desc"]) {
        if ([_descriptionTextField.text length] != 0) {
            NSString *description = _descriptionTextField.text;
            NSLog(@"*INFO*: description: %@", description);
        }
    }
    
    [textField resignFirstResponder];
    return YES;
}
@end
