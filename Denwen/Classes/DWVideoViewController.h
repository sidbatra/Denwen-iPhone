//
//  DWVideoViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

/**
 * Customized version of MPMoviePlayerViewController with a custom spinner
 * to show loading progress
 */
@interface DWVideoViewController : MPMoviePlayerViewController {
	UIActivityIndicatorView		*_spinner;
}

/**
 * Spinner to show progress while the move is loading
 */
@property (nonatomic,retain) UIActivityIndicatorView *spinner;

/**
 * Init with URL of the video
 */
- (id)initWithMediaURL:(NSString*)theURL;


@end
