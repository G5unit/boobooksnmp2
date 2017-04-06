/*
 BookmarksTreeController.m
 
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
#import "BookmarksTreeController.h"

@implementation BookmarksTreeController

// Calls to save and load bookmarks from userDefaults
-(void)saveBookmarks {
    NSData * bookmarksData = [NSKeyedArchiver archivedDataWithRootObject:[self content]];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:bookmarksData forKey:@"BBS2SavedBookmarks"];
}
-(void)loadBookmarks {
    NSArray * bookmarksArray;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * bookmarksData = [userDefaults objectForKey:@"BBS2SavedBookmarks"];
    if(bookmarksData) {
        bookmarksArray = [NSKeyedUnarchiver unarchiveObjectWithData:bookmarksData];
    }
    [self setContent:bookmarksArray];
    [self setChildrenKeyPath:@"children"];
}


//Datasource method that keeps nagging output when a  child object is created
- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item {
    return nil;
}

//Datasource methods to support Drag&Drop Reorder, as well as Drag&Drop of OID from MIB Tree OutlineView
- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item {
    NSPasteboardItem * dragPasteItem = [[NSPasteboardItem alloc] init];
    
    //Encode item index path into NSData and post to pasteboard
    NSData * itemData = [NSKeyedArchiver archivedDataWithRootObject:[item indexPath]];
    
    [dragPasteItem setData:itemData forType:@"bookmarksDrag.type"];
     return dragPasteItem;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
    //Figure out drop location
    NSUInteger indexLocation = 0;
    NSIndexPath * dropLocation ;
    if(index!=NSUIntegerMax && index >= 0) {
        indexLocation = index;
    }
    dropLocation = [NSIndexPath indexPathWithIndex:indexLocation];
    if(item) {
        dropLocation = [[item indexPath] indexPathByAddingIndex:indexLocation];
    }
    
    // If drag type then move items
    if([[info draggingPasteboard] dataForType:@"bookmarksDrag.type"]) {

        //Get pasted item data and convert to index paths
        NSArray * selectedNodes = [self selectedNodes];
        NSData * pdata = [[info draggingPasteboard] dataForType:@"bookmarksDrag.type"];
        NSIndexPath * dindex = [NSKeyedUnarchiver unarchiveObjectWithData:pdata];

        [self setSelectionIndexPath:dindex];
        NSUInteger multiMove = 0;
        for(id selectno in selectedNodes) {
            if(selectno == [[self selectedNodes] objectAtIndex:0]) {
                multiMove = 1;
                break;
            }
        }
        if(multiMove > 0) { // We move all selected nodes as dragged node is part of them
            [self moveNodes:selectedNodes toIndexPath:dropLocation];
        } else { // Move only the dragged node
            [self moveNodes:[self selectedNodes] toIndexPath:dropLocation];
        }
    }
    // Create bookmark from OID
    if([[info draggingPasteboard] dataForType:@"oidDrag.type"]) {
        NSData * oiddata = [[info draggingPasteboard] dataForType:@"oidDrag.type"];
        NSDictionary * oidDict = [NSKeyedUnarchiver unarchiveObjectWithData:oiddata];

            BookmarksTreeItem * newItem = [[BookmarksTreeItem alloc] initWithOID:oidDict];
            [self insertObject:newItem atArrangedObjectIndexPath:dropLocation];
    }
    // Create Url bookmark
    if([[info draggingPasteboard] stringForType:@"public.url"]) {
        BookmarksTreeItem * newItem = [[BookmarksTreeItem alloc] initWithURL:[NSDictionary dictionaryWithObjectsAndKeys:[[info draggingPasteboard] stringForType:@"public.url"],@"url", nil]];
        [self insertObject:newItem atArrangedObjectIndexPath:dropLocation];
    }
    [self saveBookmarks];
    return YES;
}
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    //Get proposed drop indexPath
    NSUInteger indexLocation = 0;
    NSIndexPath * dropLocation;
    if(index!=NSUIntegerMax && index >= 0) {
        indexLocation = index;
    }
    dropLocation = [NSIndexPath indexPathWithIndex:indexLocation];
    if(item) {
        dropLocation = [[item indexPath] indexPathByAddingIndex:indexLocation];
    }

    //Handle for drop request of type url, i.e. drag&drop from browser
    if([[info draggingPasteboard] stringForType:@"public.url"] && (item || index != NSUIntegerMax)){
        return NSDragOperationCopy;
    }
    //If pasteItem of right type exists, and drop location index is not at NSUIntegerMax : validate move
    if([[info draggingPasteboard] dataForType:@"bookmarksDrag.type"] && (item || index != NSUIntegerMax || index < 0)) {

        //Need a check that ensures user is not dropping Parent onto its own Child node, nor onto itself!!

        //Get pasted item data and convert to index paths
        NSArray * selectedIndexPaths = [self selectionIndexPaths];
        NSData * pdata = [[info draggingPasteboard] dataForType:@"bookmarksDrag.type"];
        NSIndexPath * dindex = [NSKeyedUnarchiver unarchiveObjectWithData:pdata];
        
 //       [self setSelectionIndexPath:dindex];
        NSUInteger multiMove = 0;
        for(id selectno in selectedIndexPaths) {
            if([selectno compare:dindex] == NSOrderedSame) {
                multiMove = 1;
                break;
            }
        }
        if(multiMove > 0) { //Check selectionArray index paths against proposed dropIndexPath
            for(id selectedPath in selectedIndexPaths) {
                NSIndexPath * sp = dropLocation;
                if([sp length] >= [selectedPath length]) {
                    while([sp length] > [selectedPath length]) {
                        sp = [sp indexPathByRemovingLastIndex];
                    }
                    if([selectedPath compare:sp] == NSOrderedSame) {
                        [self setSelectionIndexPaths:selectedIndexPaths];
                        return NSDragOperationNone;
                    }
                }
            }
        } else { // Check only the dragged node
            if([dropLocation length] >= [dindex length]) {
                NSIndexPath * sp = dropLocation;
                while([sp length] > [dindex length]) {
                    sp = [sp indexPathByRemovingLastIndex];
                }
                if([dindex compare:sp] == NSOrderedSame) {
                    return NSDragOperationNone;
                }
            }
        }

        return NSDragOperationMove;
    }
    if([[info draggingPasteboard] dataForType:@"oidDrag.type"] && (item || index != NSUIntegerMax)) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

@end
