//
//  NSUserDefaults+OneOff.h
//  telobike
//
//  Created by Elad Ben-Israel on 1/29/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (OneOff)

- (BOOL)oneOff:(NSString*)key;

@end
