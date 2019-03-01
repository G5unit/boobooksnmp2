/*
 MMTabBarModel.m
 
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
#import "MMTabBarModel.h"

@implementation MMTabBarModel

- (instancetype)init {
    if (self = [super init]) {
        _isProcessing = NO;
        _icon = nil;
        _iconName = nil;
        _largeImage = nil;
        _objectCount = 2;
        _isEdited = NO;
        _hasCloseButton = YES;
        _title = @"Untitled";
        _objectCountColor = nil;
        _showObjectCount = NO;
    }
    return self;
}

@end
