//
//  UTMConverter.swift
//  UTMConverter
//
//  Created by Cameron Palmer on 22.10.2015.
//  Copyright © 2015 Bird and Bear Productions. All rights reserved.
//

import Foundation
import CoreLocation

public enum UTMHemisphere {
    case Undefined, Northern, Southern

    init() {
        self = .Undefined
    }
}

public enum UTMLatitudeBand {
    case Undefined, A, B, C, D, E, F, G, H, J, K, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z

    init() {
        self = .Undefined
    }
}

public struct UTMDatum {
    public var equitorialRadius: Double
    public var polarRadius: Double
}
let WGS84 = UTMDatum(equitorialRadius: 6378137.0, polarRadius: 6356752.314140)

struct TMCoordinate {
    var easting = 0.0
    var northing = 0.0
}
func TMCoordinateMake(easting: Double, _ northing: Double) -> TMCoordinate {
    return TMCoordinate(easting: easting, northing: northing)
}

public struct UTMCoordinate {
    public var easting = 0.0
    public var northing = 0.0
    public var gridZone: Double
    public var latitudeBand: UTMLatitudeBand
    public var hemisphere: UTMHemisphere
}
public func UTMCoordinateMake(easting: Double, _ northing: Double, _ gridZone: Double, _ latitudeBand: UTMLatitudeBand, _ hemisphere: UTMHemisphere) -> UTMCoordinate {
    return UTMCoordinate(easting: easting, northing: northing, gridZone: gridZone, latitudeBand: latitudeBand, hemisphere: hemisphere)
}

public class UTMConverter {
    var datum: UTMDatum
    var centralMeridianScaleFactor = 0.9996

    convenience init() {
        self.init(withDatum: WGS84)
    }

    init(withDatum datum: UTMDatum) {
        self.datum = datum
    }

    func locationToUTM(location: CLLocationCoordinate2D) -> UTMCoordinate {
        let band = UTMLatitudeBand.A
        let zone = floor((location.longitude + 180.0) / 6) + 1;
        var hemisphere: UTMHemisphere;
        if (location.latitude < 0) {
            hemisphere = UTMHemisphere.Southern;
        } else {
            hemisphere = UTMHemisphere.Northern;
        }
        let centralMeridian = self.centralMeridianForZone(gridZone: zone, latitudeBand: band);

//        latitudeAndLongitudeCoordinates.longitude = degreesToRadians(latitudeAndLongitudeCoordinates.longitude);
//        latitudeAndLongitudeCoordinates.latitude = degreesToRadians(latitudeAndLongitudeCoordinates.latitude);
        let TM = self.locationToTM(withLocation: location, centralMeridian: centralMeridian)

        /* Adjust easting and northing for UTM system. */
        let x = TM.easting * self.centralMeridianScaleFactor + 500000.0;
        var y = TM.northing * self.centralMeridianScaleFactor;
        if (y < 0.0) {
            y = y + 10000000.0;
        }

        return UTMCoordinateMake(x, y, zone, band, hemisphere)
    }

    func UTMToLocation(UTM: UTMCoordinate) -> CLLocationCoordinate2D {
        var x = UTM.easting
        var y = UTM.northing
        let zone = UTM.gridZone
        let band = UTM.latitudeBand
        let hemisphere = UTM.hemisphere

        x -= 500000.0
        x /= self.centralMeridianScaleFactor

        /* If in southern hemisphere, adjust y accordingly. */
        if (hemisphere == UTMHemisphere.Southern) {
            y -= 10000000.0
        }

        y /= self.centralMeridianScaleFactor

        let TM = TMCoordinateMake(x, y)
        let centralMeridian = self.centralMeridianForZone(gridZone: zone, latitudeBand: band)
        return self.TMToLocation(withTM: TM, centralMeridian: centralMeridian)
//        location.latitude = radiansToDegrees(location.latitude);
//        location.longitude = radiansToDegrees(location.longitude);
    }

    func locationToTM(withLocation location: CLLocationCoordinate2D, centralMeridian lambda0: Double) -> TMCoordinate {
        let phi = degreesToRadians(location.latitude) // Latitude in radians
        let lambda = degreesToRadians(location.longitude) // Longitude in radians

        let equitorialRadus = self.datum.equitorialRadius;
        let polarRadius = self.datum.polarRadius;

        /* Precalculate ep2 */
        let ep2 = (pow(equitorialRadus, 2.0) - pow(polarRadius, 2.0)) / pow(polarRadius, 2.0);

        /* Precalculate nu2 */
        let nu2 = ep2 * pow(cos(phi), 2.0);

        /* Precalculate N */
        let N = pow(equitorialRadus, 2.0) / (polarRadius * sqrt(1 + nu2));

        /* Precalculate t */
        let t = tan(phi);
        let t2 = t * t;
//        let tmp = pow(t2, 3.0) - pow(t, 6.0);

        /* Precalculate l */
        let l = lambda - lambda0;

        /* Precalculate coefficients for l**n in the equations below
        so a normal human being can read the expressions for easting
        and northing
        -- l**1 and l**2 have coefficients of 1.0 */
        let l3coef = 1.0 - t2 + nu2;
        let l4coef = 5.0 - t2 + 9 * nu2 + 4.0 * (nu2 * nu2);
        let l5coef = 5.0 - 18.0 * t2 + (t2 * t2) + 14.0 * nu2 - 58.0 * t2 * nu2;
        let l6coef = 61.0 - 58.0 * t2 + (t2 * t2) + 270.0 * nu2 - 330.0 * t2 * nu2;
        let l7coef = 61.0 - 479.0 * t2 + 179.0 * (t2 * t2) - pow(t2, 3.0);
        let l8coef = 1385.0 - 3111.0 * t2 + 543.0 * (t2 * t2) - pow(t2, 3.0);

        /* Calculate easting (x) */
        let N1 = N * cos(phi) * l
        let N2 = N / 6.0 * pow(cos(phi), 3.0) * l3coef * pow(l, 3.0)
        let N3 = N / 120.0 * pow(cos(phi), 5.0) * l5coef * pow(l, 5.0)
        let N4 = N / 5040.0 * pow(cos(phi), 7.0) * l7coef * pow(l, 7.0)
        let easting = N1 + N2 + N3 + N4

        /* Calculate northing (y) */
        let N5 = t / 2.0 * N * pow(cos(phi), 2.0) * pow(l, 2.0)
        let N6 = t / 24.0 * N * pow(cos(phi), 4.0) * l4coef * pow(l, 4.0)
        let N7 = t / 720.0 * N * pow(cos(phi), 6.0) * l6coef * pow(l, 6.0)
        let N8 = t / 40320.0 * N * pow(cos(phi), 8.0) * l8coef * pow(l, 8.0)
        let northing = self.arcLengthOfMeridian(phi) + N5 + N6 + N7 + N8
        
        return TMCoordinateMake(easting, northing)
    }

    /** Converts x and y coordinates in the Transverse Mercator projection to a latitude/longitude pair.  Note that Transverse Mercator is not the same as UTM; a scale factor is required to convert between them.
        Remarks:
        The local variables Nf, nuf2, tf, and tf2 serve the same purpose as N, nu2, t, and t2 in MapLatLonToXY, but they are computed with respect to the footpoint latitude phif. x1frac, x2frac, x2poly, x3poly, etc. are to enhance readability and to optimize computations. */
    func TMToLocation(withTM TM: TMCoordinate, centralMeridian lambda0: Double) -> CLLocationCoordinate2D {
        let x = TM.easting
        let y = TM.northing

        let equitorialRadius = self.datum.equitorialRadius
        let polarRadius = self.datum.polarRadius

        /* Get the value of phif, the footpoint latitude. */
        let phif = self.footprintLatitudeInRadians(y)

        /* Precalculate ep2 */
        let ep2 = (pow(equitorialRadius, 2.0) - pow(polarRadius, 2.0)) / pow(polarRadius, 2.0)

        /* Precalculate cos (phif) */
        let cf = cos(phif)

        /* Precalculate nuf2 */
        let nuf2 = ep2 * pow(cf, 2.0)

        /* Precalculate Nf and initialize Nfpow */
        let Nf = pow(equitorialRadius, 2.0) / (polarRadius * sqrt(1 + nuf2))
        var Nfpow = Nf

        /* Precalculate tf */
        let tf = tan(phif)
        let tf2 = tf * tf
        let tf4 = tf2 * tf2

        /* Precalculate fractional coefficients for x**n in the equations
        below to simplify the expressions for latitude and longitude. */
        let x1frac = 1.0 / (Nfpow * cf)

        Nfpow *= Nf   /* now equals Nf**2) */
        let x2frac = tf / (2.0 * Nfpow)

        Nfpow *= Nf   /* now equals Nf**3) */
        let x3frac = 1.0 / (6.0 * Nfpow * cf)

        Nfpow *= Nf   /* now equals Nf**4) */
        let x4frac = tf / (24.0 * Nfpow)

        Nfpow *= Nf   /* now equals Nf**5) */
        let x5frac = 1.0 / (120.0 * Nfpow * cf)

        Nfpow *= Nf   /* now equals Nf**6) */
        let x6frac = tf / (720.0 * Nfpow)

        Nfpow *= Nf   /* now equals Nf**7) */
        let x7frac = 1.0 / (5040.0 * Nfpow * cf)

        Nfpow *= Nf   /* now equals Nf**8) */
        let x8frac = tf / (40320.0 * Nfpow)

        /* Precalculate polynomial coefficients for x**n.
        -- x**1 does not have a polynomial coefficient. */
        let x2poly = -1.0 - nuf2
        let x3poly = -1.0 - 2 * tf2 - nuf2
        let x4poly = 5.0 + 3.0 * tf2 + 6.0 * nuf2 - 6.0 * tf2 * nuf2 - 3.0 * (nuf2 * nuf2) - 9.0 * tf2 * (nuf2 * nuf2)
        let x5poly = 5.0 + 28.0 * tf2 + 24.0 * tf4 + 6.0 * nuf2 + 8.0 * tf2 * nuf2
        let x6poly = -61.0 - 90.0 * tf2 - 45.0 * tf4 - 107.0 * nuf2 + 162.0 * tf2 * nuf2
        let x7poly = -61.0 - 662.0 * tf2 - 1320.0 * tf4 - 720.0 * (tf4 * tf2)
        let x8poly = 1385.0 + 3633.0 * tf2 + 4095.0 * tf4 + 1575 * (tf4 * tf2)

        /* Calculate latitude */
        let latitude = radiansToDegrees(phif + x2frac * x2poly * (x * x) + x4frac * x4poly * pow(x, 4.0) + x6frac * x6poly * pow(x, 6.0) + x8frac * x8poly * pow(x, 8.0))
        
        /* Calculate longitude */
        let longitude = radiansToDegrees(lambda0 + x1frac * x + x3frac * x3poly * pow(x, 3.0) + x5frac * x5poly * pow(x, 5.0) + x7frac * x7poly * pow(x, 7.0))
        
        return CLLocationCoordinate2DMake(latitude, longitude)
    }

    //
    // Determines the central meridian for the given UTM zone.
    func centralMeridianForZone(gridZone gridZone: Double, latitudeBand: UTMLatitudeBand) -> Double {
        return degreesToRadians(-183.0 + (gridZone * 6.0))
    }

    //
    // Computes the ellipsoidal distance from the equator to a point at a given latitude in meters
    func arcLengthOfMeridian(latitudeInRadians: Double) -> Double {
        let equitorialRadus = self.datum.equitorialRadius;
        let polarRadius = self.datum.polarRadius;

        /* Precalculate n */
        let n = (equitorialRadus - polarRadius) / (equitorialRadus + polarRadius);

        /* Precalculate alpha */
        let alpha = ((equitorialRadus + polarRadius) / 2.0) * (1.0 + (pow(n, 2.0) / 4.0) + (pow(n, 4.0) / 64.0));

        /* Precalculate beta */
        let beta = (-3.0 * n / 2.0) + (9.0 * pow(n, 3.0) / 16.0) + (-3.0 * pow(n, 5.0) / 32.0);

        /* Precalculate gamma */
        let gamma = (15.0 * pow(n, 2.0) / 16.0) + (-15.0 * pow(n, 4.0) / 32.0);

        /* Precalculate delta */
        let delta = (-35.0 * pow(n, 3.0) / 48.0) + (105.0 * pow(n, 5.0) / 256.0);

        /* Precalculate epsilon */
        let epsilon = (315.0 * pow(n, 4.0) / 512.0);

        let beta2 = beta * sin(2.0 * latitudeInRadians)
        let gamma2 = gamma * sin(4.0 * latitudeInRadians)
        let delta2 = delta * sin(6.0 * latitudeInRadians)
        let epsilon2 = epsilon * sin(8.0 * latitudeInRadians)

        /* Now calculate the sum of the series and return */
        let meters = alpha * (latitudeInRadians + beta2 + gamma2 + delta2 + epsilon2);
        
        return meters;
    }

    //
    // Computes the footprint latitude for use in converting transverse Mercator coordinates to ellipsoidal coordinates.
    func footprintLatitudeInRadians(northingInMeters: Double) -> Double {
        let equitorialRadus = self.datum.equitorialRadius
        let polarRadius = self.datum.polarRadius

        /* Precalculate n (Eq. 10.18) */
        let n = (equitorialRadus - polarRadius) / (equitorialRadus + polarRadius)

        /* Precalculate alpha_ (Eq. 10.22) */
        /* (Same as alpha in Eq. 10.17) */
        let alpha = ((equitorialRadus + polarRadius) / 2.0) * (1 + (pow(n, 2.0) / 4) + (pow(n, 4.0) / 64))

        /* Precalculate y (Eq. 10.23) */
        let y = northingInMeters / alpha

        /* Precalculate beta (Eq. 10.22) */
        let beta = (3.0 * n / 2.0) + (-27.0 * pow(n, 3.0) / 32.0) + (269.0 * pow(n, 5.0) / 512.0)

        /* Precalculate gamma (Eq. 10.22) */
        let gamma = (21.0 * pow(n, 2.0) / 16.0) + (-55.0 * pow(n, 4.0) / 32.0)

        /* Precalculate delta (Eq. 10.22) */
        let delta = (151.0 * pow(n, 3.0) / 96.0) + (-417.0 * pow(n, 5.0) / 128.0)

        /* Precalculate epsilon (Eq. 10.22) */
        let epsilon = (1097.0 * pow(n, 4.0) / 512.0)

        /* Now calculate the sum of the series (Eq. 10.21) */
        let beta2 = beta * sin(2.0 * y)
        let gamma2 = gamma * sin(4.0 * y)
        let delta2 = delta * sin(6.0 * y)
        let epsilon2 = epsilon * sin(8.0 * y)
        let footprintLatitudeInRadians = y + beta2 + gamma2 + delta2 + epsilon2
        
        return footprintLatitudeInRadians
    }
    
    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180 / M_PI
    }

    func degreesToRadians(degrees: Double) -> Double {
        return degrees / 180 * M_PI
    }

}