//
//  EffViewController.h
//  LifeTime
//
//  Created by Danny Lee on 2017-01-10.
//  Copyright © 2017 DaekunKim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"

@interface EfficiencyViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *description;

@property NSTimeInterval duration;

@property (strong, nonatomic) NSString *efficiency;

@end
