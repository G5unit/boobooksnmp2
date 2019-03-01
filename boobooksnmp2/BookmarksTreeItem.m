/*
 BookmarksTreeItem.m
 
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
#import "BookmarksTreeItem.h"

@implementation BookmarksTreeItem

-(instancetype)init {
    self = [super init];
    if (self != nil)
    {
        /*
        _url = @"www.github.com";
        _label = @"Untitled Plain";
        _children = [[NSMutableArray alloc] init];
        _bookmarkType = 3;
      */
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _label = [coder decodeObjectForKey:@"BBS2BKLabel"];
        _bookmarkType = [coder decodeIntegerForKey:@"BBS2BKBookmarkType"];
        if(_bookmarkType == 1) {
            _agentHostname = [coder decodeObjectForKey:@"BBS2BKagentHostname"];
            _agentSnmpVersion = [coder decodeIntegerForKey:@"BBS2BKagentSnmpVersion"];
            
            _agentReadCommunity = [coder decodeObjectForKey:@"BBS2BKagentReadCommunity"];
            _agentWriteCommunity = [coder decodeObjectForKey:@"BBS2BKagentWriteCommunity"];
            _agentSnmpRetries = [coder decodeIntegerForKey:@"BBS2BKagentSnmpRetries"];
            _agentSnmpTimeout = [coder decodeIntegerForKey:@"BBS2BKagentSnmpTimeout"];
                
            _agentV3Username = [coder decodeObjectForKey:@"BBS2BKagentV3Username"];
            _agentV3Context = [coder decodeObjectForKey:@"BBS2BKagentV3Context"];
            _agentV3AuthMethod = [coder decodeObjectForKey:@"BBS2BKagentV3AuthMethod"];
            _agentV3AuthProto = [coder decodeObjectForKey:@"BBS2BKagentV3AuthProto"];
            _agentV3AuthPhrase = [coder decodeObjectForKey:@"BBS2BKagentV3AuthPhrase"];
            _agentV3PrivProto = [coder decodeObjectForKey:@"BBS2BKagentV3PrivProto"];
            _agentV3PrivPhrase = [coder decodeObjectForKey:@"BBS2BKagentV3PrivPhrase"];
        }
        else if(_bookmarkType == 2) {
            _oid = [coder decodeObjectForKey:@"BBS2BKOid"];
        }
        else if(_bookmarkType == 3) {
            _url = [coder decodeObjectForKey:@"BBS2BKUrl"];

        }
        _children = [coder decodeObjectForKey:@"BBS2BKchildren"];

    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_label forKey:@"BBS2BKLabel"];
    [coder encodeInteger:_bookmarkType forKey:@"BBS2BKBookmarkType"];
    if(_bookmarkType == 1) {
            [coder encodeObject:_agentHostname forKey:@"BBS2BKagentHostname"];
            [coder encodeInteger:_agentSnmpVersion forKey:@"BBS2BKagentSnmpVersion"];
            
            [coder encodeObject:_agentReadCommunity forKey:@"BBS2BKagentReadCommunity"];
            [coder encodeObject:_agentWriteCommunity forKey:@"BBS2BKagentWriteCommunity"];
            [coder encodeInteger:_agentSnmpRetries forKey:@"BBS2BKagentSnmpRetries"];
            [coder encodeInteger:_agentSnmpTimeout forKey:@"BBS2BKagentSnmpTimeout"];
            
            [coder encodeObject:_agentV3Username forKey:@"BBS2BKagentV3Username"];
            [coder encodeObject:_agentV3Context forKey:@"BBS2BKagentV3Context"];
            [coder encodeObject:_agentV3AuthMethod forKey:@"BBS2BKagentV3AuthMethod"];
            [coder encodeObject:_agentV3AuthProto forKey:@"BBS2BKagentV3AuthProto"];
            [coder encodeObject:_agentV3AuthPhrase forKey:@"BBS2BKagentV3AuthPhrase"];
            [coder encodeObject:_agentV3PrivProto forKey:@"BBS2BKagentV3PrivProto"];
            [coder encodeObject:_agentV3PrivPhrase forKey:@"BBS2BKagentV3PrivPhrase"];
    }
    else if(_bookmarkType == 2) {
        [coder encodeObject:_oid forKey:@"BBS2BKOid"];
    }
    else if(_bookmarkType ==3) {
        [coder encodeObject:_url forKey:@"BBS2BKUrl"];
    }
    [coder encodeObject:_children forKey:@"BBS2BKchildren"];
}

- (instancetype)initWithAgent:(NSDictionary *)newagent
{
    self = [super init];
    if (self != nil)
    {
        _label = @"";
        _children = [[NSMutableArray alloc] init];
        _bookmarkType = 1;
        _agentSnmpVersion = 2;
        _agentSnmpRetries = [[NSUserDefaults standardUserDefaults] integerForKey:@"snmpRequestRetries"];
        _agentSnmpTimeout = [[NSUserDefaults standardUserDefaults] integerForKey:@"snmpRequestTimeout"];
        
        _agentV3AuthMethod = @"Authentication";
        _agentV3AuthProto = @"SHA";
        _agentV3PrivProto = @"AES";
        
        if(newagent) {
            _label = [newagent objectForKey:@"name"];
            _agentHostname = [newagent objectForKey:@"Hostname"];
            _agentSnmpVersion = [[newagent objectForKey:@"snmpVersion"] integerValue];
        
            _agentReadCommunity = [newagent objectForKey:@"ReadCommunity"];
            _agentWriteCommunity = [newagent objectForKey:@"WriteCommunity"];
            _agentSnmpRetries = [[newagent objectForKey:@"snmpRetries"] integerValue];
            _agentSnmpTimeout = [[newagent objectForKey:@"snmpTimeout"] integerValue];
        
            _agentV3Username = [newagent objectForKey:@"v3Username"];
            _agentV3Context = [newagent objectForKey:@"v3Context"];
            _agentV3AuthMethod = [newagent objectForKey:@"v3AuthMethod"];
            _agentV3AuthProto = [newagent objectForKey:@"v3AuthProto"];
            _agentV3AuthPhrase = [newagent objectForKey:@"v3AuthPhrase"];
            _agentV3PrivProto = [newagent objectForKey:@"v3PrivProto"];
            _agentV3PrivPhrase = [newagent objectForKey:@"v3PrivPhrase"];
        }

    }
    return self;
}
- (instancetype)initWithOID:(NSDictionary *)oid
{
    self = [super init];
    if (self != nil)
    {
        _oid = @"";
        _label = @"Untitled Oid";
        if(oid) {
            _oid = [oid objectForKey:@"oid"];
            _label = [oid objectForKey:@"name"];
        }
        _children = [[NSMutableArray alloc] init];
        _bookmarkType = 2;
        
    }
    return self;
}
- (instancetype)initWithURL:(NSDictionary *)newUrl
{
    self = [super init];
    if (self != nil)
    {
        _label = @"Untitled Url";
        _url = @"";
        if(newUrl) {
            _url = [newUrl objectForKey:@"url"];
            _label = [newUrl objectForKey:@"url"];
        }
        _children = [[NSMutableArray alloc] init];
        _bookmarkType = 3;
    }
    return self;
}


@end
