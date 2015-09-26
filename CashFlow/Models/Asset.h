// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2015, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

@import Foundation;

typedef NS_ENUM(NSInteger, AssetType) {
    AssetTypeCash = 0,
    AssetTypeBank = 1,
    AssetTypeCard = 2,
    AssetTypeInvest = 3,
    AssetTypeEmoney = 4
};
