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
	self = [super initWithCapacity:kCapacity 
                       andDelegate:delegate];
	
	if (self) {
        
        _tableViewUsage					= kTableViewAsMessage;
        self.messageCellText			= kMsgInitial;
		
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
	
    if(!searchBar) {
        searchBar					= [[UISearchBar alloc] initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    self.tableView.frame.size.width,
                                                                                    0)];
        searchBar.delegate			= self;
        searchBar.placeholder		= kSearchBarText;
        searchBar.backgroundColor	= [UIColor colorWithRed:0.1764 
                                                      green:0.1764
                                                       blue:0.1764
                                                      alpha:1.0];
        [searchBar sizeToFit];	
        
        
        for (UIView *subview in searchBar.subviews) {
            if ([subview isKindOfClass:NSClassFromString(kSearchBarBackgroundClass)]) {
                [subview removeFromSuperview];
                break;
            }
        }
    }
	
    self.tableView.tableHeaderView  = searchBar;
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
    [searchBar release];
    
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
	}
    
    [super finishedLoading];
    [self markEndOfPagination];
    [self.tableView reloadData];
}

//----------------------------------------------------------------------------------------------------
- (void)searchPlacesError:(NSNotification*)notification {
    [super finishedLoading];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UISearchBarDelegate

//----------------------------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	if(theSearchBar.text.length >= kMinimumQueryLength) {
		
		_tableViewUsage					= kTableViewAsSpinner;
		[self.tableView reloadData];
		
		[searchBar resignFirstResponder];
		
		[_dataSourceDelegate loadData];
	}
	
}

//----------------------------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar
	textDidChange:(NSString *)searchText {
	
	if([searchText isEqualToString:kEmptyString]) {
        _tableViewUsage					= kTableViewAsMessage;
        self.messageCellText			= kMsgInitial;
        
		[_placeManager clearPlaces];
		[self.tableView reloadData];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [super tableView:theTableView cellForRowAtIndexPath:indexPath];
	
	if([cell isKindOfClass:[DWLoadingCell class]]) {
		[((DWLoadingCell*)cell) shorterCellMode];
	}
	else if([cell isKindOfClass:[DWMessageCell class]]) {
		[((DWMessageCell*)cell) shorterCellMode];
	}
    
	return cell;
}



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTableViewDataSourceDelegate

//----------------------------------------------------------------------------------------------------
- (void)loadData {
    if(_isLoadedOnce && searchBar.text.length >= kMinimumQueryLength) {
		[[DWRequestsManager sharedDWRequestsManager] getSearchPlaces:searchBar.text];
	}
	else {
		[super performSelector:@selector(finishedLoading) 
					withObject:nil
					afterDelay:0.5];
	}
}

@end

