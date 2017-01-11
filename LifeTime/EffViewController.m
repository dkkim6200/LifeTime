//
//  EffViewController.m
//  LifeTime
//
//  Created by Danny Lee on 2017-01-10.
//  Copyright © 2017 DaekunKim. All rights reserved.
//

#import "EffViewController.h"
#import "EFCircularSlider.h"

@interface EffViewController ()

@end

@implementation EffViewController

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
    
    NSLog(@"%@", [NSString stringWithFormat:@"%.0f", slider.currentValue ]);
}

-(IBAction)saveBtnPressed:(id)sender {
    NSLog(@"save button clicked!");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    NSLog(@"save button process complete!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
