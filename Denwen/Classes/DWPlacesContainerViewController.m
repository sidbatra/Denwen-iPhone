//
//  DWPlacesContainerViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlacesContainerViewController.h"
#import "DWNewPlaceViewController.h"
#import "DWSession.h"

static NSString* const kTabTitle					= @"Places";
static NSString* const kImgTab						= @"places.png";
static NSInteger const kSelectedIndex				= 0;
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
		self.title						= kTabTitle;
		self.tabBarItem.image			= [UIImage imageNamed:kImgTab];
		_currentSelectedSegmentIndex	= kSelectedIndex;
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
			
	CGRect segmentedViewFrame		= CGRectMake(0,0,kSegmentedPlacesViewWidth,kSegmentedPlacesViewHeight);
	UIView *segmentedView			= [[[UIView alloc] initWithFrame:segmentedViewFrame] autorelease];
	segmentedView.backgroundColor	= [UIColor colorWithPatternImage:[UIImage imageNamed:kImgSegmentedViewBackground]];	
	
	[self.view addSubview:segmentedView];
	
	
	/**
	 * Create segmented control
	 */
	UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:nil] autorelease];
	
	if(_currentSelectedSegmentIndex == kPopularIndex) {
		[segmentedControl insertSegmentWithImage:[UIImage imageNamed:kImgSegmentedViewPopularOn] 
										 atIndex:kPopularIndex
										animated:NO];
		[segmentedControl insertSegmentWithImage:[UIImage imageNamed:kImgSegmentedViewNearbyOff] 
										 atIndex:kNearbyIndex
										animated:NO];
	}
	else {
		[segmentedControl insertSegmentWithImage:[UIImage imageNamed:kImgSegmentedViewPopularOff] 
										 atIndex:kPopularIndex
										animated:NO];
		[segmentedControl insertSegmentWithImage:[UIImage imageNamed:kImgSegmentedViewNearbyOn] 
										 atIndex:kNearbyIndex
										animated:NO];
	}
	
	
	segmentedControl.segmentedControlStyle	= UISegmentedControlStyleBar;
	segmentedControl.frame					= CGRectMake(0,0,kSegmentedPlacesViewWidth,kSegmentedPlacesViewHeight);
	segmentedControl.backgroundColor		= [UIColor	clearColor];
	segmentedControl.selectedSegmentIndex	= _currentSelectedSegmentIndex;

	[segmentedControl	addTarget:self 
						   action:@selector(segmentedControllerSelectionChanged:)
				 forControlEvents:UIControlEventValueChanged];
	[segmentedView		addSubview:segmentedControl];
	
	
	/**
	 * Add sub views
	 */
	if(!popularViewController)
		popularViewController = [[DWPopularPlacesViewController alloc] initWithDelegate:self];
	[self.view addSubview:popularViewController.view];

	
	if(!nearbyViewController)
		nearbyViewController = [[DWNearbyPlacesViewController alloc] initWithDelegate:self];
	[self.view addSubview:nearbyViewController.view];
	

	[self loadSelectedView:segmentedControl];
}



//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {	
	NSLog(@"%@",kMsgUnload);
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[popularViewController	release];
	[nearbyViewController	release];
	
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Private

//----------------------------------------------------------------------------------------------------
- (void)hidePreviouslySelectedView:(UISegmentedControl*)segmentedControl {
	if(_currentSelectedSegmentIndex == kPopularIndex) {
		[popularViewController viewIsDeselected];
		[segmentedControl setImage:[UIImage imageNamed:kImgSegmentedViewPopularOff] 
				 forSegmentAtIndex:_currentSelectedSegmentIndex];
	}
	else if(_currentSelectedSegmentIndex == kNearbyIndex) {
		[nearbyViewController viewIsDeselected];
		[segmentedControl setImage:[UIImage imageNamed:kImgSegmentedViewNearbyOff] 
				 forSegmentAtIndex:_currentSelectedSegmentIndex];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)loadSelectedView:(UISegmentedControl*)segmentedControl {	
	
	if(_currentSelectedSegmentIndex == kPopularIndex) {
		[popularViewController viewIsSelected];
		[segmentedControl setImage:[UIImage imageNamed:kImgSegmentedViewPopularOn] 
				 forSegmentAtIndex:_currentSelectedSegmentIndex];
	}
	else if(_currentSelectedSegmentIndex == kNearbyIndex) {
		[nearbyViewController viewIsSelected];
		[segmentedControl setImage:[UIImage imageNamed:kImgSegmentedViewNearbyOn] 
				 forSegmentAtIndex:_currentSelectedSegmentIndex];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIControlEventValueChanged

//----------------------------------------------------------------------------------------------------
- (void)segmentedControllerSelectionChanged:(id)sender {
	UISegmentedControl *segmentedController = (UISegmentedControl*)sender;

	[self hidePreviouslySelectedView:segmentedController];
	_currentSelectedSegmentIndex = segmentedController.selectedSegmentIndex;
	[self loadSelectedView:segmentedController];
}



@end
