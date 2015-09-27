/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

import UIKit

class TCategory : TCategoryBase {
}

class Categories : NSObject {
    private var categories: [TCategory] = []

    override init() {
        super.init()
    }

    func reload() {
        self.categories = TCategory.find_all("ORDER BY sorder")
    }

    var count: Int {
        get {
            return self.categories.count
        }
    }

    func categoryAtIndex(n: Int) -> TCategory {
        //ASSERT(_categories != nil);
        return self.categories[n]
    }

    func categoryIndexWithKey(key: Int) -> Int {
        for (idx, category) in self.categories.enumerate() {
            if category.pid == key {
                return idx
            }
        }
        return -1
    }

    func categoryStringWithKey(key: Int) -> String {
        let idx = categoryIndexWithKey(key)
        if idx < 0 {
            return ""
        }
        return self.categories[idx].name
    }

    func addCategory(name: String) -> TCategory {
        let c = TCategory()
        c.name = name
        self.categories.append(c)
        
        self.renumber()

        c.save()
        return c
    }
    
    func updateCategory(category: TCategory) {
        category.save()
    }

    func deleteCategoryAtIndex(index: Int) {
        let c = self.categories[index]
        c.delete()

        self.categories.removeAtIndex(index)
    }

    func reorderCategory(from: Int, to: Int) {
        let c = self.categories[from]
        self.categories.removeAtIndex(from)
        self.categories.insert(c, atIndex: to)

        self.renumber()
    }

    func renumber() {
        for (idx, category) in self.categories.enumerate() {
            category.sorder = idx
            category.save()
        }
    }
}
