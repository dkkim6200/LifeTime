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
@property (weak, nonatomic) IBOutlet UIView *percentageRectView;

@property (nonatomic) NSString *category;
@property (nonatomic) NSString *desc;
@property NSTimeInterval duration;
@property (nonatomic) NSInteger efficiency;

//- (id)initWithName:(NSString *)category desc:(NSString *)theDesc duration:(NSTimeInterval)theDuration;

@end
