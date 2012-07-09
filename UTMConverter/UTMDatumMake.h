//
//  UTMDatumMake.h
//  UTMConverter
//
//  Created by Cameron Lowell Palmer on 09.07.12.
//  Copyright (c) 2012 Cameron Lowell Palmer & Mariia Ruchko. All rights reserved.
//

#ifndef UTMConverter_UTMDatumMake_h
#define UTMConverter_UTMDatumMake_h

static inline UTMDatum UTMDatumMake(UTMDouble equitorialRadius, UTMDouble polarRadius) {
    UTMDatum utmDatum;
    utmDatum.equitorialRadius = equitorialRadius;
    utmDatum.polarRadius = polarRadius;
    
    return utmDatum;
}

#endif
