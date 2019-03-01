/*
 OidTabBarController.m
 
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
#import "OidTabBarController.h"

@interface OidTabBarController ()

@end

@implementation OidTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    //Setup MMTabBar
    [_oidTabBar setButtonMinWidth:100];
    [_oidTabBar setButtonMaxWidth:200];
    [_oidTabBar setButtonOptimumWidth:230];
    [_oidTabBar setDisableTabClose:TRUE];
    [_oidTabBar setAllowsBackgroundTabClosing:FALSE];
    [_oidTabBar setStyleNamed:@"Card"];
    [_oidTabBar setOnlyShowCloseOnHover:TRUE];
    [_oidTabBar setCanCloseOnlyTab:FALSE];
    [_oidTabBar setHideForSingleTab:FALSE];
    [_oidTabBar setSizeButtonsToFit:FALSE];
    [_oidTabBar setUseOverflowMenu:FALSE];
    [_oidTabBar setAlwaysShowActiveTab:TRUE];
    [_oidTabBar setOrientation:MMTabBarHorizontalOrientation];
    
    /* Attempts to get the tabBarVIew background to be transparent.
     * Code below makes the whole view including tabs inside the view transparent.
    _oidTabBar.wantsLayer = TRUE;
    _oidTabBar.layer.opacity = 0;
    */

}

@end
