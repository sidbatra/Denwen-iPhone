//
//  DWMessageCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWMessageCell.h"

static NSString* const kImgBackground	= @"main_bg.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWMessageCell

@synthesize messageLabel;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style 
	reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
				reuseIdentifier:reuseIdentifier];
	
    if (self) {
		
		UIImageView *backgroundImageView	= [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,367)] autorelease];
		backgroundImageView.image			= [UIImage imageNamed:kImgBackground];
		backgroundImageView.contentMode		= UIViewContentModeScaleToFill;
		
		[self.contentView addSubview:backgroundImageView];
		
		self.messageLabel					= [[[UILabel alloc] initWithFrame:CGRectMake(0,167,320,20)] autorelease];
		self.messageLabel.font				= [UIFont fontWithName:@"HelveticaNeue" size:17];	
		self.messageLabel.textColor			= [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
		self.messageLabel.backgroundColor	= [UIColor clearColor];
		self.messageLabel.textAlignment		= UITextAlignmentCenter;
		
		[self.contentView addSubview:self.messageLabel];
		
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;	
	}
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)shorterCellMode {
	
	if(!_isShortMode) {
		CGRect messageFrame		= messageLabel.frame;
		messageFrame.origin.y	= messageFrame.origin.y - 44;
		messageLabel.frame		= messageFrame;
		
		_isShortMode			= YES;
	}
}

@end
