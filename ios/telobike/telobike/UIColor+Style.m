//
//  UIColor+Style.m
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "UIColor+Style.h"

@implementation UIColor (Style)

+ (UIColor*)lustColor                    { return [UIColor colorWithRed:166/255.0 green:72/255.0  blue:25/255.0  alpha:1.0f]; }
+ (UIColor*)terranovaColor               { return [UIColor colorWithRed:43/255.0  green:43/255.0  blue:40/255.0  alpha:1.0f]; }
+ (UIColor*)fiveThousandSkiesColor       { return [UIColor colorWithRed:57/255.0  green:162/255.0 blue:208/255.0 alpha:1.0f]; }
+ (UIColor*)jijiColor                    { return [UIColor colorWithRed:38/255.0  green:115/255.0 blue:148/255.0 alpha:0.8f]; }
+ (UIColor*)cocoColor                    { return [UIColor colorWithRed:32/255.0  green:73/255.0  blue:92/255.0  alpha:0.8f]; }

+ (UIColor*)themeColor                   { return [UIColor colorWithWhite:0.0f alpha:0.9f]; }

+ (UIColor*)tintColor                    { return [UIColor lightGrayColor]; }

+ (UIColor*)navigationBarBackgroundColor { return [UIColor themeColor]; }
+ (UIColor*)navigationBarTitleColor      { return [UIColor tintColor];  }
+ (UIColor*)navigationBarTintColor       { return [UIColor tintColor];  }
+ (UIColor*)tabbarBackgroundColor        { return [UIColor themeColor]; }
+ (UIColor*)tabbarTintColor              { return [UIColor tintColor];  }
+ (UIColor*)detailsBackgroundColor       { return [[UIColor themeColor] colorWithAlphaComponent:0.7f]; }
+ (UIColor*)detailsTintColor             { return [UIColor tintColor];  }


@end
