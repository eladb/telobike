//
//  TBFeedbackActionSheet.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/28/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TBFeedbackActionSheetService = 0,
    TBFeedbackActionSheetApp     = 1,
} TBFeedbackActionSheetOptions;

@interface TBFeedbackActionSheet : UIActionSheet

- (instancetype)initWithDelegate:(id<UIActionSheetDelegate>)delegate;

@end

