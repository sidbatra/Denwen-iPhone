//
//  DWPaginationCell.h
//  Denwen
//
//  Created by Siddharth Batra on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface DWPaginationCell : UITableViewCell {
	UIActivityIndicatorView *spinner;
	UILabel *messageLabel;
	BOOL _isInLoadingState;
}

- (void)displayProcessingState;
- (void)displaySteadyState;
		
@property (readonly) BOOL isInLoadingState;

@end