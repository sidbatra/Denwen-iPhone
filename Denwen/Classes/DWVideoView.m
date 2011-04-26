//
//  DWVideoView.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWVideoView.h"
#import "DWGUIManager.h"
#import "DWConstants.h"

static NSInteger const kSpinnerSide                         = 25;
static MPMoviePlayerController* sharedMoviePlayerController = nil;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWVideoView

@synthesize movieController     = _movieController;
@synthesize spinner             = _spinner;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.clipsToBounds                                  = YES;
        self.hidden                                         = YES;
        self.backgroundColor                                = [UIColor clearColor];
    
        if(!sharedMoviePlayerController) {
            sharedMoviePlayerController                                = [[MPMoviePlayerController alloc] init];
            sharedMoviePlayerController.movieSourceType                = MPMovieSourceTypeFile;
            sharedMoviePlayerController.backgroundView.backgroundColor = [UIColor clearColor];
            sharedMoviePlayerController.view.backgroundColor           = [UIColor clearColor];
            sharedMoviePlayerController.view.frame                     = CGRectMake(0,-80,320,480);
            sharedMoviePlayerController.controlStyle                   = MPMovieControlStyleNone;
            sharedMoviePlayerController.scalingMode                    = MPMovieScalingModeAspectFill;
            sharedMoviePlayerController.shouldAutoplay                 = YES;
            sharedMoviePlayerController.fullscreen                     = NO;
        }
        
        self.movieController = sharedMoviePlayerController;
            
        
        
        self.spinner = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((frame.size.width  - kSpinnerSide) / 2,
                                                                                  (frame.size.height - kSpinnerSide) / 2,
                                                                                  kSpinnerSide,
                                                                                  kSpinnerSide)] autorelease];
		[self addSubview:self.spinner];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(moviePlayerStateChanged:) 
													 name:MPMoviePlayerLoadStateDidChangeNotification 
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(playbackDidFinish:) 
													 name:MPMoviePlayerPlaybackDidFinishNotification 
												   object:nil];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    self.movieController    = nil;
	self.spinner            = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)displayLoadingUI {
    [self addSubview:self.movieController.view];
    [self.spinner startAnimating];
    self.hidden                         = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)displayPlayingUI {
    [self.spinner stopAnimating];
}

//----------------------------------------------------------------------------------------------------
- (void)displayFinishedUI {
    [self.movieController.view removeFromSuperview];
    self.hidden                         = YES;
}

//----------------------------------------------------------------------------------------------------
- (void)startPlayingVideoAtURL:(NSString*)url {
    
    self.movieController.contentURL = [NSURL URLWithString:url];
    
    [self.movieController play];
        
    [self displayLoadingUI];
}

//----------------------------------------------------------------------------------------------------
- (void)stopPlayingVideo {
    [self displayFinishedUI];
    [self.movieController stop];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)moviePlayerStateChanged:(NSNotification*)notification {

	if ([self.movieController loadState] == MPMovieLoadStatePlayable) {
        [self performSelector:@selector(displayPlayingUI)
                   withObject:nil
                   afterDelay:0.75];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)playbackDidFinish:(NSNotification*)notification {
    [self displayFinishedUI];
}

@end
