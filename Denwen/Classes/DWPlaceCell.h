//
//  DWPlaceCell.h
//  Denwen
//
//  Created by Deepak Rao on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Constants.h"

@interface DWPlaceCell : UITableViewCell {
	id _eventTarget;
	NSInteger _rowInTable;	
	
	UILabel *placeName;
	UIButton *editPlaceImage;
	UIButton *followButton;
	UIButton *unfollowButton;
	UIButton *shareButton;
	//UIImageView *changePlaceImage;
	UIImageView *placeBackgroundImage;
	UIImageView *placeBackgroundImageFilter;
	UIImageView *arrowImage;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
			withRow:(NSInteger)rowInTable andTaget:(id)target;

@property (nonatomic, retain) UILabel *placeName;
@property (nonatomic, retain) UIImageView *placeBackgroundImageFilter;
@property (nonatomic, retain) UIImageView *placeBackgroundImage;

- (void)setMediumPreviewPlaceImage:(UIImage*)image;

- (void)displayFollowingState;
- (void)displayUnfollowingState;

- (void)displaySignedInState:(BOOL)hasPhoto;
- (void)displaySignedOutState;

@end