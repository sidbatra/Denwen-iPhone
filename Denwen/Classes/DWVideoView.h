//
//  DWVideoView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

/**
 * Custom video playing view for playing videos with
 * table view cells
 */
@interface DWVideoView : UIView {
    MPMoviePlayerController     *_movieController;
	UIActivityIndicatorView		*_spinner;
}

/**
 * Apple's movie player controller
 */
@property (nonatomic,retain) MPMoviePlayerController *movieController;

/**
 * Spinner to show progress while the move is loading
 */
@property (nonatomic,retain) UIActivityIndicatorView *spinner;


/**
 * Start playing the video located at the given URL
 */
- (void)startPlayingVideoAtURL:(NSString*)url;

/**
 * Stop the video playback
 */
- (void)stopPlayingVideo;

@end
