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

@property (weak, nonatomic) IBOutlet UITextField *descTxtField;

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
    NSLog(@"categoryLbl.text length %lu",[_categoryLbl.text length]);
    NSLog(@"_descLbl.text length %lu",[_descLbl.text length]);

    if ([_categoryLbl.text length] != 0 && [_descLbl.text length] != 0) {
        if([[(UIButton *)sender currentTitle]isEqualToString:@"S T A R T"]) {
            
            // same codes are required when reset button was pressed and when the timer is initially started
            
            // THIS IS WHEN START BUTTON IS PRESSED WHILE RESET OR FIRST TIME STARTING THE TIMER
            if (_resetPressed || !_firstStartBtnPressed) {
                _firstStartBtnPressed = true;
                _resetPressed = false;
                _stopPressed = false;
                [_timer resetTimer];
                [_timer startTimer];
                
            }
            // THIS IS WHEN START BUTTON IS PRESSED WITHOUT RESET OR WHEN IT'S NOT FIRST TIME STARTING
            if (_stopPressed && !_resetPressed) {
                _stopPressed = false;
                [_timer resumeTimer];
                
                // resetBtn disappeared
                [_resetBtn setEnabled:NO];
                [_resetBtn setTitle:@"" forState:UIControlStateNormal];
                
                [_finishBtn setEnabled: NO];
                [_finishBtn setTitle:@"" forState:UIControlStateNormal];
                
                [_descTxtField setEnabled:true];
                
                
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
            
            [_finishBtn setEnabled:YES];
            [_finishBtn setTitle:@"F I N I S H" forState:UIControlStateNormal];
            
            // change the button text to START
            [sender setTitle:@"S T A R T" forState:UIControlStateNormal];
        }
    }
    else {
        NSLog(@"Must fill the category or the description to start timer!!");
        return;
    }
}

- (IBAction)resetBtn:(id)sender {
    _resetPressed = true;
    [_timer resetTimer]; // redundant??????????????????????????????????????????????????????????????????????
//    _timerLbl.text = @"00:00";
    
    
    // resetBtn disappeared
    [_resetBtn setEnabled:NO];
    [_resetBtn setTitle:@"" forState:UIControlStateNormal];
    
    [_finishBtn setEnabled: NO];
    [_finishBtn setTitle:@"" forState:UIControlStateNormal];
    
    
    // emptying the category Lable and the description field
    _categoryLbl.text = @"";
    _descTxtField.text = @"";
    _descLbl.text = @"";
    
    // make everything visible
    
    [_categoryPicker reloadAllComponents];
    [_categoryPicker selectRow:0 inComponent:0 animated:YES];
    [_categoryPicker setAlpha:1];
    
    [_categorySelectBtn setAlpha:1];
    [_descSelectBtn setAlpha:1];
    [_descTxtField setAlpha:1];
}

- (IBAction)categorySelectBtn:(id)sender {
    
    int row;
    row = [_categoryPicker selectedRowInComponent:0];
    NSString *selectedCategory = [_activityCategories objectAtIndex:row];
    [_activity setCategory: selectedCategory];
    NSLog (@"selected activity: %@", selectedCategory);
    
    [_categoryPicker setAlpha:0]; // if ok button is pressed, picker "dissappears" = transparent
    [_categoryLbl setEnabled:true];
    [_categoryLbl setAlpha:1];
    _categoryLbl.text = selectedCategory;
    
    NSLog(@"_categoryLbl.text length %lu",[_categoryLbl.text length]);
    if ([_categoryLbl.text length] != 0) {
        [_categorySelectBtn setAlpha:0];
    }
}

- (IBAction)finishBt:(id)sender {
    NSLog(@"finish button clicked!");
    
    [self resetBtn:NULL];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EffView"];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:vc animated:YES completion:NULL];
    
    NSLog(@"finish button process complete!");
}
- (IBAction)descBtn:(id)sender {
    NSLog(@"desc ok button clicked!");
    if ([_descTxtField.text length] != 0) {
        [_descSelectBtn setAlpha:0];
    }

    if ([_descTxtField.text length] != 0) {
        NSString *desc = _descTxtField.text;
        NSLog(@"description: %@", desc);
        
        [_activity setDesc: desc];
        
        [_descLbl setEnabled:true];
        [_descLbl setAlpha:1];
        _descLbl.text = desc;
        
        [_descTxtField setAlpha:0];
        
        NSLog(@"desc ok process complete!");
    }
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
