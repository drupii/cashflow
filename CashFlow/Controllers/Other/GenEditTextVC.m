// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "GenEditTextVC.h"
#import "AppDelegate.h"

@implementation GenEditTextViewController
{
    IBOutlet UITextField *_textField;
}

+ (GenEditTextViewController *)create:(id<GenEditTextViewDelegate>)delegate title:(NSString*)title identifier:(NSInteger)id
{
    GenEditTextViewController *vc = [[GenEditTextViewController alloc]
                                         initWithNibName:@"GenEditTextView"
                                         bundle:[NSBundle mainBundle]];
    vc.delegate = delegate;
    vc.title = title;
    vc.identifier = id;

    return vc;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPAD) {
        CGSize s = self.preferredContentSize;
        s.height = 300;
        self.preferredContentSize = s;
    }
    
    _textField.placeholder = self.title;
	
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated
{
    _textField.text = _text;
    [_textField becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)doneAction
{
    self.text = _textField.text;
    [_delegate genEditTextViewChanged:self identifier:_identifier];

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return IS_IPAD;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (IS_IPAD) return UIInterfaceOrientationMaskAll;
    return UIInterfaceOrientationMaskPortrait;
}

@end
