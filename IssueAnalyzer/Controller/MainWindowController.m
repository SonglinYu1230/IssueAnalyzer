//
//  MainWindowController.m
//  IssueAnalyzer
//
//  Created by yu on 2018/8/3.
//  Copyright © 2018 yu. All rights reserved.
//

#import "MainWindowController.h"
#import "DragDropView.h"

@interface MainWindowController () <DragDropViewDelegate>

@property (weak) IBOutlet DragDropView *dragDropView;
@property (weak) IBOutlet NSTextFieldCell *filePathLabel;

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.backgroundColor = [NSColor whiteColor];
    self.window.title = NSLocalizedString(@"mainWindowTitle", nil);
    self.dragDropView.delegate = self;
}
- (IBAction)chooseFileAction:(id)sender {
    NSLog(@"%s", __func__);
}
- (IBAction)analyzeAction:(id)sender {
    NSLog(@"%s", __func__);
}

#pragma mark - DragDropViewDelegate Methods

- (void)dragDropView:(DragDropView *)view didGetFile:(NSString *)filePath {
    self.filePathLabel.stringValue = filePath;
}

@end
