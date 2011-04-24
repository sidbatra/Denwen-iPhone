//
//  DWTouchCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTouchCell.h"

static NSString* const kImgSeparator	= @"hr_place_list.png";
static NSString* const kImgChevron		= @"chevron.png";

#define kAnimationDuration          0.25
#define kNoAnimationDuration		0.0
#define kFadeDelay                  0.75
#define kNormalAlpha                0.55
#define kHighlightAlpha             0.35



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTouchCellDrawingLayer

@synthesize touchCell;

//----------------------------------------------------------------------------------------------------
- (void)drawInContext:(CGContextRef)context {
	
	UIGraphicsPushContext(context);
	
	
	CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
	//CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
    
    [touchCell.itemData  drawInRect:CGRectMake(65,5,220,50) 
                           withFont:[UIFont fontWithName:@"HelveticaNeue" size:13]
                      lineBreakMode:UILineBreakModeWordWrap
                          alignment:UITextAlignmentLeft];
	
	UIGraphicsPopContext();
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTouchCell

@synthesize itemData			= _itemData;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
				reuseIdentifier:reuseIdentifier];
    
	if (self) {
        
		CGRect frame = CGRectMake(0,0,320,60);
        
        attachmentImageLayer                    = [CALayer layer];
		attachmentImageLayer.frame              = frame;
		attachmentImageLayer.contentsScale      = [[UIScreen mainScreen] scale];
		attachmentImageLayer.backgroundColor	= [UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor;
		attachmentImageLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNull null], @"contents",
                                                   nil];
		[[self layer] addSublayer:attachmentImageLayer];
		
		userImageLayer					= [CALayer layer];
		userImageLayer.frame			= CGRectMake(0,0,60,60);
		userImageLayer.contentsScale	= [[UIScreen mainScreen] scale];
		userImageLayer.backgroundColor	= [UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor;
		userImageLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNull null], @"contents",
										   nil];
		[[self layer] addSublayer:userImageLayer];
		
		drawingLayer					= [DWTouchCellDrawingLayer layer];
		drawingLayer.touchCell			= self;
		drawingLayer.frame				= frame;
		drawingLayer.contentsScale		= [[UIScreen mainScreen] scale];
		drawingLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNull null], @"contents",
										   nil];
        [[self layer] addSublayer:drawingLayer];
		
		CALayer *chevronLayer			= [CALayer layer];
		chevronLayer.frame				= CGRectMake(307,31,6,11);
		chevronLayer.contentsScale		= [[UIScreen mainScreen] scale];
		chevronLayer.contents			= (id)[UIImage imageNamed:kImgChevron].CGImage;
		[[self layer] addSublayer:chevronLayer];
		
		CALayer *separatorLayer			= [CALayer layer];
		separatorLayer.frame			= CGRectMake(0,59,320,1);
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
	self.itemData		= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted    = NO;
    
    
    [CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kNoAnimationDuration]
					 forKey:kCATransactionAnimationDuration];		
	attachmentImageLayer.opacity    = kNormalAlpha;
	[CATransaction commit];

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
- (void)setUserImage:(UIImage *)userImage {
	userImageLayer.contents = (id)userImage.CGImage;
}

//----------------------------------------------------------------------------------------------------
- (void)setAttachmentImage:(UIImage *)attachmentImage {
    attachmentImageLayer.contents   = (id)attachmentImage.CGImage;
    attachmentImageLayer.opaque     = kNormalAlpha;
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
	attachmentImageLayer.opacity = kHighlightAlpha;
	[CATransaction commit];
}

//----------------------------------------------------------------------------------------------------
- (void)fadeCell {
	_highlighted = NO;
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kAnimationDuration]
					 forKey:kCATransactionAnimationDuration];		
	attachmentImageLayer.opacity = kNormalAlpha;
	[CATransaction commit];
}

@end
