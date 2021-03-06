// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"
#import "DataModel.h"

@interface AssetTest : IUTTest {
    Asset *asset;
}
@end

@implementation AssetTest

- (void)setUp
{
    [super setUp];
    [TestCommon deleteDatabase];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testWithData
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    AssetEntry *e;

    asset = [ledger assetAtIndex:0];
    ASSERT_EQUAL_INT(1, asset.pid);
    ASSERT_EQUAL_INT(0, asset.type);
    ASSERT([asset.name isEqualToString:@"Cash"]);
    ASSERT_EQUAL_INT(0, asset.sorder);
    ASSERT_EQUAL_DOUBLE(5000, asset.initialBalance);
    
    ASSERT_EQUAL_INT(4, [asset entryCount]);
    e = [asset entryAt:0];
    ASSERT_EQUAL_DOUBLE(-100, e.value);
    ASSERT_EQUAL_DOUBLE(4900, e.balance);
    e = [asset entryAt:1];
    ASSERT_EQUAL_DOUBLE(-800, e.value);
    ASSERT_EQUAL_DOUBLE(4100, e.balance);
    e = [asset entryAt:2];
    ASSERT_EQUAL_DOUBLE(-100, e.value);
    ASSERT_EQUAL_DOUBLE(4000, e.balance);
    e = [asset entryAt:3];
    ASSERT_EQUAL_DOUBLE(5000, e.value);
    ASSERT_EQUAL_DOUBLE(9000, e.balance);

    asset = [ledger assetAtIndex:1];
    ASSERT_EQUAL_INT(2, asset.pid);
    ASSERT_EQUAL_INT(1, asset.type);
    ASSERT([asset.name isEqualToString:@"Bank"]);
    ASSERT_EQUAL_INT(1, asset.sorder);
    ASSERT_EQUAL_DOUBLE(100000, asset.initialBalance);

    ASSERT_EQUAL_INT(2, [asset entryCount]);
    e = [asset entryAt:0];
    ASSERT_EQUAL_DOUBLE(-5000, e.value);
    ASSERT_EQUAL_DOUBLE(95000, e.balance);
    e = [asset entryAt:1];
    ASSERT_EQUAL_DOUBLE(100000, e.value);
    ASSERT_EQUAL_DOUBLE(195000, e.balance);

    asset = [ledger assetAtIndex:2];
    ASSERT_EQUAL_INT(3, asset.pid);
    ASSERT_EQUAL_INT(2, asset.type);
    ASSERT([asset.name isEqualToString:@"Card"]);
    ASSERT_EQUAL_INT(2, asset.sorder);
    ASSERT_EQUAL_DOUBLE(-10000, asset.initialBalance);
    
    ASSERT_EQUAL_INT(1, [asset entryCount]);

    e = [asset entryAt:0];
    ASSERT_EQUAL_DOUBLE( -2100, e.value);
    ASSERT_EQUAL_DOUBLE(-12100, e.balance);
}

// 支払い取引の追加
- (void)testInsertOutgo
{
    // not yet
}

// 入金取引の追加
- (void)testInsertIncome
{
    // not yet
}

// 残高調整の追加
- (void)testInsertAdjustment
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    asset = [ledger assetAtIndex:0];
    
    ASSERT_EQUAL_DOUBLE(9000, [asset lastBalance]);

    // 新規エントリ
    AssetEntry *ae = [[[AssetEntry alloc] initWithTransaction:nil withAsset:asset] autorelease];

    ae.assetKey = asset.pid;
    ae.transaction.type = TYPE_ADJ;
    [ae setEvalue:10000.0];
    ae.transaction.date = [TestCommon dateWithString:@"20090201000000"];

    [asset insertEntry:ae];
    ASSERT_EQUAL_DOUBLE(10000, [asset lastBalance]);
}

// 資産間移動の追加
- (void)testInsertTransfer
{
    // not yet
}

// 初期残高変更処理
- (void)testChangeInitialBalance
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    asset = [ledger assetAtIndex:0];

    ASSERT_EQUAL_DOUBLE(5000, [asset initialBalance]);
    ASSERT_EQUAL_DOUBLE(9000, [asset lastBalance]);
    
    asset.initialBalance = 0.0;
    [asset rebuild];
    ASSERT_EQUAL_DOUBLE(0, [asset initialBalance]);

    AssetEntry *e;
    e = [asset entryAt:0];
    ASSERT_EQUAL_DOUBLE(e.balance, -100);
    e = [asset entryAt:1];
    ASSERT_EQUAL_DOUBLE(e.balance, -900);    
    e = [asset entryAt:2];
    ASSERT_EQUAL_DOUBLE(e.balance, 4000);    // 残高調整のため、balance 変化なし
    ASSERT_EQUAL_DOUBLE(e.value, 4900);
    
    ASSERT_EQUAL_DOUBLE(9000, [asset lastBalance]);
}

// 取引削除
- (void)testDeleteEntryAt
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    
    asset = [ledger assetAtIndex:0];
    ASSERT_EQUAL_DOUBLE(5000, asset.initialBalance);

    [asset deleteEntryAt:3]; // 資産間移動取引を削除する

    ASSERT_EQUAL_INT(3, [asset entryCount]);
    ASSERT_EQUAL_DOUBLE(5000, asset.initialBalance);

    // 別資産の取引数が減って「いない」ことを確認(置換されているはず)
    ASSERT_EQUAL_INT(2, [[ledger assetAtIndex:1] entryCount]);

    // データベースが更新されていることを確認する
    [DataModel load];
    ASSERT_EQUAL_INT(3, [asset entryCount]);
    ASSERT_EQUAL_INT(2, [[ledger assetAtIndex:1] entryCount]);
}

// 先頭取引削除
-(void)testDeleteFirstEntry
{
    // not yet
}

// 古い取引削除
- (void)testDeleteOldEntriesBefore
{
    [TestCommon installDatabase:@"testdata1"];
    Ledger *ledger = [DataModel ledger];
    AssetEntry *e;
    NSDate *date;

    asset = [ledger assetAtIndex:0];
    ASSERT_EQUAL_INT(4, [asset entryCount]);

    // 最初よりも早い日付の場合に何も削除されないこと
    date = [TestCommon dateWithString:@"20081231000000"];
    [asset deleteOldEntriesBefore:date];
    ASSERT_EQUAL_INT(4, [asset entryCount]);    

    // 途中削除
    e = [asset entryAt:2];
    [asset deleteOldEntriesBefore:e.transaction.date];
    ASSERT_EQUAL_INT(2, [asset entryCount]);    

    // 最後の日付の後で削除
    date = [TestCommon dateWithString:@"20090201000000"];
    [asset deleteOldEntriesBefore:date];
    ASSERT_EQUAL_INT(0, [asset entryCount]);

    // 残高チェック
    ASSERT_EQUAL_DOUBLE(9000, asset.initialBalance);

    // データベースが更新されていることを確認する
    [DataModel load];
    ASSERT_EQUAL_INT(0, [asset entryCount]);
    ASSERT_EQUAL_DOUBLE(9000, asset.initialBalance);
}

// replace : 日付変更、種別変更なし
// replace : 通常から資産間移動に変更
// replace : 資産間移動のままだけど相手資産変更
// replace : 資産間移動のままだけど相手資産変更(dstAsset側)
// replace : 資産間移動から通常に変更
// replace : 資産間移動から通常に変更(dstAsset側)

@end
