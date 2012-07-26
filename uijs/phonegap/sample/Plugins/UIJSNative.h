//
//  UIJSMap.h
//  sample
//
//  Created by ELAD BEN-ISRAEL on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface UIJSNative : CDVPlugin

- (NSString *)pathForResource:(NSString *)relativePath;
- (UIImage*)imageForResource:(NSString*)relativePath;

@end
