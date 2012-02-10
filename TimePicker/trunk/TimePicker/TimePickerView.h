//
//  TimePickerView.h
//  TimePicker
//
//  Created by Mark Alldritt on 12-01-23.
//  Copyright (c) 2012 Late Night Software Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TimePickerView : NSView

@property (nonatomic) NSTimeInterval fromTime;
@property (nonatomic) NSTimeInterval toTime;
@property (nonatomic) NSTimeInterval hoverTime;
@property (nonatomic) NSTimeInterval anchorTime;

- (void) scrollToSelection;
- (void) scrollToNow;

@end
