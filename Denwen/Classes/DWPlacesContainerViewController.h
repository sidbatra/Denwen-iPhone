//
//  DWPlacesContainerViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWNearbyPlacesViewController.h"
#import "DWPopularPlacesViewController.h"
#import "DWNewPlaceViewController.h"
#import "DWContainerViewController.h"


#import "DWSession.h"
#import "Constants.h"


@interface DWPlacesContainerViewController : DWContainerViewController {
	
	DWPopularPlacesViewController *popularViewController;
	DWNearbyPlacesViewController *nearbyViewController;
		
	int _currentSelectedSegmentIndex;
}

@end
