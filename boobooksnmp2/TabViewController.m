/*
 TabViewController.m
 
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
#import "TabViewController.h"

@interface TabViewController ()

@end

@implementation TabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    //Setup MMTabBar
    [_mmTabBar setButtonMinWidth:100];
    [_mmTabBar setButtonMaxWidth:200];
    [_mmTabBar setButtonOptimumWidth:130];
    [_mmTabBar setDisableTabClose:FALSE];
    [_mmTabBar setAllowsBackgroundTabClosing:TRUE];
    [_mmTabBar setStyleNamed:@"Adium"];
    [_mmTabBar setOnlyShowCloseOnHover:TRUE];
    [_mmTabBar setCanCloseOnlyTab:TRUE];
    [_mmTabBar setHideForSingleTab:FALSE];
    [_mmTabBar setSizeButtonsToFit:TRUE];
    [_mmTabBar setUseOverflowMenu:TRUE];
    [_mmTabBar setAlwaysShowActiveTab:TRUE];
    [_mmTabBar setOrientation:MMTabBarHorizontalOrientation];
    
    //Init Log View Item
    if(!_logTabItem) {
        MMTabBarModel *newModel = [[MMTabBarModel alloc] init];
        [newModel setTitle:@"Log messages"];
        [newModel setIcon:[NSImage imageNamed:@"LogView"]];
        _logTabItem = [[TabViewItem alloc] initLogView];
        [_logTabItem setIdentifier:newModel];

    }
    //Add userInfo from Notification to Log array controller
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readLogMessage:)
                                                 name:@"Bbs2SnmpLogMessagePosted" object:nil];

}
-(void)readLogMessage:(NSNotification *)senderNotify {
    
    [[[_logTabItem logViewController] logArrayController] addObject:[senderNotify userInfo]];
}
-(IBAction)clearLogViewContent:(id)sender {
    [[[_logTabItem logViewController] logArrayController] setContent:[[NSMutableArray alloc] init]];
}
-(IBAction)openLogView:(id)sender {
    TabViewItem * existingTab = nil;
    //Find and select existing Preferences Tab View
    for(id tabs in [_tabView tabViewItems]) {
        if([tabs logViewController] != nil) {
            existingTab = tabs;
            break;
        }
    }
    //Otherwise add it to Tab view at the end, and select it
    if(existingTab == nil) {
        [_tabView addTabViewItem:_logTabItem];
        existingTab = _logTabItem;
    }
    //Select file tab view
    [_tabView selectTabViewItem:existingTab];

}

- (IBAction)addFileView:(id)sender {
    TabViewItem * existingTab = nil;
    NSString * filePath = [_filePathField stringValue];
    if(filePath && ![filePath isEqualToString:@""]) {
        //Check if view for this file already exists, if so switch to it
        for(int i=0;i<[_tabView numberOfTabViewItems];i++) {
            if([[(TabViewItem *)[[_tabView tabViewItems] objectAtIndex:i] displayFile] isEqualToString:filePath]) {
                existingTab = (TabViewItem *)[[_tabView tabViewItems] objectAtIndex:i];
                i = (int)[_tabView numberOfTabViewItems];
            }
        }
        //Otherwise create new fileView and add it to Tab view at the end, and select it
        if(existingTab == nil) {
            existingTab = [[TabViewItem alloc] initFileViewWithFile:filePath];
            if(existingTab != nil) {
                MMTabBarModel *newModel = [[MMTabBarModel alloc] init];
                [newModel setTitle:filePath];
                [newModel setIcon:[NSImage imageNamed:@"OpenMIBFile"]];
                [existingTab setIdentifier:newModel];

                [[[[existingTab fileController] textView] textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:[existingTab contentsToDisplay]]];
                [_tabView addTabViewItem:existingTab];
            }
        }
        //Select file tab view
        if(existingTab != nil) { [_tabView selectTabViewItem:existingTab]; }
    }
}

- (IBAction)addQueryView:(id)sender {
    MMTabBarModel *newModel = [[MMTabBarModel alloc] init];
    [newModel setTitle:@"Query Results"];
    TabViewItem * newQueryTab = [[TabViewItem alloc] initQueryView];
    [newQueryTab setIdentifier:newModel];
    [_tabView addTabViewItem:newQueryTab];
    [_tabView selectTabViewItem:newQueryTab];
    
}

- (IBAction)addUrlView:(id)sender {
    MMTabBarModel *newModel = [[MMTabBarModel alloc] init];
    [newModel setTitle:@"Web View"];
    [newModel setIcon:[NSImage imageNamed:@"AddWebView"]];
    TabViewItem * newUrlTab = [[TabViewItem alloc] initUrlView];
    [newUrlTab setIdentifier:newModel];
    [_tabView addTabViewItem:newUrlTab];
    [_tabView selectTabViewItem:newUrlTab];
    [[[newUrlTab urlController] urlField] becomeFirstResponder];
    
}
- (void)addUrlViewWithUrl:(NSString *)url {
    MMTabBarModel *newModel = [[MMTabBarModel alloc] init];
    [newModel setTitle:url];
    [newModel setIcon:[NSImage imageNamed:@"AddWebView"]];
    TabViewItem * newUrlTab = [[TabViewItem alloc] initUrlView];
    [newUrlTab setIdentifier:newModel];
    [_tabView addTabViewItem:newUrlTab];
    [_tabView selectTabViewItem:newUrlTab];
    
    [[[newUrlTab urlController] urlField] becomeFirstResponder];
    [[[newUrlTab urlController] urlField] setStringValue:url];
    [[[newUrlTab urlController] urlField] selectText:self];
    [[[newUrlTab urlController] webView] becomeFirstResponder];

}


-(void)addQueryResult:(NSArray *)queryResultsArray {
    if(queryResultsArray && [queryResultsArray count] > 0) {
        if([(TabViewItem *)[_tabView selectedTabViewItem] queryController]) {
            [[[(TabViewItem *)[_tabView selectedTabViewItem] queryController] queryTableArrayController] addObjects:queryResultsArray];
        } else {
            TabViewItem * queryTabView;
            for(int i=(int)[_tabView numberOfTabViewItems]-1;i>=0;i--) {
                if([(TabViewItem *)[_tabView tabViewItemAtIndex:(i)] queryController]) {
                    queryTabView = (TabViewItem *)[_tabView tabViewItemAtIndex:(i)];
                    break;
                }
            }
            if(queryTabView) {
                [_tabView selectTabViewItem:queryTabView];
                [[[queryTabView queryController] queryTableArrayController] addObjects:queryResultsArray];
            } else {
                [self addQueryView:self];
                [[[(TabViewItem *)[_tabView selectedTabViewItem] queryController] queryTableArrayController] addObjects:queryResultsArray];
            }
        }
    }
}


- (IBAction)addPreferencesView:(id)sender {
    TabViewItem * existingTab = nil;
    //Find and select existing Preferences Tab View
    for(id tabs in [_tabView tabViewItems]) {
        if([tabs preferencesController] != nil) {
            existingTab = tabs;
            break;
        }
    }
    //Otherwise create new PreferencesView and add it to Tab view at the end, and select it
    if(existingTab == nil) {
        MMTabBarModel *newModel = [[MMTabBarModel alloc] init];
        [newModel setTitle:@"Preferences"];
        [newModel setIcon:[NSImage imageNamed:@"Preferences"]];
        existingTab = [[TabViewItem alloc] initPreferencesView];
        [existingTab setIdentifier:newModel];
        [_tabView addTabViewItem:existingTab];
    }
    //Select file tab view
    [_tabView selectTabViewItem:existingTab];
}

-(IBAction)closeTab:(id)sender {
    TabViewItem * selectedTab = (TabViewItem *)[_tabView selectedTabViewItem];
    if(selectedTab) {
        [_tabView removeTabViewItem:selectedTab];
    }
}

@end
