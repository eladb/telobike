//
//  NSObject+Binding.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Binding)

- (void)observeValueOfKeyPath:(NSString *)keyPath object:(id)object with:(void(^)(id new, id old))block;

@end