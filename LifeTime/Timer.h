//
//  Timer.h
//  LifeTime
//
//  Created by Danny Lee on 2016-12-30.
//  Copyright © 2016 DaekunKim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject

@property (strong, nonatomic) NSTimer *timer; // Store the timer that fires after a certain time

-(NSTimeInterval) getInterval;

-(void) pauseTimer;
-(void) resumeTimer;
-(void) resetTimer;
-(void) startTimer;

@end
