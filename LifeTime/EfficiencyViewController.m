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

//- (id)initWithName:(NSString *)category desc:(NSString *)theDesc duration:(NSTimeInterval)theDuration {
//    
////    self = [super initWithNibName:@"EfficiencyViewController" bundle:nil];
//    
////    if (self != nil) {
////    if (self = [super init]) {
//    if (self != nil) {
//        NSLog (@"copying the values");
//
//        _category = category;
//        _desc = theDesc;
//        _duration = theDuration;
//        
//        NSLog (@"eff category2: %@", _category);
//        NSLog (@"effdescription2: %@", _desc);
//        NSLog (@"eff duration2: %f", _duration);
//    }
////    NSLog (@"eff category2: %@", _category);
////    NSLog (@"effdescription2: %@", _desc);
////    NSLog (@"eff duration2: %f", _duration);
//    return self;
//}

//
//- (id)initWithName:(NSString *)category desc:(NSString *)theDesc duration:(NSTimeInterval)theDuration {
//
////    self = [super initWithNibName:@"EfficiencyViewController" bundle:nil];
//    if (self != nil) {//
//        _category = category;
//        _desc = theDesc;
//        _duration = theDuration;
//    }
//    return self;
//}

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
    NSLog(@"save button pressed!");
    
    _efficiency = [_percentageLabel.text intValue];
    _percentageLabel.text = nil;
    
    NSLog(@"efficiency: %li%%", (long)self.efficiency);
    NSLog (@"eff category2: %@", self.category);
    NSLog (@"effdescription2: %@", self.desc);
    NSLog (@"eff duration2: %f", self.duration);
    
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM categories"];
    
    NSArray *activities = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
    
//    NSLog(@"TEST!!!!!!!!!!!!! %@ ======================", [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]]);
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
