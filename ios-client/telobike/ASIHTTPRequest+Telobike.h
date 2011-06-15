//
//  RequestFactory.h
//  telobike
//
//  Created by eladb on 6/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface ASIHTTPRequest (Telobike)

+ (ASIHTTPRequest*)telobikeRequestWithQuery:(NSString*)query useCache:(BOOL)useCache;

@end
