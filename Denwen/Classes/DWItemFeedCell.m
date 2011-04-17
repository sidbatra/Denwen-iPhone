//
//  DWItemFeedCell.m
//  Denwen
//
//  Created by Deepak Rao on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWItemFeedCell.h"

#define kImgTouchIcon			@"chevron.png"
#define kImgTouched				@"chevron.png"
#define kImgPlay				@"play.png"
#define kFontItemPlaceName		[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
#define kFontItemData			[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]
#define kFontItemUserName		[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
#define kFontItemCreatedAt		[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
#define kItemDataWidth			293
#define kItemDataHeight			70
#define kItemDataY				124
#define kItemPlaceNameY			104
#define kNormalAlpha			0.45
#define kHighlightAlpha			1.0
#define kSelectionDelay			0.45
#define kTouchInterval			0.6
#define kAfterTouchFadeInerval	1.0
#define kNormalFadeInterval		0.5
#define kNoAnimationDuration	0.0
#define kCellAnimationDuration	0.65


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedCellDrawingLayer

@synthesize itemCell;
@synthesize disableAnimation = _disableAnimation;

//----------------------------------------------------------------------------------------------------
- (id<CAAction>)actionForKey:(NSString *)key {
	
	//if([key isEqualToString:@"contents"] && _disableAnimation)
	//	return (id)[NSNull null];		
		
	return [super actionForKey:key];
}

//----------------------------------------------------------------------------------------------------
- (void)drawInContext:(CGContextRef)context {
	
	UIGraphicsPushContext(context);
	
	if(![itemCell isHighlighted]) {
		
		CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
		CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
		
		if(itemCell.placeButtonPressed) {
			CGContextSetFillColorWithColor(context,[UIColor grayColor].CGColor);
			CGContextSetShadowWithColor(context,CGSizeMake(0.0f,1.0f),0.0f,[UIColor whiteColor].CGColor);
		}
		
		[@"at" drawInRect:CGRectMake(7,104,20,10) 
				 withFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
		
		[itemCell.itemPlaceName	drawInRect:CGRectMake(24,kItemPlaceNameY,293,20) 
								  withFont:kFontItemPlaceName];
		
		
		CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
		CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
		
		[itemCell.itemData drawInRect:CGRectMake(7,
												 kItemDataY,
												 kItemDataWidth,
												 kItemDataHeight) 
							   withFont:kFontItemData
						  lineBreakMode:UILineBreakModeWordWrap
							  alignment:UITextAlignmentLeft];
		
		if(itemCell.userButtonPressed) {
			CGContextSetFillColorWithColor(context,[UIColor grayColor].CGColor);
			CGContextSetShadowWithColor(context,CGSizeMake(0.0f,1.0f),0.0f,[UIColor whiteColor].CGColor);
		}
		
		[itemCell.itemUserName drawInRect:CGRectMake(7,
													 kItemDataY+itemCell.itemDataSize.height,
													 self.itemCell.itemUserNameSize.width,
													 20) 
								 withFont:kFontItemUserName];
		
		[itemCell.itemCreatedAt drawInRect:CGRectMake(7+itemCell.itemUserNameSize.width+5,
													  kItemDataY+itemCell.itemDataSize.height,100,20) 
								  withFont:kFontItemCreatedAt];
		
		
		CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
		CGContextSetShadowWithColor(context,CGSizeMake(0.0f,-1.0f),0.0f,[UIColor blackColor].CGColor);
		
		[itemCell.itemTouchesCount drawInRect:CGRectMake(180,320-30,100,20)
									 withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
								lineBreakMode:UILineBreakModeTailTruncation
									alignment:UITextAlignmentRight];
	}

	
	UIGraphicsPopContext();
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedCell

@synthesize itemID				= _itemID;
@synthesize placeButtonPressed	= _placeButtonPressed;
@synthesize userButtonPressed	= _userButtonPressed;
@synthesize itemData			= _itemData;
@synthesize itemPlaceName		= _itemPlaceName;
@synthesize itemUserName		= _itemUserName;
@synthesize itemCreatedAt		= _itemCreatedAt;
@synthesize highlightedAt		= _highlightedAt;
@synthesize itemTouchesCount	= _itemTouchesCount;
@synthesize itemDataSize		= _itemDataSize;
@synthesize itemUserNameSize	= _itemUserNameSize;
@synthesize itemPlaceNameSize	= _itemPlaceNameSize;
@synthesize itemCreatedAtSize	= _itemCreatedAtSize;
@synthesize delegate			= _delegate;

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
		itemImageLayer.opacity			= kNormalAlpha;
		itemImageLayer.backgroundColor	= [UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor;
		itemImageLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNull null], @"onOrderIn",
										   [NSNull null], @"onOrderOut",
										   [NSNull null], @"sublayers",
										   [NSNull null], @"contents",
										   nil];
		[[self layer] addSublayer:itemImageLayer];
		
		touchIconImageLayer					= [CALayer layer];
		touchIconImageLayer.frame			= CGRectMake(320-9,320-14,9,14);
		touchIconImageLayer.contentsScale	= [[UIScreen mainScreen] scale];
		touchIconImageLayer.contents		= (id)[UIImage imageNamed:kImgTouchIcon].CGImage;
		touchIconImageLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
											   [NSNull null], @"onOrderIn",
											   [NSNull null], @"onOrderOut",
											   [NSNull null], @"sublayers",
											   [NSNull null], @"contents",
											   [NSNull null], @"bounds",
											   nil];
		[[self layer] addSublayer:touchIconImageLayer];
		
		
		touchedImageLayer				= [CALayer layer];
		touchedImageLayer.frame			= CGRectMake(160-9,20,9,14);
		touchedImageLayer.contentsScale	= [[UIScreen mainScreen] scale];
		touchedImageLayer.contents		= (id)[UIImage imageNamed:kImgTouched].CGImage;
		touchedImageLayer.hidden		= YES;
		touchedImageLayer.actions		= [NSMutableDictionary dictionaryWithObjectsAndKeys:
											[NSNull null], @"onOrderIn",
											[NSNull null], @"onOrderOut",
											[NSNull null], @"sublayers",
											[NSNull null], @"contents",
											[NSNull null], @"bounds",
											nil];
		[[self layer] addSublayer:touchedImageLayer];
		
		
		playImageLayer					= [CALayer layer];
		playImageLayer.frame			= CGRectMake(7,320-20,20,20);
		playImageLayer.contentsScale	= [[UIScreen mainScreen] scale];
		playImageLayer.contents		= (id)[UIImage imageNamed:kImgPlay].CGImage;
		playImageLayer.hidden		= YES;
		playImageLayer.actions		= [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNull null], @"onOrderIn",
										   [NSNull null], @"onOrderOut",
										   [NSNull null], @"sublayers",
										   [NSNull null], @"contents",
										   [NSNull null], @"bounds",
										   nil];
		[[self layer] addSublayer:playImageLayer];
		
		
		
		drawingLayer					= [DWItemFeedCellDrawingLayer layer];
		drawingLayer.disableAnimation	= YES;
		drawingLayer.itemCell			= self;
		drawingLayer.frame				= frame;
		drawingLayer.contentsScale		= [[UIScreen mainScreen] scale];
		drawingLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
											[NSNull null], @"onOrderIn",
											[NSNull null], @"onOrderOut",
											[NSNull null], @"sublayers",
											[NSNull null], @"bounds",
											nil];
		[[self layer] addSublayer:drawingLayer];
		
		
		placeButton						= [[[UIButton alloc] init] autorelease];
		placeButton.backgroundColor		= [UIColor greenColor];
		
		[placeButton addTarget:self
						action:@selector(didTouchDownOnPlaceButton:) 
				forControlEvents:UIControlEventTouchDown];
		
		[placeButton addTarget:self
						action:@selector(didTouchUpOnPlaceButton:) 
			  forControlEvents:UIControlEventTouchUpInside];
		
		[placeButton addTarget:self
						action:@selector(didDragOutsidePlaceButton:) 
			  forControlEvents:UIControlEventTouchDragOutside];
		
		[placeButton addTarget:self
						action:@selector(didDragInsidePlaceButton:) 
			  forControlEvents:UIControlEventTouchDragInside];
		
		[self.contentView addSubview:placeButton];
		
		
		
		userButton						= [[[UIButton alloc] init] autorelease];
		userButton.backgroundColor		= [UIColor greenColor];
		
		[userButton addTarget:self
					   action:@selector(didTouchDownOnUserButton:)				
			 forControlEvents:UIControlEventTouchDown];
		
		[userButton addTarget:self
					   action:@selector(didTouchUpOnUserButton:) 
			 forControlEvents:UIControlEventTouchUpInside];
		
		[userButton addTarget:self
					   action:@selector(didDragOutsideUserButton:) 
			 forControlEvents:UIControlEventTouchDragOutside];
		
		[userButton addTarget:self
					   action:@selector(didDragInsideUserButton:) 
			 forControlEvents:UIControlEventTouchDragInside];
		
		[self.contentView addSubview:userButton];
		
										   
		
		self.selectionStyle				= UITableViewCellSelectionStyleNone;
		self.accessoryType				= UITableViewCellAccessoryNone;
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	self.itemData			= nil;
	self.itemPlaceName		= nil;
	self.itemUserName		= nil;
	self.itemCreatedAt		= nil;
	self.itemTouchesCount	= nil;
	self.highlightedAt		= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted				= NO;
	_placeButtonPressed			= NO;
	_userButtonPressed			= NO;
	_isVideoAttachment			= NO;
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kNoAnimationDuration]
					 forKey:kCATransactionAnimationDuration];
	
	itemImageLayer.opacity		= kNormalAlpha;
	touchedImageLayer.hidden	= YES;
	playImageLayer.hidden		= YES;
	[CATransaction commit];
	
	_itemPlaceNameSize			= [self.itemPlaceName sizeWithFont:kFontItemPlaceName];
	
	_itemDataSize				= [self.itemData sizeWithFont:kFontItemData
											constrainedToSize:CGSizeMake(kItemDataWidth,kItemDataHeight)
												lineBreakMode:UILineBreakModeWordWrap];
	
	_itemUserNameSize			= [self.itemUserName sizeWithFont:kFontItemUserName];
	
	_itemCreatedAtSize			= [self.itemCreatedAt sizeWithFont:kFontItemCreatedAt];
	
	placeButton.frame			= CGRectMake(7,kItemPlaceNameY,_itemPlaceNameSize.width + 25,20);
	
	userButton.frame			= CGRectMake(7,kItemDataY+_itemDataSize.height,_itemCreatedAtSize.width + _itemUserNameSize.width + 5,20);
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted 
			  animated:(BOOL)animated {
	
	if(highlighted && !_highlighted) {
		[self highlightCell];
	}
	else if(!highlighted && _highlighted) {
		
		if(fabs([self.highlightedAt timeIntervalSinceNow]) > kTouchInterval) {
			[self touchCell];
		}
		else {
			[self performSelector:@selector(fadeCell)
					   withObject:nil 
					   afterDelay:kNormalFadeInterval];
		}
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

//----------------------------------------------------------------------------------------------------
- (void)touchCell {
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.5f] 
					 forKey:kCATransactionAnimationDuration];
	
	touchedImageLayer.hidden = NO;
	
	[CATransaction commit];
	
	[self performSelector:@selector(finishTouchCell) 
			   withObject:nil
			   afterDelay:1.0];
}

//----------------------------------------------------------------------------------------------------
- (void)finishTouchCell {
	[self fadeCell];
	[_delegate cellTouched:_itemID];
}

//----------------------------------------------------------------------------------------------------
- (void)highlightCell {
	_highlighted				= YES;
	self.highlightedAt			= [NSDate dateWithTimeIntervalSinceNow:0];
	
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kCellAnimationDuration] 
					 forKey:kCATransactionAnimationDuration];
	
	touchIconImageLayer.hidden	= YES;
	itemImageLayer.opacity		= kHighlightAlpha;
	
	if(_isVideoAttachment)
		playImageLayer.hidden	= YES;
	
	[self redisplay];

	[CATransaction commit];
}

//----------------------------------------------------------------------------------------------------
- (void)fadeCell {
	_highlighted				= NO;
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kCellAnimationDuration] 
					 forKey:kCATransactionAnimationDuration];
	
	touchIconImageLayer.hidden	= NO;
	itemImageLayer.opacity		= kNormalAlpha;
	touchedImageLayer.hidden	= YES;
	
	if(_isVideoAttachment)
		playImageLayer.hidden	= NO;
	
	[self redisplay];
	
	[CATransaction commit];
}

//----------------------------------------------------------------------------------------------------
- (void)highlightPlaceButton {
	_placeButtonPressed = YES;
	[self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)fadePlaceButton {
	_placeButtonPressed = NO;
	[self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)fadeUserButton {
	_userButtonPressed = NO;
	[self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)highlightUserButton {
	_userButtonPressed = YES;
	[self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)setAsVideoAttachment {
	playImageLayer.hidden	= NO;
	_isVideoAttachment		= YES;
}



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIControlEventTouches

//----------------------------------------------------------------------------------------------------
- (void)didTouchDownOnPlaceButton:(UIButton*)button {
	[self highlightPlaceButton];
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchUpOnPlaceButton:(UIButton*)button {
	
	[self performSelector:@selector(fadePlaceButton) 
			   withObject:nil
			   afterDelay:kSelectionDelay];
	
	[_delegate placeSelectedForItemID:_itemID];
}

//----------------------------------------------------------------------------------------------------
- (void)didDragOutsidePlaceButton:(UIButton*)button {
	[self fadePlaceButton];
}

//----------------------------------------------------------------------------------------------------
- (void)didDragInsidePlaceButton:(UIButton*)button {
	[self highlightPlaceButton];
}


//----------------------------------------------------------------------------------------------------
- (void)didTouchDownOnUserButton:(UIButton*)button {
	[self highlightUserButton];
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchUpOnUserButton:(UIButton*)button {

	[self performSelector:@selector(fadeUserButton) 
			   withObject:nil
			   afterDelay:kSelectionDelay];
	
	[_delegate userSelectedForItemID:_itemID];
}

//----------------------------------------------------------------------------------------------------
- (void)didDragOutsideUserButton:(UIButton*)button {
	[self fadeUserButton];
}

//----------------------------------------------------------------------------------------------------
- (void)didDragInsideUserButton:(UIButton*)button {
	[self highlightUserButton];
}

@end

