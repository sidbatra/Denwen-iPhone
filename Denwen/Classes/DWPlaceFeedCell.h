//
//  DWPlaceFeedCell.h
//  Denwen
//
//  Created by Deepak Rao on 1/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DWPlaceFeedCell : UITableViewCell {
	UILabel *placeName;
	UIImageView *placeImage;
	UILabel *placeDetails;
}

@property (nonatomic, retain) UILabel *placeName;
@property (nonatomic, retain) UIImageView *placeImage;
@property (nonatomic, retain) UILabel *placeDetails;

@end
