    //
//  DWVideoViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWVideoViewController.h"
#import "DWGUIManager.h"
#import "DWConstants.h"

static NSInteger const kSpinnerSide		= 25;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWVideoViewController

@synthesize spinner = _spinner;

//----------------------------------------------------------------------------------------------------
- (id)initWithMediaURL:(NSString*)theURL {
	
	self = [super initWithContentURL:[NSURL URLWithString:theURL]];
    
	if (self) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(moviePlayerStateChanged:) 
													 name:MPMoviePlayerLoadStateDidChangeNotification 
												   object:[self moviePlayer]];
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.spinner = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)displaySpinnerAtOrientation:(UIInterfaceOrientation)orientation {
	
	CGSize screenSize = [DWGUIManager currentScreenSize:orientation];
	
	/**
	 * Add spinner to center of movie player
	 */
	CGRect frame = CGRectMake((screenSize.width - kSpinnerSide)/2,
							  (screenSize.height - kSpinnerSide)/2 ,
							  kSpinnerSide,
							  kSpinnerSide
							  );
	
	if(!self.spinner) {
		self.spinner = [[[UIActivityIndicatorView alloc] initWithFrame:frame] autorelease];
		[self.spinner startAnimating];
		[self.view addSubview:self.spinner];
	}
	else {
		self.spinner.frame = frame;
	}
	
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor blackColor];
	
	[self displaySpinnerAtOrientation:[DWGUIManager getCurrentOrientation]];
	
	self.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
	[self.moviePlayer play];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

//----------------------------------------------------------------------------------------------------
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration {
	
	[self displaySpinnerAtOrientation:toInterfaceOrientation];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)moviePlayerStateChanged:(NSNotification*)notification {
	/**
	 * Receives notifications from the movie player. When the video has loaded
	 * i.e. loadState is 1 the spinner stops animating
	 */
	if ([[self moviePlayer] loadState] == 1) {
		[self.spinner stopAnimating];
	}
}


@end
