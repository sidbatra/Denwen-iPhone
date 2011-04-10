//
//  DWChooseLocationViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWChooseLocationViewController.h"
#import "DWConstants.h"

#import "DDAnnotationView.h"
#import "DDAnnotation.h"

static float	 const kMapCenterLatOffset		= 0.0005;
static NSInteger const kMapZoomLevel			= 500;
static NSString* const kPinIdentifier			= @"PinIdentifier";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWChooseLocationViewController

@synthesize selectedLocation	= _selectedLocation;
@synthesize mapView				= _mapView;

//----------------------------------------------------------------------------------------------------
- (id)initWithLocation:(CLLocation*)location 
		   andDelegate:(id)theDelegate {
	
	self = [super init];
	
	if(self) {
		
		self.selectedLocation	= location;
		_delegate				= theDelegate;
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	
	self.selectedLocation	= nil;
	self.mapView			= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
	
	CLLocationCoordinate2D mapCenter;
	mapCenter.latitude	= self.selectedLocation.coordinate.latitude + kMapCenterLatOffset;
	mapCenter.longitude = self.selectedLocation.coordinate.longitude;
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapCenter,kMapZoomLevel,kMapZoomLevel);
	[self.mapView setRegion:region animated:YES];
	
	DDAnnotation *annotation	= [[[DDAnnotation alloc] initWithCoordinate:self.selectedLocation.coordinate
													   addressDictionary:nil] autorelease];
		
	[self.mapView addAnnotation:annotation];
	[self.mapView selectAnnotation:annotation animated:NO];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
}


//----------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)doneButtonClicked:(id)sender {
	[_delegate chooseLocationFinishedWithLocation:self.selectedLocation];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MKMapViewDelegate

//----------------------------------------------------------------------------------------------------
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinIdentifier];
	
	if (!pinView) {
		pinView	= [[[MKPinAnnotationView alloc] initWithAnnotation:annotation 
												   reuseIdentifier:kPinIdentifier] autorelease];
		pinView.draggable = YES;
	}
	else
		pinView.annotation = annotation;
	
	return pinView;
}

//----------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)theMapView didAddAnnotationViews:(NSArray *)views {
	
	for (id<MKAnnotation> currentAnnotation in self.mapView.annotations)    
		[self.mapView selectAnnotation:currentAnnotation 
							  animated:NO];
}

//----------------------------------------------------------------------------------------------------
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
	
	if (oldState == MKAnnotationViewDragStateDragging) {
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
		
		self.selectedLocation = [[[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude 
														   longitude:annotation.coordinate.longitude] autorelease];		
	}
}

@end
