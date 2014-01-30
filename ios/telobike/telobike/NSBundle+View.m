//
//  NSBundle+View.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "NSBundle+View.h"

@implementation NSBundle (View)

- (id)loadViewFromNibForClass:(Class)class {
    return [[self loadNibNamed:NSStringFromClass(class) owner:nil options:nil] objectAtIndex:0];
}

@end
