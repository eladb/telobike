//
//  StationTableViewCell.m
//  telofun
//
//  Created by eladb on 5/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StationTableViewCell.h"
#import "NSDictionary+Station.h"

@implementation StationTableViewCell

@synthesize stationNameLabel=_stationNameLabel;
@synthesize distanceLabel=_distanceLabel;
@synthesize availBikeLabel=_availBikeLabel;
@synthesize availSpaceLabel=_availSpaceLabel;
@synthesize icon=_icon;

- (void)dealloc
{
    [station release];
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSDictionary*)station
{
    return station;
}

- (void)setStation:(NSDictionary *)newStation
{
    [station release];
    station = [newStation retain];
    
    _stationNameLabel.text = [station stationName];
    
    NSNumber* distance = [station objectForKey:@"distance"];
    if (distance)
    {    
        double distance = [[station objectForKey:@"distance"] doubleValue];

        NSString* dist;
        if (distance < 1000) dist = [NSString stringWithFormat:@"%.0fm", distance];
        else dist = [NSString stringWithFormat:@"%.1fkm", (distance/1000.0)];
        
        _distanceLabel.text = dist;
    }
    else
    {
        _distanceLabel.hidden = YES;
    }

    if (![station isActive])
    {
        for (UIView* v in self.contentView.subviews)
        {
            if ([v isKindOfClass:[UILabel class]])
            {
                
                [((UILabel*)v) setTextColor:[UIColor lightGrayColor]];
            }
        }
    }
    
    _availSpaceLabel.text = [station availSpaceDesc];
    _availBikeLabel.text = [station availBikeDesc];
    
    if ([station availSpaceColor]) _availSpaceLabel.textColor = [station availSpaceColor];
    if ([station availBikeColor]) _availBikeLabel.textColor = [station availBikeColor];
    
    _icon.image = [station listImage];
}

@end
