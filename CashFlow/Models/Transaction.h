// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

@import UIKit;

typedef NS_ENUM(NSInteger, TransactionType) {
    TransactionTypeOutgo = 0, //支払い
    TransactionTypeIncome = 1, // 入金
    TransactionTypeAdj = 2, // 残高調整
    TransactionTypeTransfer = 3 // 資産間移動
};
