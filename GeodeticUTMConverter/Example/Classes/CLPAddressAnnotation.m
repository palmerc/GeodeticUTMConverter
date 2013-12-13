//
//  AddressAnnotation.m
//  Oslo
//
//  Created by Cameron Lowell Palmer & Mariia Ruchko on 19.06.12.
//  Copyright (c) 2012 Cameron Lowell Palmer & Mariia Ruchko. All rights reserved.
//

#import "CLPAddressAnnotation.h"



@interface CLPAddressAnnotation ()
@end



@implementation CLPAddressAnnotation

- (NSString *)subtitle
{
	return nil;
}

- (NSString *)title
{
	return nil;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self != nil) {
        _coordinate = coordinate;
    }
    
	return self;
}

@end
