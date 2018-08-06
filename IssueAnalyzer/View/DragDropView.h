//
//  DragDropView.h
//  IssueAnalyzer
//
//  Created by yusonglin on 2018/8/6.
//  Copyright © 2018 yu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DragDropView;
@protocol DragDropViewDelegate <NSObject>;

@optional
- (void)dragDropView:(DragDropView *)view didGetFile:(NSString *)filePath;

@end

@interface DragDropView : NSView <NSDraggingDestination>
/**<, NSDraggingDestination, NSPasteboardItemDataProvider>*/

@property (nonatomic, weak) id<DragDropViewDelegate> delegate;

- (id)initWithCoder:(NSCoder *)coder;

@end
