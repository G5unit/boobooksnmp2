/*
 TabViewItem.h
 
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
#import "FileViewController.h"
#import "QueryTableViewController.h"
#import "PreferencesViewController.h"
#import "UrlViewController.h"
#import "LogView.h"


@interface TabViewItem : NSTabViewItem

@property FileViewController * fileController;
@property QueryTableViewController * queryController;
@property PreferencesViewController * preferencesController;
@property UrlViewController * urlController;
@property LogView * logViewController;
@property (readonly) NSString * displayFile;
@property NSString * displayLabel;
@property NSString * contentsToDisplay;


-(instancetype)initFileViewWithFile:(NSString *)filePath;
-(instancetype)initQueryView;
-(instancetype)initPreferencesView;
-(instancetype)initUrlView;
-(instancetype)initLogView;

@end
