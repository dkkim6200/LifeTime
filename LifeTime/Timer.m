//
//  Timer.m
//  LifeTime
//
//  Created by Danny Lee on 2016-12-30.
//  Copyright © 2016 DaekunKim. All rights reserved.
//

#import "Timer.h"

@implementation Timer {
    NSTimeInterval timeInterval;

    NSTimeInterval pauseResumeInterval;
    
    NSDate *pausedTime, *resumedTime, *initialStartTime;
}

-(id) init {
    self = [super init];
    
    if(self) {
    }
    
    return self;
    
}
// timer를 그리는 아이
- (void)updateTimer {
    // Create date from the elapsed time
    NSDate *currentDate = [NSDate date];
    
    // Timer time = current time - intial time - pausedInterval
    timeInterval =
    [currentDate timeIntervalSinceDate:[initialStartTime dateByAddingTimeInterval: pauseResumeInterval]];
    //    NSLog(@"timeInterval: %f", timeInterval);
    
}

-(NSTimeInterval) getInterval {
    return timeInterval;
}

-(void) pauseTimer {
    // save the time where the timer was paused
    pausedTime = [NSDate date];
    
    // actually pause the timer
    [self.timer setFireDate:[NSDate distantFuture]];
}

-(void) resumeTimer {
    // save the time where the timer was resumed
    resumedTime = [NSDate date];
    
    // calculate the amount of total time the timer was paused
    pauseResumeInterval += [resumedTime timeIntervalSinceDate:pausedTime];
    
    [self.timer invalidate];
    self.timer = nil;
    
    [self startTimer];
}

-(void) resetTimer {
    initialStartTime = [NSDate date];
    timeInterval = 0;
    pauseResumeInterval = 0;
//    timerDate = [NSDate dateWithTimeIntervalSince1970:0];

    [self.timer invalidate];
    self.timer = nil;
}

-(void) startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];
}

@end
