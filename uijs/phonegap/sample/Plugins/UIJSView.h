//
//  UIJSView.h
//  sample
//
//  Created by ELAD BEN-ISRAEL on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIJSNative.h"

@interface UIJSView : UIView

@property (nonatomic, retain) NSString* objid;
@property (nonatomic, retain) UIJSNative* uijs;

- (void)emitEvent:(NSString*)name withObject:(id)object;

@end
