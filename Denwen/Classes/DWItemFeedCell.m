//
//  DWItemFeedCell.m
//  Denwen
//
//  Created by Deepak Rao on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWItemFeedCell.h"

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
		[[self layer] addSublayer:itemImageLayer];
		
		drawingLayer					= [DWItemFeedCellDrawingLayer layer];
		drawingLayer.itemCell			= self;
		drawingLayer.frame				= frame;
		drawingLayer.contentsScale		= [[UIScreen mainScreen] scale];
        [[self layer] addSublayer:drawingLayer];
		
		
		placeButton						= [[[UIButton alloc] init] autorelease];
		placeButton.backgroundColor		= [UIColor greenColor];
		
		[placeButton addTarget:self
						action:@selector(didTouchDownOnPlaceButton:) 
				forControlEvents:UIControlEventTouchDown];
		
		[placeButton addTarget:self
						action:@selector(didTouchUpOnPlaceButton:) 
			  forControlEvents:UIControlEventTouchUpInside];
		
		[self.contentView addSubview:placeButton];
		
		
		
		userButton						= [[[UIButton alloc] init] autorelease];
		userButton.backgroundColor		= [UIColor greenColor];
		
		[userButton addTarget:self
					   action:@selector(didTouchDownOnUserButton:)				
			 forControlEvents:UIControlEventTouchDown];
		
		[userButton addTarget:self
					   action:@selector(didTouchUpOnUserButton:) 
			 forControlEvents:UIControlEventTouchUpInside];
		
		[self.contentView addSubview:userButton];
		
										   
		
		self.selectionStyle				= UITableViewCellSelectionStyleNone;
		self.accessoryType				= UITableViewCellAccessoryNone;
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {	
	self.itemData		= nil;
	self.itemPlaceName	= nil;
	self.itemUserName	= nil;
	self.itemCreatedAt	= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted = NO;
	
	_itemPlaceNameSize		= [self.itemPlaceName sizeWithFont:kFontItemPlaceName];
	
	_itemDataSize			= [self.itemData sizeWithFont:kFontItemData
										constrainedToSize:CGSizeMake(kItemDataWidth,kItemDataHeight)
											lineBreakMode:UILineBreakModeWordWrap];
	
	_itemUserNameSize		= [self.itemUserName sizeWithFont:kFontItemUserName];
	
	_itemCreatedAtSize		= [self.itemCreatedAt sizeWithFont:kFontItemCreatedAt];
	
	placeButton.frame		= CGRectMake(7,kItemPlaceNameY,_itemPlaceNameSize.width + 25,20);
	
	userButton.frame		= CGRectMake(7,kItemDataY+_itemDataSize.height,_itemCreatedAtSize.width + _itemUserNameSize.width + 5,20);
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted 
			  animated:(BOOL)animated {
	
	if(_highlighted != highlighted) {
		_highlighted = highlighted;
		itemImageLayer.opacity = _highlighted ? kHighlightAlpha : kNormalAlpha;
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


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIControlEventTouch

//----------------------------------------------------------------------------------------------------
- (void)didTouchDownOnPlaceButton:(UIButton*)button {
	_placeButtonPressed = YES;
	[self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchUpOnPlaceButton:(UIButton*)button {
	_placeButtonPressed = NO;
	[self redisplay];
	
	[_delegate placeSelectedForItemID:_itemID];
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchDownOnUserButton:(UIButton*)button {
	_userButtonPressed = YES;
	[self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchUpOnUserButton:(UIButton*)button {
	_userButtonPressed = NO;
	[self redisplay];
	
	[_delegate userSelectedForItemID:_itemID];
}

@end

