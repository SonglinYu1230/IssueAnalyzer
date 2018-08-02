//
//  MainWindowController.m
//  IssueAnalyzer
//
//  Created by yu on 2018/8/3.
//  Copyright © 2018 yu. All rights reserved.
//

#import "MainWindowController.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.backgroundColor = [NSColor whiteColor];

}
- (IBAction)chooseFileAction:(id)sender {
    NSLog(@"%s", __func__);
}
- (IBAction)analyzeAction:(id)sender {
    NSLog(@"%s", __func__);
}

@end
