//
//  DWPlaceDetailsViewController.h
//  Denwen
//
//  Created by Deepak Rao on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWConstants.h"
#import "DDAnnotation.h"

@interface DWPlaceDetailsViewController : UIViewController<MKMapViewDelegate> {
	MKMapView *mapView;	
	NSString *_placeName;
	NSString *_placeAddress;
	CLLocation *_placeLocation;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (id)initWithPlaceName:(NSString *)placeName placeAddress:(NSString*)placeAddress andLocation:(CLLocation*)placeLocation;

@end
