//
//  Timer.m
//  LifeTime
//
//  Created by Danny Lee on 2016-12-30.
//  Copyright © 2016 DaekunKim. All rights reserved.
//

#import "Timer.h"

@implementation Timer {
    NSTimeInterval pauseResumeInterval;
    NSDate *timerDate, *pausedTime, *resumedTime, *initialStartTime;
}

-(id) init {
    self = [super init];
    
    if(self) {
        timerDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    return self;
    
}
// timer 시간을 주기적으로 생성하는 아이
- (void)updateTimer {
    // Create date from the elapsed time
    NSDate *currentDate = [NSDate date];
    
    // Timer time = current time - intial time - pausedInterval
    NSTimeInterval timeInterval =
    [currentDate timeIntervalSinceDate:[initialStartTime dateByAddingTimeInterval: pauseResumeInterval]];
    //    NSLog(@"timeInterval: %f", timeInterval);
    
    timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];

}

-(NSDate *) getTime {
    return timerDate;
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
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];}

-(void) resetTimer {

    timerDate = [NSDate dateWithTimeIntervalSince1970:0];

    [self.timer invalidate];
    self.timer = nil;
}

-(void) startTimer {
    initialStartTime = [NSDate date];
    pauseResumeInterval = 0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];
}

@end
