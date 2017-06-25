//
//  GraphViewController.m
//  LifeTime
//
//  Created by Danny Lee on 2017-05-13.
//  Copyright © 2017 DaekunKim. All rights reserved.
//

#import "GraphViewController.h"
#import "LifeTime-Swift.h"
#import "DBManager.h"
@import Charts;

@interface GraphViewController () <ChartViewDelegate>
@property (weak, nonatomic) IBOutlet BarChartView *barChartView;
@property (weak, nonatomic) IBOutlet PieChartView *pieChartView;

@property (weak, nonatomic) IBOutlet UILabel *dailyAvgEff;
@property (weak, nonatomic) IBOutlet UILabel *dailyMsg;
@end

@implementation GraphViewController {
    NSArray *activities;
    NSMutableArray *categories;
    int lastSameDayActivitiesIndex;
}

@synthesize modeSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DBManager *dbManager1 = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
    NSString *selectActivitiesQuery = [NSString stringWithFormat:@"SELECT * FROM activities"];
    activities = [dbManager1 loadDataFromDB:selectActivitiesQuery];
    NSLog(@"%@\n%@\n\n\n", selectActivitiesQuery, activities);
//    NSLog(@"%@ activities: ", activities);

    // re-reading from db, because dbManger code is bad
    DBManager *dbManager2 = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
    NSString *categoriesQuery = [NSString stringWithFormat:@"%@", @"SELECT * FROM categories"];
    NSArray *result = [[NSArray alloc] initWithArray:[dbManager2 loadDataFromDB:categoriesQuery]];
    
    // make a categories array with the categories inside
    categories = [[NSMutableArray alloc] initWithCapacity:result.count];
    for (int i = 0; i < result.count; i++) {
        [categories addObject:[result[i] objectAtIndex:1]];
    }
    NSLog(@"%@ categories: ", categories);
    
    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Values"},
                     @{@"key": @"toggleIcons", @"label": @"Toggle Icons"},
                     @{@"key": @"toggleHighlight", @"label": @"Toggle Highlight"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"togglePinchZoom", @"label": @"Toggle PinchZoom"},
                     @{@"key": @"toggleAutoScaleMinMax", @"label": @"Toggle auto scale min/max"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     @{@"key": @"toggleBarBorders", @"label": @"Show Bar Borders"},
                     ];
    
    // SET UP BAR CHART
    [self setupBarLineChartView:_barChartView];
    _barChartView.delegate = self;
    
    _barChartView.drawBarShadowEnabled = NO;
    _barChartView.drawValueAboveBarEnabled = YES;
    
    _barChartView.maxVisibleCount = 60;

    ChartXAxis *xAxis = _barChartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.granularity = 1.0; // only intervals of 1 day
    xAxis.labelCount = 7;
//    xAxis.valueFormatter = [[DayAxisValueFormatter alloc] initForChart:_chartView];
    
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 1;
    leftAxisFormatter.negativeSuffix = @" %"; // percentage on the sides
    leftAxisFormatter.positiveSuffix = @" %";
    
    ChartYAxis *leftAxis = _barChartView.leftAxis;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 8;
    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.15;
    leftAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    
    ChartYAxis *rightAxis = _barChartView.rightAxis;
    rightAxis.enabled = YES;
    rightAxis.drawGridLinesEnabled = NO;
    rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
    rightAxis.labelCount = 8;
    rightAxis.valueFormatter = leftAxis.valueFormatter;
    rightAxis.spaceTop = 0.15;
    rightAxis.axisMinimum = 0.0; // this replaces startAtZero = YES
    
    ChartLegend *l1 = _barChartView.legend;
    l1.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
    l1.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    l1.orientation = ChartLegendOrientationHorizontal;
    l1.drawInside = NO;
    l1.form = ChartLegendFormSquare;
    l1.formSize = 9.0;
    l1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    l1.xEntrySpace = 4.0;
    
//    XYMarkerView *marker = [[XYMarkerView alloc]
//                            initWithColor: [UIColor colorWithWhite:180/255. alpha:1.0]
//                            font: [UIFont systemFontOfSize:12.0]
//                            textColor: UIColor.whiteColor
//                            insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)
//                            xAxisValueFormatter: _chartView.xAxis.valueFormatter];
//    marker.chartView = _barChartView;
//    marker.minimumSize = CGSizeMake(80.f, 40.f);
//    _barChartView.marker = marker;
    
    // SET UP PIE CHART
    [self setupPieChartView:_pieChartView];

    _pieChartView.delegate = self;
    
//    ChartLegend *l2 = _pieChartView.legend;
//    l2.horizontalAlignment = ChartLegendHorizontalAlignmentRight;
//    l2.verticalAlignment = ChartLegendVerticalAlignmentTop;
//    l2.orientation = ChartLegendOrientationVertical;
//    l2.drawInside = NO;
//    l2.xEntrySpace = 7.0;
//    l2.yEntrySpace = 0.0;
//    l2.yOffset = 0.0;
    
    // entry label styling
    _pieChartView.entryLabelColor = UIColor.whiteColor;
    _pieChartView.entryLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    [_pieChartView animateWithXAxisDuration:1.4 easingOption:ChartEasingOptionEaseOutBack];
    [self updateChartData];
    [self calcDailyAvgEff];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChartData
{
    if (self.shouldHideData)
    {
        _barChartView.data = nil;
        _pieChartView.data = nil;
        return;
    }
    
//    [self setBarDataCount:_sliderX.value * 15 range:_sliderY.value * 100];
//    [self setBarDataCount:7 range:100];//arbitary values
    [self drawPieChart:[self setActivitiesPieData:@"day"]];
}

//------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------drawing graphs----------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawBarChart:(NSMutableArray*) values {
    int count = 7;
    int range = 100;
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    int startingDataIndex = 1;
    
    for (int i = startingDataIndex; i < startingDataIndex + count; i++)
    {
        double mult = (range + 1);
        double val = (double) (arc4random_uniform(mult));
        if (arc4random_uniform(100) < 25) {
            [yVals addObject:[[BarChartDataEntry alloc] initWithX:i y:val icon: [UIImage imageNamed:@"icon"]]];
        } else {
            [yVals addObject:[[BarChartDataEntry alloc] initWithX:i y:val]];
        }
    }
    
    BarChartDataSet *set1 = nil;
    if (_barChartView.data.dataSetCount > 0)
    {
        set1 = (BarChartDataSet *)_barChartView.data.dataSets[0];
        set1.values = yVals;
        [_barChartView.data notifyDataChanged];
        [_barChartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[BarChartDataSet alloc] initWithValues:yVals label:@"The year 2017"];
        [set1 setColors:ChartColorTemplates.material];
        set1.drawIconsEnabled = NO;
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
        [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
        
        data.barWidth = 0.9f;
        
        _barChartView.data = data;
    }
    _barChartView.legend.enabled = FALSE;
}

- (void)drawPieChart: (NSMutableArray *) values {
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:values];
    dataSet.drawIconsEnabled = YES;
    
    dataSet.sliceSpace = 2.0;
    dataSet.iconsOffset = CGPointMake(0, 40);
    
    // add a lot of colors
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObjectsFromArray:ChartColorTemplates.vordiplom];
    [colors addObjectsFromArray:ChartColorTemplates.joyful];
    [colors addObjectsFromArray:ChartColorTemplates.colorful];
    [colors addObjectsFromArray:ChartColorTemplates.liberty];
    [colors addObjectsFromArray:ChartColorTemplates.pastel];
    [colors addObject:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
    
    dataSet.colors = colors;
    
    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];
    
    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 0; // percentage decimal
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    pFormatter.zeroSymbol = @""; // getting rid of all the zero values
    [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.f]];
    [data setValueTextColor:UIColor.whiteColor];
    
    _pieChartView.data = data;
    _pieChartView.legend.enabled = FALSE; // disabling the legends (litle squares)
    [_pieChartView highlightValues:nil];

}
//------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------organizing data----------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
- (NSMutableArray *)setActivitiesPieData: (NSString *) period {
    int subIndex = 0; // this is the substring index
    if ([period isEqualToString: @"day"]) {
        subIndex = 11;
    }
    if ([period isEqualToString: @"month"]) {
        subIndex = 7;
    }
    if ([period isEqualToString: @"year"]) {
        subIndex = 4;
    }
    
    NSMutableArray *pieChartValues = [[NSMutableArray alloc] init];
    for (int i = 0; i < categories.count; i++) {
        [pieChartValues addObject:[NSNumber numberWithInt:0]];
    }
//    bool check = [[NSCalendar currentCalendar] isDateInToday:date];
    int index = (int)[activities count]-1;
    NSLog(@"activities INDEX: %d", index);
    
    NSString* format = @"yyyy-MM-dd HH:mm:ss";
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setDateFormat:format];
    [df_local setTimeZone:[NSTimeZone localTimeZone]];

    // substring of the string format of the unix time in activities array
    NSString *subUnixTimeString = [[df_local stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[activities objectAtIndex:index][5] doubleValue]]] substringWithRange:NSMakeRange(0, subIndex)];
    NSLog(@" %@", subUnixTimeString);

    // substring of string format of the current unix time
    NSString *subCurTimeString = [[df_local stringFromDate:[NSDate date]] substringWithRange:NSMakeRange(0, subIndex)];
    NSLog(@" %@", subCurTimeString);
    
    while ([subUnixTimeString isEqualToString:subCurTimeString] && index > 0) {
        index--;
//        NSLog (@" %d", index);
        subUnixTimeString = [[df_local stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[activities objectAtIndex:index][5] doubleValue]]] substringWithRange:NSMakeRange(0, subIndex)];
    }
    lastSameDayActivitiesIndex = index; // This index is where the given period stops (day, week, month...etc)
    NSLog(@" finalTodayIndex: %d", index);
    
    for (int i = 0; i < pieChartValues.count; i++) {
//        for (NSArray *obj in activities) {
        for (int j = (int)activities.count-1; j > index; j--) {
            if (i == [[activities objectAtIndex:j][1] intValue]) { // if the category ID is the same as the activities array, add its duration to itl
                int value = [pieChartValues[i] intValue]+ [[activities objectAtIndex:j][2] intValue]; // add to the current value and replace
                [pieChartValues replaceObjectAtIndex:i withObject: [NSNumber numberWithInt:value]];
            }
        }
        if ([pieChartValues[i] intValue] != 0) { // if it's not 0, make it into PieChart Data
            [pieChartValues replaceObjectAtIndex:i withObject:[[PieChartDataEntry alloc] initWithValue:[pieChartValues[i] intValue] label:categories[i-1] icon: [UIImage imageNamed:@"icon"]]]; // categories는
        }
        else { // if it is 0, just put some dummy data in
            [pieChartValues replaceObjectAtIndex:i withObject:[[PieChartDataEntry alloc] initWithValue:0 label:@""]];
        }
    }
    return pieChartValues;
}

- (NSMutableArray *)setWeeklyActivitiesPieData {
    NSMutableArray *pieChartValues = [[NSMutableArray alloc] init];
    for (int i = 0; i < categories.count; i++) {
        [pieChartValues addObject:[NSNumber numberWithInt:0]];
    }
    //    bool check = [[NSCalendar currentCalendar] isDateInToday:date];
    int index = (int)[activities count]-1;
    NSLog(@"activities INDEX: %d", index);
    
    NSString* format = @"yyyy-MM-dd HH:mm:ss";
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setDateFormat:format];
    [df_local setTimeZone:[NSTimeZone localTimeZone]];
    
    // substring of the string format of the unix time in activities array
    NSString *subUnixTimeString = [[df_local stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[activities objectAtIndex:index][5] doubleValue]]] substringWithRange:NSMakeRange(0, 11)];
    NSLog(@" %@", subUnixTimeString);
    
    // substring of string format of the current unix time
    NSString *subCurTimeString = [[df_local stringFromDate:[NSDate date]] substringWithRange:NSMakeRange(0, 11)];
    NSLog(@" %@", subCurTimeString);
    
    while ([subUnixTimeString isEqualToString:subCurTimeString]) {
        index--;
        subUnixTimeString = [[df_local stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[activities objectAtIndex:index][5] doubleValue]]] substringWithRange:NSMakeRange(0, 11)];
    }
    lastSameDayActivitiesIndex = index;
    NSLog(@" finalTodayIndex: %d", index);
    
    for (int i = 0; i < pieChartValues.count; i++) {
        for (int j = (int)activities.count-1; j > index; j--) {
            if (i == [[activities objectAtIndex:j][1] intValue]) { // if the category ID is the same as the activities array, add its duration to it
                int value = [pieChartValues[i] intValue]+ [[activities objectAtIndex:j][2] intValue];
                [pieChartValues replaceObjectAtIndex:i withObject: [NSNumber numberWithInt:value]];
            }
        }
        if ([pieChartValues[i] intValue] != 0) { // if it's not 0, make it into PieChart Data
            [pieChartValues replaceObjectAtIndex:i withObject:[[PieChartDataEntry alloc] initWithValue:[pieChartValues[i] intValue] label:categories[i-1] icon: [UIImage imageNamed:@"icon"]]]; // feel like that i-1 is gonna be a problem, but whatever
        }
        else { // if it is 0, just put some dummy data in
            [pieChartValues replaceObjectAtIndex:i withObject:[[PieChartDataEntry alloc] initWithValue:0 label:@""]];
        }
    }
    return pieChartValues;
}
- (void) calcDailyAvgEff {
    int effSum = 0;
    int count = 0; // this is how many activities are TODAY
    for (int i = (int)activities.count-1; i > lastSameDayActivitiesIndex; i--) { // starting from the top data
        effSum += [[activities objectAtIndex:i][3] intValue];
        count++;
    }
    int effAvg = effSum / count;
    NSLog(@"effSum: %d effAvg: %d", effSum, effAvg);
    
    NSString *daily = [NSString stringWithFormat:@"You have been %d%% efficient today!", effAvg];
    NSString *msg;
    
    if (effAvg > 90) {
        msg = [NSString stringWithFormat:@"Good job! You had a really productive day!"];
    }
    else if (effAvg > 70) {
        msg = [NSString stringWithFormat:@"Hey! That was a pretty decent day!"];
    }
    else if (effAvg >50) {
        msg = [NSString stringWithFormat:@"Tommorow can be better."];
    }
    else if (effAvg <= 50) {
        msg = [NSString stringWithFormat:@"Bruh."];
    }
    _dailyAvgEff.text = daily;
    _dailyMsg.text = msg;
}

// trying to refresh when clicked
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    NSLog(@"tab clicked!");
    
    if([item.title isEqual: @"Report"])
    {
        [self viewDidLoad];
    }
}

- (void)optionTapped:(NSString *)key
{
    [super handleOption:key forChartView:_barChartView];
}
- (IBAction)modeChanged:(id)sender {
    switch (self.modeSwitch.selectedSegmentIndex) {
        case 0:
            // show daily here
            NSLog(@"daily");
            break;
        case 1:
            // show weekly here;
            NSLog(@"weekly");
            break;
        case 2:
            // show monthly here;
            NSLog(@"monthly");

            break;
        case 3:
            // show yearly here;
            NSLog(@"yearly");
            break;
        default:
            break;
    }
}

#pragma mark - Actions

#pragma mark - ChartViewDelegate


- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}
- (IBAction)pleasework:(UIButton *)sender {
    NSLog(@"chartValueNothingSelected");

}

@end
