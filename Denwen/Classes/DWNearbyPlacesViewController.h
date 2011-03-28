//
//  DWNearbyPlacesViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWPlaceListViewController.h"
#import "DWRequestsManager.h"

@interface DWNearbyPlacesViewController : DWPlaceListViewController {
}

- (id)initWithDelegate:(id)delegate;


@end
