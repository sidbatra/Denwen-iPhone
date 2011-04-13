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
@synthesize placeImageView	= _placeImageView;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
    if (self) {
        self.opaque				= YES;
		self.backgroundColor	= [UIColor blackColor];
        self.placeImageView     = [[[UIImageView alloc] 
                                    initWithFrame:CGRectMake(0, 0, 320, 92)] autorelease];
        
        [self addSubview:self.placeImageView];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.placeName          = nil;
	self.placeData          = nil;
	self.placeDetails       = nil;
	self.placeImageView     = nil;
	
	[super dealloc];
}


//----------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);	

	//if(self.placeImage)
	//	[self.placeImage drawAtPoint:CGPointMake(0,0)];
						  /*blendMode:kCGBlendModeNormal 
							  alpha:_highlighted ? 0.45 : 0.65];*/
	/*if(self.placeImage)
		[self.placeImage drawAtPoint:CGPointMake(0,0)
						  blendMode:kCGBlendModeNormal 
							  alpha:_highlighted ? 0.45 : 0.65];*/
	if(self.placeData) {
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
	
			
	//CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
    	[[UIColor whiteColor] set];
	//CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
	
	[self.placeName drawInRect:CGRectMake(7,24,293,23) 
					  withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
				 lineBreakMode:UILineBreakModeTailTruncation
					 alignment:UITextAlignmentLeft];
		
	[self.placeDetails drawInRect:CGRectMake(7,48,293,23)
						 withFont:[UIFont fontWithName:@"HelveticaNeue" size:14] 
					lineBreakMode:UILineBreakModeTailTruncation
						alignment:UITextAlignmentLeft];
	 
	//CGContextRestoreGState(context);
	
	/*[[UIImage imageNamed:kImgSeparator] drawAtPoint:CGPointMake(0,91)];
	[[UIImage imageNamed:kImgChevron]	drawAtPoint:CGPointMake(304,38)];*/
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted	= NO;
	self.placeData	= nil;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[self setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted {
    if (_highlighted != highlighted) {
        _highlighted = highlighted;
        [self redisplay];
    }
	
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
        
		CGRect frame = CGRectMake(0.0,0.0,320,92);//self.contentView.bounds.size.width,self.contentView.bounds.size.height);
        
		self.placeFeedView = [[[DWPlaceFeedView alloc] initWithFrame:frame] autorelease];
        //self.placeFeedView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.placeFeedView.contentMode		= UIViewContentModeRedraw;
        [self.contentView addSubview:self.placeFeedView];
        
        /*
        _placeImage = [[UIImageView alloc] init];
        _placeImage.frame = CGRectMake(0, 0, 320, 92);
        

        [self.contentView addSubview:_placeImage];
        [_placeImage release];
        
        _placeName = [[UILabel alloc] init];
        _placeName.frame = CGRectMake(7,24,293,23);
        _placeName.lineBreakMode = UILineBreakModeTailTruncation;
        _placeName.backgroundColor = [UIColor clearColor];
        _placeName.textColor = [UIColor whiteColor];
        _placeName.textAlignment = UITextAlignmentLeft;
        _placeName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        [self.contentView addSubview:_placeName];
        [_placeName release];
        
        _placeDetails = [[UILabel alloc] init];
        _placeDetails.frame = CGRectMake(7,47,293,23);
        _placeDetails.lineBreakMode = UILineBreakModeTailTruncation;
        _placeDetails.textAlignment = UITextAlignmentLeft;
        _placeDetails.backgroundColor = [UIColor clearColor];
        _placeDetails.textColor = [UIColor whiteColor];
        _placeDetails.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        [self.contentView addSubview:_placeDetails];
        [_placeDetails release];*/
		
		//self.selectedBackgroundView = [[[DWPlaceFeedSelectedView alloc] initWithFrame:frame] autorelease];
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
    //_placeName.text = placeName;
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceData:(NSString*)placeData {
	self.placeFeedView.placeData = placeData;
    //_placeDetails.text = placeData;
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceDetails:(NSString *)placeDetails {
	self.placeFeedView.placeDetails = placeDetails;
    //_placeDetails.text = placeDetails;
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceImage:(UIImage*)placeImage {
	self.placeFeedView.placeImageView.image = placeImage;
    //_placeImage.image = placeImage;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[self.placeFeedView redisplay];
}


@end
