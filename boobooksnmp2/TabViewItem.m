/*
 TabViewItem.m
 
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
#import "TabViewItem.h"

@implementation TabViewItem

-(instancetype)initLogView {
    self = [super init];
    if (self != nil){
        _logViewController = [[LogView alloc] init];
        [_logViewController loadView];
        self.view = [_logViewController view];
    }
    return self;
}

-(instancetype)initFileViewWithFile:(NSString *)filePath {
    self = [super init];
    if (self != nil){
        _fileController = [[FileViewController alloc] init];
        _displayLabel = filePath;
        _displayFile = filePath;
        //Open file and append text ti text view
        NSError * mybkerror = nil;
        NSString * fullFilePath;
        NSArray * directoryPath = NSSearchPathForDirectoriesInDomains (NSApplicationSupportDirectory, NSUserDomainMask, YES);
        if ([directoryPath count] > 0)  {
            fullFilePath = [[[directoryPath objectAtIndex:0] stringByAppendingPathComponent:@"Boobooksnmp2"] stringByAppendingPathComponent:filePath];
        }
        NSString *displayString = [[NSString alloc] initWithContentsOfFile:fullFilePath encoding:NSUTF8StringEncoding error:&mybkerror];
        if(mybkerror) {
            NSDictionary * fileViewNotice = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"timestamp",
                                [NSString stringWithFormat:@"[Bbs2] Issue opening file: %@ : %@",filePath,mybkerror.description],@"message", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Bbs2SnmpLogMessagePosted" object:nil userInfo:fileViewNotice];
            return nil;
        } else {
            _contentsToDisplay = displayString;
            [_fileController loadView];
            self.view = [_fileController view];
            [self setLabel:filePath];

        }
    }
    return self;
}

-(instancetype)initQueryView {
    self = [super init];
    if (self != nil){
        _queryController = [[QueryTableViewController alloc] init];
        [_queryController loadView];
        [_queryController setTimeFormat];
        self.view = [_queryController view];
        [self setLabel:@"Query Results"];
    }
    return self;
}

-(instancetype)initPreferencesView {
    self = [super init];
    if (self != nil){
        _preferencesController = [[PreferencesViewController alloc] init];
        [_preferencesController loadView];
        self.view = [_preferencesController view];
        [self setLabel:@"Preferences"];
    }
    return self;
}

-(instancetype)initUrlView {
    self = [super init];
    if (self != nil){
        _urlController = [[UrlViewController alloc] init];
        [_urlController loadView];
        self.view = [_urlController view];
        [self setLabel:@"WebView"];
    }
    return self;
}


@end
