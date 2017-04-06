/*
 Bbs2NetSnmp.h
 
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
#import "TabViewController.h"

#import <net-snmp/net-snmp-config.h>
#import <net-snmp/net-snmp-includes.h>

@interface Bbs2NetSnmpRequest : NSObject
    @property NSDictionary * agent;
    @property NSDictionary * oid;
    @property NSString * setValue;
    @property NSInteger requestType;

@end


@interface Bbs2NetSnmp : NSObject

@property IBOutlet TabViewController * tabView;
@property (readonly) struct tree * rootNode;
@property netsnmp_log_handler * bbs2logHandler;

-(void)reInitNetSnmp;
-(NSArray *)searchMibTree:(NSString *)searchString;

-(NSString *)snmpGetRequest:(Bbs2NetSnmpRequest *)requestData;
-(NSString *)snmpWalkRequest:(Bbs2NetSnmpRequest *)requestData;

@end
