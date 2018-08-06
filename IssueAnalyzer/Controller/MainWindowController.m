//
//  MainWindowController.m
//  IssueAnalyzer
//
//  Created by yu on 2018/8/3.
//  Copyright © 2018 yu. All rights reserved.
//

#import "MainWindowController.h"
#import "DragDropView.h"
#import "DDFileReader.h"
#import <RegExCategories/RegExCategories.h>

@interface MainWindowController () <DragDropViewDelegate>

@property (weak) IBOutlet DragDropView *dragDropView;
@property (weak) IBOutlet NSTextFieldCell *filePathLabel;
@property (weak) IBOutlet NSButton *analyzeButton;

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.backgroundColor = [NSColor whiteColor];
    self.window.title = NSLocalizedString(@"mainWindowTitle", nil);
    self.dragDropView.delegate = self;
}

#pragma mark - Event Response

- (IBAction)analyzeAction:(NSButton *)sender {
    sender.enabled = !sender.isEnabled;
    sender.title = @"分析结果中...";
    
    NSString *filePath = self.filePathLabel.stringValue;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:filePath];
            __block NSMutableDictionary *warningInfo = [NSMutableDictionary dictionary];
            [reader enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                // [-Wproperty-attribute-mismatch]
                NSString *warning = [line firstMatch:RX(@"\\[-W[^\\]]+\\]")];
                if ([warning length] > 0) {
                    //                ABController.m:114:37:
                    NSUInteger count = [warningInfo[warning] unsignedIntegerValue];
                    warningInfo[warning] = @(++count);
                    NSString *fileInfo = [line firstMatch:RX(@"[a-zA-Z0-9+]+\\.[hmc]{1,2}:\\d+:\\d+:")];
                    NSLog(@"fileInfo: %@-----warning: %@", fileInfo, warning);
                }
            }];

            [self handleWarningInfo:warningInfo];
        }
        [self enableAnalyzeButton];
    });
}

- (void)enableAnalyzeButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.analyzeButton.title = @"分析结果";
        self.analyzeButton.enabled = YES;
    });
}

#pragma mark - Private Methods

- (void)handleWarningInfo:(NSMutableDictionary *)warningInfo {
    NSLog(@"warningInfo: %@", warningInfo);
    
    NSArray *orderedKeys = [warningInfo keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj2 compare:obj1];
    }];
    
    __block NSUInteger total = 0;
    [orderedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Warning: %@, Count is %@", key, warningInfo[key]);
        total += [warningInfo[key] unsignedIntegerValue];
    }];
    NSLog(@"total is %ld", total);
}

#pragma mark - DragDropViewDelegate Methods

- (void)dragDropView:(DragDropView *)view didGetFile:(NSString *)filePath {
    self.filePathLabel.stringValue = filePath;
}

@end
