//
//  TBAppDelegate.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/23/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBAppDelegate.h"
#import <RESideMenu/RESideMenu.h>

@interface TBAppDelegate ()

@property (strong, nonatomic)  RESideMenu* sideMenuController;

@end

@implementation TBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary* d = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSLog(@"keyboards: %@", d[@"AppleKeyboards"]);
    
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* contentViewController = [storyboard instantiateInitialViewController];
    UIViewController* menuViewController = [storyboard instantiateViewControllerWithIdentifier:@"menu"];
    self.sideMenuController = [[RESideMenu alloc] initWithContentViewController:contentViewController menuViewController:menuViewController];
    self.sideMenuController.backgroundImage = [UIImage imageNamed:@"tlv-blur"];
    self.sideMenuController.panGestureEnabled = NO;
    self.sideMenuController.panFromEdge = YES;
    self.window.rootViewController = self.sideMenuController;
    return YES;
}
							
@end