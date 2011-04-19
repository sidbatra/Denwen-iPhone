//
//  DWPostProgressView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Creates a progress view used in the title view of
 * a navigation bar to 
 */
@interface DWPostProgressView : UIView {
	UILabel			*statusLabel;
	UIProgressView	*progressView;
}

/**
 * Update the progress view with new creation queue info
 */
- (void)updateDisplayWithTotalActive:(NSInteger)totalActive
						 totalFailed:(NSInteger)totalFailed 
					   totalProgress:(float)totalProgress;

@end
