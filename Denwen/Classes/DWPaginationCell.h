//
//  DWPaginationCell.h
//  Denwen
//
//  Created by Siddharth Batra on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWConstants.h"

@interface DWPaginationCell : UITableViewCell {
	UIActivityIndicatorView *spinner;
}

- (void)displayProcessingState;
		

@end