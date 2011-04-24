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
#import "EGORefreshTableHeaderView.h"
#import "DWGUIManager.h"

static NSInteger const kTouchesPerPage          = 20;
static NSInteger const kTouchCellHeight         = 60;
static NSString* const kMsgNoItemsTouched       = @"No one has touched your items";
static NSString* const kTouchCellIdentifier		= @"TouchCell";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNotificationsViewController

@synthesize touchesManager      = _touchesManager;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
    
	self = [super init];
	
	if (self) {
		
		_delegate       = delegate;
        _rowsPerPage    = kTouchesPerPage;
		
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

    self.navigationItem.leftBarButtonItem   = [DWGUIManager customBackButton:_delegate];
    
    [self loadData];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (void)addNewTouch:(DWTouch*)touch {
	
	if(_tableViewUsage != kTableViewAsData) {
		_tableViewUsage = kTableViewAsData;
		[self.tableView reloadData];
	}
	
	[self.touchesManager addTouch:touch
                          atIndex:0];
	
	NSIndexPath *touchIndexPath = [NSIndexPath indexPathForRow:0
													 inSection:0];
	NSArray *indexPaths			= [NSArray arrayWithObjects:touchIndexPath,nil];
	
	[self.tableView insertRowsAtIndexPaths:indexPaths
						  withRowAnimation:UITableViewRowAnimationRight];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)totalRows {
    return [self.touchesManager totalTouches];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)dataCellHeight {
    return kTouchCellHeight;
}

//----------------------------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows {
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) { 
		DWTouch *touch = [self.touchesManager getTouch:indexPath.row];
		
		[touch startDownloadingImages];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)loadData {
    [super loadData];
    
    [[DWRequestsManager sharedDWRequestsManager] getTouchesForCurrentUser:_currentPage];
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
			
            DWTouchCell *cell = nil;
            cell = (DWTouchCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            
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
			
            DWTouchCell *cell = nil;
            cell = (DWTouchCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            
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
        		
        if([self totalRows])
            _tableViewUsage = kTableViewAsData;
        else {
            _tableViewUsage         = kTableViewAsMessage;
            self.messageCellText    = kMsgNoItemsTouched;
        }
	}
	
	[self finishedLoading];
	[self.tableView reloadData];
}

//----------------------------------------------------------------------------------------------------
- (void)touchesError:(NSNotification*)notification {
	[self finishedLoading];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDataSource

//----------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
	if(_tableViewUsage == kTableViewAsData && [self totalRows]) {
           
        DWTouch *touch      = [self.touchesManager getTouch:indexPath.row];
           
        DWTouchCell *cell   = (DWTouchCell*)[tableView dequeueReusableCellWithIdentifier:kTouchCellIdentifier];

        if (!cell) 
           cell = [[[DWTouchCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                          reuseIdentifier:kTouchCellIdentifier] autorelease];

        [cell reset];
     
        cell.itemData   = [touch displayText];
        
        if (!tableView.dragging && !tableView.decelerating)
            [touch startDownloadingImages];

        if (touch.attachment && touch.attachment.sliceImage)
            [cell setAttachmentImage:touch.attachment.sliceImage];
        else
           [cell setAttachmentImage:nil];

        if(touch.user.smallPreviewImage)
            [cell setUserImage:touch.user.smallPreviewImage];
        else
            [cell setUserImage:nil];
      
        [cell redisplay];

        return cell;
    }
	else {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
	return cell;	
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UITableViewDelegate

//----------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DWTouch *touch      = [self.touchesManager getTouch:indexPath.row];
    [_delegate userSelected:touch.user];
}

@end
