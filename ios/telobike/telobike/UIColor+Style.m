//
//  UIColor+Style.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "UIColor+Style.h"

@implementation UIColor (Style)

+ (UIColor*)themeColor                   { return [UIColor blackColor]; }

+ (UIColor*)navigationBarBackgroundColor { return [UIColor themeColor]; }
+ (UIColor*)navigationBarTitleColor      { return [UIColor whiteColor]; }
+ (UIColor*)navigationBarTintColor       { return [UIColor whiteColor]; }
+ (UIColor*)tabbarBackgroundColor        { return [UIColor whiteColor]; }
+ (UIColor*)tabbarTintColor              { return [UIColor themeColor]; }

@end
