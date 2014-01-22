//
//  TBDrawerView.m
//  expand
//
//  Created by Elad Ben-Israel on 12/11/13.
//  Copyright (c) 2013 Citylifeapps. All rights reserved.
//

#import "TBDrawerView.h"

@interface TBDrawerView ()

@property (strong, nonatomic) UIView* containerView;
@property (assign, nonatomic) BOOL isOpened;

@end

@implementation TBDrawerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self initialize];
    return self;
}

- (id)init {
    self = [super init];
    [self initialize];
    return self;
}

- (void)initialize {
    self.isOpened = YES;
}

- (void)didMoveToSuperview {
    if (self.superview == self.containerView) {
        return;
    }
    
    CGRect containerRect = self.frame;
    self.containerView = [[UIView alloc] initWithFrame:containerRect];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.userInteractionEnabled = YES;
    self.containerView.clipsToBounds = NO;
    [[self superview] addSubview:self.containerView];
    [self.containerView addSubview:self];
}

#pragma mark - Open/close

- (void)openAnimated:(BOOL)animated {
    CGRect frame = self.frame;
    frame.origin.y = 0.0f;
    [self updateFrame:frame initialVelocity:8.0f animated:animated completion:^(BOOL finished) {
        self.isOpened = YES;
        self.containerView.userInteractionEnabled = YES;
    }];
}

- (void)closeAnimated:(BOOL)animated {
    CGRect frame = self.frame;
    frame.origin.y = -frame.size.height;
    [self updateFrame:frame initialVelocity:-8.0f animated:animated completion:^(BOOL finished) {
        self.isOpened = NO;
        self.containerView.userInteractionEnabled = NO;
    }];
}

- (void)updateFrame:(CGRect)frame initialVelocity:(CGFloat)initialVelocity animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    void(^block)() = ^{
        self.frame = frame;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:0.6f
              initialSpringVelocity:initialVelocity
                            options:0
                         animations:block
                         completion:completion];
    } else {
        block();
    }
}

@end
