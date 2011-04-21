//
//  DWPostProgressView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol DWPostProgressViewDelegate;

/**
 * Creates a progress view used in the title view of
 * a navigation bar to 
 */
@interface DWPostProgressView : UIView {
	UILabel			*statusLabel;
	UIButton		*deleteButton;
	UIButton		*retryButton;
    CALayer         *progressLayer;
	
	id<DWPostProgressViewDelegate> _delegate;
}

/**
 * Delegate to receive events about button touches
 */
@property (nonatomic,assign) id<DWPostProgressViewDelegate> delegate;

/**
 * Update the progress view with new creation queue info
 */
- (void)updateDisplayWithTotalActive:(NSInteger)totalActive
						 totalFailed:(NSInteger)totalFailed 
					   totalProgress:(float)totalProgress;

@end


/**
 * Delegate protocol to send events about delete and retry 
 * button touches
 */ 
@protocol DWPostProgressViewDelegate
- (void)deleteButtonPressed;
- (void)retryButtonPressed;
@end