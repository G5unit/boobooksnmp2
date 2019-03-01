/*
 MIBTreeViewController.m
 
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
#import "MIBTreeViewController.h"

@interface MIBTreeViewController ()

@end

@implementation MIBTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSString * nserr = [self loadTree];
    if(nserr) {
        NSDictionary * startErrNotice = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",
                                      [NSString stringWithFormat:@"[Bbs2] MIB Tree Reload issue: %@",nserr],@"message", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:startErrNotice];

    } else {
        NSDictionary * startNotice = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",
                                      [NSString stringWithFormat:@"[Bbs2] MIB Tree Loaded"],@"message", nil];
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:startNotice];

    //Post files parsed and objects in MIB tree count to Log.
        NSInteger fsct = 0;
        NSArray * filesParsedCount = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BBS2SavedMibLibrary"]];
        if(filesParsedCount) { fsct = [filesParsedCount count]; }
        NSDictionary * fileCountNotice = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",
                                      [NSString stringWithFormat:@"[Bbs2] MIB files parsed: %li",(long)fsct],@"message", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:fileCountNotice];
    
        NSDictionary * objectCountNotice = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",
                                        [NSString stringWithFormat:@"[Bbs2] MIB Tree Object count: %i",[MIBTreeItem objectCountValue]],@"message", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:objectCountNotice];
   }

}

-(IBAction)reloadTreeAction:(id)sender {
    [self reloadTree];
}
- (void)reloadTree {
    
    // hide outline view
    [self.mibTreeOutlineView setHidden:YES];
    if([self.mibTreeController content] && [[self.mibTreeController content] isKindOfClass:[NSArray class]]) {
        for(id rootNode in [self.mibTreeController content]) {
            [rootNode zeroOutTreeNode];
        }
    } else if([self.mibTreeController content] && [[self.mibTreeController content] isKindOfClass:[MIBTreeItem class]]) {
        [[self.mibTreeController content] zeroOutTreeNode];
    }

    [self.mibTreeController setContent:nil];
    [MIBTreeItem objectCountReset];

    //Re-init net-snmp
    [self.bbs2NetSnmp reInitNetSnmp];

   // load Tree
    NSDictionary * reloadTreeNotice;
    NSString * nserr = [self loadTree];
    if(nserr) {
        //Post Reload Tree Error
        reloadTreeNotice = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",
                           [NSString stringWithFormat:@"[Bbs2] MIB Tree Reload issue: %@",nserr],@"message", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:reloadTreeNotice];
    } else {
        //Post Reload Tree status
        reloadTreeNotice = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",
                            @"[Bbs2] MIB Tree Reloaded",@"message", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:reloadTreeNotice];

        //Post files parsed and objects in MIB tree count to Log.
        NSInteger fsct = 0;
        NSArray * filesParsedCount = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BBS2SavedMibLibrary"]];
        if(filesParsedCount) {
            for(id mfile in filesParsedCount) {
                if([[mfile objectForKey:@"loadFile"] intValue] > 0) {
                    fsct++;
                }
            }
        }
        NSDictionary * fileCountNotice = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",
                                      [NSString stringWithFormat:@"[Bbs2] MIB files parsed: %li",(long)fsct],@"message", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:fileCountNotice];
    
        NSDictionary * objectCountNotice = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",
                                        [NSString stringWithFormat:@"[Bbs2] MIB Tree Object count: %i",[MIBTreeItem objectCountValue]],@"message", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:objectCountNotice];
    }
}

- (NSString *)loadTree {

    if(!_bbs2NetSnmp || ![_bbs2NetSnmp rootNode]) {
        return @"Bbs2NetSnmp Object could not be initialized";
    }
    
    
    // Net-SNMP shows the root object which could have peers.
    //  We create an array of root objects, and set tree controller content to it.
    NSMutableArray * mibTreeContentArray = [[NSMutableArray alloc] init];
    struct tree * treeP;
    for(treeP=[_bbs2NetSnmp rootNode];treeP;treeP=treeP->next_peer) {
        [mibTreeContentArray addObject:[[MIBTreeItem alloc] initWithNode:treeP withParent:nil]];
    }
    [self.mibTreeOutlineView setHidden:YES];
    [self.mibTreeController setContent:mibTreeContentArray];
    [self.mibTreeController setChildrenKeyPath:@"children"];
    [self.mibTreeOutlineView setHidden:NO];
    
    
    return nil;
}

/* Search Tree function uses NET-SNMP "find_best_tree_node()" function for search results.
    Looks like this search function uses "begins with" predicament which might not be the optimal one.
    It could be worth writing our own search function.
 */
-(IBAction)searchTree:(id)sender {
    //setup NSMenu (one assigned to popup button) properties
    NSMenu * searchResultsMenu = [[NSMenu alloc] init];
    NSMenuItem * resultMenuItem;
    NSString *searchString;
    NSArray * results;
    
    [searchResultsMenu setAutoenablesItems:YES];
    [searchResultsMenu setShowsStateColumn:NO];

    //Get search results from net-snmp library
    searchString = [_searchField stringValue];
    if(searchString && ![searchString isEqualToString:@""]) {
        results = [self.bbs2NetSnmp searchMibTree:searchString];
        //Populate results
        if(results) {
            for(id searchResult in results) {
                resultMenuItem = [[NSMenuItem alloc] initWithTitle:searchResult
                                                     action:@selector(selectFoundOID:)
                                                     keyEquivalent:@""];
            [resultMenuItem setTarget:self];
            [resultMenuItem setTag:4335];
            [searchResultsMenu addItem:resultMenuItem];
            }
        }

        //assign menu
        [_searchResultsPopUpButton setMenu:nil];
        [_searchResultsPopUpButton setMenu:searchResultsMenu];
        //Show popup menu
        [_searchResultsPopUpButton performClick:_searchResultsPopUpButton];
    }

}

-(NSTreeNode *)findInTree:(NSTreeNode *)treeItem searchString:(NSString *)searchString {
    NSTreeNode * searchedForItem;
    if([[[treeItem representedObject] label] isEqualToString:searchString]) {
        return treeItem;
    } else if ([treeItem childNodes]) {
        for(id items in [treeItem childNodes]) {
            searchedForItem = [self findInTree:items searchString:searchString];
            if(searchedForItem != nil) {
                //FOund item, select it from view....
                return searchedForItem;
            }
        }
    }
    return nil;
}

-(IBAction)selectFoundOID:(id)sender {
    //Called from bookmarks doubleclick
    if([[sender className] isEqualToString:@"BookmarksViewController"]) {
        NSTreeNode * searchedForItem;
        NSString * searchString;
        if([[_bookmarksTreeController selectedObjects] count] > 0) {
            searchString = [[[_bookmarksTreeController selectedObjects] objectAtIndex:0] label];
        }
        for(id items in [[_mibTreeController arrangedObjects] childNodes]) {
            searchedForItem = [self findInTree:items searchString:searchString];
            if(searchedForItem != nil) {
                break;
            }
        }
        if(searchedForItem != nil) {
            [_mibTreeController setSelectionIndexPath:[searchedForItem indexPath]];
            [[_mibTreeOutlineView window] makeFirstResponder:_mibTreeOutlineView];
        }
    }
    
    // Called from search popup menu
    else if([sender tag] == 4335) {
        NSTreeNode * searchedForItem;
        NSString * searchString = [(NSMenuItem *)sender title];
        for(id items in [[_mibTreeController arrangedObjects] childNodes]) {
            searchedForItem = [self findInTree:items searchString:[(NSMenuItem *)sender title]];
            if(searchedForItem != nil) {
                break;
            }
        }
        if(searchedForItem != nil) {
            [_mibTreeController setSelectionIndexPath:[searchedForItem indexPath]];
            [_searchField setStringValue:searchString];
            [[_mibTreeOutlineView window] makeFirstResponder:_mibTreeOutlineView];
        }
    }
}

@end
