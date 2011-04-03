//
//  DWPlaceFeedCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceFeedCell.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceFeedView

@synthesize placeName		= _placeName;
@synthesize placeDetails	= _placeDetails;
@synthesize placeImage		= _placeImage;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
    if (self) {
        self.opaque = YES;
		self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.placeName		= nil;
	self.placeDetails	= nil;
	self.placeImage		= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect {
	_highlighted ? [[UIColor whiteColor] set] : NO;
		
	[self.placeName drawInRect:CGRectMake(64, 7, 230, 22) 
					  withFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]
				 lineBreakMode:UILineBreakModeTailTruncation
					 alignment:UITextAlignmentLeft];
	
	
	_highlighted ? [[UIColor whiteColor] set] : [[UIColor colorWithRed:0.1411 green:0.4392 blue:0.8470 alpha:1.0] set];
	
	[self.placeDetails drawInRect:CGRectMake(64, 31, 230, 16) 
						 withFont:[UIFont fontWithName:@"Helvetica" size:13] 
					lineBreakMode:UILineBreakModeTailTruncation
						alignment:UITextAlignmentLeft];
	
	[self.placeImage drawInRect:CGRectMake(0, 0, 55, 55)];
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[self setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
    [self setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isHighlighted {
    return _highlighted;
}

@end


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceFeedCell

@synthesize placeFeedView = _placeFeedView;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self) {
		CGRect frame = CGRectMake(0.0,0.0,self.contentView.bounds.size.width,self.contentView.bounds.size.height);
		
		self.placeFeedView = [[[DWPlaceFeedView alloc] initWithFrame:frame] autorelease];
        self.placeFeedView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.placeFeedView.contentMode		= UIViewContentModeRedraw;
		
		[self.contentView addSubview:self.placeFeedView];
		
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	self.placeFeedView = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceName:(NSString*)placeName {
	self.placeFeedView.placeName = placeName;
	[self.placeFeedView redisplay];

}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceDetails:(NSString *)placeDetails {
	self.placeFeedView.placeDetails = placeDetails;
	[self.placeFeedView redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceImage:(UIImage*)placeImage {
	self.placeFeedView.placeImage = placeImage;
	[self.placeFeedView redisplay];
}

@end
