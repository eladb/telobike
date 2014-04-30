//
//  TBObserver.h
//
//  Created by Elad Ben-Israel on 4/24/14.
//  Copyright (c) 2014 Citylifeapps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBObserver : NSObject

@property (readonly, nonatomic) id object;
@property (readonly, nonatomic) NSString *keyPath;
@property (readonly, nonatomic) void(^block)(void);

+ (instancetype)observerForObject:(id)object keyPath:(NSString *)keyPath block:(void(^)(void))block;
- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath block:(void(^)(void))block;

@end