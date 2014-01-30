//
//  UIAlertView+Blocks.m
//  telobike
//
//  Created by Elad Ben-Israel on 1/29/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

#import "UIAlertView+Blocks.h"

@interface BlockDelegate : NSObject <UIAlertViewDelegate>

@property (copy, nonatomic) void(^completion)(NSInteger buttonIndex);

@end

@implementation UIAlertView (Blocks)

static NSMutableArray* delegates = NULL;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle completion:(void(^)(NSInteger buttonIndex))completion {
    BlockDelegate* delegate = [[BlockDelegate alloc] init];
    delegate.completion = completion;
    self = [self initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    if (self) {
        if (!delegates) {
            delegates = [[NSMutableArray alloc] init];
        }
        
        [delegates addObject:delegate]; // retain delegate
    }
    return self;
}

@end

@implementation BlockDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (!self.completion) return;
    self.completion(buttonIndex);
    [delegates removeObject:self]; // release delegate
}

@end
