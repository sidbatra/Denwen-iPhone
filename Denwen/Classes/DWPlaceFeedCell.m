//
//  DWPlaceFeedCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceFeedCell.h"

static NSString* const kImgSeparator	= @"hr_place_list.png";
static NSString* const kImgChevron		= @"chevron.png";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceFeedSelectedView

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
    if (self) {
        self.opaque				= YES;
		self.backgroundColor	= [UIColor blackColor];
    }
    
    return self;
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceFeedView

@synthesize placeName		= _placeName;
@synthesize placeData		= _placeData;
@synthesize placeDetails	= _placeDetails;
@synthesize placeImage		= _placeImage;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
    if (self) {
        self.opaque				= YES;
		self.backgroundColor	= [UIColor blackColor];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.placeName		= nil;
	self.placeData		= nil;
	self.placeDetails	= nil;
	self.placeImage		= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect {
	
	CGRect imageFrame = CGRectMake(0,0,320,92);

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);	
	
	[[UIColor blackColor] set];
	CGContextFillRect(context,imageFrame);
	
	if(self.placeImage)
		[self.placeImage drawInRect:imageFrame blendMode:kCGBlendModeNormal alpha:_highlighted ? 0.65 : 0.6];
			

	[[UIColor whiteColor] set];
	
	CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
	
	[self.placeName drawInRect:CGRectMake(7,24,293,23) 
					  withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]
				 lineBreakMode:UILineBreakModeTailTruncation
					 alignment:UITextAlignmentLeft];
		
	[self.placeDetails drawInRect:CGRectMake(7,47,293,23)
						 withFont:[UIFont fontWithName:@"HelveticaNeue" size:13] 
					lineBreakMode:UILineBreakModeTailTruncation
						alignment:UITextAlignmentLeft];

	CGContextRestoreGState(context);
	
	[[UIImage imageNamed:kImgSeparator] drawInRect:CGRectMake(0,91,320,1)];
	[[UIImage imageNamed:kImgChevron]	drawInRect:CGRectMake(304,38,9,14)];
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
	
	/*if(!_highlighted) {
		_highlighted = highlighted;
		[self redisplay];
	}
	else {
		[self performSelector:@selector(removeHighlight:) 
				   withObject:nil
				   afterDelay:5.0];
	}
	 */
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
		
		self.selectedBackgroundView = [[[DWPlaceFeedSelectedView alloc] initWithFrame:frame] autorelease];
		self.accessoryType			= UITableViewCellAccessoryNone;
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	self.placeFeedView = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	[self.placeFeedView reset];
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceName:(NSString*)placeName {
	self.placeFeedView.placeName = placeName;
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceData:(NSString*)placeData {
	self.placeFeedView.placeData = placeData;
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceDetails:(NSString *)placeDetails {
	self.placeFeedView.placeDetails = placeDetails;
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceImage:(UIImage*)placeImage {
	self.placeFeedView.placeImage = placeImage;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[self.placeFeedView redisplay];
}


@end
