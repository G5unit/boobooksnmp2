/*
 Bbs2SnmpOperation.h
 
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
#import "Bbs2NetSnmp.h"

@interface Bbs2SnmpOperation : NSOperation

@property (strong) Bbs2NetSnmpRequest * requestData;
@property (strong) Bbs2NetSnmp * snmpObject;

- (id)initWithRequest:(Bbs2NetSnmpRequest *)data withSnmpObject:(Bbs2NetSnmp *)object;

@end
