//
//  DWPlaceDetailsViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceDetailsViewController.h"
#import "DWGUIManager.h"
#import "DDAnnotation.h"
#import "DWConstants.h"

static float	 const kMapCenterLatOffset		= 0.0005;
static NSInteger const kMapZoomLevel			= 500;
static NSString* const kPinIdentifier			= @"PinIdentifier";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceDetailsViewController

@synthesize place		= _place;
@synthesize mapView		= _mapView;

//----------------------------------------------------------------------------------------------------
- (id)initWithPlace:(DWPlace*)thePlace andDelegate:(id)delegate{
    self = [super init];
	
    if (self) {
		self.place  = thePlace;
        _delegate   = delegate;
    }
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    self.navigationItem.leftBarButtonItem = [DWGUIManager customBackButton:_delegate];
    
	CLLocationCoordinate2D mapCenter;
	mapCenter.latitude          = self.place.location.coordinate.latitude + kMapCenterLatOffset;
	mapCenter.longitude         = self.place.location.coordinate.longitude;
	MKCoordinateRegion region   = MKCoordinateRegionMakeWithDistance(mapCenter,
                                                                     kMapZoomLevel,kMapZoomLevel);
    
	[self.mapView setRegion:region 
                   animated:YES];
		
	DDAnnotation *annotation	= [[[DDAnnotation alloc] initWithCoordinate:self.place.location.coordinate
														  addressDictionary:nil] autorelease];
	annotation.title			= self.place.name;
	annotation.subtitle			= [self.place displayAddress];
	
	[self.mapView addAnnotation:annotation];
	[self.mapView selectAnnotation:annotation animated:NO];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];   
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.place		= nil;
	self.mapView	= nil;

	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}


//----------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:kStatusBarStyle];
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
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
		//pinView.animatesDrop = YES;
		pinView.canShowCallout = YES;
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



@end
