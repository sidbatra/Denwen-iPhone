//
//  DWPostProgressView.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPostProgressView.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPostProgressView

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
	if (self) {
		statusLabel					= [[[UILabel alloc] initWithFrame:CGRectMake(25,5,200,20)] autorelease];
		statusLabel.font			= [UIFont fontWithName:@"HelveticaNeue" size:13];
		statusLabel.textColor		= [UIColor whiteColor];
		statusLabel.backgroundColor	= [UIColor clearColor];
		statusLabel.textAlignment	= UITextAlignmentCenter;
		//statusLabel.text			= @"Posting... 2 of 2";
		[self addSubview:statusLabel];
		
		progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(25,30,200,10)] autorelease];
		progressView.progress = 0.0;
		[self addSubview:progressView];
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
		[progressView setProgress:totalProgress];
		
		if(totalActive == 1) {
			statusLabel.text = @"Posting...";
		}
		else {
			statusLabel.text = [NSString stringWithFormat:@"Posting %d of %d",totalActive,totalActive];
		}

	}
}

@end
