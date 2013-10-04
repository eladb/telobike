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
+ (UIColor*)tintColor                    { return [UIColor whiteColor]; }

+ (UIColor*)navigationBarBackgroundColor { return [UIColor themeColor]; }
+ (UIColor*)navigationBarTitleColor      { return [UIColor tintColor]; }
+ (UIColor*)navigationBarTintColor       { return [UIColor tintColor]; }
+ (UIColor*)tabbarBackgroundColor        { return [UIColor themeColor]; }
+ (UIColor*)tabbarTintColor              { return [UIColor tintColor]; }
+ (UIColor*)detailsBackgroundColor       { return [UIColor tabbarBackgroundColor]; }

@end
