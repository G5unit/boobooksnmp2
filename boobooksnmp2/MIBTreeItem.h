/*
 MIBTreeItem.h
 
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
#import <net-snmp/net-snmp-config.h>
#import <net-snmp/net-snmp-includes.h>


@interface MIBTreeItem : NSObject

+(int)objectCountValue;
+(void)objectCountReset;


//Tree Item properties
@property MIBTreeItem * parent;
@property NSMutableArray *children; //returns array of child items


//OID properties
@property struct tree *nsNode; // net-snmp tree pointer to node
@property (readonly) NSString *subID;  // This is just the subid
@property (readonly) NSString *fullOID;	// Store the full oid in .1.3.6.4.5.x.y.z notation
@property (readonly) NSString *label;
@property (readonly) NSString *oidDescription;
@property (readonly) NSString *fullPath;
@property (readonly) NSString *module;
@property (readonly) NSString *filename;
@property (readonly) NSString *status;
@property (readonly) NSString *access;
@property (readonly) NSString *type;
@property (readonly) NSString *textconv;
@property (readonly) NSString *arguments;
@property (readonly) NSString *hint;
@property (readonly) NSString *units;
@property (readonly) NSString *reference;
@property (readonly) NSString *defaultValue;
@property (readonly) NSArray *varbinds;
@property (readonly) NSArray *enums;
@property (readonly) NSArray *indexes;


- (instancetype)initWithNode:(struct tree*)node withParent:(MIBTreeItem *)newparent;

-(void)zeroOutTreeNode;

@end


