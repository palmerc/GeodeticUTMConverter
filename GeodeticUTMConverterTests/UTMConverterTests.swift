//
//  UTMConverterTests.swift
//  UTMConverterTests
//
//  Created by Cameron Palmer on 22.10.2015.
//  Copyright © 2015 Bird and Bear Productions. All rights reserved.
//

import XCTest
import CoreLocation
@testable import UTMConverter

class UTMConverterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUTMToLocation() {
        let coordinate = UTMCoordinate(easting: 598430, northing: 6643010, gridZone: 32, latitudeBand: UTMLatitudeBand.A, hemisphere: UTMHemisphere.Northern)

        let converter = UTMConverter()
        let location = converter.UTMToLocation(coordinate)

        NSLog("Latitude: %f, Longitude: %f", location.latitude, location.longitude);
        XCTAssertEqualWithAccuracy(location.latitude, 59.912814611065265, accuracy: 0.001, "Should be equal.");
        XCTAssertEqualWithAccuracy(location.longitude, 10.760192985178369, accuracy: 0.001, "Should be equal.");
    }

    func testLocationToUTM() {
        let location = CLLocationCoordinate2DMake(59.912814611065265, 10.760192985178369)

        let converter = UTMConverter()
        let UTM = converter.locationToUTM(location)

        var hemisphere: String;
        if (UTM.hemisphere == UTMHemisphere.Northern) {
            hemisphere = "Northern";
        } else {
            hemisphere = "Southern";
        }

        NSLog("Northing: %f, Easting: %f, GridZone: %d, Hemisphere: %@", UTM.northing, UTM.easting, UTM.gridZone, hemisphere);
        XCTAssertEqualWithAccuracy(UTM.northing, 6643010, accuracy: 0.1, "Should be equal.");
        XCTAssertEqualWithAccuracy(UTM.easting, 598430, accuracy: 0.1, "Should be equal.");
        XCTAssertEqual(UTM.gridZone, 32, "");
        XCTAssertEqual(UTM.hemisphere, UTMHemisphere.Northern, "");
    }
}
