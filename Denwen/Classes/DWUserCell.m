//
//  DWUserCell.m
//  Denwen
//
//  Created by Deepak Rao on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWUserCell.h"

@interface DWUserCell() 

- (void) createUserName;
- (void) createUserImage;
- (void) createChangeUserImage;
- (void) createUserBackgroundImageFilter;
- (void) createArrowImage;
- (void) drawCellItems;

@end


@implementation DWUserCell


@synthesize userName,changeUserImage;


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


// Creates label which is used to display the user name in the user info cell.
//
- (void) createUserName {
	CGRect rect = CGRectMake(125,7,self.contentView.frame.size.width - 149, 112);
	userName = [[UILabel alloc] initWithFrame:rect];
	
	userName.lineBreakMode = UILineBreakModeWordWrap;
	userName.numberOfLines = 2;
	userName.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];	
	userName.textColor = [UIColor whiteColor];
	userName.backgroundColor = [UIColor clearColor];
	userName.shadowColor = [UIColor blackColor];
	[self.contentView addSubview:userName];
	[userName release];
}


// Creates a button which is used to display the user image in the user info cell
//
- (void) createUserImage {
	CGRect rect = CGRectMake(7, 7, 112, 112); 
	userImage = [[UIButton alloc] initWithFrame:rect];
	[[userImage layer] setCornerRadius:2.5f];
	[[userImage layer] setMasksToBounds:YES];
	userImage.enabled = NO;
	userImage.tag = _rowInTable;
	
	[userImage addTarget:_eventTarget action:@selector(didTapUserMediumImage:event:) 
		 forControlEvents:UIControlEventTouchUpInside];
	
	[self.contentView addSubview:userImage];	
	[userImage release];
}


// Creates an Imageview which is used to display the user Background Image Filter
//
- (void) createUserBackgroundImageFilter {
 	CGRect rect = CGRectMake(0, 0, self.contentView.frame.size.width, FOLLOW_CURRENT_USER_CELL_HEIGHT);
	userBackgroundImageFilter = [[UIImageView alloc] initWithFrame:rect];
	userBackgroundImageFilter.contentMode = UIViewContentModeScaleToFill;
	[self.contentView addSubview:userBackgroundImageFilter];
	userBackgroundImageFilter.image = [UIImage imageNamed:USER_PROFILE_BG_TEXTURE];
	[userBackgroundImageFilter release];
}


// Creates an imageview which is used to display the change user image in the user info cell
// The imageview is hidden by default.
//
- (void) createChangeUserImage {
	CGRect rect = CGRectMake(94, 93, 28, 29); 
	changeUserImage = [[UIImageView alloc] initWithFrame:rect];
	changeUserImage.hidden = YES;
	
	[self.contentView addSubview:changeUserImage];	
	[changeUserImage release];
}


// Creates a new place button
//
- (void) createNewPlaceButton {
	CGRect rect = CGRectMake(7, 126, 150, 44); //self.contentView.frame.size.width 14
	placeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	placeButton.frame = rect;
	placeButton.hidden = YES;
	
	[placeButton setBackgroundImage:[UIImage imageNamed:USER_PROFILE_CREATE_PLACE_IMAGE_NAME] forState:UIControlStateNormal];
	[placeButton setBackgroundImage:[UIImage imageNamed:USER_PROFILE_CREATE_PLACE_HIGHLIGHTED_IMAGE_NAME] forState:UIControlStateHighlighted];
	
	// rounded corners and border customization
	[[placeButton layer] setCornerRadius:2.5f];
	[[placeButton layer] setMasksToBounds:YES];
	
	placeButton.tag = _rowInTable;
	placeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	
	[placeButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[placeButton setTitleShadowColor:[UIColor colorWithRed:0.00784 green:0.4196 blue:0.9215 alpha:1.0] forState:UIControlStateHighlighted];
	[placeButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
	
	[placeButton setTitleColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] forState:UIControlStateNormal];
	[placeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[placeButton setTitle:@"     Create a place" forState:UIControlStateNormal];
	
	[placeButton addTarget:_eventTarget action:@selector(didTapNewPlaceButton:event:) 
		   forControlEvents:UIControlEventTouchUpInside];
	
	[self.contentView addSubview:placeButton];	
}



// Creates a new post button
//
- (void) createNewPostButton {
	CGRect rect = CGRectMake(163, 126, 150, 44); //self.contentView.frame.size.width - 14
	postButton = [UIButton buttonWithType:UIButtonTypeCustom];
	postButton.frame = rect;
	postButton.hidden = YES;
	
	[postButton setBackgroundImage:[UIImage imageNamed:USER_PROFILE_CREATE_POST_IMAGE_NAME] forState:UIControlStateNormal];
	[postButton setBackgroundImage:[UIImage imageNamed:USER_PROFILE_CREATE_POST_HIGHLIGHTED_IMAGE_NAME] forState:UIControlStateHighlighted];
	
	// rounded corners and border customization
	[[postButton layer] setCornerRadius:2.5f];
	[[postButton layer] setMasksToBounds:YES];
	
	postButton.tag = _rowInTable;
	postButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	
	[postButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[postButton setTitleShadowColor:[UIColor colorWithRed:0.00784 green:0.4196 blue:0.9215 alpha:1.0] forState:UIControlStateHighlighted];
	[postButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
	
	[postButton setTitleColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0] forState:UIControlStateNormal];
	[postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[postButton setTitle:@"       Post at a place" forState:UIControlStateNormal];
	
	[postButton addTarget:_eventTarget action:@selector(didTapNewPostButton:event:) 
		   forControlEvents:UIControlEventTouchUpInside];
	
	[self.contentView addSubview:postButton];
}



// Creates an arrow button for displaying the place location on the map in the next view
//
- (void) createArrowImage {
	CGRect rect = CGRectMake(270,25,50,75); 
	arrowImage = [[UIImageView alloc] initWithFrame:rect];
	arrowImage.tag = _rowInTable;
	arrowImage.image = [UIImage imageNamed:ARROW_BUTTON_USER_IMAGE_NAME];
	
	[self.contentView addSubview:arrowImage];	
	[arrowImage release];
}



// Create a customized wireframe of the user info cell.
//
- (void) drawCellItems {
	self.clipsToBounds = YES;
	self.contentView.backgroundColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.0];
	[self createUserBackgroundImageFilter];
	[self createUserName];
	[self createUserImage];
	[self createChangeUserImage];
	[self createNewPlaceButton];
	[self createNewPostButton];
	[self createArrowImage];
}


// Set user Image background from cache or after lazy loading
//
- (void)setMediumPreviewUserImage:(UIImage*)image {
	[userImage setBackgroundImage:image forState:UIControlStateNormal];
	[userImage setBackgroundImage:image forState:UIControlStateDisabled];	
}


// Display the signed in state of the cell
//
- (void)displaySignedInState:(BOOL)hasPhoto {
	if(hasPhoto) {
		changeUserImage.image = [UIImage imageNamed:CHANGE_USER_PIC_IMAGE_NAME];
		changeUserImage.hidden = NO;	
	}
	
	//CGRect rect = CGRectMake(0, 0,self.contentView.frame.size.width,FOLLOW_CURRENT_USER_CELL_HEIGHT);
	//userBackgroundImageFilter.frame = rect;
	
	placeButton.hidden = NO;
	postButton.hidden = NO;
	userImage.enabled = YES;
}


// Display the signed out state of the cell
//
- (void)displaySignedOutState {
	changeUserImage.hidden = YES;
	
	//CGRect rect = CGRectMake(0, 0,self.contentView.frame.size.width,kUserViewCellHeight);
	//userBackgroundImageFilter.frame = rect;
	
	placeButton.hidden = YES;
	postButton.hidden = YES;
}



#pragma mark -
#pragma mark Memory Management 


// The ususal memory cleanup
//
- (void)dealloc {
    [super dealloc];
}


@end
