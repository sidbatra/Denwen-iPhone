//
//  DWItemFeedCell.h
//  Denwen
//
//  Created by Deepak Rao on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DWGUIManager.h"
#import "InteractiveLabel.h"
#import "DWConstants.h"


@interface DWItemFeedCell : UITableViewCell {
	id _eventTarget;
	bool _hasAttachment;
	NSInteger _itemID;
	UIButton *placeName;
	UIButton *placeImage;
	UIImageView *userImage;
	InteractiveLabel *dataLabel;
	UILabel *userName;
	UIButton *attachmentImage;
	UIImageView *videoPlayIcon;
	UILabel *timeLabel;
	UIButton *transparentButton;
}

@property (nonatomic, retain) UIButton *placeName;
@property (nonatomic, retain) UIImageView *userImage;
@property (nonatomic, retain) UIButton *attachmentImage;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTarget:(id)target;
- (void)updateClassMemberHasAttachment:(BOOL)hasAttachment andItemID:(NSInteger)itemID;
- (void)positionAndCustomizeCellItemsFrom:(NSString*)data userName:(NSString*)fullName andTime:(NSString*)timeAgoInWords;

- (void)disablePlaceButtons;
- (void)disableUserButtons;

- (void)displayNewCellState;
- (void)displayPlayIcon;

- (void)setSmallPreviewPlaceImage:(UIImage*)image;

@end

