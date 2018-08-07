//
//  DragDropView.m
//  IssueAnalyzer
//
//  Created by yusonglin on 2018/8/6.
//  Copyright © 2018 yu. All rights reserved.
//

#import "DragDropView.h"

@implementation DragDropView

- (instancetype)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

- (void)setup {
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [self setWantsLayer:YES];
//    [self.layer setBackgroundColor:[[NSColor grayColor] CGColor]];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [[NSColor grayColor] CGColor];
    self.layer.cornerRadius = 5.f;
}

#pragma mark - NSDraggingDestination Delegate Methods

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation operation = NSDragOperationNone;
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        operation =  NSDragOperationCopy;
    }
    return operation;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSArray *list = [pasteboard propertyListForType:NSFilenamesPboardType];
    NSLog(@"Dragges list: %@", list);
    
    BOOL result = [list count] > 0;
    if (result && self.delegate && [self.delegate respondsToSelector:@selector(dragDropView:didGetFile:)]) {
        [self.delegate dragDropView:self didGetFile:list[0]];
    }
    return result;
}

@end
