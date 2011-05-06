//
//  DWFollowedItemsViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWFollowedItemsViewController.h"
#import "DWItemFeedCell.h"
#import "DWNotificationsHelper.h"
#import "DWRequestsManager.h"
#import "DWSession.h"

static NSString* const kImgOnBoarding   = @"onboarding.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWFollowedItemsViewController

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
	self = [super initWithDelegate:delegate];
	
	if (self) {
        		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newItemParsed:) 
													 name:kNNewItemParsed 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemsLoaded:) 
													 name:kNFollowedItemsLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemsError:) 
													 name:kNFollowedItemsError
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingModified:) 
													 name:kNNewFollowingCreated
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(followingModified:) 
													 name:kNFollowingDestroyed
												   object:nil];
	}
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
    
    if([DWSession sharedDWSession].firstTimeUser && !onBoardingButton) {
        self.tableView.scrollEnabled                    = NO;
        
        onBoardingButton                                = [UIButton buttonWithType:UIButtonTypeCustom];
        onBoardingButton.adjustsImageWhenHighlighted    = NO;
        onBoardingButton.frame                          = CGRectMake(0,0,320,367);
        
        [onBoardingButton setBackgroundImage:[UIImage imageNamed:kImgOnBoarding] 
                                    forState:UIControlStateNormal];
        
        [onBoardingButton addTarget:self
                             action:@selector(didTouchDownOnOnBoardingButton:)				
                   forControlEvents:UIControlEventTouchDown];
        
        [self.view addSubview:onBoardingButton];
    }
	 
	if(!_isLoadedOnce)
        [_dataSourceDelegate loadData];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)scrollToTop {
	if(_isLoadedOnce && [self.tableView numberOfSections]) {

		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
							  atScrollPosition:UITableViewScrollPositionTop 
									  animated:NO];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)loadNewItems {
    [self hardRefresh];
}

//----------------------------------------------------------------------------------------------------
- (void)disableOnboarding {
    self.tableView.scrollEnabled    = YES;
    [onBoardingButton removeFromSuperview];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)newItemParsed:(NSNotification*)notification {
	DWItem *item = (DWItem*)[(NSDictionary*)[notification userInfo] objectForKey:kKeyItem];
	
	if(_isLoadedOnce)
		[self addNewItem:item 
                 atIndex:0];
}

//----------------------------------------------------------------------------------------------------
- (void)itemsLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSArray *items = [[info objectForKey:kKeyBody] objectForKey:kKeyItems];
        
        
		[_itemManager populateItems:items
                         withBuffer:NO
                          withClear:_isReloading];
         
		
		if(![_itemManager totalItems]) {
			_tableViewUsage         = kTableViewAsMessage;
			self.messageCellText    = kMsgNoFollowPlacesCurrentUser;
		}
		else {
			_tableViewUsage = kTableViewAsData;
        }
		
		_isLoadedOnce = YES;
	}
    
    
    /**
     * Search for new unread items
     */
    if(_isReloading) {
       NSInteger newItemID = [_itemManager getItemIDNotByUserID:[DWSession sharedDWSession].currentUser.databaseID
                                              greaterThanItemID:[DWSession sharedDWSession].lastReadItemID];
       
       if(newItemID)
           [[DWSession sharedDWSession] gotoUnreadItemsMode:newItemID];
       else
           [[DWSession sharedDWSession] gotoReadItemsMode];
    }
       
	
	[self finishedLoading];
	[self.tableView reloadData];
}		

//----------------------------------------------------------------------------------------------------
- (void)itemsError:(NSNotification*)notification {
	[self finishedLoadingWithError];
}

//----------------------------------------------------------------------------------------------------
- (void)followingModified:(NSNotification*)notification {
	[self hardRefresh];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTableViewDataSourceDelegate

//----------------------------------------------------------------------------------------------------
- (void)loadData {
	[[DWRequestsManager sharedDWRequestsManager] getFollowedItemsFromLastID:_lastID];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIButtonEvents

//----------------------------------------------------------------------------------------------------
- (void)didTouchDownOnOnBoardingButton:(UIButton*)button {
    [self disableOnboarding];
    [[DWSession sharedDWSession] updateFirstTimeUser];
}


@end

