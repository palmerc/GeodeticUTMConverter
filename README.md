### Geodetic UTM Coordinate Converter ### 

UTM or [Universal Transverse Mercator][2] is an older system for specifying a global position on the planet similar to the Latitude and Longitude except the values are called Northing and Easting and requires a [Zone][3].

In Norway, this UTM system is a standard way for governmental organizations to define location. For example, Ruter, the public transit agency, uses it in their public transit [APIs][1]. This library will tranlate between a UTM coordinate and the Lat/Long coordinates that are more commonly used on modern platforms like iOS.

#### Sample Code ####

    UTMCoordinates coordinates;
    coordinates.gridZone = 32;
    coordinates.northing = 6643010;
    coordinates.easting = 598430;
    coordinates.hemisphere = kUTMHemisphereNorthern;
    
    GeodeticUTMConverter *converter = [[GeodeticUTMConverter alloc] init];
    CLLocationCoordinate2D groenland = [converter UTMCoordinatesToLatitudeAndLongitude:coordinates];

[1]: http://labs.trafikanten.no/2011/3/22/hvordan-bruke-json-data.aspx
[2]: http://en.wikipedia.org/wiki/Universal_Transverse_Mercator_coordinate_system
[3]: http://www.dmap.co.uk/utmworld.htm
