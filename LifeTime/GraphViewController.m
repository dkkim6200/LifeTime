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
    int lastSamePeriodActivityStartIndex;
    int lastSamePeriodActivityEndIndex;
    NSArray *weekdays;
    NSArray *weeks;
    NSArray *months;
}

@synthesize modeSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];
    weekdays = [NSArray arrayWithObjects: @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun", nil];
    weeks = [NSArray arrayWithObjects: @"Week 1", @"Month 2", @"Week 3", @"Week 4", nil];
    months = [NSArray arrayWithObjects: @"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil];

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
    
    [self setPieInterval:@"day"];
//    [self calcDailyAvgEff:lastSamePeriodActivityStartIndex endIndex:lastSamePeriodActivityEndIndex];
    [self avgEff];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChartData
{
    if (self.shouldHideData) {
        _barChartView.data = nil;
        _pieChartView.data = nil;
        return;
    }
    
//    [self drawBarChart:@"month"];
    [self drawBarChart];
//    [self drawPieChart:[self setPieData:@"day"]];
//    [self drawPieChart:[self setPieData:@"week"]];
    [self drawPieChart:@"month"];
//    [self drawPieChart:[self setPieData:@"year"]];
}

//------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------BAR CHART--------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------Draw bar chart-----------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
- (void)drawBarChart {
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    NSMutableArray *values = [[NSMutableArray alloc] init];
    values = [self parseArray:[self avgEff] time: @"week"];
    int numData = values.count;
    for (int i = 0; i < numData; i++) {
        [yVals addObject:[[BarChartDataEntry alloc] initWithX:numData-i y:[values[i] doubleValue] icon: [UIImage imageNamed:@"icon"]]]; // x values are 7-i to make the graph go from right-->left
    }
    NSLog(@" %@", yVals);

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

//------------------------------------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------Organize bar data----------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
-(NSMutableArray *) avgEff {
    NSMutableArray *avgEffValues = [[NSMutableArray alloc] init];
    for (int i = 0; i < 500; i++) { // arbitrary value
        [avgEffValues addObject:[NSNumber numberWithInt:0]];
    }
    NSDate *now = [NSDate date];
    int index = 0;
    int activitiesIndex = (int)activities.count-1;
    int effSum = 0;
    int count = 0;
    while (index < [avgEffValues count] ) {
        NSDate *activitiesDate = [NSDate dateWithTimeIntervalSince1970:[activities[activitiesIndex][5] doubleValue]];
        int diff = (int)[self daysBetweenDate:now andDate:activitiesDate];
        //        NSLog(@"##0: index: %d diff: %d", index, -diff);
        while (-diff == index && activitiesIndex > 0) {
            effSum += [activities[activitiesIndex][3] intValue];
            count++;
            activitiesIndex--;
            activitiesDate = [NSDate dateWithTimeIntervalSince1970:[activities[activitiesIndex][5] doubleValue]];
            diff = (int)[self daysBetweenDate:now andDate:activitiesDate];
            //            NSLog(@"##1: effSum: %d count: %d index: %d activitiesIndex: %d diff: %d", effSum, count, index, activitiesIndex, -diff);
        }
        if (count == 0) {
            index++;
            //            NSLog(@"##2: index: %d", index);
        }
        else {
            //            NSLog(@"##3: effSum: %d count: %d index: %d", effSum, count, index);
            [avgEffValues insertObject:[NSNumber numberWithInt:effSum/count] atIndex:index];
            effSum = 0;
            count = 0;
            index++;
        }
        //        NSLog(@"##4: index: %d diff: %d", index, -diff);
    }
    //    NSLog(@"avgEffValues: %@", avgEffValues);
    return avgEffValues;
}

-(NSMutableArray *) parseArray: (NSMutableArray *)avgEffArray time: (NSString *) period {
    int parseBoundary = 0;
    int size = 1;
    if ([period isEqualToString: @"week"]) {
        parseBoundary = 1;
        size = 7;
    }
    else if ([period isEqualToString: @"month"]) {
        parseBoundary = 7;
        size = 4;
    }
    else if ([period isEqualToString: @"year"]) {
        parseBoundary = 28;
        size = 12;
    }
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < size; i++) {
        //        NSLog(@"%zd", avgEffArray[i]);
        int sum = 0;
        for (int j = i*parseBoundary; j < (i+1)*parseBoundary; j++) {
            sum += [avgEffArray[j] intValue];
        }
        [weekArray addObject:[NSNumber numberWithInt:sum/parseBoundary]];
    }
    NSLog(@"dataArray: %@", dataArray);
    return dataArray;
}

//------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------PIE CHART--------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------Draw pie chart-----------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
//- (void)drawPieChart: (NSMutableArray *) values {
- (void)drawPieChart: (NSString *) period {
    [self setPieInterval:period];
    NSMutableArray *values = [self setPieData:lastSamePeriodActivityStartIndex endIndex:lastSamePeriodActivityEndIndex];

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
//---------------------------------------------------------Organize pie data----------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------
-(void)setPieInterval: (NSString *)period {
    int index = (int)[activities count]-1;
    NSLog(@"activities INDEX: %d", index);
    
    bool dayPeriod = false;
    int dateOffset = 0;
    if ([period isEqualToString: @"day"]) {
        dateOffset = 0;
        dayPeriod = true;
    }
    else if ([period isEqualToString: @"week"]) {
        dateOffset = 7;
    }
    else if ([period isEqualToString: @"month"]) {
        dateOffset = 28;
    }
    else if ([period isEqualToString: @"year"]) {
        dateOffset = 365;
    }
    int index1 = index;
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:now];
    
    if (!dayPeriod) {
        [components setHour:0];
        [components setMinute:0];
        [components setSecond:0];
    }
//    NSLog(@" dateOffset: %d", dateOffset);
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                          value:-dateOffset
                                                         toDate:startDate
                                                        options:0];
    double startUnixTime = [startDate timeIntervalSince1970];
    double endUnixTime = [endDate timeIntervalSince1970];
    
    NSLog(@" startUnixTime: %f \nweekBeforeStartUnixTime: %f ",startUnixTime, endUnixTime);
    double dataUnixTime = [activities[index1][5] doubleValue];
    while (dataUnixTime >= startUnixTime && index1 > 0) { // find the index that has the last activity that occurred within the same day
        index1--;
        dataUnixTime = [activities[index1][5] doubleValue];
    }
    NSLog (@" different weekday index found! the index is: %d", index1);
    int index2 = index1-1; // index2 has to start after index 1, or else while loop doesn't run
    
    while (dataUnixTime >= endUnixTime && index2 > 0) { // this finds the index all the way to the previous week
        index2--;
//        NSLog(@" we in bois, index2: %d", index2);
        dataUnixTime = [[activities objectAtIndex:index2][5] doubleValue];
    }
    lastSamePeriodActivityStartIndex = index2;  // start-----------end
    lastSamePeriodActivityEndIndex = index1;    // index2----------index1
}
- (NSMutableArray *)setPieData: (int) start endIndex:(int) end {
    NSMutableArray *pieChartValues = [[NSMutableArray alloc] init];
    for (int i = 0; i < categories.count; i++) {
        [pieChartValues addObject:[NSNumber numberWithInt:0]];
    }
    for (int i = 0; i < pieChartValues.count; i++) {
        for (int j = end; j > start; j--) {
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
    NSLog(@" %@", pieChartValues);
    return pieChartValues;
}

-(void) evalEff: (int) avg {
    NSString *daily;
    NSString *msg;

    daily = [NSString stringWithFormat:@"You have been %d%% efficient today!", avg];
    NSLog(@"effAvg: %d", avg);
    
    if (avg > 90) {
        msg = [NSString stringWithFormat:@"Good job! You had a really productive day!"];
    }
    else if (avg > 70) {
        msg = [NSString stringWithFormat:@"Hey! That was a pretty decent day!"];
    }
    else if (avg >50) {
        msg = [NSString stringWithFormat:@"Tommorow can be better."];
    }
    else if (avg <= 50) {
        msg = [NSString stringWithFormat:@"Bruh."];
    }
    _dailyAvgEff.text = daily; // putting the messages on the label
    _dailyMsg.text = msg;
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
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
