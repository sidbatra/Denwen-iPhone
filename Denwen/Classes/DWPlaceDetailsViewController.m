//
//  DWPlaceDetailsViewController.m
//  Denwen
//
//  Created by Deepak Rao on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPlaceDetailsViewController.h"


@implementation DWPlaceDetailsViewController

@synthesize mapView;


#pragma mark -
#pragma mark View lifecycle


// Init the view with initializations for the member variables
//
- (id)initWithPlaceName:(NSString *)placeName placeAddress:(NSString*)placeAddress andLocation:(CLLocation*)placeLocation {
    self = [super init];
    if (self) {
		_placeName = [[NSString alloc] initWithString:placeName];
		_placeAddress = [[NSString alloc] initWithString:placeAddress];
		_placeLocation = [[CLLocation alloc] initWithLatitude:placeLocation.coordinate.latitude longitude:placeLocation.coordinate.longitude];
    }
    return self;
}


// Setup the UI and position the map
//
- (void)viewDidLoad {
	CLLocationCoordinate2D mapCenter;
	mapCenter.latitude = _placeLocation.coordinate.latitude + 0.0005;
	mapCenter.longitude = _placeLocation.coordinate.longitude;
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapCenter, 500, 500);
	[mapView setRegion:region animated:YES];
		
	DDAnnotation *annotation = [[DDAnnotation alloc] initWithCoordinate:_placeLocation.coordinate addressDictionary:nil];
	annotation.title = _placeName;
	annotation.subtitle = _placeAddress;
	[mapView addAnnotation:annotation];
	[annotation release];
	
	[mapView selectAnnotation:annotation animated:NO];
}


// Change the navigation and status bar styles 
//
- (void)viewWillAppear:(BOOL)animated {
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}


// Reset the navigation and status bar style changes
//
- (void)viewWillDisappear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:STATUS_BAR_STYLE];
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark -
#pragma mark MKMapViewDelegate


// Generate view for annotation
//
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:STATIC_PIN_IDENTIFIER];
	
	if (!pinView) {
		pinView	= [[[MKPinAnnotationView alloc]
											   initWithAnnotation:annotation reuseIdentifier:STATIC_PIN_IDENTIFIER] autorelease];
		//pinView.pinColor = MKPinAnnotationColorPurple;
		//pinView.animatesDrop = YES;
		pinView.canShowCallout = YES;
	}
	else
		pinView.annotation = annotation;
	
	
	return pinView;
}


// After an annotation is added, select it to show the text bubble
//
- (void)mapView:(MKMapView *)theMapView didAddAnnotationViews:(NSArray *)views {

	for (id<MKAnnotation> currentAnnotation in mapView.annotations)    
		[mapView selectAnnotation:currentAnnotation animated:NO];
}



#pragma mark -
#pragma mark Memory management


// The usual did receive memory warning
//
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];   
}



// The usual memory cleanup
//
- (void)dealloc {
	[_placeName release];
	[_placeAddress release];
	[_placeLocation release];
	
	[mapView release];
	
	[super dealloc];
}


@end
