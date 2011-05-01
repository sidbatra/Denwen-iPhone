//
//  DWNotificationsViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNotificationsViewController.h"
#import "DWTouchesManager.h"
#import "DWTouch.h"
#import "DWRequestsManager.h"
#import "DWItemFeedViewController.h"
#import "DWTouchCell.h"
#import "DWNotificationsHelper.h"
#import "DWGUIManager.h"

static NSInteger const kTouchesPerPage          = 20;
static NSInteger const kTouchCellHeight         = 60;
static NSString* const kMsgNoItemsTouched       = @"No one has touched your items";
static NSString* const kTouchCellIdentifier		= @"TouchCell";
static NSString* const kTitleText               = @"Notifications";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNotificationsViewController

@synthesize touchesManager      = _touchesManager;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
    
	self = [super init];
	
	if (self) {
		
		_delegate               = delegate;
		
		self.touchesManager     = [[[DWTouchesManager alloc] init] autorelease];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(touchesLoaded:) 
													 name:kNTouchesLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(touchesError:) 
													 name:kNTouchesError
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(attachmentImageLoaded:) 
													 name:kNImgSliceAttachmentFinalized
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(userImageLoaded:) 
													 name:kNImgSmallUserLoaded
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.touchesManager     = nil;
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView           = [DWGUIManager customTitleWithText:kTitleText];
    self.navigationItem.leftBarButtonItem   = [DWGUIManager customBackButton:_delegate];
    
    [_dataSourceDelegate loadData];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)attachmentImageLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData)
		return;
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
    
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
        DWTouch *touch = [self.touchesManager getTouch:indexPath.row];
		
		if(touch.attachment.databaseID == resourceID) {
			
            DWTouchCell *cell = (DWTouchCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            
            [cell setAttachmentImage:[info objectForKey:kKeyImage]];
			[cell redisplay];
		}
	}	
	
}

//----------------------------------------------------------------------------------------------------
- (void)userImageLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData)
		return;
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
    
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
        DWTouch *touch = [self.touchesManager getTouch:indexPath.row];
		
		if(touch.user.databaseID == resourceID) {
			
            DWTouchCell *cell = (DWTouchCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            
            [cell setUserImage:[info objectForKey:kKeyImage]];
			[cell redisplay];
		}
	}	
	
}

//----------------------------------------------------------------------------------------------------
- (void)touchesLoaded:(NSNotification*)notification {
	NSDictionary *info = [notification userInfo];
	
	if([[info objectForKey:kKeyStatus] isEqualToString:kKeySuccess]) {
		
		NSArray *touches = [[info objectForKey:kKeyBody] objectForKey:kKeyTouches];
		        
        [_touchesManager populateTouches:touches
                         withClearStatus:_isReloading];
        		
        if([_dataSourceDelegate numberOfDataRows])
            _tableViewUsage = kTableViewAsData;
        else {
            _tableViewUsage         = kTableViewAsMessage;
            self.messageCellText    = kMsgNoItemsTouched;
        }
	}
	
	[self finishedLoading];
	[self.tableView reloadData];
    
    [DWNotificationsHelper sharedDWNotificationsHelper].unreadNotifications = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)touchesError:(NSNotification*)notification {
	[self finishedLoading];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTableViewDataSourceDelegate

//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfDataRows {
    return [self.touchesManager totalTouches];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfDataRowsPerPage {
    return kTouchesPerPage;
}

//----------------------------------------------------------------------------------------------------
- (CGFloat)heightForDataRows {
    return kTouchCellHeight;
}

//----------------------------------------------------------------------------------------------------
- (void)loadData {
     [[DWRequestsManager sharedDWRequestsManager] getTouchesForCurrentUser:_currentPage];
}

//----------------------------------------------------------------------------------------------------
- (void)loadImagesForDataRowAtIndex:(NSIndexPath *)indexPath {
    DWTouch *touch = [self.touchesManager getTouch:indexPath.row];
    [touch startDownloadingImages];
}

//----------------------------------------------------------------------------------------------------
- (UITableViewCell*)cellForDataRowAt:(NSIndexPath *)indexPath
                         inTableView:(UITableView*)tableView {
        
    DWTouch *touch      = [self.touchesManager getTouch:indexPath.row];
    
    DWTouchCell *cell   = (DWTouchCell*)[tableView dequeueReusableCellWithIdentifier:kTouchCellIdentifier];
    
    if (!cell) 
        cell = [[[DWTouchCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                   reuseIdentifier:kTouchCellIdentifier] autorelease];
    
    cell.userName       = touch.user.firstName;
    cell.itemData       = touch.itemData;
    cell.hasAttachment  = touch.attachment ? YES : NO;
    
    [cell setPlaceName:touch.placeName
           andItemData:touch.itemData];
    
    //if (!tableView.dragging && !tableView.decelerating)
        [touch startDownloadingImages];
    
    if (touch.attachment && touch.attachment.sliceImage)
        [cell setAttachmentImage:touch.attachment.sliceImage];
    else
        [cell setAttachmentImage:nil];
    
    if(touch.user.smallPreviewImage)
        [cell setUserImage:touch.user.smallPreviewImage];
    else
        [cell setUserImage:nil];
    
    [cell reset];
    [cell redisplay];
    
    
    return cell;
}

//----------------------------------------------------------------------------------------------------
- (void)didSelectDataRowAt:(NSIndexPath*)indexPath
               inTableView:(UITableView*)tableView {
    
    DWTouch *touch      = [self.touchesManager getTouch:indexPath.row];
    [_delegate userSelected:touch.user];
}

@end
