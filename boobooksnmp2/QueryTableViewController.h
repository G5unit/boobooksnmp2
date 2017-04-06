/*
 QueryTableViewController.h
 
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

#define MyPrivateTableViewDataType @"MyPrivateTableViewDataType"


@interface QueryTableViewController : NSViewController

@property IBOutlet NSArrayController * queryTableArrayController;
@property IBOutlet NSTableView * queryTableView;
@property IBOutlet NSDateFormatter * timeColumnFormater;
@property IBOutlet NSTableColumn * timeColumn;
@property IBOutlet NSTableColumn * agentColumn;
@property IBOutlet NSTableColumn * objectColumn;
@property IBOutlet NSTableColumn * actionColumn;
@property IBOutlet NSTableColumn * resultColumn;
@property IBOutlet NSTableColumn * setvalueColumn;

-(IBAction)toggleHideColumn:(id)sender;
-(void)setTimeFormat;

//- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard;
//- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation;
@end
