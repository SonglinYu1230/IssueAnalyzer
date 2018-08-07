//
//  AppDelegate.m
//  IssueAnalyzer
//
//  Created by yu on 2018/8/2.
//  Copyright © 2018 yu. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate ()

//@property (weak) IBOutlet NSWindow *window;
@property (nonatomic,strong) IBOutlet MainWindowController *mainWindowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    [self.mainWindowController showWindow:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
    return YES;
}

@end
