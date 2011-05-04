//
//  DWFollowedPlacesViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWFollowedPlacesViewController.h"
#import "DWRequestsManager.h"
#import "DWGUIManager.h"

static NSString* const kCurrentUserTitle			= @"Your Places";
static NSString* const kNormalUserTitle				= @"%@'s Places";
static NSString* const kSearchString				= @"Search %@";
static NSInteger const kCapacity					= 1;
static NSInteger const kPlacesIndex					= 0;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWFollowedPlacesViewController

@synthesize user = _user;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate 
			  withUser:(DWUser*)user {
	
	self = [super initWithCapacity:kCapacity
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
    
    self.view.hidden = NO;
    
    self.navigationItem.leftBarButtonItem = [DWGUIManager customBackButton:_delegate];
    self.navigationItem.titleView         = [DWGUIManager customTitleWithText:(NSString*)([self.user isCurrentUser] ? 
                                                                                          kCurrentUserTitle :
                                                                                          [NSString stringWithFormat:kNormalUserTitle,
                                                                                           self.user.firstName])];
	
	[_dataSourceDelegate loadData];	
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
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
        
		[_placeManager populatePlaces:places 
                              atIndex:kPlacesIndex];
		

		if([_placeManager totalPlacesAtRow:kPlacesIndex]) {
			_tableViewUsage = kTableViewAsData;	
			_isLoadedOnce = YES;
		}
		else {
			
			self.messageCellText = (NSString*)([self.user isCurrentUser] ?
												kMsgNoFollowPlacesCurrentUser :
												kMsgNoFollowPlacesNormalUser);
			
			_tableViewUsage = kTableViewAsMessage;
		}
	}
	
	[self finishedLoading];
    [self markEndOfPagination];
    [self.tableView reloadData];
}

//----------------------------------------------------------------------------------------------------
- (void)userPlacesError:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];

	if([[info objectForKey:kKeyResourceID] integerValue] != self.user.databaseID)
		return;
	
	[self finishedLoadingWithError];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTableViewDataSourceDelegate

//----------------------------------------------------------------------------------------------------
- (void)loadData {
	[[DWRequestsManager sharedDWRequestsManager] getUserPlaces:self.user.databaseID];	
}




@end

