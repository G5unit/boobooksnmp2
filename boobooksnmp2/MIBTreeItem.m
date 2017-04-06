/*
 MIBTreeItem.m
 
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
#import "MIBTreeItem.h"

static int objectCount = 0;

@implementation MIBTreeItem
+(int)objectCountValue {
    return objectCount;
}
+(void)objectCountReset{
    objectCount = 0;
}

- (instancetype)initWithNode:(struct tree*)node withParent:(MIBTreeItem *)newparent
{
    self = [super init];
    if (self != nil)
    {
        objectCount++;
        _nsNode = node;
        _parent = newparent;

        if (_nsNode->subid) {
            _subID =  [NSString stringWithFormat:@"%lu", _nsNode->subid];
        }
        else {
            _subID =  @"0";
        }
        if (_nsNode->label && _nsNode->label != nil) {
            _label = [NSString stringWithUTF8String:_nsNode->label];
        }
        else {
            _label = [self subID];
        }
        
        // Populate children array
        _children = [[NSMutableArray alloc] init];
        struct tree * treeP;
        for (treeP = _nsNode->child_list; treeP; treeP = treeP->next_peer) {
            [_children addObject:[[MIBTreeItem alloc] initWithNode:treeP withParent:self]];
        }
        /* Sort children array */
        if([_children count] > 1) {
            [_children sortUsingComparator:(NSComparator)^(id obj1, id obj2) {
                if ([obj1 nsNode]->subid > [obj2 nsNode]->subid) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                if ([obj1 nsNode]->subid < [obj2 nsNode]->subid) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
        }


    }
    return self;
}
// String for textual convention
- (NSString *)textconv {
    NSString * tmpDescStr = @"";
    if(self.nsNode->tc_index && self.nsNode->tc_index >= 0 && get_tc_description(self.nsNode->tc_index)) {
        tmpDescStr = [tmpDescStr stringByAppendingString:[NSString stringWithUTF8String:get_tc_description(self.nsNode->tc_index)]];
    }
    return tmpDescStr;

}
- (NSString *)arguments {
    NSString * tmpDescStr = @"";
    if(self.nsNode->augments && self.nsNode->augments != nil) {
        tmpDescStr = [tmpDescStr stringByAppendingFormat:@"%s",self.nsNode->augments];
    }
    return tmpDescStr;
    
}
- (NSString *)hint {
    NSString * tmpDescStr = @"";
    if(self.nsNode->hint && self.nsNode->hint != nil) {
        tmpDescStr = [tmpDescStr stringByAppendingFormat:@"%s",self.nsNode->hint];
    }
    return tmpDescStr;
    
}
- (NSString *)units {
    NSString * tmpDescStr = @"";
    if(self.nsNode->units && self.nsNode->units != nil) {
        tmpDescStr = [tmpDescStr stringByAppendingFormat:@"%s",self.nsNode->units];
    }
    return tmpDescStr;
    
}
- (NSString *)reference {
    NSString * tmpDescStr = @"";
    if(self.nsNode->reference && self.nsNode->reference != nil) {
        tmpDescStr = [tmpDescStr stringByAppendingFormat:@"%s",self.nsNode->reference];
    }
    return tmpDescStr;
    
}
- (NSString *)defaultValue {
    NSString * tmpDescStr = @"";
    if(self.nsNode->defaultValue && self.nsNode->defaultValue != nil) {
        tmpDescStr = [tmpDescStr stringByAppendingFormat:@"%s",self.nsNode->defaultValue];
    }
    return tmpDescStr;
    
}
- (NSArray *)indexes {
    NSMutableArray * indexArray = [[NSMutableArray alloc] init];
    if(self.nsNode->indexes && self.nsNode->indexes != nil) {
        struct index_list * indexes = self.nsNode->indexes;
        if(indexes->ilabel) { [indexArray addObject:[NSString stringWithUTF8String:indexes->ilabel]]; }
        while(indexes->next && indexes->next != nil) {
            indexes = indexes->next;
            if(indexes->ilabel) { [indexArray addObject:[NSString stringWithUTF8String:indexes->ilabel]]; }
        }
    }

    return [indexArray copy];
    
}
- (NSArray *)enums {
    NSMutableArray * enumArray = [[NSMutableArray alloc] init];
    if(self.nsNode->enums && self.nsNode->enums != nil) {
        struct enum_list * enums = self.nsNode->enums;
        if(enums->label && enums->label != nil) { [enumArray addObject:[NSString stringWithUTF8String:enums->label]]; }
        while(enums->next && enums->next != nil) {
            enums = enums->next;
            if(enums->label && enums->label != nil) { [enumArray addObject:[NSString stringWithUTF8String:enums->label]]; }
        }
    }
    return [enumArray copy];

}
- (NSArray *)varbinds {
    NSMutableArray * varbindArray = [[NSMutableArray alloc] init];
    if(self.nsNode->varbinds && self.nsNode->varbinds != nil) {
        struct varbind_list * varbinds = self.nsNode->varbinds;
        if(varbinds->vblabel && varbinds->vblabel != nil) { [varbindArray addObject:[NSString stringWithUTF8String:varbinds->vblabel]]; }
        while(varbinds->next && varbinds->next != nil) {
            varbinds = varbinds->next;
            if(varbinds->vblabel && varbinds->vblabel != nil) { [varbindArray addObject:[NSString stringWithUTF8String:varbinds->vblabel]]; }
        }
    }
    return [varbindArray copy];
    
}

- (NSString *)oidDescription {
    NSString * tmpDescStr = @"";
    if(self.nsNode->description && self.nsNode->description != nil) {
        tmpDescStr = [NSString stringWithUTF8String:self.nsNode->description];
    }
    return tmpDescStr;

}

- (NSString *)fullOID {
    MIBTreeItem * currentNode = self;
    NSString * fullOIDString = @"";
    while (currentNode) {
        fullOIDString = [[@"." stringByAppendingString:currentNode.subID] stringByAppendingString:fullOIDString];
        currentNode = currentNode.parent;
    }
    return fullOIDString;
}

- (NSString *)fullPath {
    MIBTreeItem * currentNode = self;
    NSString * fullPathString = @"";
    while (currentNode) {
        fullPathString = [[@"." stringByAppendingString:currentNode.label] stringByAppendingString:fullPathString];
        currentNode = currentNode.parent;
    }
    return fullPathString;
}

- (NSString *)module {
    struct module  * module = find_module(self.nsNode->modid);
    if (module != NULL) {
        return [NSString stringWithUTF8String:module->name];
    }
    return @"";
}

- (NSString *)filename {
    struct module  * module = find_module(self.nsNode->modid);
    if (module != NULL) {
        return [[NSString stringWithUTF8String:module->file] lastPathComponent];
    }
    return @"";
}

- (NSString *)access {
     NSDictionary * oidAccessLookup = [[NSDictionary alloc] initWithObjectsAndKeys:
        @"Read Only", @"18",
        @"Read Write", @"19",
        @"Write Only", @"20",
        @"No Access", @"21",
        @"Create",@"48",
        @"Notification Object",@"67",
        nil];
    if(self.nsNode->access && [oidAccessLookup objectForKey:[NSString stringWithFormat:@"%d",self.nsNode->access]]) {
        return [oidAccessLookup objectForKey:[NSString stringWithFormat:@"%d",self.nsNode->access]];
    }
    return @"";

}

- (NSString *)status {
    NSDictionary * oidStatusLookup = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      @"Mandatory", @"23",
                                      @"Optional", @"24",
                                      @"Obsolete", @"25",
                                      @"Deprecated", @"39",
                                      @"Current",@"57",
                                      nil];
    if(self.nsNode->status && [oidStatusLookup objectForKey:[NSString stringWithFormat:@"%d",self.nsNode->status]]) {
        return [oidStatusLookup objectForKey:[NSString stringWithFormat:@"%d",self.nsNode->status]];
    }
    return @"";
    
}

- (NSString *)type {
    NSDictionary * oidTypeLookup = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"", @"0",
                                    @"Object Identifier", @"1",
                                    @"Octet String", @"2",
                                    @"Integer", @"3",
                                    @"Network Address",@"4",
                                    @"IP Address", @"5",
                                    @"Counter", @"6",
                                    @"Gauge", @"7",
                                    @"Time Ticks", @"8",
                                    @"Opaque", @"9",
                                    @"Null", @"10",
                                    @"Counter 64", @"11",
                                    @"Bit String", @"12",
                                    @"NSAP Address", @"13",
                                    @"Unsigned Integer", @"14",
                                    @"Unsigned Integer 32", @"15",
                                    @"Integer 32", @"16",
                                    @"Trap Type", @"20",
                                    @"Notification", @"21",
                                    @"Object Group", @"22",
                                    @"Notify Group", @"23",
                                    @"Module ID", @"24",
                                    @"Agent Cap", @"25",
                                    @"Module COMP", @"26",
                                    @"Object Identifier", @"27",
                                      nil];
    if(self.nsNode->type && [oidTypeLookup objectForKey:[NSString stringWithFormat:@"%d",self.nsNode->type]]) {
        return [oidTypeLookup objectForKey:[NSString stringWithFormat:@"%d",self.nsNode->type]];
    }
    return @"";

}

-(void)zeroOutTreeNode {
    _parent = nil;
    _nsNode = nil;
    if(_children) {
        for(id childObject in _children) {
            [childObject zeroOutTreeNode];
        }
        _children = nil;
    }
}

@end

