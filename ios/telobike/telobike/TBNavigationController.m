//
//  TBNavigationController.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBNavigationController.h"
#import "UIColor+Style.h"

@interface TBNavigationController () <UITabBarDelegate>

@end

@implementation TBNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.barTintColor        = [UIColor navigationBarBackgroundColor];
    self.navigationBar.tintColor           = [UIColor navigationBarTintColor];
    self.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName:[UIColor navigationBarTitleColor] };
}

@end