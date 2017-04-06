/*
 BookmarksViewController.m
 
 Boobooksnmp2
 Cocoa based user interface program with a MIB browser and SNMP functionality
 Copyright (C) <2017>  <Faruk Grozdanic>
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 For a copy of the GNU General Public License see
 <http://www.gnu.org/licenses/>.
 
 */
#import "BookmarksViewController.h"

@interface BookmarksViewController ()

@end

@implementation BookmarksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    //REgister for bookmarks outline view selection change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bookmarkSelectionChange:)
                                                 name:NSOutlineViewSelectionDidChangeNotification object:_bookmarksOutlineView];

    

    //Load Bookmarks
    [_bookmarksOutlineView registerForDraggedTypes:[NSArray arrayWithObjects:@"bookmarksDrag.type",@"oidDrag.type",@"public.url",nil]];
    [_bookmarksOutlineView setDoubleAction:@selector(doubleClick:)];
    [_bookmarksOutlineView setHidden:YES];
    [_bookmarksTreeController loadBookmarks];
    [_bookmarksOutlineView setHidden:NO];

}
-(void)viewWillDisappear {
    [_bookmarksTreeController saveBookmarks];
}
-(void)bookmarkSelectionChange:(id)sender {
    if([_bookmarksPopover isShown]) {
        [_bookmarksPopover close];
        _bookmarksPopover = nil;
        [self showBookmarkPopover];
    }
}

-(IBAction)doubleClick:(id)sender {
    BookmarksTreeItem * selectedItem;
    
    if([[_bookmarksTreeController selectedObjects] count] > 0) {
        selectedItem = [[_bookmarksTreeController selectedObjects] objectAtIndex:0];
    }
    
    if(selectedItem && selectedItem.bookmarkType == 1) {
        NSMutableDictionary * agentDictionary = [[NSMutableDictionary alloc] init];
        //For agent just populate everything
        if(selectedItem.label) { [agentDictionary setValue:selectedItem.label forKey:@"Name"]; }
        if(selectedItem.agentHostname) { [agentDictionary setValue:selectedItem.agentHostname forKey:@"Hostname"]; }
        [agentDictionary setValue:[NSNumber numberWithInteger:selectedItem.agentSnmpRetries] forKey:@"Retries"];
        [agentDictionary setValue:[NSNumber numberWithInteger:selectedItem.agentSnmpTimeout] forKey:@"Timeout"];
        [agentDictionary setValue:[NSNumber numberWithInteger:selectedItem.agentSnmpVersion] forKey:@"Version"];

        if(selectedItem.agentReadCommunity) { [agentDictionary setValue:selectedItem.agentReadCommunity forKey:@"Readcommunity"]; }
        if(selectedItem.agentWriteCommunity) { [agentDictionary setValue:selectedItem.agentWriteCommunity forKey:@"Writecommunity"]; }
        
        if(selectedItem.agentV3Username) { [agentDictionary setValue:selectedItem.agentV3Username forKey:@"v3Username"]; }
        if(selectedItem.agentV3Context) { [agentDictionary setValue:selectedItem.agentV3Context forKey:@"v3Context"]; }
        [agentDictionary setValue:selectedItem.agentV3AuthMethod forKey:@"v3AuthMethod"];
        [agentDictionary setValue:selectedItem.agentV3AuthProto forKey:@"v3AuthProto"];
        if(selectedItem.agentV3AuthPhrase) { [agentDictionary setValue:selectedItem.agentV3AuthPhrase forKey:@"v3AuthPhrase"]; }
        [agentDictionary setValue:selectedItem.agentV3PrivProto forKey:@"v3PrivProto"];
        if(selectedItem.agentV3PrivPhrase) { [agentDictionary setValue:selectedItem.agentV3PrivPhrase forKey:@"v3PrivPhrase"]; }

        [_agentBox setAgentDictionary:[agentDictionary mutableCopy]];
    }
    else if(selectedItem && selectedItem.bookmarkType == 2) {
        NSMutableDictionary * oidDictionary = [[NSMutableDictionary alloc] init];
        [_mibTreeViewController selectFoundOID:self];
        if(selectedItem.label) { [oidDictionary setValue:selectedItem.label forKey:@"Name"]; }
        if(selectedItem.oid) { [oidDictionary setValue:selectedItem.oid forKey:@"OID"]; }
        
        [_agentBox setOidDictionary:[oidDictionary mutableCopy]];
    }
    else if(selectedItem && selectedItem.bookmarkType == 3 && selectedItem.url) {
        // For url check to see if openURLs in external app is selected, if so open in browser,
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"useSystemBrowser"] == YES) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:selectedItem.url]];
        } else {
            // else open in URL view
            [_tabViewController addUrlViewWithUrl:selectedItem.url];
        }
    }
}
-(void)showBookmarkPopover {
    BookmarksTreeItem * selectedItem;
    NSInteger relativeRow;

    if([[_bookmarksTreeController selectedObjects] count] > 0) {
        selectedItem = [[_bookmarksTreeController selectedObjects] objectAtIndex:0];
        relativeRow = [_bookmarksOutlineView selectedRow];
    }
    
    if(selectedItem.bookmarkType == 1) {
        _bookmarksPopover = _bookmarksAgentPopover;
    }
    else if(selectedItem.bookmarkType == 2) {
        _bookmarksPopover = _bookmarksOIDPopover;
    }
    else if(selectedItem.bookmarkType == 3) {
        _bookmarksPopover = _bookmarksURLPopover;
    }
    if(relativeRow > -1 && selectedItem) {
        [_bookmarksPopover showRelativeToRect:[_bookmarksOutlineView rectOfRow:relativeRow] ofView:_bookmarksOutlineView preferredEdge:NSRectEdgeMaxX];
    }
    
}

-(IBAction)editBookmark:(id)sender {

    if([_bookmarksPopover isShown]) {
        [_bookmarksPopover close];
        _bookmarksPopover = nil;
        [_bookmarksTreeController saveBookmarks];
    }
    else {
        [self showBookmarkPopover];
    }
 }

-(IBAction)addBookmark:(id)sender {
    if([sender tag] == 1) {
        [_bookmarksTreeController addObject:[[BookmarksTreeItem alloc] initWithAgent:nil]];
    } else if([sender tag] == 2) {
        [_bookmarksTreeController addObject:[[BookmarksTreeItem alloc] initWithOID:nil]];
    } else if([sender tag] == 3) {
        [_bookmarksTreeController addObject:[[BookmarksTreeItem alloc] initWithURL:nil]];
    }
    [self editBookmark:self];
    [_bookmarksTreeController saveBookmarks];
}
-(IBAction)removeBookmark:(id)sender {
    //Show popup notification or alert asking user if yes they want to delete bookmark
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Confirm to delete selected bookmark(s) ?"];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    if ([alert runModal] == NSAlertFirstButtonReturn && [_bookmarksTreeController selectedObjects]) {
        [_bookmarksTreeController removeObjectsAtArrangedObjectIndexPaths:[_bookmarksTreeController selectionIndexPaths]];
        [_bookmarksTreeController saveBookmarks];
    }
}

@end
