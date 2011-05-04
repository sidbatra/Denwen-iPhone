//
//  DWChooseLocationViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol DWChooseLocationViewControllerDelegate;

/**
 * Fullscreen map view to drag and choose a geo location
 */
@interface DWChooseLocationViewController : UIViewController {
	CLLocation		*_selectedLocation;
	MKMapView		*_mapView;
	
	id <DWChooseLocationViewControllerDelegate> _delegate;
}

/**
 * The location selected by the user
 */
@property (nonatomic,retain) CLLocation *selectedLocation;

/**
 * IBOutlet properties
 */
@property (nonatomic, retain) IBOutlet MKMapView *mapView;


/**
 * Init with location for the map center and annotation
 */
- (id)initWithLocation:(CLLocation*)location
		   andDelegate:(id)delegate;

/**
 * IBAction methods
 */
- (IBAction)doneButtonClicked:(id)sender;


@end


/**
 * Delegate protocol to receive an event when choosing is done
 */
@protocol DWChooseLocationViewControllerDelegate

@required

/**
 * Fired when choosing the location is done
 */
- (void)chooseLocationFinishedWithLocation:(CLLocation*)location;

@end

