//
//  AddressAnnotation.h
//  Oslo
//
//  Created by Cameron Lowell Palmer & Mariia Ruchko on 19.06.12.
//  Copyright (c) 2012 Cameron Lowell Palmer & Mariia Ruchko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>



@interface AddressAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)c;

@end
