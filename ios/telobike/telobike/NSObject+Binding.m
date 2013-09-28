//
//  NSObject+Binding.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/27/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "NSObject+Binding.h"
#import <objc/runtime.h>

@interface Observer : NSObject

- (id)initWithKeyPath:(NSString*)keyPath
             ofObject:(id)object
                 with:(void(^)(id new, id old))block;

@end

@implementation NSObject (Binding)

- (void)observeValueOfKeyPath:(NSString *)keyPath
                       object:(id)object
                         with:(void(^)(id new, id old))block {
    // create observer
    Observer* observer = [[Observer alloc] initWithKeyPath:keyPath ofObject:object with:block];
    
    // use object pointer as key so setAssociatedObject becomes `addAssociatedObject`
    objc_setAssociatedObject(self, (__bridge const void *)observer, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark - Observer

@interface Observer ()

@property (nonatomic, copy)   void(^block)(id, id);
@property (nonatomic, strong) id source;
@property (nonatomic, strong) NSString* keyPath;

@end

@implementation Observer

- (id)initWithKeyPath:(NSString*)keyPath ofObject:(id)object with:(void(^)(id, id))block {
    self = [super init];
    if (self) {
        self.source = object;
        self.keyPath = keyPath;
        self.block = block;
        [self.source addObserver:self
                      forKeyPath:self.keyPath
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                         context:NULL];
    }
    return self;
}

- (void)dealloc {
    [self.source removeObserver:self
                     forKeyPath:self.keyPath
                        context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* new = [change objectForKey:NSKeyValueChangeNewKey];
        NSString* old = [change objectForKey:NSKeyValueChangeOldKey];
        self.block(new, old);
    });
}

@end