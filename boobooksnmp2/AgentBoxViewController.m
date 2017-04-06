/*
 AgentBoxViewController.m
 
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
#import "AgentBoxViewController.h"

@interface AgentBoxViewController ()

@end

@implementation AgentBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewDidAppear{
    [super viewDidAppear];
    // Init the selection Objects to their defaults
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"snmpRequestTimeout"]) {
        _agentTimeoutStepper.integerValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"snmpRequestTimeout"];
        [_agentSnmpTimeout takeIntegerValueFrom:_agentTimeoutStepper];
    }
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"snmpRequestRetries"]) {
        _agentRetriesStepper.integerValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"snmpRequestRetries"];
        [_agentSnmpRetries takeIntegerValueFrom:_agentRetriesStepper];
    }
    [_agentV3AuthMethod selectItemAtIndex:0];
    [_agentV3AuthProto selectItemAtIndex:0];
    [_agentV3PrivProto selectItemAtIndex:0];

}

-(NSDictionary *)getAgentDictionary {
    NSMutableDictionary * agentDictionary = [[NSMutableDictionary alloc] init];
    // If Agent Name is not specified, populate hostname instead
    if([_agentName stringValue] && ![[_agentName stringValue] isEqualToString:@""]) { [agentDictionary setValue:[_agentName stringValue] forKey:@"Name"]; }
    else if([_agentHostname stringValue]) { [agentDictionary setValue:[_agentHostname stringValue] forKey:@"Name"]; }

    
    if([_agentHostname stringValue]) { [agentDictionary setValue:[_agentHostname stringValue] forKey:@"Hostname"]; }
    if([_agentReadCommunity stringValue]) { [agentDictionary setValue:[_agentReadCommunity stringValue] forKey:@"Readcommunity"]; }
    if([_agentWriteCommunity stringValue]) { [agentDictionary setValue:[_agentWriteCommunity stringValue] forKey:@"Writecommunity"]; }
    
    [agentDictionary setValue:[NSNumber numberWithInteger:[_agentRetriesStepper integerValue]] forKey:@"Retries"];
    [agentDictionary setValue:[NSNumber numberWithInteger:[_agentTimeoutStepper integerValue]] forKey:@"Timeout"];
    [agentDictionary setValue:[NSNumber numberWithInteger:[_agentSnmpVersion selectedTag]] forKey:@"Version"];
    
    
    /* snmp v3 params
     -a PROTOCOL		set authentication protocol (MD5|SHA)
     -A PASSPHRASE		set authentication protocol pass phrase
     -e ENGINE-ID		set security engine ID (e.g. 800000020109840301)
     -E ENGINE-ID		set context engine ID (e.g. 800000020109840301)
     -l LEVEL		set security level (noAuthNoPriv|authNoPriv|authPriv)
     -n CONTEXT		set context name (e.g. bridge1)
     -u USER-NAME		set security name (e.g. bert)
     -x PROTOCOL		set privacy protocol (DES|AES)
     -X PASSPHRASE		set privacy protocol pass phrase
     -Z BOOTS,TIME		set destination engine boots/time
     */
    if([_agentV3Username stringValue]) { [agentDictionary setValue:[_agentV3Username stringValue] forKey:@"v3Username"]; }
    if([_agentV3Context stringValue]) { [agentDictionary setValue:[_agentV3Context stringValue] forKey:@"v3Context"]; }
    [agentDictionary setValue:[NSNumber numberWithInteger:[_agentV3AuthMethod indexOfSelectedItem]] forKey:@"v3Authmethod"];
    [agentDictionary setValue:[NSNumber numberWithInteger:[_agentV3AuthProto indexOfSelectedItem]] forKey:@"v3Authproto"];
    if([_agentV3AuthPhrase stringValue]) { [agentDictionary setValue:[_agentV3AuthPhrase stringValue] forKey:@"v3Authphrase"]; }
    [agentDictionary setValue:[NSNumber numberWithInteger:[_agentV3PrivProto indexOfSelectedItem]] forKey:@"v3Privproto"];
    if([_agentV3PrivPhrase stringValue]) { [agentDictionary setValue:[_agentV3PrivPhrase stringValue] forKey:@"v3Privphrase"]; }
    
    return [agentDictionary mutableCopy];
}
-(void)setAgentDictionary:(NSDictionary *)agentDictionary {
    //Reset to blank/defaults
    [_agentName setStringValue:@""];
    [_agentHostname setStringValue:@""];
    [_agentReadCommunity setStringValue:@""];
    [_agentWriteCommunity setStringValue:@""];
    [_agentV3Username setStringValue:@""];
    [_agentV3Context setStringValue:@""];
    [_agentV3AuthPhrase setStringValue:@""];
    [_agentV3PrivPhrase setStringValue:@""];
    [_agentV3AuthMethod setStringValue:@"Authentication"];
    [_agentV3AuthProto setStringValue:@"SHA"];
    [_agentV3PrivProto setStringValue:@"AES"];
    
    /*        if(selectedItem.label) { [agentDictionary setValue:selectedItem.label forKey:@"Name"]; }
     if(selectedItem.agentHostname) { [agentDictionary setValue:selectedItem.agentHostname forKey:@"Hostname"]; }
     [agentDictionary setValue:[NSNumber numberWithInteger:selectedItem.agentSnmpRetries] forKey:@"Retries"];
     [agentDictionary setValue:[NSNumber numberWithInteger:selectedItem.agentSnmpTimeout] forKey:@"Timeout"];
     [agentDictionary setValue:[NSNumber numberWithInteger:selectedItem.agentSnmpVersion] forKey:@"Version"];
     
     if(selectedItem.agentReadCommunity) { [agentDictionary setValue:selectedItem.agentReadCommunity forKey:@"Readcommunity"]; }
     if(selectedItem.agentWriteCommunity) { [agentDictionary setValue:selectedItem.agentWriteCommunity forKey:@"Writecommunity"]; }
     
     if(selectedItem.agentV3Username) { [agentDictionary setValue:selectedItem.agentV3Username forKey:@"v3Username"]; }
     if(selectedItem.agentV3Context) { [agentDictionary setValue:selectedItem.agentV3Context forKey:@"v3Context"]; }
     [agentDictionary setValue:selectedItem.agentV3AuthMethod forKey:@"v3AuthMethod"];
     [agentDictionary setValue:selectedItem.agentV3AuthProto forKey:@"v3AuthProto"];
     if(selectedItem.agentV3AuthPhrase) { [agentDictionary setValue:selectedItem.agentV3AuthPhrase forKey:@"v3AuthPhrase"]; }
     [agentDictionary setValue:selectedItem.agentV3PrivProto forKey:@"v3PrivProto"];
     if(selectedItem.agentV3PrivPhrase) { [agentDictionary setValue:selectedItem.agentV3PrivPhrase forKey:@"v3PrivPhrase"]; }
     */
    
    if([agentDictionary valueForKey:@"Name"]) { [_agentName setStringValue:[agentDictionary valueForKey:@"Name"]];}
    if([agentDictionary valueForKey:@"Hostname"]) { [_agentHostname setStringValue:[agentDictionary valueForKey:@"Hostname"]];}
    if([agentDictionary valueForKey:@"Readcommunity"]) { [_agentReadCommunity setStringValue:[agentDictionary valueForKey:@"Readcommunity"]];}
    if([agentDictionary valueForKey:@"Writecommunity"]) { [_agentWriteCommunity setStringValue:[agentDictionary valueForKey:@"Writecommunity"]];}
    if([agentDictionary valueForKey:@"Version"]) { [_agentSnmpVersion selectCellWithTag:[[agentDictionary valueForKey:@"Version"] integerValue]];}
    if([agentDictionary valueForKey:@"Retries"]) { [_agentRetriesStepper setIntValue:(int)[[agentDictionary valueForKey:@"Retries"] integerValue]]; }
    if([agentDictionary valueForKey:@"Timeout"]) { [_agentTimeoutStepper setIntValue:(int)[[agentDictionary valueForKey:@"Timeout"] integerValue]]; }
    
    if([agentDictionary valueForKey:@"v3Username"]) { [_agentV3Username setStringValue:[agentDictionary valueForKey:@"v3Username"]];}
    if([agentDictionary valueForKey:@"v3Context"]) { [_agentV3Context setStringValue:[agentDictionary valueForKey:@"v3Context"]];}
    if([agentDictionary valueForKey:@"v3AuthMethod"]) { [_agentV3AuthMethod setStringValue:[agentDictionary valueForKey:@"v3AuthMethod"]];}
    if([agentDictionary valueForKey:@"v3AuthProto"]) { [_agentV3AuthProto selectItemWithObjectValue:@"v3AuthProto"];}
    if([agentDictionary valueForKey:@"v3AuthPhrase"]) { [_agentV3AuthPhrase setStringValue:[agentDictionary valueForKey:@"v3AuthPhrase"]];}
    if([agentDictionary valueForKey:@"v3PrivPhrase"]) { [_agentV3PrivPhrase setStringValue:[agentDictionary valueForKey:@"v3PrivPhrase"]];}
    if([agentDictionary valueForKey:@"v3PrivProto"]) { [_agentV3PrivProto selectItemWithObjectValue:@"vPrivProto"]; }
                                                        //setStringValue:[agentDictionary valueForKey:@"v3PrivProto"]];}

}
-(NSDictionary *)getOidDictionary {
    NSMutableDictionary * oidDictionary = [[NSMutableDictionary alloc] init];
    if([_oidObject stringValue]) { [oidDictionary setValue:[_oidObject stringValue] forKey:@"Name"]; }
    if([_oidOID stringValue]) { [oidDictionary setValue:[_oidOID stringValue] forKey:@"OID"]; }
    if([_oidSetValue stringValue]) { [oidDictionary setValue:[_oidSetValue stringValue] forKey:@"SetValue"]; }
    
    return [oidDictionary mutableCopy];
}
-(void)setOidDictionary:(NSDictionary *)oidDictionary {
    if([oidDictionary valueForKey:@"Name"]) { [_oidObject setStringValue:[oidDictionary valueForKey:@"Name"]]; }
    if([oidDictionary valueForKey:@"OID"]) { [_oidOID setStringValue:[oidDictionary valueForKey:@"OID"]]; }
}

-(IBAction)showSnmpv3Popover:(id)sender {
    
    if([_agentSnmpv3Popover isShown]) {
        [_agentSnmpv3Popover close];
    }
    else {
        [_agentSnmpv3Popover showRelativeToRect:[_agentSnmpv3Button bounds] ofView:self.view preferredEdge:NSRectEdgeMaxX];
    }
}

@end
