//
//  Activity.m
//  LifeTime
//
//  Created by Daekun Kim on 2017-01-03.
//  Copyright © 2017 DaekunKim. All rights reserved.
//

#import "Activity.h"

@interface Activity ()

@property (nonatomic) NSString *category;
@property NSString *desc;

@property NSDate *startTime;
@property NSDate *endTime;

@property int efficiency;

@end

@implementation Activity

-(void)setCategory:(NSString*) category {
    _category = category;
}


@end
