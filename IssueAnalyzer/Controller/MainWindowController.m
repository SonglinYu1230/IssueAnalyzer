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

static NSString * const kAnalyzeResultFolder = @"AlayzeResult";
static NSString * const kAnalyzeResultFile = @"Waring.md";
static NSString * const kAnalyzeSummeryFile = @"Summery.txt";

@interface MainWindowController () <DragDropViewDelegate, NSWindowDelegate>

@property (nonatomic, copy) NSString *resultFolderPath;
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
    self.window.delegate = self;
}

#pragma mark - Event Response

- (IBAction)chooseFileAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setPrompt:NSLocalizedString(@"select", nil)];

    if ( [panel runModal] == NSModalResponseOK) {
        NSArray *urls = [panel URLs];
        if ([urls count] > 0) {
            [self setFilePathLabel:[urls[0] relativePath] textColor:[NSColor blackColor]];
        }
    }
}

- (IBAction)analyzeAction:(NSButton *)sender {
    [self disableAnalyzeButton];
    
    NSString *filePath = self.filePathLabel.stringValue;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([filePath length] > 0) {
            if ([self creaetResultFolderWithPath:filePath]) {
                DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:filePath];
                __block NSMutableDictionary *warningInfo = [NSMutableDictionary dictionary];
                __block NSMutableDictionary *detailInfo = [NSMutableDictionary dictionary];
                [reader enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                    // [-Wproperty-attribute-mismatch]
                    NSString *warning = [line firstMatch:RX(@"\\[-W[^\\]]+\\]")];
                    if ([warning length] > 0) {
                        // ABController.m:114:37:
                        NSUInteger count = [warningInfo[warning] unsignedIntegerValue];
                        warningInfo[warning] = @(++count);
                        NSString *fileInfo = [line firstMatch:RX(@"[a-zA-Z0-9+_]+\\.[hmc]{1,2}:\\d+:\\d+")];
                        
                        [self hanleWaringDetailInfo:detailInfo withFileInfo:fileInfo warningName:warning];
                    }
                }];
                [self handleWarningInfo:warningInfo withFolderPath:[filePath stringByDeletingLastPathComponent]];
                
                NSString *resultFilePath = [NSString stringWithFormat:@"%@/%@/%@", [filePath stringByDeletingLastPathComponent], kAnalyzeResultFolder, kAnalyzeResultFile];
                
                [self writeDetailInfo:detailInfo toFilePath:resultFilePath];
                
                [self setFilePathLabel:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"resultLocationPrefix", nil), resultFilePath]
                             textColor:[NSColor colorWithCalibratedRed:0.271 green:0.576 blue:0.078 alpha:1.00]];
            }
        }
        else {
            [self setFilePathLabel:NSLocalizedString(@"selectTip", nil) textColor:[NSColor redColor]];
        }
        [self enableAnalyzeButton];
    });
}

#pragma mark - Private Methods

- (void)setFilePathLabel:(NSString *)filePath textColor:(NSColor *)color {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.filePathLabel.stringValue = filePath;
        self.filePathLabel.textColor = color;
    });
}

- (void)disableAnalyzeButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.analyzeButton.enabled = NO;
        self.analyzeButton.title = NSLocalizedString(@"analyzing", nil);
    });
}

- (void)enableAnalyzeButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.analyzeButton.title = NSLocalizedString(@"analyze", nil);
        self.analyzeButton.enabled = YES;
    });
}

- (BOOL)creaetResultFolderWithPath:(NSString *)filePath {
    BOOL result = YES;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
//        NSString *folder = [filePath stringByDeletingLastPathComponent];
        NSString *alayzeResultFolder = [NSString stringWithFormat:@"%@/%@", [filePath stringByDeletingLastPathComponent], kAnalyzeResultFolder];
        
        if (![fileManager fileExistsAtPath:alayzeResultFolder]) {
            NSError *error = nil;
            [fileManager createDirectoryAtPath:alayzeResultFolder withIntermediateDirectories:YES attributes:nil error:&error];
            result = (error == nil);
        }
    }
    return result;
}

- (void)handleWarningInfo:(NSMutableDictionary *)warningInfo withFolderPath:(NSString *)folderPath {
    NSArray *orderedKeys = [warningInfo keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj2 compare:obj1];
    }];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", folderPath, kAnalyzeResultFolder, kAnalyzeSummeryFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    __block NSUInteger total = 0;
    NSMutableString *formatString = [NSMutableString new];
    [formatString appendString:@"*************************************Warning Summery*************************************\n"];
    [orderedKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger num = [warningInfo[key] unsignedIntegerValue];
        total += num;
        key = [key stringByReplacingOccurrencesOfString:@"[" withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@"]" withString:@""];
        [formatString appendString:[NSString stringWithFormat:@"%45s :%5ld\n", [key UTF8String], num]];
    }];
    [formatString appendString:[NSString stringWithFormat:@"**************************************%ld warnings*************************************", total]];
    
    [formatString writeToFile:filePath atomically:yearMask encoding:NSUTF8StringEncoding error:nil];
}

- (void)hanleWaringDetailInfo:(NSMutableDictionary *)detailInfo
                 withFileInfo:(NSString *)fileInfo
                  warningName:(NSString *)warningName {
    
    if ([fileInfo length] > 0) {
        NSMutableArray *warnings = detailInfo[warningName];
        if (!warnings) {
            warnings = [NSMutableArray new];
        }
        
        [warnings addObject:fileInfo];
        detailInfo[warningName] = warnings;
    }
}

- (void)writeDetailInfo:(NSMutableDictionary *)detailInfo toFilePath:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    NSMutableString *formatString = [NSMutableString new];
    [detailInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *details, BOOL * _Nonnull stop) {
        [formatString appendString:[NSString stringWithFormat:@"### %@\n", key]];
        [details enumerateObjectsUsingBlock:^(NSString *fileInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            [formatString appendString:[NSString stringWithFormat:@"* %@\n", fileInfo]];
        }];
        [formatString appendString:@"\n"];
    }];
    
    [formatString writeToFile:filePath atomically:yearMask encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - DragDropViewDelegate Methods

- (void)dragDropView:(DragDropView *)view didGetFile:(NSString *)filePath {
    [self setFilePathLabel:filePath textColor:[NSColor blackColor]];
}

#pragma mark - NSWindowDelegate Methods

- (void)windowWillClose:(NSNotification *)notification {

}

@end
