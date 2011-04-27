//
//  DWVideoView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol  DWVideoViewDelegate;

/**
 * Custom video playing view for playing videos with
 * table view cells
 */
@interface DWVideoView : UIView {
    MPMoviePlayerController     *_movieController;
	UIActivityIndicatorView		*_spinner;
    
    id<DWVideoViewDelegate>     id;
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
 * Reference to the delegate
 */
@property (nonatomic,assign) id<DWVideoViewDelegate> delegate;


/**
 * Start playing the video located at the given URL
 */
- (void)startPlayingVideoAtURL:(NSString*)url;

/**
 * Stop the video playback
 */
- (void)stopPlayingVideo;

@end


/**
 * Fires events about the video state 
 */
@protocol DWVideoViewDelegate
- (void)playbackFinished;
@end