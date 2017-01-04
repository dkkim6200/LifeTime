//
//  TimerViewController.h
//  LifeTime
//
//  Created by Danny Lee on 2016-12-27.
//  Copyright © 2016 DaekunKim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;

@property (weak, nonatomic) IBOutlet UILabel *timerLbl;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (weak, nonatomic) IBOutlet UIButton *resetBtn;

@property (weak, nonatomic) IBOutlet UILabel *categoryLbl;

@end
