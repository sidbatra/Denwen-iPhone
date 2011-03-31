//
//  DWLoadingCell.h
//  Denwen
//
//  Created by Deepak Rao on 2/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWConstants.h"

@interface DWLoadingCell : UITableViewCell {
	UIActivityIndicatorView *spinner;
	UILabel *messageLabel;
}

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UILabel *messageLabel;

@end
