//
//  DWLoadingCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWLoadingCell.h"

static NSString* const kImgBackground	= @"main_bg.png";

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWLoadingCell

@synthesize spinner;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
				reuseIdentifier:reuseIdentifier];
    
	if (self) {
		[self createBackground];
        [self createSpinner];
		[self createMessageLabel];
		
		self.selectionStyle		= UITableViewCellSelectionStyleNone;
	}
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)createBackground {
	
	UIImageView *backgroundImageView	= [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,367)] autorelease];
	backgroundImageView.image			= [UIImage imageNamed:kImgBackground];
	backgroundImageView.contentMode		= UIViewContentModeScaleToFill;
	
	[self.contentView addSubview:backgroundImageView];
}

//----------------------------------------------------------------------------------------------------
- (void)createSpinner {
	spinner			= [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
	spinner.frame	= CGRectMake(109,167,20,20);
	
	[self.contentView addSubview:spinner];	
}

//----------------------------------------------------------------------------------------------------
- (void)createMessageLabel {
	messageLabel					= [[[UILabel alloc] initWithFrame:CGRectMake(136,167,90,20)] autorelease];	
	messageLabel.backgroundColor	= [UIColor clearColor];
	messageLabel.font				= [UIFont fontWithName:@"HelveticaNeue" size:17];	
	messageLabel.textColor			= [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
	messageLabel.textAlignment		= UITextAlignmentLeft;
	messageLabel.text				= @"Loading...";

	[self.contentView addSubview:messageLabel];
}

//----------------------------------------------------------------------------------------------------
- (void)shorterCellMode {
	
	if(!_isShortMode) {
		CGRect messageFrame		= messageLabel.frame;
		messageFrame.origin.y	= messageFrame.origin.y - 44;
		messageLabel.frame		= messageFrame;
		
		CGRect spinnerFrame		= spinner.frame;
		spinnerFrame.origin.y	= spinnerFrame.origin.y - 44;
		spinner.frame			= spinnerFrame;
		
		_isShortMode			= YES;
	}
}

@end
