//
//  DWPlaceFeedCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceFeedCell.h"

static NSString* const kImgSeparator	= @"hr_place_list.png";
static NSString* const kImgChevron		= @"chevron.png";

#define kAnimationDuration	0.25
#define kFadeDelay			0.75
#define kNormalAlpha		0.65
#define kHighlightAlpha		0.45

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlaceFeedCellDrawingLayer

@synthesize placeCell;

//----------------------------------------------------------------------------------------------------
- (void)drawInContext:(CGContextRef)context {
	
	UIGraphicsPushContext(context);
	
	
	CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
	//CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
	 
	
	[placeCell.placeName drawInRect:CGRectMake(20,21,280,28) 
						   withFont:[UIFont fontWithName:@"HelveticaNeue" size:22]
					  lineBreakMode:UILineBreakModeTailTruncation
						  alignment:UITextAlignmentLeft];
	 
	[placeCell.placeDetails drawInRect:CGRectMake(20,49,280,20)
							  withFont:[UIFont fontWithName:@"HelveticaNeue" size:15] 
						 lineBreakMode:UILineBreakModeTailTruncation
							 alignment:UITextAlignmentLeft];
	
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
		placeImageLayer.opacity			= kNormalAlpha;
		placeImageLayer.backgroundColor	= [UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor;
		placeImageLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNull null], @"contents",
										   nil];
		[[self layer] addSublayer:placeImageLayer];
		
		drawingLayer					= [DWPlaceFeedCellDrawingLayer layer];
		drawingLayer.placeCell			= self;
		drawingLayer.frame				= frame;
		drawingLayer.contentsScale		= [[UIScreen mainScreen] scale];
		drawingLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNull null], @"contents",
										   nil];
        [[self layer] addSublayer:drawingLayer];
		
		CALayer *chevronLayer			= [CALayer layer];
		chevronLayer.frame				= CGRectMake(307,41,6,11);
		chevronLayer.contentsScale		= [[UIScreen mainScreen] scale];
		chevronLayer.contents			= (id)[UIImage imageNamed:kImgChevron].CGImage;
		[[self layer] addSublayer:chevronLayer];
		
		CALayer *separatorLayer			= [CALayer layer];
		separatorLayer.frame			= CGRectMake(0,91,320,1);
		separatorLayer.contentsScale	= [[UIScreen mainScreen] scale];
		separatorLayer.contents			= (id)[UIImage imageNamed:kImgSeparator].CGImage;
		[[self layer] addSublayer:separatorLayer];
		
		
		self.accessoryType				= UITableViewCellAccessoryNone;
		self.selectionStyle				= UITableViewCellSelectionStyleNone;
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
	
	if(highlighted && !_highlighted) {
		[self highlightCell];
	}
	else if(!highlighted && _highlighted) {
	
		[self performSelector:@selector(fadeCell)
				   withObject:nil 
				   afterDelay:kFadeDelay];
	}
	
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isHighlighted {
    return _highlighted;
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceImage:(UIImage*)placeImage {
	placeImageLayer.contents = (id)placeImage.CGImage;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[drawingLayer setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)highlightCell {
	_highlighted = YES;
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kAnimationDuration]
					 forKey:kCATransactionAnimationDuration];		
	placeImageLayer.opacity = kHighlightAlpha;
	[CATransaction commit];
}

//----------------------------------------------------------------------------------------------------
- (void)fadeCell {
	_highlighted = NO;
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kAnimationDuration]
					 forKey:kCATransactionAnimationDuration];		
	placeImageLayer.opacity = kNormalAlpha;
	[CATransaction commit];
}


@end
