//
//  NSBundle+View.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (View)

- (id)loadViewFromNibForClass:(Class)class;

@end
