//
//  DWUserCell.h
//  Denwen
//
//  Created by Deepak Rao on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Constants.h"

@interface DWUserCell : UITableViewCell {
	id _eventTarget;
	NSInteger _rowInTable;	
	UILabel *userName;
	UIButton *userImage;
	UIButton *postButton;
	UIButton *placeButton;
	UIImageView *changeUserImage;
	UIImageView *userBackgroundImageFilter;
	UIImageView *arrowImage;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
			withRow:(NSInteger)rowInTable andTaget:(id)target;

@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UIImageView *changeUserImage;

- (void)setMediumPreviewUserImage:(UIImage*)image;

- (void)displaySignedInState:(BOOL)hasPhoto;
- (void)displaySignedOutState;

@end