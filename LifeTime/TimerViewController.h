//
//  TimerViewController.h
//  LifeTime
//
//  Created by Danny Lee on 2016-12-27.
//  Copyright © 2016 DaekunKim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *categorySelectButton;

@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

@end
