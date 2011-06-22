//
//  StationTableViewCell.m
//  telofun
//
//  Created by eladb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StationTableViewCell.h"
#import "Utils.h"

@implementation StationTableViewCell

@synthesize stationNameLabel=_stationNameLabel;
@synthesize distanceLabel=_distanceLabel;
@synthesize availBikeLabel=_availBikeLabel;
@synthesize availSpaceLabel=_availSpaceLabel;
@synthesize icon=_icon;
@synthesize station=_station;

- (void)dealloc
{
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
    return [topLevelObjects objectAtIndex:0];
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
    
    if ([_station isMyLocation])
    {
        _stationNameLabel.frame = CGRectMake(_stationNameLabel.frame.origin.x, 13, _stationNameLabel.frame.size.width, _stationNameLabel.frame.size.height);
        _icon.frame = CGRectMake(_icon.frame.origin.x, 14, _icon.frame.size.width, _icon.frame.size.height);
    }
    else
    {
        _stationNameLabel.frame = CGRectMake(_stationNameLabel.frame.origin.x, 4, _stationNameLabel.frame.size.width, _stationNameLabel.frame.size.height);
        _icon.frame = CGRectMake(_icon.frame.origin.x, 11, _icon.frame.size.width, _icon.frame.size.height);
    }
}

@end
