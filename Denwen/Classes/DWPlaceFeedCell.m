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
@implementation DWPlaceFeedCellDrawingLayer

@synthesize placeCell;

//----------------------------------------------------------------------------------------------------
- (void)drawInContext:(CGContextRef)context {
	
	UIGraphicsPushContext(context);
	
	
	CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
	CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
	 
	
	[placeCell.placeName drawInRect:CGRectMake(7,24,293,23) 
						   withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
					  lineBreakMode:UILineBreakModeTailTruncation
						  alignment:UITextAlignmentLeft];
	 
	[placeCell.placeDetails drawInRect:CGRectMake(7,48,293,23)
							  withFont:[UIFont fontWithName:@"HelveticaNeue" size:14] 
						 lineBreakMode:UILineBreakModeTailTruncation
							 alignment:UITextAlignmentLeft];
	
	/*
	CGContextSetFillColorWithColor(context,[UIColor colorWithRed:0.0549 green:0.05882 blue:0.0549 alpha:1.0].CGColor);
	CGContextFillRect(context,CGRectMake(0,0,320,92));
	
	CGContextSetFillColorWithColor(context,[UIColor colorWithRed:0.2196 green:0.2196 blue:0.2196 alpha:1.0].CGColor);
	CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
	
	[self.placeData drawAtPoint:CGPointMake(7,-10)
					   withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:78]];
	 */
	
	UIGraphicsPopContext();
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceFeedCell

@synthesize placeName			= _placeName;
@synthesize placeData			= _placeData;
@synthesize placeDetails		= _placeDetails;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
				reuseIdentifier:reuseIdentifier];
    
	if (self) {
        
		CGRect frame = CGRectMake(0,0,320,92);
		
		placeImageLayer					= [CALayer layer];
		placeImageLayer.frame			= frame;
		placeImageLayer.contentsScale	= [[UIScreen mainScreen] scale];
		placeImageLayer.opacity			= 0.65;
		placeImageLayer.backgroundColor	= [UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor;
		[[self layer] addSublayer:placeImageLayer];
		
		drawingLayer					= [DWPlaceFeedCellDrawingLayer layer];
		drawingLayer.placeCell			= self;
		drawingLayer.frame				= frame;
		drawingLayer.contentsScale		= [[UIScreen mainScreen] scale];
        [[self layer] addSublayer:drawingLayer];
		
		CALayer *chevronLayer			= [CALayer layer];
		chevronLayer.frame				= CGRectMake(304,38,9,14);
		chevronLayer.contentsScale		= [[UIScreen mainScreen] scale];
		chevronLayer.contents			= (id)[UIImage imageNamed:kImgChevron].CGImage;
		[[self layer] addSublayer:chevronLayer];
		
		CALayer *separatorLayer			= [CALayer layer];
		separatorLayer.frame			= CGRectMake(0,91,320,1);
		separatorLayer.contentsScale	= [[UIScreen mainScreen] scale];
		separatorLayer.contents			= (id)[UIImage imageNamed:kImgSeparator].CGImage;
		[[self layer] addSublayer:separatorLayer];
		
		
		self.accessoryType				= UITableViewCellAccessoryNone;
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.placeName		= nil;
	self.placeDetails	= nil;
	self.placeData		= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted = NO;
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted 
			  animated:(BOOL)animated {
	
	if(_highlighted != highlighted) {
		_highlighted = highlighted;
		placeImageLayer.opacity = _highlighted ? 0.45 : 0.65;
	}
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceImage:(UIImage*)placeImage {
	placeImageLayer.contents = (id)placeImage.CGImage;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[drawingLayer setNeedsDisplay];
}


@end
