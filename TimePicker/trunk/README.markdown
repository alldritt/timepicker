TimePicker Cocoa View
=====================

This project is an attempt to implement [David Cristian](http://dribbble.com/iamdavid)'s [Hour Picker](http://dribbble.com/shots/380911-Hour-Picker) UI design (which I found via the [UI parade site](http://www.uiparade.com/)) as a Cocoa View.  Here is how David's UI mockup appears:

![Hour Picker](http://dribbble.com/system/users/2555/screenshots/380911/hourpicker.png?1326280179)

When I first saw this UI design I found it visually compelling, and it really seems like a nice solution to the problem of allowing the user to quickly pick periods of time in 1/2 hour increments.  When I began turning it into a functional UI a number of issues concerning how users interact with the UI begin to surface:

1. This mockup shows only 6 hours.  The UI needs to scroll in order to show the full 24-hour day.
2. I chose only to implement click and drag to select time ranges.  I imagine that shift-clicking might be desirable.  I didn't attempt to handle keyboard input.
3. At first I though the 1/2 hour grid was self eveident.  However, when I began using the UI, I decided I needed duration feedback while dragging to know exactly how long the selected period is.

Here's how my implementation looks while the user is dragging the mouse:

![Cocoa Time Picker](CocoaTimePicker.jpg)

There are limitations to this UI:

1. Time can only be selected in 1/2 hour increments.
2. Time can only be selected within a single 24-hour day.
3. Auto-scrolling while dragging is problematic.  It may be that auto-scrolling needs to slow down, or more rows need to be made visible in the scroll view.

Requirements
------------

The project requires Xcode 4.2, and the Mac OS X 10.7 SDK.


