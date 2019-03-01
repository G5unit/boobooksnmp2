/*
 BookmarksViewController.h
 
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
#import <Cocoa/Cocoa.h>
#import "BookmarksTreeItem.h"
#import "BookmarksTreeController.h"
#import "MIBTreeViewController.h"
#import "TabViewController.h"
#import "AgentBoxViewController.h"


@interface BookmarksViewController : NSViewController

@property IBOutlet BookmarksTreeController * bookmarksTreeController;
@property IBOutlet NSOutlineView * bookmarksOutlineView;
@property IBOutlet NSSplitView * bookmarksSplitView;
@property NSPopover * bookmarksPopover;
@property IBOutlet NSPopover * bookmarksAgentPopover;
@property IBOutlet NSPopover * bookmarksOIDPopover;
@property IBOutlet NSPopover * bookmarksURLPopover;
@property IBOutlet MIBTreeViewController * mibTreeViewController;
@property IBOutlet TabViewController * tabViewController;


@property IBOutlet AgentBoxViewController * agentBox;


-(IBAction)doubleClick:(id)sender;

-(IBAction)editBookmark:(id)sender;
-(IBAction)addBookmark:(id)sender;
-(IBAction)removeBookmark:(id)sender;

@end
