//
//  TimePickerView.m
//  TimePicker
//
//  Created by Mark Alldritt on 12-01-23.
//  Copyright (c) 2012 Late Night Software Ltd. All rights reserved.
//

#import "TimePickerView.h"


#define kCellWidth      60.0
#define kCellHeight     29.0
#define kCellsPerRow    4
#define kHoursPerRow    (kCellsPerRow / 2)
#define kCellRows       12

#define kSecondsPerHour (60.0 * 60.0)

@implementation TimePickerView

@synthesize fromTime;
@synthesize toTime;
@synthesize hoverTime;
@synthesize anchorTime;

- (NSRect) _normalizeFrameSize:(NSRect) frame {
    frame.size.width = kCellsPerRow * kCellWidth;
    frame.size.height = kCellRows * kCellHeight;
    return frame;
}

- (void) _setupView {
    // Initialization code here.
    self.fromTime = 9.0 * kSecondsPerHour;              // 9:00
    self.toTime = 12.0 * kSecondsPerHour + 30.0 * 60.0; // 12:30
    self.anchorTime = self.hoverTime = -1.0;
    
    [self performSelector:@selector(scrollToSelection) withObject:nil afterDelay:0.0];
}

- (NSTimeInterval) _pointToTime:(NSPoint) where {
    NSUInteger row = where.y / kCellHeight;
    NSUInteger col = where.x / kCellWidth;
    NSUInteger hour = row * kHoursPerRow + col / 2;
    NSUInteger minute = col % 2 * 30;
    
    return hour * kSecondsPerHour + minute * 60;
}

- (NSUInteger) _rowForTime:(NSTimeInterval) time {
    return (time / kSecondsPerHour) / kHoursPerRow;
}

- (NSUInteger) _colForTime:(NSTimeInterval) time {
    NSUInteger row = [self _rowForTime:time];

    time = time - row * kHoursPerRow * kSecondsPerHour;
    NSUInteger hours = time / kSecondsPerHour;
    NSUInteger mins = (time - hours * kSecondsPerHour) / 60;
    
    return hours * 2 + mins / 30.0;
}

- (NSRect) _rectForTime:(NSTimeInterval) time {
    NSUInteger row = [self _rowForTime:time];
    NSUInteger col = [self _colForTime:time];
    
    return NSMakeRect(col * kCellWidth, row * kCellHeight, kCellWidth, kCellHeight);
}

- (NSString*) _timeStringForRow:(NSUInteger) row column:(NSUInteger) col {
    NSUInteger hour = row * 2 + (col < 2 ? 0 : 1);
    NSUInteger minute = col % 2 * 30;
    
    return [NSString stringWithFormat:@"%ld:%02ld", hour, minute];
}

- (id) initWithFrame:(NSRect) frame {
    if ((self = [super initWithFrame:[self _normalizeFrameSize:frame]]))
        [self _setupView];
    return self;
}

- (id) initWithCoder:(NSCoder*) decoder {
    if ((self = [super initWithCoder:decoder]))
        [self _setupView];    
    return self;
}

- (void) updateTrackingAreas {
    [super updateTrackingAreas];
    
    [self addTrackingArea:[[[NSTrackingArea alloc] initWithRect:[self bounds]
                                                        options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow
                                                          owner:self
                                                       userInfo:nil] autorelease]];
}

- (BOOL) isOpaque { return YES; }
- (BOOL) isFlipped { return YES; }

- (void) mouseEntered:(NSEvent*) theEvent {
    [self mouseMoved:theEvent];
}

- (void) mouseExited:(NSEvent*) theEvent {
    if (self.hoverTime >= 0.0) {
        self.hoverTime = -1.0;
        self.needsDisplay = YES;
    }
}
    
- (void) mouseMoved:(NSEvent*) theEvent {
    NSPoint where = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSTimeInterval time = [self _pointToTime:where];
    
    if ((self.fromTime < 0.0 && self.toTime < 0.0) ||
        (time < self.fromTime || time > self.toTime)) {
        self.hoverTime = [self _pointToTime:where];
        self.needsDisplay = YES;
    }
    else if (self.hoverTime >= 0.0) {
        self.hoverTime = -1.0;
        self.needsDisplay = YES;
    }
}

- (void) mouseDown:(NSEvent*) theEvent {
    NSPoint where = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSTimeInterval time = [self _pointToTime:where];
    
    self.hoverTime = -1;
    self.anchorTime = self.fromTime = self.toTime = time;
    self.needsDisplay = YES;
}

- (void) mouseUp:(NSEvent*) theEvent {
    self.anchorTime = -1.0;
    self.needsDisplay = YES;
}

- (void) mouseDragged:(NSEvent*) theEvent {
    NSPoint where = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSTimeInterval time = [self _pointToTime:where];
    
    if (time < self.anchorTime) {
        self.fromTime = time;
        self.toTime = anchorTime;
    }
    else if (time > self.anchorTime) {
        self.fromTime = anchorTime;
        self.toTime = time;
    }
    else
        self.fromTime = self.toTime = time;
    self.needsDisplay = YES;

    [self autoscroll:theEvent];
}

- (void) drawRect:(NSRect) dirtyRect {
    NSFont* textFont = [NSFont fontWithName:@"Helvetica Bold" size:12.0];
    NSFont* durationFont = [NSFont fontWithName:@"Helvetica Bold" size:10.0];
    NSColor* backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"BGPattern"]];
    NSColor* normalTextColor = [NSColor colorWithCalibratedWhite:0.322 alpha:1.000];
    NSColor* shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.5];
    NSColor* selectedTextColor = [NSColor whiteColor];
    NSColor* durationTextColor = selectedTextColor;
    NSColor* selectedGridColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.4];
    NSDictionary* normalTextAtts = [NSDictionary dictionaryWithObjectsAndKeys:
                                    textFont, NSFontAttributeName, 
                                    normalTextColor, NSForegroundColorAttributeName, nil];
    NSDictionary* selectedTextAtts = [NSDictionary dictionaryWithObjectsAndKeys:
                                      textFont, NSFontAttributeName, 
                                      selectedTextColor, NSForegroundColorAttributeName, nil];
    NSDictionary* durationTextAtts = [NSDictionary dictionaryWithObjectsAndKeys:
                                      durationFont, NSFontAttributeName, 
                                      durationTextColor, NSForegroundColorAttributeName, nil];
    
    
    NSRect frame = [self bounds];
    NSRect imageFrame = NSInsetRect(frame, 0.0, -10.0);
	NSImage* tempImage = [[[NSImage alloc] initWithSize:imageFrame.size] autorelease];
    
    //  I use a temp image because I need to case a shadow over the selected and hover areas.  This is done
    //  by creating a "background" image showing all the time cells.  Then I punch holes in this image to
    //  reveal the selected and hover cells.  I finall draw this image over the previously drawn selected
    //  and hover areas with a NSShadow object casing a shadow.
    //
    //  This image is slightly taller than the view so that a shadown can be case over the top row of time
    //  cells.
    //

    [tempImage setFlipped:[self isFlipped]];
    [tempImage lockFocus];
    {
        [backgroundColor set];
        NSRectFill(imageFrame);

        //  Draw times...
        for (NSUInteger row = 0; row < kCellRows; ++row) {
            for (NSUInteger col = 0; col < kCellsPerRow; ++col) {
                NSString* time = [self _timeStringForRow:row column:col];
                NSSize timeSize = [time sizeWithAttributes:normalTextAtts];
                
                [time drawInRect:NSMakeRect(col * kCellWidth + (kCellWidth - timeSize.width) / 2.0, 
                                            10.0 + row * kCellHeight + (kCellHeight - timeSize.height) / 2.0, 
                                            timeSize.width, timeSize.height) 
                  withAttributes:normalTextAtts];
            }
        }
        
        //  Draw grid lines...
        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.8] set];
        for (NSUInteger row = 0; row < kCellRows; ++row)
            NSRectFill(NSMakeRect(0.0, 10.0 + row * kCellHeight, kCellsPerRow * kCellWidth, 2.0));
        for (NSUInteger col = 0; col < kCellsPerRow; ++col)
            NSRectFill(NSMakeRect(col * kCellWidth - 1.0, 10.0, 3.0, kCellRows * kCellHeight));
        [[NSColor colorWithCalibratedWhite:0.678 alpha:1.000] set];
        for (NSUInteger row = 0; row < kCellRows; ++row)
            NSRectFill(NSMakeRect(0.0, 10.0 + row * kCellHeight, kCellsPerRow * kCellWidth, 1.0));
        for (NSUInteger col = 0; col < kCellsPerRow; ++col)
            NSRectFill(NSMakeRect(col * kCellWidth, 10.0, 1.0, kCellRows * kCellHeight));
        
        //  Erase selected/hover areas
        [[NSColor clearColor] set];

        if (self.fromTime >= 0 && self.toTime >= 0) {
            NSUInteger fromRow = [self _rowForTime:self.fromTime];
            NSUInteger fromCol = [self _colForTime:self.fromTime];
            NSUInteger toRow = [self _rowForTime:self.toTime];
            NSUInteger toCol = [self _colForTime:self.toTime];
            NSUInteger minCol = INT_MAX;
            NSUInteger maxCol = 0;
            
            for (NSUInteger row = fromRow; row <= toRow; ++row) {
                NSUInteger startCol = row == fromRow ? fromCol : 0;
                NSUInteger endCol = row == toRow ? toCol : 3;
                
                if (startCol < minCol)
                    minCol = startCol;
                if (endCol > maxCol)
                    maxCol = endCol;
                
                for (NSUInteger col = startCol; col <= endCol; ++col)
                    NSRectFill(NSMakeRect(col * kCellWidth, 10.0 + row * kCellHeight, kCellWidth + 1.0, kCellHeight + 1.0));
            }
        }

        //  Draw hover highlight...
        if (self.hoverTime >= 0.0) {
            NSUInteger col = [self _colForTime:self.hoverTime];
            NSUInteger row = [self _rowForTime:self.hoverTime];
            
            NSRectFill(NSMakeRect(col * kCellWidth, 10.0 + row * kCellHeight, kCellWidth + 1.0, kCellHeight + 1.0));
        }
    }
    [tempImage unlockFocus];
    
    //  Draw selected time range...
    NSUInteger minCol = INT_MAX;
    NSUInteger maxCol = 0;
    if (self.fromTime >= 0 && self.toTime >= 0) {
        NSUInteger fromRow = [self _rowForTime:self.fromTime];
        NSUInteger fromCol = [self _colForTime:self.fromTime];
        NSUInteger toRow = [self _rowForTime:self.toTime];
        NSUInteger toCol = [self _colForTime:self.toTime];
        
        for (NSUInteger row = fromRow; row <= toRow; ++row) {
            NSUInteger startCol = row == fromRow ? fromCol : 0;
            NSUInteger endCol = row == toRow ? toCol : 3;
            
            if (startCol < minCol)
                minCol = startCol;
            if (endCol > maxCol)
                maxCol = endCol;
    
            for (NSUInteger col = startCol; col <= endCol; ++col) {
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [[NSColor colorWithCalibratedRed:0.563 green:0.639 blue:0.073 alpha:1.000] set];
                NSRectFill(NSMakeRect(col * kCellWidth, row * kCellHeight, kCellWidth + 1.0, kCellHeight + 1.0));

                if (col > startCol) {
                    [selectedGridColor set];
                    NSRectFillUsingOperation(NSMakeRect(col * kCellWidth, row * kCellHeight, 1.0, kCellHeight), NSCompositeSourceOver);
                }
                if (row > fromRow) {
                    [selectedGridColor set];
                    NSRectFillUsingOperation(NSMakeRect(col * kCellWidth, row * kCellHeight, kCellWidth, 1.0), NSCompositeSourceOver);
                }
                                
                NSString* time = [self _timeStringForRow:row column:col];
                NSSize timeSize = [time sizeWithAttributes:normalTextAtts];        
                NSShadow* textShadow = [[[NSShadow alloc] init] autorelease];
                
                [textShadow setShadowColor:[NSColor blackColor]];
                [textShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
                [textShadow setShadowBlurRadius:1.0];
                [textShadow set];
                
                [time drawInRect:NSMakeRect(col * kCellWidth + (kCellWidth - timeSize.width) / 2.0, 
                                            row * kCellHeight + (kCellHeight - timeSize.height) / 2.0 + 1.0, 
                                            timeSize.width, timeSize.height) 
                  withAttributes:selectedTextAtts];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
            }
        }
    }

    //  Draw hover highlight...
    if (self.hoverTime >= 0.0) {
        [[NSGraphicsContext currentContext] saveGraphicsState];
        NSUInteger col = [self _colForTime:self.hoverTime];
        NSUInteger row = [self _rowForTime:self.hoverTime];
        
        [[NSColor colorWithCalibratedWhite:0.326 alpha:1.000] set];
        NSRectFill(NSMakeRect(col * kCellWidth, row * kCellHeight, kCellWidth + 1.0, kCellHeight + 1.0));
        
        NSString* time = [self _timeStringForRow:row column:col];
        NSSize timeSize = [time sizeWithAttributes:selectedTextAtts];        
        NSShadow* textShadow = [[[NSShadow alloc] init] autorelease];
        
        [textShadow setShadowColor:[NSColor blackColor]];
        [textShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        [textShadow setShadowBlurRadius:1.0];
        [textShadow set];
        
        [time drawInRect:NSMakeRect(col * kCellWidth + (kCellWidth - timeSize.width) / 2.0, 
                                    row * kCellHeight + (kCellHeight - timeSize.height) / 2.0 + 1.0, 
                                    kCellWidth, kCellHeight) 
          withAttributes:selectedTextAtts];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }

    //  Draw balance of the background
    NSShadow* textShadow = [[[NSShadow alloc] init] autorelease];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [textShadow setShadowColor:shadowColor];
    [textShadow setShadowOffset:NSMakeSize(0.0, -3.0)];
    [textShadow setShadowBlurRadius:4.0];
    [textShadow set];
    [tempImage drawInRect:frame fromRect:NSOffsetRect(frame, 0.0, 10.0) operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    
    //  If the user has dragged to extend the time range, draw the duration...
    if (self.anchorTime >= 0.0 && self.fromTime != self.toTime) {
        NSUInteger row = [self _rowForTime:self.toTime];
        NSTimeInterval duration = self.toTime - self.fromTime + 30.0 * 60.0;
        NSUInteger hours = duration / kSecondsPerHour;
        NSUInteger mins = (duration - hours * kSecondsPerHour) / 60.0;
        NSString* time;
        
        if (hours > 0) {
            if (mins > 0)
                time = [NSString stringWithFormat:@"%ldh %02ldm", hours, mins];
            else
                time = [NSString stringWithFormat:@"%ldh", hours];
        }
        else
            time = [NSString stringWithFormat:@"%ldm", mins];
        NSSize timeSize = [time sizeWithAttributes:durationTextAtts];        
        NSRect area = NSMakeRect(minCol * kCellWidth + (kCellWidth * (maxCol - minCol + 1) - timeSize.width) / 2.0, 
                                 row * kCellHeight + kCellHeight - timeSize.height / 2.0 + 2.0, 
                                 timeSize.width, timeSize.height);
        
        if (NSMaxY(area) > NSMaxY([self visibleRect]))
            area = NSOffsetRect(area, 0.0, -10.0);
        
        NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(area, -6.0, -1.0) xRadius:8.0 yRadius:8.0];
        
        [[NSColor darkGrayColor] set];
        [path fill];
        
        NSShadow* textShadow = [[[NSShadow alloc] init] autorelease];
        
        [textShadow setShadowColor:[NSColor blackColor]];
        [textShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        [textShadow setShadowBlurRadius:1.0];
        [textShadow set];
        
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [time drawInRect:area 
          withAttributes:durationTextAtts];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
}

- (void) setFrame:(NSRect) frame {
    //  We only allow our frame to be sized to 4x kCellWidth by 12x kCellHeight
    [super setFrame:[self _normalizeFrameSize:frame]];
}

- (void) scrollToSelection {
    if (self.fromTime >= 0 && self.toTime >= 0)
        [self scrollRectToVisible:NSUnionRect([self _rectForTime:self.fromTime], [self _rectForTime:self.toTime])];
    else
        [self scrollToNow];
}

- (void) scrollToNow {    
    [self scrollRectToVisible:[self _rectForTime:[NSDate timeIntervalSinceReferenceDate]]];
}

#if 0
- (NSRect) adjustScroll:(NSRect) newVisible {
    if (NSMaxY(newVisible) > NSMaxY([self visibleRect]))
        newVisible.origin.y = ceil(NSMinY(newVisible) / kCellHeight) * kCellHeight;
    else
        newVisible.origin.y = floor(NSMinY(newVisible) / kCellHeight) * kCellHeight;
    return newVisible;
}
#endif

@end
    