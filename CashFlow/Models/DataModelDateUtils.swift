/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import Foundation

extension DataModel {
    private static var dfDateOnly: NSDateFormatter?
    private static var dfDateTime: NSDateFormatter?
    
    static func dateFormatter() -> NSDateFormatter {
        if (Config.instance().dateTimeMode == .DateOnly) {
            if (dfDateOnly == nil) {
                dfDateOnly = DataModel.dateFormatter(.NoStyle, dayOfWeek:true)
            }
            return dfDateOnly!
        } else {
            if (dfDateTime == nil) {
                dfDateTime = DataModel.dateFormatter(.ShortStyle, dayOfWeek:true)
            }
            return dfDateTime!
        }
    }

    static func dateFormatter(dayOfWeek: Bool) -> NSDateFormatter {
        if (Config.instance().dateTimeMode == .DateOnly) {
            return DataModel.dateFormatter(.NoStyle, dayOfWeek:dayOfWeek)
        } else {
            return DataModel.dateFormatter(.ShortStyle, dayOfWeek: dayOfWeek)
        }
    }

    private static func dateFormatter(timeStyle: NSDateFormatterStyle, dayOfWeek: Bool) -> NSDateFormatter {
        let df = NSDateFormatter()
        df.dateStyle = .MediumStyle
        df.timeStyle = timeStyle;
    
        var s = df.dateFormat
    
        if (dayOfWeek) {
            s = s.stringByReplacingOccurrencesOfString("MMM d, y", withString: "EEE, MMM d, y")
            s = s.stringByReplacingOccurrencesOfString("yyyy/MM/dd", withString: "yyyy/MM/dd(EEEEE)")
        }
    
        df.dateFormat = s;
        return df;
    }
}
