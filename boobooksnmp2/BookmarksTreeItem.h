/*
 BookmarksTreeItem.h
 
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

@interface BookmarksTreeItem : NSObject

// THese two properties are used for display
@property (readwrite) NSString * label;
@property (readonly) NSImage * image;

@property (readwrite) NSMutableArray *children; //returns array of child items

@property NSInteger bookmarkType; // 1=agent; 2=oid; 3=url

@property NSString * agentHostname;
@property NSInteger agentSnmpVersion;

@property NSString * agentReadCommunity;
@property NSString * agentWriteCommunity;
@property NSInteger agentSnmpRetries;
@property NSInteger agentSnmpTimeout;

@property NSString * agentV3Username;
@property NSString * agentV3Context;
@property NSString * agentV3AuthMethod;
@property NSString * agentV3AuthProto;
@property NSString * agentV3AuthPhrase;
@property NSString * agentV3PrivProto;
@property NSString * agentV3PrivPhrase;

@property NSString * oid;

@property NSString * url;


- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

- (instancetype)initWithAgent:(NSDictionary *)newagent;
- (instancetype)initWithOID:(NSDictionary *)oid;
- (instancetype)initWithURL:(NSDictionary *)newUrl;
@end
