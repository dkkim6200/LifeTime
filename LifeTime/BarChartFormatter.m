//
//  BarChartFormatter.m
//  LifeTime
//
//  Created by Danny Lee on 2017-06-28.
//  Copyright © 2017 DaekunKim. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Charts;


@interface BarChartFormatter: NSObject <IChartAxisValueFormatter> {
}

@end

@implementation BarChartFormatter {
    NSArray *weekdays;

}

-(NSString *) stringForValue: (double) value axis: (ChartAxisBase *) axisBase {
     weekdays = [NSArray arrayWithObjects: @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun", nil];
    
    return weekdays[(int)value];
}
@end
