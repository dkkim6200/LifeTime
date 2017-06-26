//
//  GraphViewController.h
//  LifeTime
//
//  Created by Danny Lee on 2017-05-13.
//  Copyright © 2017 DaekunKim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DemoBaseViewController.h"
//#import <Charts/Charts.h>
@import Charts;

@interface GraphViewController : DemoBaseViewController <UITabBarDelegate> {
    
    UISegmentedControl *modeSwitch;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *modeSwitch;
@property (weak, nonatomic) IBOutlet BarChartView *barChartView;
@property (weak, nonatomic) IBOutlet PieChartView *pieChartView;


- (IBAction)modeChanged:(id)sender;

@end
