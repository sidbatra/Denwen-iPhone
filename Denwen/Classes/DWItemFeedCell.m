//
//  DWItemFeedCell.m
//  Denwen
//
//  Created by Deepak Rao on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWItemFeedCell.h"

@interface DWItemFeedCell() 

- (void) createPlaceName;
- (void) createPlaceImage;
- (void) createDataLabel;
- (void) createUserName;
- (void) createUserImage;
- (void) createTimeLabel;
- (void) createAttachmentImage;
- (void) createTransparentButton;
- (void) createCellItems;


@end

@implementation DWItemFeedCell

@synthesize placeName,userImage,attachmentImage;


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

	
	//resize the placename
	CGSize maximumLabelSize = CGSizeMake(self.contentView.frame.size.width - 69, 100);
	CGSize expectedLabelSize = [placeName.titleLabel.text sizeWithFont:placeName.titleLabel.font 
									  constrainedToSize:maximumLabelSize 
										  lineBreakMode:placeName.titleLabel.lineBreakMode]; 
	
	CGRect rect = CGRectMake(58, 5, expectedLabelSize.width + 8, 24);
	placeName.frame = rect;
	
	//Customize the interactive Label
	rect = CGRectMake(0, 0, self.contentView.frame.size.width - 69, 16);
	[dataLabel customizeUIFromText:data andUpdateFrame:rect andSeed:_itemID * URL_TAG_MULTIPLIER];
	[dataLabel changeButtonBackgroundColor:[UIColor whiteColor]];
	
	NSInteger attachmentHeight = 0;
	if (_hasAttachment) {
		rect = CGRectMake(62, 32 + dataLabel.frame.size.height, ATTACHMENT_HEIGHT, ATTACHMENT_HEIGHT); 
		attachmentImage.frame = rect;
		attachmentImage.hidden = NO;
		attachmentHeight = ATTACHMENT_HEIGHT + ATTACHMENT_Y_PADDING;
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


@end
