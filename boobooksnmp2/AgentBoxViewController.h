/*
 AgentBoxViewController.h
 
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

@interface AgentBoxViewController : NSViewController

@property IBOutlet NSTextField * oidObject;
@property IBOutlet NSTextField * oidOID;
@property IBOutlet NSTextField * oidSetValue;

@property IBOutlet NSTextField * agentName;
@property IBOutlet NSTextField * agentHostname;
@property IBOutlet NSMatrix * agentSnmpVersion;

@property IBOutlet NSTextField * agentReadCommunity;
@property IBOutlet NSTextField * agentWriteCommunity;
@property IBOutlet NSTextField * agentSnmpRetries;
@property IBOutlet NSTextField * agentSnmpTimeout;
@property IBOutlet NSStepper * agentTimeoutStepper;
@property IBOutlet NSStepper * agentRetriesStepper;

@property IBOutlet NSButton * agentSnmpv3Button;
@property IBOutlet NSPopover * agentSnmpv3Popover;
@property IBOutlet NSTextField * agentV3Username;
@property IBOutlet NSTextField * agentV3Context;
@property IBOutlet NSComboBox * agentV3AuthMethod;
@property IBOutlet NSComboBox * agentV3AuthProto;
@property IBOutlet NSTextField * agentV3AuthPhrase;
@property IBOutlet NSComboBox * agentV3PrivProto;
@property IBOutlet NSTextField * agentV3PrivPhrase;



- (void)viewDidAppear;

-(NSDictionary *)getAgentDictionary;
-(void)setAgentDictionary:(NSDictionary *)agentDictionary;
-(NSDictionary *)getOidDictionary;
-(void)setOidDictionary:(NSDictionary *)oidDictionary;
@end
