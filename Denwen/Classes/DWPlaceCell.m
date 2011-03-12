//
//  DWPlaceCell.m
//  Denwen
//
//  Created by Deepak Rao on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPlaceCell.h"

@interface DWPlaceCell() 

- (void) createPlaceBackgroundImage;
- (void) createPlaceBackgroundImageFilter;
- (void) createPlaceName;
- (void) createPlaceImage;
- (void) createChangePlaceImage;
- (void) createFollowButton;
- (void) createUnfollowButton;
- (void) createShareButton;
- (void) createArrowImage;
- (void) drawCellItems;

@end


@implementation DWPlaceCell

@synthesize placeName,placeBackgroundImageFilter,placeBackgroundImage;

#pragma mark -
#pragma mark Cell Lifecycle 


// Override the init method
//
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
			withRow:(NSInteger)rowInTable andTaget:(id)target {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		_eventTarget = target;
		_rowInTable = rowInTable;
		[self drawCellItems];
    }
    return self;
}



#pragma mark -
#pragma mark Cell Creation 


// Creates an Imageview which is used to display the place Background Image
//
- (void) createPlaceBackgroundImage; {
	CGRect rect = CGRectMake(0, 0,self.contentView.frame.size.width,FOLLOW_PLACE_CELL_HEIGHT); 
	placeBackgroundImage = [[UIImageView alloc] initWithFrame:rect];
	placeBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
	placeBackgroundImage.clipsToBounds = YES;
	[self.contentView addSubview:placeBackgroundImage];
	[placeBackgroundImage release];
}


// Creates an Imageview which is used to display the place Background Image Filter
//
- (void) createPlaceBackgroundImageFilter {
 	CGRect rect = CGRectMake(0, 0,self.contentView.frame.size.width,FOLLOW_PLACE_CELL_HEIGHT);
	placeBackgroundImageFilter = [[UIImageView alloc] initWithFrame:rect];
	placeBackgroundImageFilter.image = [UIImage imageNamed:TRANSPARENT_PLACEHOLDER_IMAGE_NAME];
	[self.contentView addSubview:placeBackgroundImageFilter];
	[placeBackgroundImageFilter release];
}


// Creates label which is used to display the place name in the place info cell.
//
- (void) createPlaceName {
	CGRect rect = CGRectMake(89, 7, self.contentView.frame.size.width - 112, 75);
	placeName = [[UILabel alloc] initWithFrame:rect];
	
	placeName.lineBreakMode = UILineBreakModeWordWrap;
	placeName.numberOfLines = 2;
	placeName.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];	
	placeName.textColor = [UIColor whiteColor];
	placeName.backgroundColor = [UIColor clearColor];
	placeName.shadowColor = [UIColor blackColor];
	[self.contentView addSubview:placeName];
	[placeName release];
}


// Creates a button which is used to display the place image in the place info cell
//
- (void) createPlaceImage {
	CGRect rect = CGRectMake(7, 7, 75, 75); 
	placeImage = [[UIButton alloc] initWithFrame:rect];
	placeImage.tag = _rowInTable;
	
	[placeImage addTarget:_eventTarget action:@selector(didTapPlaceMediumImage:event:) 
		 forControlEvents:UIControlEventTouchUpInside];
	
	[self.contentView addSubview:placeImage];	
	[placeImage release];
}


// Creates an imageview which is used to display the change place image in the place info cell
//
- (void) createChangePlaceImage {
	CGRect rect = CGRectMake(54, 56, 33, 33); 
	changePlaceImage = [[UIImageView alloc] initWithFrame:rect];
	changePlaceImage.image = [UIImage imageNamed:CHANGE_PIC_IMAGE_NAME];
	changePlaceImage.hidden = YES;
	
	[self.contentView addSubview:changePlaceImage];	
	[changePlaceImage release];
}


// Creates a follow button for the place info cell
//
- (void) createFollowButton {
	CGRect rect = CGRectMake(7, 89, 150, 44); //CGRectMake(7, 89, self.contentView.frame.size.width - 14, 44); 
	followButton = [UIButton buttonWithType:UIButtonTypeCustom];
	followButton.frame = rect;
	
	[followButton setBackgroundImage:[UIImage imageNamed:FOLLOW_BUTTON_BG_IMAGE_NAME] forState:UIControlStateNormal];
	[followButton setBackgroundImage:[UIImage imageNamed:FOLLOW_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME] forState:UIControlStateHighlighted];
	
	// rounded corners and border customization
	[[followButton layer] setCornerRadius:2.5f];
	[[followButton layer] setMasksToBounds:YES];
	
	followButton.tag = _rowInTable;
	followButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	
	[followButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[followButton setTitleShadowColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] forState:UIControlStateHighlighted];
	[followButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
	
	[followButton setTitleColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] forState:UIControlStateNormal];
	[followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[followButton setTitle:FOLLOW_PLACES_MSG forState:UIControlStateNormal];
		
	[followButton addTarget:_eventTarget action:@selector(didTapFollowButton:event:) 
		 forControlEvents:UIControlEventTouchUpInside];
	
	[self.contentView addSubview:followButton];	
}


// Creates a unfollow button for the place info cell
//
- (void) createUnfollowButton {
	CGRect rect = CGRectMake(7, 89, 150, 44); //self.contentView.frame.size.width - 14
	unfollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
	unfollowButton.frame = rect;
	
	[unfollowButton setBackgroundImage:[UIImage imageNamed:FOLLOWING_BUTTON_BG_IMAGE_NAME] forState:UIControlStateNormal];
	[unfollowButton setBackgroundImage:[UIImage imageNamed:FOLLOWING_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME] forState:UIControlStateHighlighted];
	
	// rounded corners and border customization
	[[unfollowButton layer] setCornerRadius:2.5f];
	[[unfollowButton layer] setMasksToBounds:YES];
	
	unfollowButton.tag = _rowInTable;
	unfollowButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	
	[unfollowButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[unfollowButton setTitleShadowColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] forState:UIControlStateHighlighted];
	[unfollowButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
	
	[unfollowButton setTitleColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] forState:UIControlStateNormal];
	[unfollowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[unfollowButton setTitle:@"   Following" forState:UIControlStateNormal];

	[unfollowButton addTarget:_eventTarget action:@selector(didTapUnfollowButton:event:) 
		   forControlEvents:UIControlEventTouchUpInside];
	
	[self.contentView addSubview:unfollowButton];	
}



// Creates a share button for the place
//
- (void)createShareButton {
	CGRect rect = CGRectMake(163, 89, 150, 44); //self.contentView.frame.size.width - 14
	shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	shareButton.frame = rect;
	
	[shareButton setBackgroundImage:[UIImage imageNamed:SHARE_PLACE_BUTTON_BG_IMAGE_NAME] forState:UIControlStateNormal];
	[shareButton setBackgroundImage:[UIImage imageNamed:SHARE_PLACE_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME] forState:UIControlStateHighlighted];
	
	// rounded corners and border customization
	[[shareButton layer] setCornerRadius:2.5f];
	[[shareButton layer] setMasksToBounds:YES];
	
	shareButton.tag = _rowInTable;
	shareButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	
	[shareButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[shareButton setTitleShadowColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] forState:UIControlStateHighlighted];
	[shareButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
	
	[shareButton setTitleColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] forState:UIControlStateNormal];
	[shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[shareButton setTitle:@"       Share Place" forState:UIControlStateNormal];
	
	[shareButton addTarget:_eventTarget action:@selector(didTapShareButton:event:) 
			 forControlEvents:UIControlEventTouchUpInside];
	
	[self.contentView addSubview:shareButton];	
}


// Creates an arrow button for displaying the place location on the map in the next view
//
- (void) createArrowImage{
	CGRect rect = CGRectMake(304,38,9,15); 
	arrowImage = [[UIImageView alloc] initWithFrame:rect];
	arrowImage.tag = _rowInTable;
	arrowImage.image = [UIImage imageNamed:ARROW_BUTTON_IMAGE_NAME];
	
	[self.contentView addSubview:arrowImage];	
	[arrowImage release];
}


// Create a customized wireframe of the place info cell.
//
- (void) drawCellItems {
	[self createPlaceBackgroundImage];
	[self createPlaceBackgroundImageFilter];
	[self createPlaceName];
	[self createPlaceImage];
	[self createChangePlaceImage];
	[self createUnfollowButton];
	[self createFollowButton];
	[self createShareButton];
	[self createArrowImage];
}


// Set place Image background from cache or after lazy loading
//
- (void)setMediumPreviewPlaceImage:(UIImage*)image {
	[placeImage setBackgroundImage:image forState:UIControlStateNormal];
	[placeImage setBackgroundImage:image forState:UIControlStateDisabled];	
}


// Change the UI to go into a following state
//
- (void)displayFollowingState {
	unfollowButton.hidden = NO;
	shareButton.hidden = NO;
	followButton.hidden = YES;
}

// Change the UI to go into a unfollowing state
//
-  (void)displayUnfollowingState {
	unfollowButton.hidden = YES;
	shareButton.hidden = NO;
	followButton.hidden = NO;
}

// Displays the signed in state of the cell
//
- (void)displaySignedInState:(BOOL)hasPhoto {
	if(hasPhoto)
		changePlaceImage.hidden = NO;
	
	placeImage.enabled = YES;
}


// Displays the signed out state of the cell
//
- (void)displaySignedOutState {
	changePlaceImage.hidden = YES;
	
	placeImage.enabled = NO;
	
}


#pragma mark -
#pragma mark Memory Management 


// The ususal memory cleanup
//
- (void)dealloc {
    [super dealloc];
}


@end
