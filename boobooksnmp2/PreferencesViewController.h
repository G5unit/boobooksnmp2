/*
 PreferencesViewController.h
 
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
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "MibFilesArrayController.h"


@interface PreferencesViewController : NSViewController


@property IBOutlet MibFilesArrayController * mibFilesArrayController;
@property IBOutlet NSTableView * mibTableView;
@property IBOutlet NSTextField * snmpRetries;
@property IBOutlet NSTextField * snmpTimeout;
@property IBOutlet NSStepper * timeoutStepper;
@property IBOutlet NSStepper * retriesStepper;
@property IBOutlet NSTextField * snmpMaxOps;
@property IBOutlet NSStepper * maxOpsStepper;
@property IBOutlet NSButton * addMIBFilesButton;

-(IBAction)addMibFileToLibrary:(id)sender;

-(IBAction)selecttoload:(id)sender;
-(IBAction)deselecttoload:(id)sender;
-(IBAction)selectall:(id)sender;
-(IBAction)deselectall:(id)sender;
-(IBAction)updateMaxOps:(id)sender;

- (void)viewDidLoad;
- (void)viewDidAppear;
-(IBAction)saveMIBState:(id)sender;
@end
