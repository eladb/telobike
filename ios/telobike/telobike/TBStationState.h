//
//  TBStationState.h
//  telobike
//
//  Created by Elad Ben-Israel on 9/18/14.
//  Copyright (c) 2014 Elad Ben-Israel. All rights reserved.
//

typedef enum {
    StationFull,         // red (no park)
    StationEmpty,        // red (no bike)
    StationOK,           // green
    StationMarginal,     // yellow
    StationMarginalFull, // yellow full
    StationInactive,     // gray
    StationUnknown,      // black
} TBStationState;
