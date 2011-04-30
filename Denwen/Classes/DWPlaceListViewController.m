//
//  DWPlaceListViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceListViewController.h"
#import "DWPlaceViewController.h"
#import "DWConstants.h"

//Cells
#import "DWPlaceFeedCell.h"
#import "DWPaginationCell.h"
#import "DWLoadingCell.h"
#import "DWMessageCell.h"

static NSInteger const kPlaceFeedCellHeight			= 92;
static NSString* const kPlaceFeedCellIdentifier		= @"PlaceFeedCell";
static NSInteger const kPlacesPerPage				= 20;
static NSInteger const kDefaultSection              = 0;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceListViewController

@synthesize placeManager			= _placeManager;

//----------------------------------------------------------------------------------------------------
- (id)initWithCapacity:(NSInteger)capacity 
           andDelegate:(id)delegate {
		
	self = [super init];
	
	if (self) {
		
		_delegate               = delegate;
		self.placeManager		= [[[DWPlacesManager alloc] initWithCapacity:capacity] autorelease];
				
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(placePreviewImageLoaded:) 
													 name:kNImgSliceAttachmentFinalized
												   object:nil];
	}
	
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.view.hidden	= YES;
	
	CGRect frame		= self.view.frame;
	frame.origin.y		= 0; 
	self.view.frame		= frame;
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

	self.placeManager		= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewIsSelected {
	self.view.hidden = NO;

	if(!_isLoadedOnce) {
		[_dataSourceDelegate loadData];
		_isLoadedOnce = YES;
	}
}

//----------------------------------------------------------------------------------------------------
- (void)viewIsDeselected {
	self.view.hidden = YES;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)placePreviewImageLoaded:(NSNotification*)notification {
	
	if(_tableViewUsage != kTableViewAsData || !_isLoadedOnce)
		return;
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	

	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {            
        
		DWPlace *place = [_placeManager getPlaceAtRow:indexPath.section 
                                            andColumn:indexPath.row];
		
		if(place.attachment.databaseID == resourceID) {
			DWPlaceFeedCell *cell = (DWPlaceFeedCell*)[self.tableView cellForRowAtIndexPath:indexPath];

			[cell setPlaceImage:[info objectForKey:kKeyImage]];
			[cell redisplay];
		}
	}	
	
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWTableViewDataSourceDelegate

//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfDataRows {
    return [_placeManager totalPlacesAtRow:kDefaultSection];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)numberOfDataRowsPerPage {
    return kPlacesPerPage;
}

//----------------------------------------------------------------------------------------------------
- (CGFloat)heightForDataRows {
    return kPlaceFeedCellHeight;
}

//----------------------------------------------------------------------------------------------------
- (void)loadData {
}

//----------------------------------------------------------------------------------------------------
- (void)loadImagesForDataRowAtIndex:(NSIndexPath *)indexPath {
    
    DWPlace *place = [_placeManager getPlaceAtRow:indexPath.section 
                                        andColumn:indexPath.row];
    
    [place startPreviewDownload];
}

//----------------------------------------------------------------------------------------------------
- (UITableViewCell*)cellForDataRowAt:(NSIndexPath *)indexPath
                         inTableView:(UITableView*)tableView {

    DWPlace *place = [_placeManager getPlaceAtRow:indexPath.section
                                       andColumn:indexPath.row];

    DWPlaceFeedCell *cell = (DWPlaceFeedCell*)[tableView dequeueReusableCellWithIdentifier:kPlaceFeedCellIdentifier];

    if (!cell) 
       cell = [[[DWPlaceFeedCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:kPlaceFeedCellIdentifier] autorelease];

    cell.placeName      = place.name;
    cell.placeDetails   = [place displayAddress];

    if (place.attachment && place.attachment.sliceImage)
       [cell setPlaceImage:place.attachment.sliceImage];
    else{
       [cell setPlaceImage:nil];
       [place startPreviewDownload];
    }	

    [cell reset];
    [cell redisplay];

    return cell;
}

//----------------------------------------------------------------------------------------------------
- (void)didSelectDataRowAt:(NSIndexPath*)indexPath
               inTableView:(UITableView*)tableView {
    
    DWPlace *place = [_placeManager getPlaceAtRow:indexPath.section
                                        andColumn:indexPath.row];
    
    [_delegate placeSelected:place];
}


@end

