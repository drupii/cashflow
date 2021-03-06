// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

#import "TestCommon.h"

@interface DataModelTest : IUTTest {
    DataModel *dm;
}
@end


@implementation DataModelTest

- (void)setUp
{
    [TestCommon deleteDatabase];
    dm = [DataModel instance];
    [dm load];
}

- (void)tearDown
{
}

#pragma mark -
#pragma mark Tests

// データベースがないときに、初期化されること
- (void)testInitial
{
    // 初期データチェック
    Assert(dm != nil);
    AssertEqualInt(0, [dm.journal.entries count]);

    Asset *as = [dm.ledger.assets objectAtIndex:0];
    Assert([as.name isEqualToString:@"Cash"]); 
                  
    AssertEqualInt(0, [dm.categories count]);
}

// データベースがあるときに、正常に読み込めること
- (void)testNotInitial
{
    [TestCommon installDatabase:@"testdata1"];
    dm = [DataModel instance];

    Assert([dm.journal.entries count] == 6);
    Assert([dm.ledger.assets count] == 3);
    Assert([dm.categories count] == 3);
}

@end
