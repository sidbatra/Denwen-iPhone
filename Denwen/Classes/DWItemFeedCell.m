//
//  DWItemFeedCell.m
//  Denwen
//
//  Created by Deepak Rao on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWItemFeedCell.h"
/*
@interface DWItemFeedCell() 

- (void) createPlaceName;
- (void) createPlaceImage;
- (void) createDataLabel;
- (void) createUserName;
- (void) createUserImage;
- (void) createTimeLabel;
- (void) createAttachmentImage;
- (void) createVideoPlayIcon; 
- (void) createTransparentButton;
- (void) createCellItems;


@end*/


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedSelectedView

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
    if (self) {
        self.opaque				= YES;
		self.backgroundColor	= [UIColor blackColor];
    }
    
    return self;
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedView

@synthesize itemData		= _itemData;
@synthesize itemImage		= _itemImage;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
    if (self) {
        self.opaque				= YES;
		self.backgroundColor	= [UIColor blackColor];
        _itemImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,320)];
        [self addSubview:_itemImage];
        [_itemImage release];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.itemData		= nil;
	//self.itemImage		= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect {
	/*CGRect imageFrame = CGRectMake(0,0,320,320);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);	
	
	[[UIColor blackColor] set];
	CGContextFillRect(context,imageFrame);*/
	
	//if(self.itemImage)
	//	[self.itemImage drawInRect:imageFrame]; //blendMode:kCGBlendModeNormal alpha:_highlighted ? 0.45 : 0.6];
    
    
	[[UIColor whiteColor] set];
	
	//CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
	
	[self.itemData drawInRect:CGRectMake(7,24,293,23) 
					  withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]
				 lineBreakMode:UILineBreakModeWordWrap
					 alignment:UITextAlignmentLeft];
	
    //CGContextRestoreGState(context);
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[self setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted {
	_highlighted = highlighted;
	[self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)removeHighlight:(id)sender {
	_highlighted = NO;
	[self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isHighlighted {
    return _highlighted;
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedCell

@synthesize itemFeedView = _itemFeedView;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self) {
		CGRect frame = CGRectMake(0.0,0.0,
                                  self.contentView.bounds.size.width,
                                  self.contentView.bounds.size.height
                                  );
		
		self.itemFeedView = [[[DWItemFeedView alloc] initWithFrame:frame] autorelease];
        self.itemFeedView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.itemFeedView.contentMode		= UIViewContentModeRedraw;
		
		[self.contentView addSubview:self.itemFeedView];
		
		self.selectedBackgroundView = [[[DWItemFeedSelectedView alloc] initWithFrame:frame] autorelease];
		self.accessoryType			= UITableViewCellAccessoryNone;
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	self.itemFeedView = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	[self.itemFeedView reset];
}

//----------------------------------------------------------------------------------------------------
- (void)setItemData:(NSString *)itemData {
	self.itemFeedView.itemData = itemData;
}

//----------------------------------------------------------------------------------------------------
- (void)setItemImage:(UIImage *)itemImage {
	self.itemFeedView.itemImage.image = itemImage;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[self.itemFeedView redisplay];
}

@end

/*
#pragma mark -
#pragma mark Cell Lifecycle


// Override the initialize method for the ItemCell
//
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		_eventTarget = target;
		[self createCellItems];
    }
	
    return self;
}


// Update class members HasAttachment and _itemID for every cell to overwrite the previous 
// value from dequeued cell
//
- (void)updateClassMemberHasAttachment:(BOOL)hasAttachment andItemID:(NSInteger)itemID {
	_hasAttachment = hasAttachment;
	_itemID = itemID;
}



#pragma mark -
#pragma mark Cell Creation 


// Creates a button which is used to display place name in the item feed cell
//
- (void) createPlaceName {
	placeName = [[UIButton alloc] init];
	
	placeName.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
	placeName.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];	
	[placeName setBackgroundImage:[UIImage imageNamed:TRANSPARENT_BUTTON_BG_IMAGE_NAME] forState:UIControlStateHighlighted];
	
	[placeName setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];	
	[placeName addTarget:_eventTarget action:@selector(didTapPlaceName:event:) 
		forControlEvents:UIControlEventTouchUpInside];
	
	[[placeName layer] setCornerRadius:5.0f];
	[[placeName layer] setMasksToBounds:YES];
	
	[self.contentView addSubview:placeName];
	[placeName release];
}


// Creates a button which is used to display the place image in the item feed cell
//
- (void) createPlaceImage {
	CGRect rect = CGRectMake(7, 10, 48, 48); 
	placeImage = [[UIButton alloc] initWithFrame:rect];
	//placeImage.layer.cornerRadius = 1.0;
	//placeImage.layer.masksToBounds = YES;
	
	[placeImage addTarget:_eventTarget action:@selector(didTapPlaceImage:event:) 
		 forControlEvents:UIControlEventTouchUpInside];
	
	[self.contentView addSubview:placeImage];	
	[placeImage release];
}


// Creates an expandable label that is used to display the data in the item feed cell
//
- (void) createDataLabel {
	CGRect rect = CGRectMake(62, 26, self.contentView.frame.size.width - 69, 16); 
	dataLabel = [[InteractiveLabel alloc] initWithFrame:rect withTarget:_eventTarget];
	dataLabel.label.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
	dataLabel.label.font = [UIFont fontWithName:@"Helvetica" size:15];
	dataLabel.label.numberOfLines = 0;
	
	[self.contentView addSubview:dataLabel];	
	[dataLabel release];
}


// Creates a button which is used to display the attachment in the item feed cell
//
- (void) createAttachmentImage {
	attachmentImage = [[UIButton alloc] init];
	attachmentImage.layer.cornerRadius = 2.5;
	attachmentImage.layer.masksToBounds = YES;
	
	[attachmentImage addTarget:_eventTarget action:@selector(didTapAttachmentImage:event:) 
			  forControlEvents:UIControlEventTouchUpInside];
	
	[self.contentView addSubview:attachmentImage];	
	[attachmentImage release];
}


// Creates a play icon on top of the video image preview
//
- (void)createVideoPlayIcon {
	videoPlayIcon = [[UIImageView alloc] init];
	videoPlayIcon.image = [UIImage imageNamed:VIDEO_PLAY_BUTTON_IMAGE_NAME];
	videoPlayIcon.hidden = YES;
	
	[self.contentView addSubview:videoPlayIcon];	
	[videoPlayIcon release];
}


// Creates a button which is used to display the user image in the item feed cell
//
- (void) createUserImage {
	userImage = [[UIImageView alloc] init];
	
	[self.contentView addSubview:userImage];
	[userImage release];
}


// Creates a button which is used to display user name in the item feed cell
//
- (void) createUserName {
	userName = [[UILabel alloc] init];	
	userName.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];	
	userName.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];	
	userName.backgroundColor = [UIColor clearColor];
	
	[self.contentView addSubview:userName];
	[userName release];
}


// Creates a button which is used to display time in the item feed cell
//
- (void) createTimeLabel {
	timeLabel = [[UILabel alloc] init];
	
	timeLabel.font = [UIFont fontWithName:@"Helvetica" size:11];	
	timeLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
	timeLabel.backgroundColor = [UIColor clearColor];
	
	[self.contentView addSubview:timeLabel];
	[timeLabel release];
}


// Creates a button which is used to display user name in the item feed cell
//
- (void) createTransparentButton {
	transparentButton = [[UIButton alloc] init];

	[transparentButton setBackgroundImage:[UIImage imageNamed:TRANSPARENT_BUTTON_BG_IMAGE_NAME] forState:UIControlStateHighlighted];	
	[transparentButton addTarget:_eventTarget action:@selector(didTapUserImage:event:) 
	   forControlEvents:UIControlEventTouchUpInside];
	
	[[transparentButton layer] setCornerRadius:5.0f];
	[[transparentButton layer] setMasksToBounds:YES];
	
	[self.contentView addSubview:transparentButton];
	[transparentButton release];
}


// Create a customized wireframe of the item cell.
//
- (void) createCellItems {
	[self createPlaceImage];
	[self createDataLabel];
	[self createPlaceName];
	[self createAttachmentImage];
	[self createVideoPlayIcon];
	[self createUserImage];
	[self createUserName];
	[self createTimeLabel];
	[self createTransparentButton];
}


// Position variable cell items based on the data of the current feed
//
- (void)positionAndCustomizeCellItemsFrom:(NSString*)data userName:(NSString*)fullName andTime:(NSString*)timeAgoInWords {
	
	//update the tags of all reused UI items
	placeName.tag = _itemID;
	placeImage.tag = _itemID;
	attachmentImage.tag = _itemID;
	transparentButton.tag = _itemID;
	self.contentView.backgroundColor = [UIColor clearColor];
	videoPlayIcon.hidden = YES;
	
	//resize the placename
	CGSize maximumLabelSize = CGSizeMake(self.contentView.frame.size.width - 69, 100);
	CGSize expectedLabelSize = [placeName.titleLabel.text sizeWithFont:placeName.titleLabel.font 
									  constrainedToSize:maximumLabelSize 
										  lineBreakMode:placeName.titleLabel.lineBreakMode]; 
	
	CGRect rect = CGRectMake(58, 5, expectedLabelSize.width + 8, 24);
	placeName.frame = rect;
	
	//Customize the interactive Label
	rect = CGRectMake(0, 0, self.contentView.frame.size.width - 69, 16);
	[dataLabel customizeUIFromText:data andUpdateFrame:rect andSeed:_itemID * kURLTagMultipler];
	[dataLabel changeButtonBackgroundColor:[UIColor whiteColor]];
	
	NSInteger attachmentHeight = 0;
	if (_hasAttachment) {
		rect = CGRectMake(62, 32 + dataLabel.frame.size.height, kAttachmentHeight, kAttachmentHeight); 
		attachmentImage.frame = rect;
		attachmentImage.hidden = NO;
		attachmentHeight = kAttachmentHeight + kAttachmentYPadding;
		
		videoPlayIcon.frame =  CGRectMake(attachmentImage.frame.origin.x + kAttachmentHeight / 2 - 36,\
										  attachmentImage.frame.origin.y + kAttachmentHeight / 2 - 36, 
										  72, 
										  72);
	}
	else {
		attachmentImage.hidden = YES;
	}
	
	//reposition user image and username
	rect = CGRectMake(62, 26 + attachmentHeight + dataLabel.frame.size.height + USER_LABEL_PADDING, 20, 20);
	userImage.frame = rect;
	
	rect = CGRectMake(87, 29 + attachmentHeight + dataLabel.frame.size.height + USER_LABEL_PADDING, 30, 12);
	userName.frame = rect;
	
	//Populate the username
	userName.text = fullName;
	[userName sizeToFit];
	
	//Reposition time based on attachment and username
	rect = CGRectMake(87 + userName.frame.size.width + USER_NAME_PADDING, 
					  29 + attachmentHeight + dataLabel.frame.size.height + USER_LABEL_PADDING, 0, 12);
	timeLabel.frame = rect;
	
	timeLabel.text = timeAgoInWords;
	[timeLabel sizeToFit];
	
	rect = CGRectMake(userImage.frame.origin.x - 4,userImage.frame.origin.y - 2,
					  timeLabel.frame.origin.x + timeLabel.frame.size.width - userImage.frame.origin.x + 8, 24);
	transparentButton.frame = rect;
}


// Set place Image background from cache or after lazy loading
//
- (void)setSmallPreviewPlaceImage:(UIImage*)image {
	[placeImage setBackgroundImage:image forState:UIControlStateNormal];
	[placeImage setBackgroundImage:image forState:UIControlStateDisabled];	
}


// Changes the cell state to a highlighted new cell mode
//
- (void)displayNewCellState {
	UIColor *color = [UIColor colorWithRed:1.0 green:0.97 blue:0.7843 alpha:1.0];
	self.contentView.backgroundColor = color;
	[dataLabel changeButtonBackgroundColor:color];
}


// Displays the video play icon 
//
- (void)displayPlayIcon {
	videoPlayIcon.hidden = NO;
}



#pragma mark -
#pragma mark Disable Buttons

// Disable place buttons for the place view controller
//
- (void)disablePlaceButtons {
	placeName.enabled = NO;
	placeImage.enabled = NO;
}


// Disable user buttons for the user view controller
- (void)disableUserButtons {
	transparentButton.enabled= NO;
}



#pragma mark -
#pragma mark Memory management


// The usual memory cleanup
//
- (void)dealloc {
    [super dealloc];
}
*/
