/*
 Bbs2SnmpOperation.m
 
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
#import "Bbs2SnmpOperation.h"

@implementation Bbs2SnmpOperation
- (id)initWithRequest:(Bbs2NetSnmpRequest *)data withSnmpObject:(Bbs2NetSnmp *)object {
    if (self = [super init]) {
        _requestData = data;
        _snmpObject = object;
    }
    return self;
}

-(void)main {
    @try {
        // Do some work on myData and report the results.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2operationStarted" object:self];
        if(_requestData.requestType == 4) {
            [_snmpObject snmpWalkRequest:_requestData];
        } else {
            [_snmpObject snmpGetRequest:_requestData];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2operationEnded" object:self];
    }
    @catch(NSException *ex) {
        // Do not rethrow exceptions.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2operationEnded" object:self];
        NSDictionary * snmpOperatinsNotice = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",
                            [NSString stringWithFormat:@"[Bbs2] MIB Tree Reload issue: %@",[ex reason]],@"message", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:snmpOperatinsNotice];
    }
}
@end
