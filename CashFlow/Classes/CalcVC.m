// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
  CashFlow for iPhone/iPod touch

  Copyright (c) 2008-2009, Takuya Murakami, All rights reserved.

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


#import <AudioToolbox/AudioToolbox.h>

#import "TransactionVC.h"
#import "CalcVC.h"
#import "AppDelegate.h"

@implementation CalculatorViewController

@synthesize delegate, value;

- (id)init
{
    self = [super initWithNibName:@"CalculatorView" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Amount", @"金額");
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)] autorelease];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    state = ST_DISPLAY;
    decimalPlace = 0;
    storedOperator = OP_NONE;
    storedValue = 0.0;

    [self updateLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)doneAction
{
    [delegate calculatorViewChanged:self];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNumButtonDown:(id)sender
{
    // play keyboard click sound
    AudioServicesPlaySystemSound(1105);
}

- (IBAction)onButtonPressed:(id)sender
{
    NSString *ch = nil;
    calcOperator op = OP_NONE;
    int len;
	
    if (sender == button_Clear) {
        value = 0.0;
        state = ST_DISPLAY;
        storedOperator = OP_NONE;
    }

    else if (sender == button_BS) {
        // バックスペース
        if (state == ST_INPUT && decimalPlace > 0) {
            decimalPlace--;
            [self roundInputValue]; // TBD
        } else {
            value = (int)(value / 10);
        }
        [self updateLabel];
    }

    else if (sender == button_inv) {
        value = -value;
        [self updateLabel];
    }

    else if (sender == button_plus) op = OP_PLUS;
    else if (sender == button_minus) op = OP_MINUS;
    else if (sender == button_multiply) op = OP_MULTIPLY;
    else if (sender == button_divide) op = OP_DIVIDE;
    else if (sender == button_equal) op = OP_EQUAL;
		
    else if (sender == button_0) ch = @"0";
    else if (sender == button_1) ch = @"1";
    else if (sender == button_2) ch = @"2";
    else if (sender == button_3) ch = @"3";
    else if (sender == button_4) ch = @"4";
    else if (sender == button_5) ch = @"5";
    else if (sender == button_6) ch = @"6";
    else if (sender == button_7) ch = @"7";
    else if (sender == button_8) ch = @"8";
    else if (sender == button_9) ch = @"9";
    else if (sender == button_Period) ch = @".";

    // 演算子入力
    if (op != OP_NONE) {
        if (state == ST_INPUT || op == OP_EQUAL) {
            // 数値入力中に演算ボタンが押された場合、
            // あるいは = が押された場合 (5x= など)
            // メモリしてある式を計算する
            switch (storedOperator) {
            case OP_PLUS:
                value = storedValue + value;
                break;

            case OP_MINUS:
                value = storedValue - value;
                break;

            case OP_MULTIPLY:
                value = storedValue * value;
                break;

            case OP_DIVIDE:
                if (value == 0.0) {
                    // divided by zero error
                    value = 0.0;
                } else {
                    value = storedValue / value;
                }
                break;
            }

            // 表示中の値を記憶
            storedValue = value;

            // 表示状態に遷移
            state = ST_DISPLAY;
            [self updateLabel];
        }
        
        // 表示中の場合は、operator を変えるだけ

        if (op == OP_EQUAL) {
            // '=' を押したら演算終了
            storedOperator = OP_NONE;
        } else {
            storedOperator = op;
        }
    }
    
    // 数値入力
    if (ch != nil) {
        if (state == ST_DISPLAY) {
            state = ST_INPUT; // 入力状態に遷移

            storedValue = value;

            value = 0; // 表示中の値をリセット
            decimalPlace = 0;
        }

        if ([ch isEqualToString:@"."]) { // 小数点
            if (decimalPlace == 0) {
                decimalPlace = 1;
            }
        }
        else { // 数値
            int n = [ch intValue];
            if (decimalPlace == 0) {
                value = value * 10 + n;
            } else {
                double v = (double)n;
                for (int i = 0; i < decimalPlace; i++) {
                    v /= 10.0;
                }
                value += v;

                decimalPlace++;
            }
        }
         
        [self updateLabel];
    }
	
    [self updateLabel];
}

- (void)roundInputValue
{
    double v;
    BOOL isMinus = NO;

    v = value;
    if (value < 0.0) {
        isMinus = YES;
        v = -value;
    }

    value = (int)v;
    v -= value; // 小数点以下

    if (decimalPlace >= 2) {
        int k = 1;
        for (int i = 1; i <= decimalPlace - 1; i++) {
            k *= 10;
        }
        v = (int)(v * k) / (double)k;
        value += v;
    }

    if (isMinus) {
        value = -value;
    }
}

- (void)updateLabel
{
    NSString *n;
    double v = value;
    BOOL isMinus;
    NSMutableString *numstr = [[NSMutableString alloc] initWithCapacity:16];

    // 符号の処理
    if (v < 0) {
        isMinus = YES;
        v = -v;
        [numstr setString:@"-"];
    } else {
        isMinus = NO;
        [numstr empty];
    }

    // 整数部
    n = [NSString stringWithFormat:@"%.0f", v];
    [numstr appendString:n];

    // 表示すべき小数点以下の桁数を求める
    int dp;
    double vtmp;
    switch (state) {
    case ST_INPUT:
        dp = decimalPlace - 1;
        break;

    case ST_DISPLAY:
        dp = 0;
        vtmp = v;
        for (int i = 1; i <= 6; i++) {
            vtmp *= 10;
            if ((int)vtmp % 10 != 0) {
                dp = i;
            }
        }
        break;
    }
            
    // 小数部を表示する
    if (dp > 0) {
        [numstr appendString:@"."];
        vtmp = v - (int)v;
        for (int i = 1; i <= dp; i++) {
            vtmp *= 10;
        }
        n = [NSString stringWithFormat:@"%d", (int)vtmp];
        [numstr appendString:n];
    }

    // カンマを３桁ごとに挿入
    NSRange range = [numstr rangeOfString:@"."];
    int i;
    if (range.location == NSNotFound) {
        i = tmp.length;
    } else {
        i = range.location;
    }

    for (i -= 3 ; i > 0; i -= 3) {
        if (isMinus && i <= 1) break;
        [numstr insertString:@"," atIndex:i];
    }
	
    numLabel.text = numstr;
    [numstr release];
}

@end
