//
//  DWNewPlaceCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNewPlaceCell.h"

static NSString* const kMsgNewPlace		= @"I'm adding a new place";
static NSString* const kImgBackground	= @"button_new_place.png";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNewPlaceCell

@synthesize backgroundImageView = _backgroundImageView;
@synthesize messageLabel		= _messageLabel;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
    if (self) {
		CGRect rect = CGRectMake(0,0,self.contentView.frame.size.width,self.contentView.frame.size.height);
		
		
		self.backgroundImageView			= [[[UIImageView alloc] initWithFrame:rect] autorelease];
		self.backgroundImageView.image		= [UIImage imageNamed:kImgBackground];
		
		[self.contentView addSubview:self.backgroundImageView];
		
		self.messageLabel					= [[[UILabel alloc] initWithFrame:rect] autorelease];
		self.messageLabel.text				= kMsgNewPlace;
		self.messageLabel.font				= [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];	
		self.messageLabel.backgroundColor	= [UIColor clearColor];
		self.messageLabel.textColor			= [UIColor whiteColor];
		self.messageLabel.textAlignment		= UITextAlignmentCenter;
		
		[self.contentView addSubview:self.messageLabel];
		
		UIView *selectedView			= [[[UIView alloc] initWithFrame:rect] autorelease];
		selectedView.backgroundColor	= [UIColor clearColor];
		self.selectedBackgroundView		= selectedView;
	}
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.backgroundImageView	= nil;
	self.messageLabel			=nil;
    
	[super dealloc];
}

@end
