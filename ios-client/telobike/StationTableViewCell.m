//
//  StationTableViewCell.m
//  telofun
//
//  Created by eladb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StationTableViewCell.h"
#import "AppDelegate.h"
#import "Utils.h"

@implementation StationTableViewCell

@synthesize stationNameLabel=_stationNameLabel;
@synthesize distanceLabel=_distanceLabel;
@synthesize availBikeLabel=_availBikeLabel;
@synthesize availSpaceLabel=_availSpaceLabel;
@synthesize icon=_icon;
@synthesize station=_station;
@synthesize favorite=_favorite;

- (void)dealloc
{
    [_favorite release];
    [_station release];
    [_availBikeLabel release];
    [_availSpaceLabel release];
    [_stationNameLabel release];
    [_icon release];
    [super dealloc];
}

+ (StationTableViewCell*)cell
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"StationTableViewCell" owner:self options:nil];
    StationTableViewCell* cell = [topLevelObjects objectAtIndex:0];
    UIColor* backgroundColor = [UIColor colorWithRed:0 green:230/255.0 blue:0 alpha:0.3];

    UIView* backgroundView = [[[UIView alloc] init] autorelease];
    [backgroundView setBackgroundColor:backgroundColor];
    backgroundView.frame = cell.bounds;
    [cell setBackgroundView:backgroundView];
    
    UIView* selectedBackgroundView = [[[UIView alloc] init] autorelease];
    selectedBackgroundView.frame = cell.bounds;
    selectedBackgroundView.backgroundColor = [UIColor blackColor];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    // this was nice but i'm creating only a single line separator now
    
    NSInteger lines = 1;
    CGFloat y = 0;
    CGFloat jump = 1;
    CGFloat alphaJump = 0.1;
    CGFloat alpha = alphaJump * lines;
    for (NSInteger i = 0; i < lines; ++i) {
        UIView* line = [[[UIView alloc] init] autorelease];
        line.frame = CGRectMake(0, y, cell.frame.size.width, jump);
        line.backgroundColor = [UIColor colorWithWhite:0.0 alpha:alpha];
        [cell addSubview:line];
        
        y += jump;
        alpha -= alphaJump;
    }
    
    
    return cell;
}

- (void)setStation:(Station *)newStation
{
    [_station release];
    _station = [newStation retain];
    
    _stationNameLabel.text = [_station stationName];
    
    if (_station.isMyLocation)
    {
        _distanceLabel.text = NSLocalizedString(@"MYLOCATION_DISTANCE", nil);
    }
    else
    {
        if (_station.distance != 0)
        {
            _distanceLabel.text = [Utils formattedDistance:_station.distance];
        }
        else
        {
            _distanceLabel.hidden = YES;
        }
    }

    if (![_station isActive])
    {
        for (UIView* v in self.contentView.subviews)
        {
            if ([v isKindOfClass:[UILabel class]])
            {
                [((UILabel*)v) setTextColor:[UIColor lightGrayColor]];
            }
        }
    }
    
    _availSpaceLabel.text = [_station availSpaceDesc];
    _availBikeLabel.text = [_station availBikeDesc];
    
    if ([_station availSpaceColor]) _availSpaceLabel.textColor = [_station availSpaceColor];
    if ([_station availBikeColor]) _availBikeLabel.textColor = [_station availBikeColor];
    
    _icon.image = [_station listImage];

    UIColor* backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    CGFloat red, green, blue, alpha;
    [backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    UIColor* selectedBackgroundColor = [UIColor colorWithRed:red/2 green:green/2 blue:blue/2 alpha:alpha];

    [[self backgroundView] setBackgroundColor:backgroundColor];
    [[self selectedBackgroundView] setBackgroundColor:selectedBackgroundColor];
    
    // put avail space next to avail bike based on the actual size of the label
    [_availBikeLabel sizeToFit];
    _availSpaceLabel.frame = CGRectMake(_availBikeLabel.frame.origin.x + _availBikeLabel.frame.size.width + 10, _availBikeLabel.frame.origin.y, 400, _availBikeLabel.frame.size.height);
    
    // show/hide favorite icon
    _favorite.hidden = !_station.favorite;
}

@end
