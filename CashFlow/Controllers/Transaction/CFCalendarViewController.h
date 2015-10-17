//
//  CFCalendarViewController.h
//  カスタム RDVCalendarViewController
//

@import UIKit;

#import "RDVCalendarViewController.h"

@class CFCalendarViewController;

@protocol CFCalendarViewControllerDelegate
- (void)cfcalendarViewController:(CFCalendarViewController *)aCalendarViewController didSelectDate:(NSDate *)aDate;
@end

@interface CFCalendarViewController : RDVCalendarViewController
@property(nonatomic,assign) id<CFCalendarViewControllerDelegate> delegate;
@property(nonatomic,strong) NSDate *selectedDate;
@end
