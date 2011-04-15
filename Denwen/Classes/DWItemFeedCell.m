//
//  DWItemFeedCell.m
//  Denwen
//
//  Created by Deepak Rao on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWItemFeedCell.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedCellDrawingLayer

@synthesize itemCell;

//----------------------------------------------------------------------------------------------------
- (void)drawInContext:(CGContextRef)context {
	
	UIGraphicsPushContext(context);
	
	if(![itemCell isHighlighted]) {
		CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
		CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
		
		
		[itemCell.itemData drawInRect:CGRectMake(7,124,293,70) 
							   withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16]
						  lineBreakMode:UILineBreakModeWordWrap
							  alignment:UITextAlignmentLeft];
	}
	
	UIGraphicsPopContext();
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedCell

@synthesize itemData	= _itemData;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
				reuseIdentifier:reuseIdentifier];
    
	if (self) {
		CGRect frame = CGRectMake(0,0,320,320);
                                  
		itemImageLayer					= [CALayer layer];
		itemImageLayer.frame			= frame;
		itemImageLayer.contentsScale	= [[UIScreen mainScreen] scale];
		itemImageLayer.opacity			= 0.45;
		itemImageLayer.backgroundColor	= [UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor;
		[[self layer] addSublayer:itemImageLayer];
		
		drawingLayer					= [DWItemFeedCellDrawingLayer layer];
		drawingLayer.itemCell			= self;
		drawingLayer.frame				= frame;
		drawingLayer.contentsScale		= [[UIScreen mainScreen] scale];
        [[self layer] addSublayer:drawingLayer];
		
		

		self.accessoryType			= UITableViewCellAccessoryNone;
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	self.itemData	= nil;
	
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
		itemImageLayer.opacity = _highlighted ? 1.0 : 0.45;
		[self redisplay];
	}
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isHighlighted {
    return _highlighted;
}

//----------------------------------------------------------------------------------------------------
- (void)setItemImage:(UIImage*)itemImage {
	itemImageLayer.contents = (id)itemImage.CGImage;
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[drawingLayer setNeedsDisplay];
}

@end

