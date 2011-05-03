//
//  DWItemFeedViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWItemFeedViewController.h"
#import "DWRequestsManager.h"
#import "DWMemoryPool.h"
#import "DWLoadingCell.h"
#import "DWMessageCell.h"
#import "DWPaginationCell.h"
#import "DWConstants.h"

static NSInteger const kItemsPerPage				= 10;
static NSInteger const kDefaultSections				= 1;
static NSInteger const kSpinnerCellIndex			= 0;
static NSInteger const kMessageCellIndex			= 2;
static NSInteger const kMaxFeedCellHeight			= 2000;
static NSInteger const kItemFeedCellHeight			= 320;
static NSString* const kItemFeedCellIdentifier		= @"ItemFeedCell";
static NSString* const kMsgActionSheetCancel        = @"Cancel";
static NSString* const kMsgActionSheetDelete		= @"Delete";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedViewController

@synthesize itemManager			= _itemManager;

//----------------------------------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
	self = [super init];
	
	if (self) {
		
		self.itemManager	= [[[DWItemsManager alloc] init] autorelease];
		_delegate			= delegate;
				
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(mediumAttachmentLoaded:) 
													 name:kNImgMediumAttachmentLoaded
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemDeleted:) 
													 name:kNItemDeleted
												   object:nil];
	}
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
	CGRect frame		= self.view.frame;
	frame.origin.y		= 0; 
	frame.size.height	= frame.size.height; 
	self.view.frame		= frame;
	
    /**
     * Add gesture recognizers to catch swipes on table view cells
     */
    UISwipeGestureRecognizer *swipeRight    = [[[UISwipeGestureRecognizer alloc] initWithTarget:self 
                                                                                         action:@selector(handleSwipeGesture:)] 
                                                autorelease];
    swipeRight.direction                    = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipeRight];
    
    
    UISwipeGestureRecognizer *swipeLeft     = [[[UISwipeGestureRecognizer alloc] initWithTarget:self 
                                                                                         action:@selector(handleSwipeGesture:)] 
                                                autorelease];
    swipeLeft.direction                     = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeLeft];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	_delegate				= nil;
	self.itemManager		= nil;
    
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)addNewItem:(DWItem *)item 
		   atIndex:(NSInteger)index {
        
    if(_tableViewUsage != kTableViewAsData) {
        _tableViewUsage = kTableViewAsData;
        [self.tableView reloadData];
    }
    
    [_itemManager addItem:item 
                  atIndex:index];
    
    NSIndexPath *touchIndexPath = [NSIndexPath indexPathForRow:index
                                                     inSection:0];
    NSArray *indexPaths			= [NSArray arrayWithObjects:touchIndexPath,nil];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationTop];
}

//----------------------------------------------------------------------------------------------------
- (void)deleteItemWithID:(NSInteger)itemID {

    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    BOOL itemDeletedFromPool = NO;
    
    for (NSIndexPath *indexPath in visiblePaths) { 
		DWItem *item = [_itemManager getItem:indexPath.row];
		
		if(item.databaseID == itemID) {
            NSIndexPath *deletedIndexPath   = [NSIndexPath indexPathForRow:indexPath.row 
                                                                 inSection:0];
            NSArray *deletedIndexPaths      = [NSArray arrayWithObjects:deletedIndexPath,nil];
            
            [_itemManager removeItemWithID:itemID];
            itemDeletedFromPool = YES;
            [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths
                                  withRowAnimation:UITableViewRowAnimationBottom];
            break;
		}
	}
    
    if (!itemDeletedFromPool) {
        [_itemManager removeItemWithID:itemID];
        [self.tableView reloadData];
    }
}

//----------------------------------------------------------------------------------------------------
-(void)handleSwipeGesture:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint swipeLocation           = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *swipedIndexPath    = [self.tableView indexPathForRowAtPoint:swipeLocation];
        
        if ([[_itemManager getItem:swipedIndexPath.row].user isCurrentUser]) {
            
            UIActionSheet *actionSheet  = [[UIActionSheet alloc] initWithTitle:nil 
                                                                      delegate:self 
                                                             cancelButtonTitle:kMsgActionSheetCancel
                                                        destructiveButtonTitle:kMsgActionSheetDelete
                                                             otherButtonTitles:nil];
            
            actionSheet.tag             = [_itemManager getItem:swipedIndexPath.row].databaseID;
            
            [actionSheet showInView:[_delegate requestCustomTabBarController].view];
            [actionSheet release];
        }
    }
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIActionSheet Delegate

//----------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {	
	if (buttonIndex == 0) {
        
        [[DWRequestsManager sharedDWRequestsManager] deleteItemWithID:actionSheet.tag];        
        
        NSDictionary *info	= [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt:actionSheet.tag]	,kKeyResourceID,
                               nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNItemDeleted
                                                            object:nil
                                                          userInfo:info];
    }
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications
//----------------------------------------------------------------------------------------------------
- (void)mediumAttachmentLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData || ![_itemManager totalItems])
		return;
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
		DWItem *item = [_itemManager getItem:indexPath.row];
		
		if(item.attachment.databaseID == resourceID) {
			DWItemFeedCell *cell = (DWItemFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell setItemImage:[info objectForKey:kKeyImage]];
            [cell redisplay];
		}
	}	
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)itemDeleted:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
    
    [self deleteItemWithID:resourceID];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWItemFeedCellDelegate

//----------------------------------------------------------------------------------------------------
- (BOOL)shouldTouchItemWithID:(NSInteger)itemID {
	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:itemID
																	atRow:kMPItemsIndex];
	
	return !item.isTouched && ![item.user isCurrentUser];
}

//----------------------------------------------------------------------------------------------------
- (void)cellTouched:(NSInteger)itemID {
	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:itemID
																	atRow:kMPItemsIndex];
	
	item.isTouched = YES;
	
	[[DWRequestsManager sharedDWRequestsManager] createTouch:itemID];
}

//----------------------------------------------------------------------------------------------------
- (void)placeSelectedForItemID:(NSInteger)itemID {

	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:itemID
																	atRow:kMPItemsIndex];
	
	[_delegate placeSelected:item.place];
}

//----------------------------------------------------------------------------------------------------
- (void)userSelectedForItemID:(NSInteger)itemID {
	
	DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:itemID
																	atRow:kMPItemsIndex];
	
	[_delegate userSelected:item.user];
}

//----------------------------------------------------------------------------------------------------
- (void)shareSelectedForItemID:(NSInteger)itemID {
	NSLog(@"shared seleced for %d",itemID);
}

//----------------------------------------------------------------------------------------------------
- (NSString*)getVideoAttachmentURLForItemID:(NSInteger)itemID {
    DWItem *item = (DWItem*)[[DWMemoryPool sharedDWMemoryPool]  getObject:itemID
																	atRow:kMPItemsIndex];
	
    return item.attachment.fileURL;
}

//----------------------------------------------------------------------------------------------------
- (UIViewController*)requestCustomTabBarController {
	return [_delegate requestCustomTabBarController];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTableViewDataSourceDelegate

//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfDataRows {
    return [_itemManager totalItems];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfDataRowsPerPage {
    return kItemsPerPage;
}

//----------------------------------------------------------------------------------------------------
- (CGFloat)heightForDataRows {
    return kItemFeedCellHeight;
}

//----------------------------------------------------------------------------------------------------
- (void)loadData {
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)idForLastDataRow {
    return [self.itemManager getIDForLastItem];
}

//----------------------------------------------------------------------------------------------------
- (void)loadImagesForDataRowAtIndex:(NSIndexPath *)indexPath {
    DWItem *item = [_itemManager getItem:indexPath.row];
    [item startRemoteImagesDownload];
}

//----------------------------------------------------------------------------------------------------
- (UITableViewCell*)cellForDataRowAt:(NSIndexPath *)indexPath
                         inTableView:(UITableView*)tableView {
	DWItem *item			= [_itemManager getItem:indexPath.row];
    DWItemFeedCell *cell	= (DWItemFeedCell*)[tableView dequeueReusableCellWithIdentifier:kItemFeedCellIdentifier];
    
    if(!cell) 
        cell = [[[DWItemFeedCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:kItemFeedCellIdentifier] autorelease];
    
	
    cell.delegate			= self;
    
    cell.itemID				= item.databaseID;
    cell.itemData			= item.data;
    cell.itemPlaceName		= item.place.name;
    cell.itemUserName		= item.user.firstName;
    
    [cell setDetails:item.touchesCount 
        andCreatedAt:[item createdTimeAgoInWords]];
    
    
    [item startRemoteImagesDownload];
    
    
    if (item.attachment) {
        [cell setItemImage:item.attachment.previewImage];
        
        if([item.attachment isVideo])
            cell.attachmentType = kAttachmentVideo;
        else if([item.attachment isImage])
            cell.attachmentType = kAttachmentImage;
    }
    else {
        [cell setItemImage:nil];
        
        cell.attachmentType = kAttachmentNone;
    }
    
    [cell reset];
    [cell redisplay];
    
    return cell;
}

//----------------------------------------------------------------------------------------------------
- (void)didSelectDataRowAt:(NSIndexPath*)indexPath
               inTableView:(UITableView*)tableView {
    
}



@end

