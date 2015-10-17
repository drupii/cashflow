/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

class DescLRUManager : NSObject {
    // 旧バージョンからの移行処理
    // Transaction から DescLRU を生成する
    static func migrate() {
        let ary = self.getDescLRUs(-1)
        if ary.count > 0 {
            return
        }
    
        // okay, we need to migrate...
        let transactions = Transaction.find_all("ORDER BY date DESC LIMIT 100")
        for t in transactions {
            self.addDescLRU(t.desc, category:t.category, date:t.date)
        }
    }

    static func addDescLRU(description: String, category: Int) {
        let now = NSDate()
        self.addDescLRU(description, category: category, date: now)
    }
    
    static func addDescLRU(desc: String, category: Int, date: NSDate) {
        if desc.isEmpty {
            return
        }

        // find desc LRU from history
        var lru: DescLRU? = DescLRU.find_by_description(desc)

        if (lru == nil) {
            // create new LRU
            lru = DescLRU()
            lru!.desc = desc
        }
        lru!.category = category
        lru!.lastUse = date
        lru!.save()
    }
    
    static func getDescLRUs(category: Int) -> [DescLRU] {
        if category < 0 {
            // 全検索
            return DescLRU.find_all("ORDER BY lastUse DESC LIMIT 100")
        } else {
            let stmt = DescLRU.gen_stmt("WHERE category = ? ORDER BY lastUse DESC LIMIT 100")
            stmt.bindInt(0, val:category)
            return DescLRU.find_all_stmt(stmt)
        }
    }

    /*
#if 0
+ (void)gc
{
    NSMutableArray *ary = [DescLRU find:cond:@"ORDER BY lastUse DESC LIMIT 1 OFFSET 100"];
    if ([ary count] > 0) {
        DescLRU *lru = [ary objectAtIndex:0];
        dbstmt *stmt = [[Database instance] prepare:@"DELETE FROM DescLRUs WHERE lastUse < ?"];
        [stmt bindDate:0 val:lru.date];
        [stmt step];
    }
}
#endif
*/
}

