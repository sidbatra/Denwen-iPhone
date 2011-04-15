//
//  DWPlaceFeedCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlaceFeedCell.h"

static NSString* const kImgSeparator	= @"hr_place_list.png";
static NSString* const kImgChevron		= @"chevron.png";


@interface DWPlaceFeedDrawingLayer : CALayer
@end

@implementation DWPlaceFeedDrawingLayer

- (void)drawInContext:(CGContextRef)context {
	
	//CGContextRef context = UIGraphicsGetCurrentContext();
	//CGContextSaveGState(context);	
	UIGraphicsPushContext(context);
	
	
	 CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
	 CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
	 
	 [@"Gates Computer Science Building" drawInRect:CGRectMake(7,24,293,23) 
				withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
		   lineBreakMode:UILineBreakModeTailTruncation
			   alignment:UITextAlignmentLeft];
	 
	
	UIGraphicsPopContext();
	//CGContextRestoreGState(context);	
}



@end




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

@synthesize placeName			= _placeName;
@synthesize placeData			= _placeData;
@synthesize placeDetails		= _placeDetails;
@synthesize placeImage			= _placeImage;
@synthesize placeImageLayer		= _placeImageLayer;
@synthesize	placeNameLayer		= _placeNameLayer;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
    if (self) {
        self.opaque				= YES;
		self.backgroundColor	= [UIColor blackColor];

		//self.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.contentMode		= UIViewContentModeRedraw;
		self.placeImageLayer					= [CALayer layer];
		self.placeImageLayer.frame				= frame;
		self.placeImageLayer.contentsScale		= [[UIScreen mainScreen] scale];
		self.placeImageLayer.opacity			= 0.65;
		self.placeImageLayer.backgroundColor	= [UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor;
		[[self layer] addSublayer:self.placeImageLayer];
		
		self.placeNameLayer						= [DWPlaceFeedDrawingLayer layer];
		//self.placeNameLayer.delegate			= self;
		self.placeNameLayer.frame				= frame;//CGRectMake(7,24,293,23);
		self.placeNameLayer.contentsScale		= [[UIScreen mainScreen] scale];
		//self.placeNameLayer.backgroundColor		= [UIColor greenColor].CGColor;
        //self.placeNameLayer.font				= @"HelveticaNeue-Bold";
        //self.placeNameLayer.fontSize			= 18;
        //self.placeNameLayer.alignmentMode		= UITextAlignmentLeft;
		//self.placeNameLayer.truncationMode		= kCATruncationStart;
        //self.placeNameLayer.foregroundColor		= [[UIColor whiteColor] CGColor];
        [[self layer] addSublayer:self.placeNameLayer];
		[self.placeNameLayer setNeedsDisplay];
		//[attrStr set

						   
			/*
		[self.placeName drawInRect:CGRectMake(7,24,293,23) 
						  withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
					 lineBreakMode:UILineBreakModeTailTruncation
						 alignment:UITextAlignmentLeft];
		
		[self.placeDetails drawInRect:CGRectMake(7,48,293,23)
							 withFont:[UIFont fontWithName:@"HelveticaNeue" size:14] 
						lineBreakMode:UILineBreakModeTailTruncation
							alignment:UITextAlignmentLeft];
			 */
		
    }
    
    return self;
}


//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.placeName          = nil;
	self.placeData          = nil;
	self.placeDetails       = nil;
	self.placeImage			= nil;
	self.placeImageLayer	= nil;
	
	[super dealloc];
}


//----------------------------------------------------------------------------------------------------
/*
- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);	
	CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
	CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
	
	
	
	[self.placeName drawInRect:CGRectMake(7,24,293,23) 
					  withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
				 lineBreakMode:UILineBreakModeTailTruncation
					 alignment:UITextAlignmentLeft];
	CGContextRestoreGState(context);

}
 */
/*
- (void)drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);	

	if(self.placeImage) {
		[self.placeImage drawAtPoint:CGPointMake(0,0)];
						  //blendMode:kCGBlendModeNormal 
							//  alpha:_highlighted ? 0.45 : 0.65];
	}
	else if(self.placeData) {
		CGContextSetFillColorWithColor(context,[UIColor colorWithRed:0.0549 green:0.05882 blue:0.0549 alpha:1.0].CGColor);
		CGContextFillRect(context,CGRectMake(0,0,320,92));
		
		CGContextSetFillColorWithColor(context,[UIColor colorWithRed:0.2196 green:0.2196 blue:0.2196 alpha:1.0].CGColor);
		CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
		
		[self.placeData drawAtPoint:CGPointMake(7,-10)
						   withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:78]];
	}
	else {
		CGContextSetFillColorWithColor(context,[UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor);
		CGContextFillRect(context,CGRectMake(0,0,320,92));
	}
	
	
	CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
	CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
	
	[self.placeName drawInRect:CGRectMake(7,24,293,23) 
					  withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
				 lineBreakMode:UILineBreakModeTailTruncation
					 alignment:UITextAlignmentLeft];
		
	[self.placeDetails drawInRect:CGRectMake(7,48,293,23)
						 withFont:[UIFont fontWithName:@"HelveticaNeue" size:14] 
					lineBreakMode:UILineBreakModeTailTruncation
						alignment:UITextAlignmentLeft];
	 
	CGContextRestoreGState(context);
	
	//[[UIImage imageNamed:kImgSeparator] drawAtPoint:CGPointMake(0,91)];
	//[[UIImage imageNamed:kImgChevron]	drawAtPoint:CGPointMake(304,38)];
}
 */

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted	= NO;
	self.placeData	= nil;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[self setNeedsDisplay];
	[self.layer setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted {
	
	if(_highlighted != highlighted) {
		_highlighted = highlighted;
		self.placeImageLayer.opacity = _highlighted ? 0.45 : 0.65;
		[self redisplay];
	}
	
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

@synthesize placeFeedView	= _placeFeedView;
@synthesize placeImageView	= _placeImageView;


//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
	if (self) {
        
		CGRect frame = CGRectMake(0.0,0.0,320,92);
        
         /*placeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 92)];
        [self.contentView addSubview:placeImageView];
        [placeImageView release];*/
        
		self.placeFeedView = [[[DWPlaceFeedView alloc] initWithFrame:frame] autorelease];
        [self.contentView addSubview:self.placeFeedView];
        
		//self.placeImageView     = [[[UIImageView alloc] 
		//							initWithFrame:frame] autorelease];
		//[self addSubview:self.placeImageView];
		
		
		self.selectedBackgroundView = [[[DWPlaceFeedSelectedView alloc] initWithFrame:frame] autorelease];
		self.accessoryType			= UITableViewCellAccessoryNone;
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	self.placeFeedView	= nil;
	self.placeImageView	= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	[self.placeFeedView reset];
	[self.placeFeedView.layer setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceName:(NSString*)placeName {
	self.placeFeedView.placeName = placeName;
	//self.placeFeedView.placeNameLayer.string = placeName;
	
	/*
	NSMutableAttributedString* attrStr = [[[NSMutableAttributedString alloc] initWithString:placeName] autorelease];
	[attrStr addAttribute:(NSString*)kCTForegroundColorAttributeName 
					value:(id)[UIColor whiteColor].CGColor
					range:NSMakeRange(0, attrStr.length)];
	
	[attrStr addAttribute:(NSString*)kCTFontAttributeName
					value:(id)CTFontCreateWithName((CFStringRef)@"HelveticaNeue-Bold",18, nil)
					range:NSMakeRange(0, attrStr.length)];
	*/
	//[attrStr addAttribute:kCTFontURLAttribute value:<#(id)value#> range:<#(NSRange)range#>
	//NSFontAttributeName;
	
	//[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
	//self.placeFeedView.placeNameLayer.string = attrStr;
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
	self.placeFeedView.placeImageLayer.contents = (id)placeImage.CGImage;
	//self.placeFeedView.placeImage	= placeImage;
	//self.placeImageView.image = placeImage;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[self.placeFeedView redisplay];
}


@end
