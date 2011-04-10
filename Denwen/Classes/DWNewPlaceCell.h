//
//  DWNewPlaceCell.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Displays a cell for displaying an option to create
 * a new option
 */
@interface DWNewPlaceCell : UITableViewCell {
	UIImageView		*_backgroundImageView;
	UIImageView		*_separatorImageView;
}

@property (nonatomic,retain) UIImageView *backgroundImageView;
@property (nonatomic,retain) UIImageView *separatorImageView;


@end
