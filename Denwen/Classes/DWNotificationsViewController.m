//
//  DWNotificationsViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNotificationsViewController.h"
#import "DWTouchesManager.h"
#import "DWTouch.h"
#import "DWRequestsManager.h"
#import "DWItemFeedViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "DWGUIManager.h"

static NSInteger const kTouchesPerPage      = 20;
static NSInteger const kTouchCellHeight     = 80;
static NSString* const kMsgNoItemsTouched   = @"No one has touched your items";


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
			/*
            DWPlaceFeedCell *cell = nil;
            cell = (DWPlaceFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            
			[cell setPlaceImage:[info objectForKey:kKeyImage]];
			[cell redisplay];
             */
		}
	}	
	
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

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
           
        DWTouch *touch = [self.touchesManager getTouch:indexPath.row];

            /*
           
           DWPlaceFeedCell *cell = (DWPlaceFeedCell*)[tableView dequeueReusableCellWithIdentifier:kPlaceFeedCellIdentifier];
           
           if (!cell) 
               cell = [[[DWPlaceFeedCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                              reuseIdentifier:kPlaceFeedCellIdentifier] autorelease];
           
           [cell reset];
           cell.placeName  = place.name;
           cell.placeDetails = [place displayAddress];
           
           //if (!tableView.dragging && !tableView.decelerating)
           //	[place startPreviewDownload];
           
           if (place.attachment && place.attachment.sliceImage)
               [cell setPlaceImage:place.attachment.sliceImage];
           else{
               [cell setPlaceImage:nil];
               [place startPreviewDownload];
           }	
           
           
           //if(!place.attachment)
           //	cell.placeData = [place sliceText];
           
           
           [cell redisplay];
           
           return cell;
             */
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTVDefaultCellIdentifier];
		
		if (!cell) 
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
										   reuseIdentifier:kTVDefaultCellIdentifier] autorelease];
		
		cell.selectionStyle					= UITableViewCellSelectionStyleNone;
		cell.contentView.backgroundColor	= [UIColor blackColor];
        cell.textLabel.textColor            = [UIColor whiteColor];
        cell.textLabel.text                 = [touch displayText];
		
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
}

@end
