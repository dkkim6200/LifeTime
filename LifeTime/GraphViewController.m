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
@property (weak, nonatomic) IBOutlet UILabel *dailyAvgEff;
@property (weak, nonatomic) IBOutlet UILabel *dailyMsg;
@end

@implementation GraphViewController {
//    NSArray *activities;
//    NSMutableArray *categories;
//    int lastSamePeriodActivityStartIndex;
//    int lastSamePeriodActivityEndIndex;
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
    NSArray *activities = [dbManager1 loadDataFromDB:selectActivitiesQuery];
    NSLog(@"%@\n%@\n\n\n", selectActivitiesQuery, activities);
    NSLog(@"%@ activities: ", activities);

    // re-reading from db, because dbManger code is bad
    DBManager *dbManager2 = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
    NSString *categoriesQuery = [NSString stringWithFormat:@"%@", @"SELECT * FROM categories ORDER BY cat_order"];
    NSArray *result = [[NSArray alloc] initWithArray:[dbManager2 loadDataFromDB:categoriesQuery]];
    
    // make a categories array with the categories inside
////    categories = [[NSMutableArray alloc] initWithCapacity:result.count];
//    for (int i = 0; i < result.count; i++) {
//        [categories addObject:[result[i] objectAtIndex:1]];
//    }
//    NSLog(@"%@ categories: ", categories);
//    
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
    [self updateChartData:@"day"];
    [self evalEff];
}

- (void)viewWillAppear:(BOOL)animated {
    [self modeChanged:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateChartData: (NSString *) period {
    if (self.shouldHideData) {
        _barChartView.data = nil;
        _pieChartView.data = nil;
        return;
    }
    
    [self drawBarChart:period];
    [self drawPieChart:period];
    [self.view setNeedsDisplay];
    
    [self.barChartView animateWithYAxisDuration:1.0];
    [self.pieChartView animateWithYAxisDuration:1.0];
}

- (void)drawBarChart: (NSString *) period {
    NSMutableArray<BarChartDataEntry *> *efficiencyPercentages = [[NSMutableArray alloc] init];
    int numData = -1;
    int factor = -1;
    if ([period isEqualToString:@"daily"]) {
        return;
    }
    else if ([period isEqualToString:@"week"]) {
        numData = 7;
        factor = 1;
    }
    else if ([period isEqualToString:@"month"]) {
        numData = 4;
        factor = 7;
    }
    else if ([period isEqualToString:@"year"]) {
        numData = 12;
        factor = 28;
    }
    efficiencyPercentages = [self getAvgEffSQLite:numData num:factor];

    
    NSLog(@" %@", efficiencyPercentages);

    BarChartDataSet *set1 = nil;
    if (_barChartView.data.dataSetCount > 0)
    {
        set1 = (BarChartDataSet *)_barChartView.data.dataSets[0];
        set1.values = efficiencyPercentages;
        [_barChartView.data notifyDataChanged];
        [_barChartView notifyDataSetChanged];
    }
    else {
        set1 = [[BarChartDataSet alloc] initWithValues:efficiencyPercentages label:@"The year 2017"];
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

-(NSMutableArray<BarChartDataEntry *> *) getAvgEffSQLite: (int) numData num:(int) factor {
    NSMutableArray<BarChartDataEntry *> *efficiencyPercentages = [[NSMutableArray alloc] init];

    for (int i = 0; i < numData; i++) {
        // %+d forces the integer value to be printed with sign (+ or -) even if it is a positive value.
        DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
        NSString *query = [NSString stringWithFormat:@"SELECT avg(efficiency) FROM activities WHERE finish_time BETWEEN datetime('now', 'localtime', '%+d days', 'start of day') AND datetime('now', 'localtime', '%+d days', 'start of day')", (i-numData+1)*factor, (i-numData+2)*factor];
        NSArray *result = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
        
        if (result.count == 0) {
            [efficiencyPercentages addObject:[[BarChartDataEntry alloc] initWithX:i y:0.0 icon: [UIImage imageNamed:@"icon"]]];
        }
        else {
            [efficiencyPercentages addObject:[[BarChartDataEntry alloc] initWithX:i y:[result[0][0] doubleValue] icon: [UIImage imageNamed:@"icon"]]];
        }
    }
    
    return efficiencyPercentages;
}
- (void)drawPieChart: (NSString *) period {
    NSMutableArray<PieChartDataEntry *> *durationSums = [[NSMutableArray alloc] init];
    int numDays = -1;
    if ([period isEqualToString:@"day"]) {
        numDays = 0;
    }
    else if ([period isEqualToString:@"week"]) {
        numDays = 7;
    }
    else if ([period isEqualToString:@"month"]) {
        numDays = 28;
    }
    else if ([period isEqualToString:@"year"]) {
        numDays = 365;
    }
    durationSums = [self getDurationSumsSQLite:numDays];

    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithValues:durationSums];
    dataSet.drawIconsEnabled = YES;
    
    dataSet.sliceSpace = 2.0;
    dataSet.iconsOffset = CGPointMake(0, 40);
    
    // add a lot of colors
    NSMutableArray *colors = [[NSMutableArray alloc] init];
//    [colors addObjectsFromArray:ChartColorTemplates.vordiplom];
//    [colors addObjectsFromArray:ChartColorTemplates.joyful];
    [colors addObjectsFromArray:ChartColorTemplates.colorful];
//    [colors addObjectsFromArray:ChartColorTemplates.liberty];
//    [colors addObjectsFromArray:ChartColorTemplates.pastel];
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

-(NSMutableArray<PieChartDataEntry *> *) getDurationSumsSQLite: (int) numDays {
    NSMutableArray<PieChartDataEntry *> *durationSums = [[NSMutableArray alloc] init];
    
    DBManager *dbManager1 = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
    NSString *query1 = [NSString stringWithFormat:@"SELECT id, name FROM categories ORDER BY cat_order"];
    NSArray *categories = [[NSArray alloc] initWithArray:[dbManager1 loadDataFromDB:query1]];
    
    for (int i = 0; i < categories.count; i++) {
        DBManager *dbManager2 = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
        NSString *query2 = [NSString stringWithFormat:@"SELECT sum(duration) FROM activities WHERE category_id IS %d AND finish_time BETWEEN datetime('now', 'localtime', '-%d days', 'start of day') AND datetime('now', 'localtime')", [categories[i][0] intValue], numDays];
        NSArray *sum = [[NSArray alloc] initWithArray:[dbManager2 loadDataFromDB:query2]];
        
        if (!(sum == nil || sum.count == 0)) {
            [durationSums addObject:[[PieChartDataEntry alloc] initWithValue:[sum[0][0] doubleValue] label:categories[i][1]]];
        }
    }
    return durationSums;
}

-(int) getDailyAvgEff {
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
    NSString *query = [NSString stringWithFormat:@"SELECT avg(efficiency) FROM activities WHERE finish_time BETWEEN datetime('now', 'localtime', 'start of day') AND datetime('now', 'localtime')"];
    NSArray *result = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
    
    return [result[0][0] intValue];
}

-(void) evalEff {
    int avg = [self getDailyAvgEff];
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
//            [self updateChartData:@"daily"];
            [self updateChartData:@"day"];
            NSLog(@"daily");
            
            if (self.pieChartView.alpha == 0) {
                self.barChartView.alpha = 0;
                self.pieChartView.alpha = 1;
                
                [self.pieChartView animateWithYAxisDuration:1.0];
            }
            
            break;
        case 1:
            // show weekly here;
            NSLog(@"weekly");
            [self updateChartData:@"week"];
            break;
        case 2:
            // show monthly here;
            NSLog(@"monthly");
            [self updateChartData:@"month"];
            break;
        case 3:
            // show yearly here;
            NSLog(@"yearly");
            [self updateChartData:@"year"];
            break;
        default:
            break;
    }
}

- (IBAction)graphTapped:(id)sender {
    NSLog(@"graphTapped");
    
    if (self.modeSwitch.selectedSegmentIndex != 0) {
        if (self.barChartView.alpha == 0) {
            self.barChartView.alpha = 1;
            self.pieChartView.alpha = 0;
            
            [self.barChartView animateWithYAxisDuration:1.0];
        }
        else if (self.pieChartView.alpha == 0) {
            self.barChartView.alpha = 0;
            self.pieChartView.alpha = 1;
            
            [self.pieChartView animateWithYAxisDuration:1.0];
        }
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
