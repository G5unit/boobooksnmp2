/*
 QueryTableViewController.m
 
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
#import "QueryTableViewController.h"



@interface QueryTableViewController ()

@end

@implementation QueryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_queryTableView registerForDraggedTypes:[NSArray arrayWithObjects:MyPrivateTableViewDataType, nil]];
}

-(void)setTimeFormat{
    [_timeColumnFormater setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"outputTimeFormat"]];
}

-(IBAction)toggleHideColumn:(id)sender {
    
    switch ([sender tag]) {
        case 1:
            if([_timeColumn isHidden]) { [_timeColumn setHidden:NO];
                [sender setState:1];}
            else { [_timeColumn setHidden:YES];
                [sender setState:0];}
            break;
        case 2:
            if([_agentColumn isHidden]) { [_agentColumn setHidden:NO];
                [sender setState:1];}
            else { [_agentColumn setHidden:YES];
                [sender setState:0];}
            break;
        case 3:
            if([_objectColumn isHidden]) { [_objectColumn setHidden:NO];
                [sender setState:1];}
            else { [_objectColumn setHidden:YES];
                [sender setState:0];}
            break;
        case 4:
            if([_resultColumn isHidden]) { [_resultColumn setHidden:NO];
                [sender setState:1];}
            else { [_resultColumn setHidden:YES];
                [sender setState:0];}
            break;
        case 5:
            if([_actionColumn isHidden]) { [_actionColumn setHidden:NO];
                [sender setState:1];}
            else { [_actionColumn setHidden:YES];
                [sender setState:0];}
            break;
        case 6:
            if([_setvalueColumn isHidden]) { [_setvalueColumn setHidden:NO];
                [sender setState:1];
            }
            else {
                [_setvalueColumn setHidden:YES];
                [sender setState:0];
            }
            break;
        default:
            break;
    }
    
}


- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSArray * selectedObjects = [_queryTableArrayController selectedObjects];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:selectedObjects];
    [pboard declareTypes:[NSArray arrayWithObjects:MyPrivateTableViewDataType,nil] owner:self];
    [pboard setData:data forType:MyPrivateTableViewDataType];
    return YES;
}
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    // Add code here to validate the drop
    if ([info draggingSource] != tableView )  //|| row >= [[_queryTableArrayController content] count] || row < 0)
    {
        return NSDragOperationNone;
    }
    else {
        [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
    }
    return NSDragOperationMove;
}
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
//    NSPasteboard* pboard = [info draggingPasteboard];
//    NSData* rowData = [pboard dataForType:MyPrivateTableViewDataType];
//    NSIndexSet * dropRowIndex = [[NSIndexSet alloc] initWithIndex:row]
    NSArray* rowsToMoveArray = [NSKeyedUnarchiver unarchiveObjectWithData:[[info draggingPasteboard] dataForType:MyPrivateTableViewDataType]];
//    NSInteger dragRow = [rowIndexes firstIndex];
    
    // Move the specified row to its new location...
//    boobookDisplayDictionary  * myTempbbDict;// = [[boobookDisplayDictionary alloc] init];
//    myTempbbDict = [tbDisplayArray objectAtIndex:dragRow];
//    [boobookoutArrayController removeObjectAtArrangedObjectIndex:dragRow];
    
//    [boobookoutArrayController insertObject:myTempbbDict atArrangedObjectIndex:row];
  
    [_queryTableArrayController removeObjects:[_queryTableArrayController selectedObjects]];
    
    [_queryTableArrayController insertObjects:rowsToMoveArray atArrangedObjectIndexes:[NSIndexSet indexSetWithIndex:row]];
    
    
    return YES;
}

-(IBAction)copyRows:(id)sender {
    NSDateFormatter * displayDateFormater = [[NSDateFormatter alloc] init];
    NSMutableString * copyToPBoard = [[NSMutableString alloc] init];
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"outputTimeFormat"] && ![[[NSUserDefaults standardUserDefaults] stringForKey:@"outputTimeFormat"] isEqualToString:@""]) {
        [displayDateFormater setDateFormat:[[NSUserDefaults standardUserDefaults] stringForKey:@"outputTimeFormat"]];
    } else {
        displayDateFormater.dateStyle = NSDateFormatterMediumStyle;
        displayDateFormater.timeStyle = NSDateFormatterMediumStyle;
    }
    for(id selectedRow in [_queryTableArrayController selectedObjects]) {
        [copyToPBoard appendString:[displayDateFormater stringFromDate:[selectedRow objectForKey:@"timestamp"]]];
        [copyToPBoard appendString:@"\t"] ;
        [copyToPBoard appendString:[selectedRow objectForKey:@"agent"]];
        [copyToPBoard appendString:@"\t"] ;
        [copyToPBoard appendString:[selectedRow objectForKey:@"snmpObject"]];
        [copyToPBoard appendString:@"\t"] ;
        [copyToPBoard appendString:[selectedRow objectForKey:@"result"]];
        [copyToPBoard appendString:@"\t"] ;
        [copyToPBoard appendString:[selectedRow objectForKey:@"action"]];
        [copyToPBoard appendString:@"\t"] ;
        if([selectedRow objectForKey:@"setValue"] && ![[selectedRow objectForKey:@"setValue"] isEqualToString:@""]) {
            [copyToPBoard appendString:[selectedRow objectForKey:@"setValue"]];
        }
        [copyToPBoard appendString:@"\n"] ;
    }
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:copyToPBoard forType:NSStringPboardType];
}

@end
