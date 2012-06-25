//
//  MapTest.m
//  UTMConverter
//
//  Created by Cameron Lowell Palmer & Mariia Ruchko on 19.06.12.
//  Copyright (c) 2012 Cameron Lowell Palmer & Mariia Ruchko. All rights reserved.
//

#import "MapTest.h"

#import "UTMConverter.h"
#import "AddressAnnotation.h"



@implementation MapTest
@synthesize mapView = _mapView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UTMCoordinates coordinates;
    coordinates.gridZone = 32;
    coordinates.northing = 6643010;
    coordinates.easting = 598430;
    coordinates.hemisphere = kUTMHemisphereNorthern;
    
    UTMConverter *converter = [[UTMConverter alloc] init];
    CLLocationCoordinate2D groenland = [converter UTMCoordinatesToLatitudeAndLongitude:coordinates];
    
    AddressAnnotation *addressAnnotation = [[AddressAnnotation alloc] initWithCoordinate:groenland];
    
    [self.mapView addAnnotation:addressAnnotation];
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta=0.005;
    span.longitudeDelta=0.005; 
    
    region.span=span;
    region.center=groenland;
    
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView regionThatFits:region];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
