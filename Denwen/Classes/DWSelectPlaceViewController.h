//
//  DWSelectPlaceViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "DWPlaceListViewController.h"
#import "DWSessionManager.h"
#import "DWUserLocation.h"


@protocol DWSelectPlaceViewControllerDelegate;


@interface DWSelectPlaceViewController : DWPlaceListViewController {
	IBOutlet UITableView *tableView;
	
	DWRequestManager *_followedRequestManager;
	
	id<DWSelectPlaceViewControllerDelegate> _selectPlaceDelegate;
}

//@property (nonatomic,retain) IBOutlet UITableView *tableView;

- (id)initWithDelegate:(id)delegate;

@end


@protocol DWSelectPlaceViewControllerDelegate
- (void)selectPlaceCancelled;
- (void)selectPlaceFinished:(NSString*)placeName andPlaceID:(NSInteger)placeID;
@end