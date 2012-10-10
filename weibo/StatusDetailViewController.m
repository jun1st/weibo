//
//  StatusDetailViewController.m
//  weibo
//
//  Created by feng qijun on 9/24/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "StatusDetailViewController.h"
#import "MainWindowController.h"

@interface StatusDetailViewController ()

@end

@implementation StatusDetailViewController

-(id)init
{
    self = [super initWithNibName:@"StatusDetailViewController" bundle:nil];
    
//    if (self) {
//        
//    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)popup:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PopupViewControllerNotification" object:nil];
}
@end
