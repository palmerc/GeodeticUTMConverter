//
//  GeodeticUTMConverter.m
//  GeodeticUTMConverter
//
//  Created by Cameron Lowell Palmer & Mariia Ruchko on 19.06.12.
//  Copyright (c) 2012 Cameron Lowell Palmer & Mariia Ruchko. All rights reserved.
//
//  Code converted from Javascript as written by Chuck Taylor http://home.hiwaay.net/~taylorc/toolbox/geography/geoutm.html
//  Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J., GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
//

#import "GeodeticUTMConverter.h"



@interface GeodeticUTMConverter ()
@property (assign, nonatomic) UTMDouble utmScaleFactor;

double radiansToDegrees(double radians);
double degreesToRadians(double degrees);
@end



@implementation GeodeticUTMConverter

+ (CLLocationCoordinate2D)UTMCoordinatesToLatitudeAndLongitude:(UTMCoordinates)UTMCoordinates
{
    GeodeticUTMConverter *utmConverter = [[GeodeticUTMConverter alloc] init];
    CLLocationCoordinate2D latLong = [utmConverter UTMCoordinatesToLatitudeAndLongitude:UTMCoordinates];
    return latLong;
}

+ (UTMCoordinates)latitudeAndLongitudeToUTMCoordinates:(CLLocationCoordinate2D)latitudeAndLongitudeCoordinates
{
    GeodeticUTMConverter *utmConverter = [[self alloc] init];
    UTMCoordinates utmCoordinates = [utmConverter latitudeAndLongitudeToUTMCoordinates:latitudeAndLongitudeCoordinates];
    return utmCoordinates;
}



- (id)init
{
    self = [super init];
    if (self != nil) {
        UTMDouble equitorialRadius = 6378137;
        UTMDouble polarRadius = 6356752.3142;
        UTMDatum wgs84datum = UTMDatumMake(equitorialRadius, polarRadius);
        
        _utmDatum = wgs84datum;
        
        _utmScaleFactor = 0.9996;
    }
    
    return self;
}

- (id)initWithDatum:(UTMDatum)utmDatum
{
    self = [super init];
    if (self != nil) {
        _utmDatum = utmDatum;
        
        _utmScaleFactor = 0.9996;
    }
    
    return self;
}



#pragma mark - Public Interface methods

- (UTMCoordinates)latitudeAndLongitudeToUTMCoordinates:(CLLocationCoordinate2D)latitudeAndLongitudeCoordinates
{
    UTMCoordinates utmCoordinates;
    
    UTMGridZone zone = floor((latitudeAndLongitudeCoordinates.longitude + 180.0) / 6) + 1;
    UTMHemisphere hemisphere;
    if (latitudeAndLongitudeCoordinates.latitude < 0) {
        hemisphere = kUTMHemisphereSouthern;
    } else {
        hemisphere = kUTMHemisphereNorthern;
    }
    UTMDouble cmeridian = [self UTMCentralMeridian:zone];
    
    latitudeAndLongitudeCoordinates.longitude = degreesToRadians(latitudeAndLongitudeCoordinates.longitude);
    latitudeAndLongitudeCoordinates.latitude = degreesToRadians(latitudeAndLongitudeCoordinates.latitude);
    utmCoordinates = [self latitudeAndLongitudeToTMCoordinates:latitudeAndLongitudeCoordinates centralMeridian:cmeridian];
    
    /* Adjust easting and northing for UTM system. */
    UTMDouble x = utmCoordinates.easting * _utmScaleFactor + 500000.0;
    UTMDouble y = utmCoordinates.northing * _utmScaleFactor;
    if (y < 0.0) {
        y = y + 10000000.0;
    }
    
    utmCoordinates.easting = x;
    utmCoordinates.northing = y;
    utmCoordinates.gridZone = zone;
    utmCoordinates.hemisphere = hemisphere;
    
    return utmCoordinates;
}

- (CLLocationCoordinate2D)UTMCoordinatesToLatitudeAndLongitude:(UTMCoordinates)UTMCoordinates
{
    UTMDouble cmeridian;
    
    UTMDouble x = UTMCoordinates.easting;
    UTMDouble y = UTMCoordinates.northing;
    UTMDouble zone = UTMCoordinates.gridZone;
    UTMHemisphere hemisphere = UTMCoordinates.hemisphere;
    
    x -= 500000.0;
    x /= _utmScaleFactor;
    
    /* If in southern hemisphere, adjust y accordingly. */
    if (hemisphere == kUTMHemisphereSouthern) {
        y -= 10000000.0;
    }
    
    y /= _utmScaleFactor;
    
    UTMCoordinates.easting = x;
    UTMCoordinates.northing = y;
    
    cmeridian = [self UTMCentralMeridian:zone];
    CLLocationCoordinate2D location = [self TMCoordinatesToLatitudeAndLongitude:UTMCoordinates andCentralMeridian:cmeridian];
    location.latitude = radiansToDegrees(location.latitude);
    location.longitude = radiansToDegrees(location.longitude);
    
    return location;
}



#pragma mark - Private Category methods

//
// Computes the ellipsoidal distance from the equator to a point at a given latitude in meters
- (UTMDouble)arcLengthOfMeridian:(UTMDouble)latitudeInRadians
{
    UTMDouble alpha;
    UTMDouble beta;
    UTMDouble gamma;
    UTMDouble delta;
    UTMDouble epsilon;
    UTMDouble n;
    
    UTMDouble result;
    
    UTMDouble equitorialRadus = _utmDatum.equitorialRadius;
    UTMDouble polarRadius = _utmDatum.polarRadius;
    
    /* Precalculate n */
    n = (equitorialRadus - polarRadius) / (equitorialRadus + polarRadius);
    
    /* Precalculate alpha */
    alpha = ((equitorialRadus + polarRadius) / 2.0) * (1.0 + (pow(n, 2.0) / 4.0) + (pow(n, 4.0) / 64.0));
    
    /* Precalculate beta */
    beta = (-3.0 * n / 2.0) + (9.0 * pow(n, 3.0) / 16.0) + (-3.0 * pow(n, 5.0) / 32.0);
    
    /* Precalculate gamma */
    gamma = (15.0 * pow(n, 2.0) / 16.0) + (-15.0 * pow(n, 4.0) / 32.0);
    
    /* Precalculate delta */
    delta = (-35.0 * pow(n, 3.0) / 48.0) + (105.0 * pow(n, 5.0) / 256.0);
    
    /* Precalculate epsilon */
    epsilon = (315.0 * pow(n, 4.0) / 512.0);
    
    /* Now calculate the sum of the series and return */
    result = alpha * (latitudeInRadians + (beta * sin(2.0 * latitudeInRadians)) + (gamma * sin(4.0 * latitudeInRadians)) + (delta * sin(6.0 * latitudeInRadians)) + (epsilon * sin(8.0 * latitudeInRadians)));
    
    return result;
}

//
// Determines the central meridian for the given UTM zone.
- (UTMDouble)UTMCentralMeridian:(UTMGridZone)zone
{
    UTMDouble cmeridian;
    
    cmeridian = degreesToRadians(-183.0 + (zone * 6.0));
    
    return cmeridian;
}

//
// Computes the footpoint latitude for use in converting transverse Mercator coordinates to ellipsoidal coordinates.
- (UTMDouble)footpointLatitude:(UTMDouble)northingInMeters
{
    UTMDouble y;
    UTMDouble alpha; 
    UTMDouble beta;
    UTMDouble gamma;
    UTMDouble delta;
    UTMDouble epsilon; 
    UTMDouble n;
    
    UTMDouble footprintLatitudeInRadians;
    
    UTMDouble equitorialRadus = _utmDatum.equitorialRadius;
    UTMDouble polarRadius = _utmDatum.polarRadius;
    
    /* Precalculate n (Eq. 10.18) */
    n = (equitorialRadus - polarRadius) / (equitorialRadus + polarRadius);
    
    /* Precalculate alpha_ (Eq. 10.22) */
    /* (Same as alpha in Eq. 10.17) */
    alpha = ((equitorialRadus + polarRadius) / 2.0) * (1 + (pow(n, 2.0) / 4) + (pow(n, 4.0) / 64));
    
    /* Precalculate y (Eq. 10.23) */
    y = northingInMeters / alpha;
    
    /* Precalculate beta (Eq. 10.22) */
    beta = (3.0 * n / 2.0) + (-27.0 * pow(n, 3.0) / 32.0) + (269.0 * pow(n, 5.0) / 512.0);
    
    /* Precalculate gamma (Eq. 10.22) */
    gamma = (21.0 * pow(n, 2.0) / 16.0) + (-55.0 * pow(n, 4.0) / 32.0);
    
    /* Precalculate delta (Eq. 10.22) */
    delta = (151.0 * pow(n, 3.0) / 96.0) + (-417.0 * pow(n, 5.0) / 128.0);
    
    /* Precalculate epsilon (Eq. 10.22) */
    epsilon = (1097.0 * pow(n, 4.0) / 512.0);
    
    /* Now calculate the sum of the series (Eq. 10.21) */
    footprintLatitudeInRadians = y + (beta * sin(2.0 * y)) + (gamma * sin(4.0 * y)) + (delta * sin(6.0 * y)) + (epsilon * sin(8.0 * y));
    
    return footprintLatitudeInRadians;
}

//
// Converts a latitude/longitude pair to x and y coordinates in the Transverse Mercator projection.  Note that Transverse Mercator is not the same as UTM; a scale factor is required to convert between them.
- (UTMCoordinates)latitudeAndLongitudeToTMCoordinates:(CLLocationCoordinate2D)coordinates centralMeridian:(UTMDouble)lambda0
{
    UTMCoordinates tmCoordinates;
    
    UTMDouble N, nu2, ep2, t, t2, l;
    UTMDouble l3coef, l4coef, l5coef, l6coef, l7coef, l8coef;
    UTMDouble tmp;
    
    UTMDouble phi = coordinates.latitude; // Latitude in radians
    UTMDouble lambda = coordinates.longitude; // Longitude in radians
    
    UTMDouble equitorialRadus = _utmDatum.equitorialRadius;
    UTMDouble polarRadius = _utmDatum.polarRadius;
    
    /* Precalculate ep2 */
    ep2 = (pow(equitorialRadus, 2.0) - pow(polarRadius, 2.0)) / pow(polarRadius, 2.0);
    
    /* Precalculate nu2 */
    nu2 = ep2 * pow(cos(phi), 2.0);
    
    /* Precalculate N */
    N = pow(equitorialRadus, 2.0) / (polarRadius * sqrt(1 + nu2));
    
    /* Precalculate t */
    t = tan(phi);
    t2 = t * t;
    tmp = (t2 * t2 * t2) - pow(t, 6.0);
    
    /* Precalculate l */
    l = lambda - lambda0;
    
    /* Precalculate coefficients for l**n in the equations below
     so a normal human being can read the expressions for easting
     and northing
     -- l**1 and l**2 have coefficients of 1.0 */
    l3coef = 1.0 - t2 + nu2;
    l4coef = 5.0 - t2 + 9 * nu2 + 4.0 * (nu2 * nu2);
    l5coef = 5.0 - 18.0 * t2 + (t2 * t2) + 14.0 * nu2 - 58.0 * t2 * nu2;
    l6coef = 61.0 - 58.0 * t2 + (t2 * t2) + 270.0 * nu2 - 330.0 * t2 * nu2;
    l7coef = 61.0 - 479.0 * t2 + 179.0 * (t2 * t2) - (t2 * t2 * t2);
    l8coef = 1385.0 - 3111.0 * t2 + 543.0 * (t2 * t2) - (t2 * t2 * t2);
    
    /* Calculate easting (x) */
    tmCoordinates.easting = N * cos(phi) * l + (N / 6.0 * pow(cos(phi), 3.0) * l3coef * pow(l, 3.0)) + (N / 120.0 * pow(cos(phi), 5.0) * l5coef * pow(l, 5.0)) + (N / 5040.0 * pow(cos(phi), 7.0) * l7coef * pow(l, 7.0));
    
    /* Calculate northing (y) */
    tmCoordinates.northing = [self arcLengthOfMeridian:phi] + (t / 2.0 * N * pow(cos(phi), 2.0) * pow(l, 2.0)) + (t / 24.0 * N * pow(cos(phi), 4.0) * l4coef * pow(l, 4.0)) + (t / 720.0 * N * pow(cos(phi), 6.0) * l6coef * pow(l, 6.0)) + (t / 40320.0 * N * pow(cos(phi), 8.0) * l8coef * pow(l, 8.0));
    
    return tmCoordinates;
}



//
// Converts x and y coordinates in the Transverse Mercator projection to a latitude/longitude pair.  Note that Transverse Mercator is not the same as UTM; a scale factor is required to convert between them.
// Remarks:
// The local variables Nf, nuf2, tf, and tf2 serve the same purpose as N, nu2, t, and t2 in MapLatLonToXY, but they are computed with respect to the footpoint latitude phif.
// x1frac, x2frac, x2poly, x3poly, etc. are to enhance readability and to optimize computations.
- (CLLocationCoordinate2D)TMCoordinatesToLatitudeAndLongitude:(UTMCoordinates)TMCoordinates andCentralMeridian:(UTMDouble)lambda0
{
    CLLocationCoordinate2D coordinates;
    
    UTMDouble x = TMCoordinates.easting;
    UTMDouble y = TMCoordinates.northing;
    
    UTMDouble equitorialRadus = _utmDatum.equitorialRadius;
    UTMDouble polarRadius = _utmDatum.polarRadius;
    
    UTMDouble phif, Nf, Nfpow, nuf2, ep2, tf, tf2, tf4, cf;
    UTMDouble x1frac, x2frac, x3frac, x4frac, x5frac, x6frac, x7frac, x8frac;
    UTMDouble x2poly, x3poly, x4poly, x5poly, x6poly, x7poly, x8poly;
    
    /* Get the value of phif, the footpoint latitude. */
    phif = [self footpointLatitude:y];
    
    /* Precalculate ep2 */
    ep2 = (pow(equitorialRadus, 2.0) - pow(polarRadius, 2.0)) / pow(polarRadius, 2.0);
    
    /* Precalculate cos (phif) */
    cf = cos(phif);
    
    /* Precalculate nuf2 */
    nuf2 = ep2 * pow(cf, 2.0);
    
    /* Precalculate Nf and initialize Nfpow */
    Nf = pow(equitorialRadus, 2.0) / (polarRadius * sqrt(1 + nuf2));
    Nfpow = Nf;
    
    /* Precalculate tf */
    tf = tan(phif);
    tf2 = tf * tf;
    tf4 = tf2 * tf2;
    
    /* Precalculate fractional coefficients for x**n in the equations
     below to simplify the expressions for latitude and longitude. */
    x1frac = 1.0 / (Nfpow * cf);
    
    Nfpow *= Nf;   /* now equals Nf**2) */
    x2frac = tf / (2.0 * Nfpow);
    
    Nfpow *= Nf;   /* now equals Nf**3) */
    x3frac = 1.0 / (6.0 * Nfpow * cf);
    
    Nfpow *= Nf;   /* now equals Nf**4) */
    x4frac = tf / (24.0 * Nfpow);
    
    Nfpow *= Nf;   /* now equals Nf**5) */
    x5frac = 1.0 / (120.0 * Nfpow * cf);
    
    Nfpow *= Nf;   /* now equals Nf**6) */
    x6frac = tf / (720.0 * Nfpow);
    
    Nfpow *= Nf;   /* now equals Nf**7) */
    x7frac = 1.0 / (5040.0 * Nfpow * cf);
    
    Nfpow *= Nf;   /* now equals Nf**8) */
    x8frac = tf / (40320.0 * Nfpow);
    
    /* Precalculate polynomial coefficients for x**n.
     -- x**1 does not have a polynomial coefficient. */
    x2poly = -1.0 - nuf2;
    x3poly = -1.0 - 2 * tf2 - nuf2;
    x4poly = 5.0 + 3.0 * tf2 + 6.0 * nuf2 - 6.0 * tf2 * nuf2 - 3.0 * (nuf2 *nuf2) - 9.0 * tf2 * (nuf2 * nuf2);
    x5poly = 5.0 + 28.0 * tf2 + 24.0 * tf4 + 6.0 * nuf2 + 8.0 * tf2 * nuf2;
    x6poly = -61.0 - 90.0 * tf2 - 45.0 * tf4 - 107.0 * nuf2 + 162.0 * tf2 * nuf2;
    x7poly = -61.0 - 662.0 * tf2 - 1320.0 * tf4 - 720.0 * (tf4 * tf2);
    x8poly = 1385.0 + 3633.0 * tf2 + 4095.0 * tf4 + 1575 * (tf4 * tf2);
    
    /* Calculate latitude */
    coordinates.latitude = phif + x2frac * x2poly * (x * x) + x4frac * x4poly * pow(x, 4.0) + x6frac * x6poly * pow(x, 6.0) + x8frac * x8poly * pow(x, 8.0);
    
    /* Calculate longitude */
    coordinates.longitude = lambda0 + x1frac * x + x3frac * x3poly * pow(x, 3.0) + x5frac * x5poly * pow(x, 5.0) + x7frac * x7poly * pow(x, 7.0);
    
    return coordinates;
}



//
// Radians to Degrees and vice-versa
double radiansToDegrees(double radians)
{
    return radians * 180 / M_PI;
}

double degreesToRadians(double degrees)
{
    return degrees / 180 * M_PI;
}

@end
