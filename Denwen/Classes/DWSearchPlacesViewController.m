//
//  DWSearchPlacesViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSearchPlacesViewController.h"
#import "DWRequestsManager.h"
#import "DWLoadingCell.h"
#import "DWMessageCell.h"

static NSString* const kSearchBarText				= @"Search places worldwide";
static NSString* const kMsgInitial					= @"";
static NSString* const kMsgNotFound					= @"No places found for %@";
static NSString* const kSearchBarBackgroundClass	= @"UISearchBarBackground";
static NSInteger const kMinimumQueryLength			= 1;
static NSInteger const kCapacity					= 1;
static NSInteger const kPlacesIndex					= 0;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSearchPlacesViewController


//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
	self = [super initWithSearchType:NO 
						withCapacity:kCapacity 
						 andDelegate:delegate];
	
	if (self) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(searchPlacesLoaded:) 
													 name:kNSearchPlacesLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(searchPlacesError:) 
													 name:kNSearchPlacesError
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
	
	searchBar					= [[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width,0)] autorelease];
	searchBar.delegate			= self;
	searchBar.placeholder		= kSearchBarText;
	searchBar.backgroundColor	= [UIColor colorWithRed:0.1294 green:0.1294 blue:0.1294 alpha:1.0];
	[searchBar sizeToFit];	
	
	
	for (UIView *subview in searchBar.subviews) {
		if ([subview isKindOfClass:NSClassFromString(kSearchBarBackgroundClass)]) {
			[subview removeFromSuperview];
			break;
		}
	}
	
	self.tableView.tableHeaderView = searchBar;
	
	_tableViewUsage					= kTableViewAsMessage;
	self.messageCellText			= kMsgInitial;
	
	[self.refreshHeaderView applyBackgroundImage:nil 
								   withFadeImage:nil
							 withBackgroundColor:[UIColor colorWithRed:0.1294 green:0.1294 blue:0.1294 alpha:1.0]];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewIsSelected {
	[super viewIsSelected];
	
	[searchBar becomeFirstResponder];
}

//----------------------------------------------------------------------------------------------------
- (void)viewIsDeselected {
	[super viewIsDeselected];
	
	[searchBar resignFirstResponder];
}

//----------------------------------------------------------------------------------------------------
- (void)loadPlaces {
	[super loadPlaces];
	
	if(_isLoadedOnce && searchBar.text.length >= kMinimumQueryLength) {
		[[DWRequestsManager sharedDWRequestsManager] getSearchPlaces:searchBar.text];
	}
	else {
		[super performSelector:@selector(finishedLoadingPlaces) 
					withObject:nil
					afterDelay:0.5];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)searchPlacesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		NSArray *places = [[info objectForKey:kKeyBody] objectForKey:kKeyPlaces];
				
		[_placeManager populatePlaces:places 
							  atIndex:kPlacesIndex];
		
		if([_placeManager totalPlacesAtRow:kPlacesIndex]) {
			_tableViewUsage = kTableViewAsData;
		}
		else {
			_tableViewUsage			= kTableViewAsMessage;
			self.messageCellText	= [NSString stringWithFormat:kMsgNotFound,searchBar.text];
		}

		
		[self markEndOfPagination];
		[self.tableView reloadData];
	}
	
	[super finishedLoadingPlaces];
}

//----------------------------------------------------------------------------------------------------
- (void)searchPlacesError:(NSNotification*)notification {
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UISearchBarDelegate

//----------------------------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	if(theSearchBar.text.length >= kMinimumQueryLength) {
		
		_tableViewUsage					= kTableViewAsSpinner;
		self.tableView.scrollEnabled	= NO;
		[self.tableView reloadData];
		
		[searchBar resignFirstResponder];
		
		[self loadPlaces];
	}
	
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [super tableView:theTableView cellForRowAtIndexPath:indexPath];
	
	if(_tableViewUsage == kTableViewAsSpinner) {
		[((DWLoadingCell*)cell) shorterCellMode];
	}
	else if(_tableViewUsage == kTableViewAsMessage) {
		[((DWMessageCell*)cell) shorterCellMode];
	}

	return cell;
}

@end

