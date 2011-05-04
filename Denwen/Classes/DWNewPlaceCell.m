//
//  DWNewPlaceCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNewPlaceCell.h"

static NSString* const kMsgNewPlace			= @"I'm adding a new place";
static NSString* const kImgBackground		= @"button_new_place.png";
static NSString* const kImgBackgroundActive	= @"button_new_place_active.png";
static NSString* const kImgSeparator		= @"hr_gray_create.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNewPlaceCell

@synthesize backgroundImageView = _backgroundImageView;
@synthesize separatorImageView	= _separatorImageView;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
    if (self) {
		CGRect rect = CGRectMake(0,0,self.contentView.frame.size.width,self.contentView.frame.size.height);
		
		
		self.backgroundImageView			= [[[UIImageView alloc] initWithFrame:rect] autorelease];
		self.backgroundImageView.image		= [UIImage imageNamed:kImgBackground];
		
		[self.contentView addSubview:self.backgroundImageView];
		
		rect								= CGRectMake(0, 43, 320, 1);
		self.separatorImageView				= [[[UIImageView alloc] initWithFrame:rect] autorelease];
		self.separatorImageView.image		= [UIImage imageNamed:kImgSeparator];
		
		[self.contentView addSubview:self.separatorImageView];
		
		UIView *selectedView			= [[[UIView alloc] initWithFrame:rect] autorelease];
		selectedView.backgroundColor	= [UIColor clearColor];
		self.selectedBackgroundView		= selectedView;
		 
	}
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	
	if(highlighted)
		self.backgroundImageView.image		= [UIImage imageNamed:kImgBackgroundActive];
	else
		self.backgroundImageView.image		= [UIImage imageNamed:kImgBackground];
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.backgroundImageView	= nil;
	self.separatorImageView		= nil;
    
	[super dealloc];
}

@end
