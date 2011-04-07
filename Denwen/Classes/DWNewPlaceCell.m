//
//  DWNewPlaceCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWNewPlaceCell.h"

static NSString* const kMsgNewPlace = @"I am adding a new place";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWNewPlaceCell

@synthesize messageLabel = _messageLabel;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
    if (self) {
		CGRect rect = CGRectMake(0,0,self.contentView.frame.size.width,self.contentView.frame.size.height);
		
		self.messageLabel					= [[[UILabel alloc] initWithFrame:rect] autorelease];
		self.messageLabel.text				= kMsgNewPlace;
		self.messageLabel.font				= [UIFont fontWithName:@"Helvetica" size:15];	
		self.messageLabel.textColor			= [UIColor whiteColor];
		self.messageLabel.backgroundColor	= [UIColor blueColor];
		self.messageLabel.textAlignment		= UITextAlignmentCenter;
		
		[self.contentView addSubview:self.messageLabel];
	}
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

@end
