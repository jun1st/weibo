//
//  TitleBarView.h
//  weibo
//
//  Created by derek on 9/3/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"

@interface TitleBarView : NSView

@property (assign) MainWindowController *hostWindowController;
@property (weak) IBOutlet NSButton *backButton;

- (IBAction)showComposeDialog:(id)sender;
- (IBAction)back:(id)sender;

-(void)setBackButtonHidden:(BOOL)hidden;

@end
