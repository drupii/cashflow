// -*-  Mode:ObjC; c-basic-offset:4; tab-width:4; indent-tabs-mode:t -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008, Takuya Murakami, All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer. 

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution. 

  3. Neither the name of the project nor the names of its contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission. 

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AppDelegate.h"
#import "Report.h"
#import "Database.h"

@implementation Report
@synthesize date, totalIncome, totalOutgo;

- (id)init
{
	[super init];
	date = nil;
	totalIncome = 0.0;
	totalOutgo = 0.0;

	return self;
}

- (void)dealloc 
{
	[date release];
	[super dealloc];
}

@end

/////////////////////////////////////////////////////////////////////

@implementation Reports
@synthesize reports, type;

- (id)init
{
	[super init];
	type = REPORT_MONTHLY;
	reports = nil;
	return self;
}

- (void)dealloc
{
	[reports release];
	[super dealloc];
}

- (void)generate:(int)t asset:(Asset*)asset
{
	Database *db = theDataModel.db;
	
	self.type = t;
	
	if (reports != nil) {
		[reports release];
	}
	reports = [[NSMutableArray alloc] init];

	NSCalendar *greg = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	
	//	NSDate *firstDate = [[asset transactionAt:0] date];
	NSDate *firstDate = [db firstDateOfAsset:asset.pkey];
	if (firstDate == nil) return; // no data
	NSDate *lastDate = [db lastDateOfAsset:asset.pkey];

	// レポート周期の開始時間および間隔を求める
	NSDateComponents *dc, *steps;
	NSDate *dd;
	
	steps = [[[NSDateComponents alloc] init] autorelease];
	switch (type) {
		case REPORT_MONTHLY:
			dc = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:firstDate];
			[dc setDay:1];
			dd = [greg dateFromComponents:dc];
			[steps setMonth:1];
			break;
			
		case REPORT_WEEKLY:
			dc = [greg components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit) fromDate:firstDate];
			dd = [greg dateFromComponents:dc];
			int weekday = [dc weekday];
			[steps setDay:-weekday+1];
			dd = [greg dateByAddingComponents:steps toDate:dd options:0];
			[steps setDay:7];
			break;
	}
	
	while ([dd compare:lastDate] != NSOrderedDescending) {
		// Report 生成
		Report *r = [[Report alloc] init];
		[reports addObject:r];
		[r release];

		// 日付設定
		r.date = dd;
		
		// 次の期間開始時期を計算する
		dd = [greg dateByAddingComponents:steps toDate:dd options:0];

		// 集計
		r.totalIncome = [db calculateSumWithinRange:asset.pkey isOutgo:NO startDate:r.date endDate:dd];
		r.totalOutgo = -[db calculateSumWithinRange:asset.pkey isOutgo:YES startDate:r.date endDate:dd];
	}
}

@end
