/*
 Bbs2NetSnmpRequestHandler.m
 
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
#import "Bbs2SnmpRequestHandler.h"

@implementation Bbs2SnmpRequestHandler

-(id)init {
    if(!_snmpOpQue) {
        _snmpOpQue = [[NSOperationQueue alloc] init];
        [self setMaxOpCount:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setMaxOpCount:)
                                                     name:@"Bbs2maxConcurentOperationsChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(operationStarted:)
                                                     name:@"Bbs2operationStarted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(operationEnded:)
                                                     name:@"Bbs2operationEnded" object:nil];
    }
    _opSpinner.usesThreadedAnimation=YES; //My hope was to avoid sporadic 'uncommited CATransactions' message logged on occasion.
    _operationsInQueueCount = 0;
    return self;
}

-(void)operationStarted:(id)sender {
    if(_operationsInQueueCount == 0) {
        [_opSpinner startAnimation:self];
    }
    _operationsInQueueCount++;
}
-(void)operationEnded:(id)sender {
    _operationsInQueueCount--;
    if(_operationsInQueueCount == 0) {
        [_opSpinner stopAnimation:self];
    }
}
-(void)setMaxOpCount:(id)sender {
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"maxConcurentOperations"]) {
        _snmpOpQue.maxConcurrentOperationCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxConcurentOperations"];
    } else {
        _snmpOpQue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
}

-(NSDictionary *)collectOidInfo {
    return [_agentBox getOidDictionary];
}
-(NSDictionary *)collectAgentInfo {
    return [_agentBox getAgentDictionary];
}
-(IBAction)snmpGetRequest:(id)sender {
    
    Bbs2NetSnmpRequest * newRequest = [[Bbs2NetSnmpRequest alloc] init];
    newRequest.oid = [self collectOidInfo];
    newRequest.agent = [self collectAgentInfo];
    newRequest.requestType = 1;
    Bbs2SnmpOperation * newOp = [[Bbs2SnmpOperation alloc] initWithRequest:newRequest withSnmpObject:_bb2NetSnmpObject];
    [_snmpOpQue addOperation:newOp];
    
}
-(IBAction)snmpGetNextRequest:(id)sender {
    Bbs2NetSnmpRequest * newRequest = [[Bbs2NetSnmpRequest alloc] init];
    newRequest.oid = [self collectOidInfo];
    newRequest.agent = [self collectAgentInfo];
    newRequest.requestType = 2;
    Bbs2SnmpOperation * newOp = [[Bbs2SnmpOperation alloc] initWithRequest:newRequest withSnmpObject:_bb2NetSnmpObject];
    [_snmpOpQue addOperation:newOp];
}
-(IBAction)snmpSetRequest:(id)sender {
    Bbs2NetSnmpRequest * newRequest = [[Bbs2NetSnmpRequest alloc] init];
    newRequest.oid = [self collectOidInfo];
    newRequest.agent = [self collectAgentInfo];
    newRequest.requestType = 3;
    Bbs2SnmpOperation * newOp = [[Bbs2SnmpOperation alloc] initWithRequest:newRequest withSnmpObject:_bb2NetSnmpObject];
    [_snmpOpQue addOperation:newOp];
}
-(IBAction)snmpWalkRequest:(id)sender {
    Bbs2NetSnmpRequest * newRequest = [[Bbs2NetSnmpRequest alloc] init];
    newRequest.oid = [self collectOidInfo];
    newRequest.agent = [self collectAgentInfo];
    newRequest.requestType = 4;
    Bbs2SnmpOperation * newOp = [[Bbs2SnmpOperation alloc] initWithRequest:newRequest withSnmpObject:_bb2NetSnmpObject];
    [_snmpOpQue addOperation:newOp];
}
@end
