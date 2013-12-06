//
//  TBToggleFavoritesActivity.m
//  telobike
//
//  Created by Elad Ben-Israel on 12/6/13.
//  Copyright (c) 2013 Elad Ben-Israel. All rights reserved.
//

#import "TBToggleFavoritesActivity.h"
#import "TBStation.h"
#import "TBFavorites.h"

@interface TBToggleFavoritesActivity ()

@property (strong, nonatomic) TBStation* station;

@end

@implementation TBToggleFavoritesActivity

- (id)initWithStation:(TBStation*)station {
    self = [super init];
    if (self) {
        self.station = station;
    }
    return self;
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (NSString *)activityType {
    return @"kActivityTypeAddToFavorites";
}

- (NSString *)activityTitle {
    return !self.station.isFavorite ? @"Add to Favorites" : @"Remove from Favorites";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"Favorites"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)performActivity {
    [self.station setFavorite:!self.station.isFavorite];
    [self activityDidFinish:YES];
}

@end
