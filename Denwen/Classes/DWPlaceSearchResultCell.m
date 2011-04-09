//
//  DWPlaceSearchResultCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceSearchResultCell.h"

static NSString* const kImgPlaceIcon = @"pointer_mini_gray_dark.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceSearchResultSelectedView

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
    if (self) {
        self.opaque				= YES;
		self.backgroundColor	= [UIColor greenColor];
    }
    
    return self;
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceSearchResultView

@synthesize placeName		= _placeName;
@synthesize placeDetails	= _placeDetails;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
    if (self) {
        self.opaque				= YES;
		self.backgroundColor	= [UIColor whiteColor];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.placeName		= nil;
	self.placeDetails	= nil;
	
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
	
	[[UIImage imageNamed:kImgPlaceIcon] drawInRect:CGRectMake(0, 0, 20, 20)];
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[self setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted {
	_highlighted = highlighted;
	[self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)removeHighlight:(id)sender {
	_highlighted = NO;
	[self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isHighlighted {
    return _highlighted;
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceSearchResultCell

@synthesize placeSearchResultView = _placeSearchResultView;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self) {
		CGRect frame = CGRectMake(0.0,0.0,self.contentView.bounds.size.width,self.contentView.bounds.size.height);
		
		self.placeSearchResultView = [[[DWPlaceSearchResultView alloc] initWithFrame:frame] autorelease];
        self.placeSearchResultView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.placeSearchResultView.contentMode		= UIViewContentModeRedraw;
		
		[self.contentView addSubview:self.placeSearchResultView];
		
		self.selectedBackgroundView = [[[DWPlaceSearchResultSelectedView alloc] initWithFrame:frame] autorelease];
		self.accessoryType			= UITableViewCellAccessoryNone;
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	self.placeSearchResultView = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	[self.placeSearchResultView reset];
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceName:(NSString*)placeName {
	self.placeSearchResultView.placeName = placeName;
	[self.placeSearchResultView redisplay];
	
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceDetails:(NSString *)placeDetails {
	self.placeSearchResultView.placeDetails = placeDetails;
	[self.placeSearchResultView redisplay];
}


//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[self.placeSearchResultView redisplay];
}



@end



