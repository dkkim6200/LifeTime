//
//  EffViewController.m
//  LifeTime
//
//  Created by Danny Lee on 2017-01-10.
//  Copyright © 2017 DaekunKim. All rights reserved.
//

#import "EfficiencyViewController.h"
#import "EFCircularSlider.h"
#import "DBManager.h"

@interface EfficiencyViewController ()

@end

@implementation EfficiencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#define SLIDER_SIZE 300
    
    CGRect sliderFrame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - SLIDER_SIZE) / 2,
                                    ([[UIScreen mainScreen] bounds].size.height - SLIDER_SIZE) / 2,
                                    SLIDER_SIZE,
                                    SLIDER_SIZE);
    EFCircularSlider* circularSlider = [[EFCircularSlider alloc] initWithFrame:sliderFrame];
    [circularSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSArray* labels = @[@"10", @"20", @"30", @"40", @"50", @"60", @"70", @"80", @"90", @"0"];
    [circularSlider setInnerMarkingLabels:labels];
    
    circularSlider.labelFont = [UIFont systemFontOfSize:14.0f];
    circularSlider.lineWidth = 14;
    
    [self.view addSubview:circularSlider];
}

-(void)valueChanged:(EFCircularSlider*)slider {
    _percentageLabel.text = [NSString stringWithFormat:@"%.0f%%", slider.currentValue];
    
//    NSLog(@"%@", [NSString stringWithFormat:@"%.0f", slider.currentValue ]);
}

- (IBAction)saveButtonPressed:(id)sender {
    NSLog(@"*INFO*: save button pressed!");
    
    _efficiency = [_percentageLabel.text intValue];
    _percentageLabel.text = nil;
    
    NSLog(@"*INFO*: eff category: %@", self.category);
    NSLog(@"*INFO*: eff description: %@", self.desc);
    NSLog(@"*INFO*: eff duration: %f", self.duration);
    NSLog(@"*INFO*: efficiency: %li%%", (long)self.efficiency);
    
    DBManager *dbManager2 = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
    
    NSString *findCategoryIndexQuery = [NSString stringWithFormat:@"SELECT * FROM categories WHERE name LIKE \"%@\" ORDER BY cat_order", _category];
    int categoryIndex = [[[[dbManager2 loadDataFromDB:findCategoryIndexQuery] objectAtIndex:0] objectAtIndex:0] intValue];
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString *finishDateString = [df stringFromDate:[NSDate date]];
    NSLog(@"dateString: %@", finishDateString);
    NSString *insertActivityQuery = [NSString stringWithFormat:@"INSERT INTO activities (category_id,duration,efficiency,description,finish_time) VALUES (%d, %d, %d, \"%@\", \"%@\")", categoryIndex, (int)_duration, (int) _efficiency, _desc, finishDateString];
    [dbManager2 executeQuery:insertActivityQuery];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
