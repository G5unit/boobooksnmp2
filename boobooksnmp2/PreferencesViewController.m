/*
 PreferencesViewController.m
 
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
#import "PreferencesViewController.h"

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController


// This "viewDidLoad" is not called when view loads for some reason??, using viewDidAppear instead!
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
 }

- (void)viewDidAppear{
    [super viewDidAppear];
    [_mibFilesArrayController loadMibLibrary];

    
    [_mibTableView registerForDraggedTypes:[NSArray arrayWithObjects:@"MIBFileTableDataType", nil]];

    [_snmpTimeout takeIntegerValueFrom:_timeoutStepper];
    [_snmpRetries takeIntegerValueFrom:_retriesStepper];
    [_snmpMaxOps takeIntegerValueFrom:_maxOpsStepper];
}

-(IBAction)updateMaxOps:(id)sender {
    [_snmpMaxOps takeIntegerValueFrom:_maxOpsStepper];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2maxConcurentOperationsChange" object:self];
}

-(IBAction)addMibFileToLibrary:(id)sender {
    //Check to see if Application support directory exists, if not create it
    NSString *userAppSupportDirectory;
    BOOL isDir = TRUE;
    NSError * dirCreateError = nil;
    NSError * fileCopyError = nil;

    
    
    NSArray *directoryPath = NSSearchPathForDirectoriesInDomains (NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if ([directoryPath count] > 0)  {
        userAppSupportDirectory = [[directoryPath objectAtIndex:0] stringByAppendingPathComponent:@"Boobooksnmp2"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:userAppSupportDirectory isDirectory:&isDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:userAppSupportDirectory withIntermediateDirectories:0 attributes:nil error:&dirCreateError];
            if(dirCreateError) {
                //Directory could not be created,
                // hence MIB files could not be stored nor loaded
            }
        }
    }else {
        //Notify user that Application support directory could not be retrieved from OSX,
        // hence MIB files could not be stored nor loaded
    }
    
    //Show user file select option popup/ Open file
    
    // Get the main window for the document.
    NSWindow* window = [self.view window];
    
    // Create and configure the panel.
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:YES];
    [panel setMessage:@"Select MIB files to import into boobooksnmp2 library"];
    
    // Display the panel attached to the document's window.
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) {
            NSArray* urls = [panel URLs];
            BOOL fileExists = FALSE;
            for(id fileUrl in urls) {
                //Check to see if file is already in library, if so notify user and select that file from table view
                for(id mibFileElement in [self->_mibFilesArrayController content]) {
                    if([[(NSDictionary *)mibFileElement objectForKey:@"mibFileName"] isEqualToString:[fileUrl lastPathComponent]]) {
                        // Notify user that this file is already in Library
                        fileExists = TRUE;
                        break;
                    }
                }
                
                //If file is not already in Library, copy file to library & add it to mibFileArrayController
                if(fileExists == FALSE) {
                    [[NSFileManager defaultManager] copyItemAtPath:[fileUrl path] toPath:[userAppSupportDirectory stringByAppendingPathComponent:[fileUrl lastPathComponent]] error:(NSError **)&fileCopyError];
                    //Check error!!
                    
                    NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [fileUrl lastPathComponent], @"mibFileName",
                                        @"0",@"loadFile",
                                        nil];
                    [self->_mibFilesArrayController addObject:dict];
                }
            }
            [self->_mibFilesArrayController saveMIBLibrary];
        }
    }];
}

-(IBAction)removeMibFileFromLibrary:(id)sender {
    //Show popup notification or alert asking user if yes they want to delete mib files from loibrary
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Confirm to delete selected MIB file(s) ?"];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    if ([alert runModal] == NSAlertFirstButtonReturn && [_mibFilesArrayController selectedObjects]) {
        
        NSString *userAppSupportDirectory;
        BOOL isDir = FALSE;
        NSError * fileRemoveError = nil ;
        
        NSArray *directoryPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        if ([directoryPath count] > 0)  {
            userAppSupportDirectory = [[directoryPath objectAtIndex:0] stringByAppendingPathComponent:@"Boobooksnmp2"];
        }else {
            //Notify user that Application support directory could not be retrieved from OSX,
            // hence MIB files could not be deleted
        }
        for(id mibFileElement in [_mibFilesArrayController selectedObjects]) {
            if([[NSFileManager defaultManager] fileExistsAtPath:[userAppSupportDirectory stringByAppendingPathComponent:[(NSDictionary *)mibFileElement objectForKey:@"mibFileName"]] isDirectory:&isDir]) {
                
                    [[NSFileManager defaultManager] removeItemAtPath:[userAppSupportDirectory stringByAppendingPathComponent:[(NSDictionary *)mibFileElement objectForKey:@"mibFileName"]] error:&fileRemoveError];
                
                    // If error notify user of such action
                
                    // Else
                    [_mibFilesArrayController removeObject:mibFileElement];
            }
        }
        [_mibFilesArrayController saveMIBLibrary];
    }

}

// Menu actions
-(IBAction)selecttoload:(id)sender {
    for(id mibFileElement in [_mibFilesArrayController selectedObjects]) {
        if([[mibFileElement objectForKey:@"loadFile"] integerValue] == 0) {
            [mibFileElement setObject:@"1"  forKey:@"loadFile"];
        }
    }
    [_mibFilesArrayController saveMIBLibrary];

}

-(IBAction)deselecttoload:(id)sender {
    for(id mibFileElement in [_mibFilesArrayController selectedObjects]) {
        if([[mibFileElement objectForKey:@"loadFile"] integerValue] == 1) {
            [mibFileElement setObject:@"0"  forKey:@"loadFile"];
        }
    }
    [_mibFilesArrayController saveMIBLibrary];

}
-(IBAction)selectall:(id)sender {
    for(id mibFileElement in [_mibFilesArrayController content]) {
        if([[mibFileElement objectForKey:@"loadFile"] integerValue] == 0) {
            [mibFileElement setObject:@"1" forKey:@"loadFile"];
        }
    }
    [_mibFilesArrayController saveMIBLibrary];

}
-(IBAction)deselectall:(id)sender {
    for(id mibFileElement in [_mibFilesArrayController content]) {
        if([[mibFileElement objectForKey:@"loadFile"] integerValue] == 1) {
            [mibFileElement setObject:@"0" forKey:@"loadFile"];
        }
    }
    [_mibFilesArrayController saveMIBLibrary];

}


//Delegate methods to support MIB table drag and drop sort
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObjects:@"MIBFileTableDataType",nil] owner:self];
    [pboard setData:data forType:@"MIBFileTableDataType"];
    return YES;
}
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    // Add code here to validate the drop
    if ([info draggingSource] != tableView || row >= [[_mibFilesArrayController content] count] || row < 0)
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
    NSData * pdata = [[info draggingPasteboard] dataForType:@"MIBFileTableDataType"];
    NSIndexSet * indexSet = [NSKeyedUnarchiver unarchiveObjectWithData:pdata];
    [_mibFilesArrayController setSelectionIndexes:indexSet];
    NSArray* rowsToMoveArray = [_mibFilesArrayController selectedObjects];
    [_mibFilesArrayController removeObjects:rowsToMoveArray];
    
    for(id rowToAdd in rowsToMoveArray) {
        [_mibFilesArrayController insertObject:rowToAdd atArrangedObjectIndex:row];
    }
    [_mibFilesArrayController setSelectedObjects:rowsToMoveArray];
    [_mibFilesArrayController saveMIBLibrary];

    return YES;
}
//Action for checkbox change. needed to save values

-(IBAction)saveMIBState:(id)sender {
    [_mibFilesArrayController saveMIBLibrary];
}


@end
