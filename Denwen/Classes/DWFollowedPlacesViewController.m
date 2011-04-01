//
//  DWFollowedPlacesViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWFollowedPlacesViewController.h"
#import "DWRequestsManager.h"

static NSString* const kCurrentUserTitle			= @"Your Places";
static NSString* const kNormalUserTitle				= @"%@'s Places";
static NSString* const kSearchString				= @"Search %@";
static NSInteger const kCapacity					= 1;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWFollowedPlacesViewController

@synthesize user = _user;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate 
			  withUser:(DWUser*)user {
	
	self = [super initWithNibName:kPlaceListViewControllerNib 
						   bundle:nil
					   searchType:YES
					 withCapacity:kCapacity
					  andDelegate:delegate];
	
	if (self) {
		
		self.user = user;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userPlacesLoaded:) 
													 name:kNUserPlacesLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userPlacesError:) 
													 name:kNUserPlacesError
												   object:nil];
	}
	
		
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.hidden	= NO;
	self.title			=  (NSString*)([[DWSession sharedDWSession] doesCurrentUserHaveID:self.user.databaseID] ? 
										kCurrentUserTitle :
										[NSString stringWithFormat:kNormalUserTitle,self.user.firstName]);
	
	self.searchDisplayController.searchBar.placeholder = [NSString stringWithFormat:kSearchString,
														  self.title];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:kGenericBackButtonTitle
																   style:UIBarButtonItemStyleBordered
																  target:nil
																  action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	
	_tableViewUsage = kTableViewAsSpinner;
	[self.tableView reloadData];
	
	[self loadPlaces];	
}


//----------------------------------------------------------------------------------------------------
- (void)loadPlaces {
	[super loadPlaces];
	
	[[DWRequestsManager sharedDWRequestsManager] getUserPlaces:self.user.databaseID];	
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.user = nil;
	
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)userPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;

	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSArray *places = [[info objectForKey:kKeyBody] objectForKey:kKeyPlaces];
		[_placeManager populatePlaces:places atIndex:kCapacity-1];
		
		
		if([_placeManager totalPlacesAtRow:kCapacity-1]) {
			_tableViewUsage = kTableViewAsData;	
			_isLoadedOnce = YES;
		}
		else {
			
			self.messageCellText = (NSString*)([[DWSession sharedDWSession] doesCurrentUserHaveID:self.user.databaseID] ?
												kMsgNoFollowPlacesCurrentUser :
												kMsgNoFollowPlacesNormalUser);
			
			_tableViewUsage = kTableViewAsMessage;
		}
		
		[self markEndOfPagination];
		[self.tableView reloadData];
	}
	
	[self finishedLoadingPlaces];
}

//----------------------------------------------------------------------------------------------------
- (void)userPlacesError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];

	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
	[self finishedLoadingPlaces];
}


@end

