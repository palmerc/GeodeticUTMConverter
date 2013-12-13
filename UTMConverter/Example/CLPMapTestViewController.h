//
//  MapTest.h
//  UTMConverter
//
//  Created by Cameron Lowell Palmer & Mariia Ruchko on 19.06.12.
//  Copyright (c) 2012 Cameron Lowell Palmer & Mariia Ruchko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>


@interface CLPMapTestViewController : UIViewController {
@private
    MKMapView *_mapView;
}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end
