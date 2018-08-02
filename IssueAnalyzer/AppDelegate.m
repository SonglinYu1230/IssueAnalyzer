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
    // Insert code here to initialize your application
//    self.masterViewController = [[MainWindowController alloc] initWithNibName:@"MainWindowController" bundle:nil];
//
//    // 2. Add the view controller to the Window's content view
//    [self.window.contentView addSubview:self.mainWindowController.view];
    self.mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    [self.mainWindowController showWindow:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
