/*
 MIBTreeViewController.h
 
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

#import "Bbs2NetSnmp.h"
#import "MIBTreeItem.h"

@interface MIBTreeViewController : NSViewController

@property IBOutlet NSTreeController * mibTreeController;
@property IBOutlet NSOutlineView * mibTreeOutlineView;
@property IBOutlet NSSearchField * searchField;
@property IBOutlet NSPopUpButton * searchResultsPopUpButton;
@property IBOutlet NSTreeController * bookmarksTreeController;


//IBoutlets for OID fields
/*
@property IBOutlet NSTextField * oidObjectTextField;
@property IBOutlet NSTextField * oidOIDTextField;
@property IBOutlet NSTextField * oidTypeTextField;
@property IBOutlet NSTextField * oidFileTextField;
@property IBOutlet NSTextField * oidModuleTextField;
@property IBOutlet NSTextField * oidStatusTextField;
@property IBOutlet NSTextField * oidTextConvTextField;
@property IBOutlet NSTextField * oidSetValueTextField;
@property IBOutlet NSTextField * oidAccessTextField;
@property IBOutlet NSTextView * oidDescriptionTextView;
*/

@property IBOutlet Bbs2NetSnmp * bbs2NetSnmp;

-(void)reloadTree;
-(IBAction)searchTree:(id)sender;
-(IBAction)selectFoundOID:(id)sender;
-(IBAction)reloadTreeAction:(id)sender;

@end
