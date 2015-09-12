// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>
#import <sys/socket.h>
#import <netinet/in.h>

/**
   Simple web server
*/
@interface WebServer : NSObject

@property (nonatomic, readonly) BOOL startServer;
- (void)stopServer;

// private
@property (nonatomic, readonly, copy) NSString *serverUrl;
- (void)threadMain:(id)dummy;

- (BOOL)readLine:(int)s line:(char *)line size:(NSInteger)size;
- (char *)readBody:(int)s contentLength:(NSInteger)contentLength NS_RETURNS_INNER_POINTER;
- (void)handleHttpRequest:(int)s;
- (void)send:(int)s string:(NSString *)string;
- (void)requestHandler:(int)s filereq:(NSString*)filereq body:(char *)body bodylen:(NSInteger)bodylen;

@end
