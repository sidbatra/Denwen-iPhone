//
//  DWPlacesContainerViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlacesContainerViewController.h"
#import "DWNearbyPlacesViewController.h"
#import "DWPopularPlacesViewController.h"
#import "DWSegmentedControl.h"
#import "DWSession.h"

static NSString* const kTabTitle					= @"Places";
static NSString* const kImgTab						= @"places.png";
static NSInteger const kSelectedIndex				= 0;
static NSInteger const kSegmentedPlacesViewWidth	= 320;
static NSInteger const kSegmentedPlacesViewHeight	= 44;
static NSString* const kImgSegmentedViewBackground	= @"segmented_view_bg.png";
static NSString* const kImgSegmentedViewPopularOn	= @"popular_on.png";
static NSString* const kImgSegmentedViewPopularOff	= @"popular_off.png";
static NSString* const kImgSegmentedViewNearbyOn	= @"nearby_on.png";
static NSString* const kImgSegmentedViewNearbyOff	= @"nearby_off.png";
static NSInteger const kPopularIndex				= 0;
static NSInteger const kNearbyIndex					= 1;
static NSString* const kMsgUnload					= @"Unload called on places container";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlacesContainerViewController

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if (self) {
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[popularViewController	release];
	[nearbyViewController	release];
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
		
	NSArray *segmentImageNames = [NSArray arrayWithObjects:
								  kImgSegmentedViewPopularOn,kImgSegmentedViewPopularOff,
								  kImgSegmentedViewNearbyOn,kImgSegmentedViewNearbyOff,
								  nil];
	
	segmentedControl = [[[DWSegmentedControl alloc] initWithFrame:CGRectMake(0,0,kSegmentedPlacesViewWidth,kSegmentedPlacesViewHeight)
									   withImageNamesForSegments:segmentImageNames
											   withSelectedIndex:kSelectedIndex
													 andDelegate:self] autorelease];

	[self.navigationController.navigationBar addSubview:segmentedControl];
	self.navigationItem.titleView = nil;
	  
	
	/**
	 * Add sub views
	 */
	if(!popularViewController)
		popularViewController = [[DWPopularPlacesViewController alloc] initWithDelegate:self];
	[self.view addSubview:popularViewController.view];

	
	if(!nearbyViewController)
		nearbyViewController = [[DWNearbyPlacesViewController alloc] initWithDelegate:self];
	[self.view addSubview:nearbyViewController.view];
	

	[self loadSelectedView:kSelectedIndex];
}



//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {	
	NSLog(@"%@",kMsgUnload);
}

//----------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	segmentedControl.hidden = YES;
}

//----------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	segmentedControl.hidden = NO;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private

//----------------------------------------------------------------------------------------------------
- (void)hidePreviouslySelectedView:(NSInteger)previousSelectedIndex {
	
	if(previousSelectedIndex == kPopularIndex) {
		[popularViewController viewIsDeselected];
	}
	else if(previousSelectedIndex == kNearbyIndex) {
		[nearbyViewController viewIsDeselected];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)loadSelectedView:(NSInteger)currentSelectedIndex {	
	
	if(currentSelectedIndex == kPopularIndex) {
		[popularViewController viewIsSelected];
	}
	else if(currentSelectedIndex == kNearbyIndex) {
		[nearbyViewController viewIsSelected];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWSegmentedControlDelegate


//----------------------------------------------------------------------------------------------------
- (void)selectedSegmentModifiedFrom:(NSInteger)oldSelectedIndex 
								 to:(NSInteger)newSelectedIndex {
	
	[self hidePreviouslySelectedView:oldSelectedIndex];
	[self loadSelectedView:newSelectedIndex];
}


@end
