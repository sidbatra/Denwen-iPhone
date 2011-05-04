//
//  DWPlaceDetailsViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWPlace.h"

/**
 * Display detailed information about a place on a map
 */
@interface DWPlaceDetailsViewController : UIViewController<MKMapViewDelegate> {
	DWPlace		*_place;
	MKMapView	*_mapView;	
    
    id          _delegate;
}

/**
 * The place object whose details are being displayed
 */
@property (nonatomic,retain) DWPlace *place;

/**
 * Map object setup in the nib
 */
@property (nonatomic,retain) IBOutlet MKMapView *mapView;

/**
 * Init with the place whose details are to be shown
 * and delegate to catch the back button event
 */
- (id)initWithPlace:(DWPlace*)place andDelegate:(id)delegate;

@end
