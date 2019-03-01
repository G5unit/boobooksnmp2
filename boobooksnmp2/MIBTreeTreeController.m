/*
 MIBTreeTreeController.m
 
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
#import "MIBTreeTreeController.h"

@implementation MIBTreeTreeController

- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item {
    NSPasteboardItem * dragPasteItem = [[NSPasteboardItem alloc] init];
    NSDictionary * oidDic = [NSDictionary dictionaryWithObjectsAndKeys:[[item representedObject] label],@"name",[[item representedObject] fullOID],@"oid", nil];
    NSData * itemData = [NSKeyedArchiver archivedDataWithRootObject:oidDic];
    
    [dragPasteItem setData:itemData forType:@"oidDrag.type"];
    return dragPasteItem;
}

@end
