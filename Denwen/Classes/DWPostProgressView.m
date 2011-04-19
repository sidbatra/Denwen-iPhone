//
//  DWPostProgressView.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPostProgressView.h"
#import "DWConstants.h"

static const float kMinimumProgress = 0.001;



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPostProgressView

@synthesize delegate = _delegate;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
	if (self) {
		statusLabel					= [[[UILabel alloc] initWithFrame:CGRectMake(25,5,200,20)] autorelease];
		statusLabel.font			= [UIFont fontWithName:@"HelveticaNeue" size:13];
		statusLabel.textColor		= [UIColor whiteColor];
		statusLabel.backgroundColor	= [UIColor clearColor];
		statusLabel.textAlignment	= UITextAlignmentCenter;
		[self addSubview:statusLabel];
		
		progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(25,30,200,10)] autorelease];
		[self addSubview:progressView];
		
		deleteButton					= [UIButton buttonWithType:UIButtonTypeRoundedRect];
		deleteButton.frame				= CGRectMake(0,20,55,20);
		deleteButton.hidden				= YES;
		
		[deleteButton setTitle:@"Delete"
					  forState:UIControlStateNormal];
		
		[deleteButton addTarget:self
						 action:@selector(didTapDeleteButton:)
			   forControlEvents:UIControlEventTouchUpInside];
		
		
		[self addSubview:deleteButton];
		
		
		retryButton						= [UIButton buttonWithType:UIButtonTypeRoundedRect];
		retryButton.frame				= CGRectMake(60,20,55,20);
		retryButton.hidden				= YES;
		
		[retryButton setTitle:@"Retry"
					 forState:UIControlStateNormal];
		
		[retryButton addTarget:self
						 action:@selector(didTapRetryButton:)
			   forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:retryButton];
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)updateDisplayWithTotalActive:(NSInteger)totalActive
						 totalFailed:(NSInteger)totalFailed 
					   totalProgress:(float)totalProgress {
	
	if(totalActive) {
		deleteButton.hidden		= YES;
		retryButton.hidden		= YES;
		progressView.hidden		= NO;
		
		[progressView setProgress:totalProgress];
		
		if(totalActive == 1 && totalProgress < kMinimumProgress) {
			statusLabel.text = @"Connecting..";
		}
		else if(totalActive == 1)
			statusLabel.text = @"Posting...";
		else {
			statusLabel.text = [NSString stringWithFormat:@"Posting %d of %d",totalActive,totalActive];
		}

	}
	else if(totalFailed) {
		statusLabel.text		= [NSString stringWithFormat:@"%d Failed",totalFailed];
		progressView.hidden		= YES;
		deleteButton.hidden		= NO;
		retryButton.hidden		= NO;
	}
}

//----------------------------------------------------------------------------------------------------
- (void)didTapDeleteButton:(UIButton*)button {
	[_delegate deleteButtonPressed];
}

//----------------------------------------------------------------------------------------------------
- (void)didTapRetryButton:(UIButton*)button {
	progressView.progress	= 0.0;
	statusLabel.text		= kEmptyString;
	deleteButton.hidden		= YES;
	retryButton.hidden		= YES;
	progressView.hidden		= NO;
	
	[_delegate retryButtonPressed];
}

@end
