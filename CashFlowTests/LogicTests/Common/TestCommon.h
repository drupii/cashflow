// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-

@import UIKit;
@import XCTest;

#ifndef IGNORE_SWIFT_HEADER
#import "CashFlow-Swift.h" // Bridge
#endif

#import "ViewControllerTestCase.h"

#import "Database.h"
#import "DataModel.h"
#import "DateFormatter2.h"

#define NOTYET STFail(@"not yet")

// Simplefied macros
//#define Assert(x) XCTAssertTrue(x)
//#define AssertTrue(x) XCTAssertTrue(x, @"")
//#define AssertFalse(x) XCTAssertFalse(x, @"")
//#define AssertNil(x) XCTAssertNil(x, @"")
//#define AssertNotNil(x) XCTAssertNotNil(x, @"")
//#define AssertEqual(a, b) XCTAssertEqual(a, b, @"")
//#define AssertEqualInt(a, b) XCTAssertEqual((int)(a), (int)(b), @"")
//#define AssertEqualDouble(a, b) XCTAssertEqual((double)(a), (double)(b), @"")
//#define AssertEqualObjects(a, b) XCTAssertEqualObjects(a, b, @"")
