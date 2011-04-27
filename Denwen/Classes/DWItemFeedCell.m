//
//  DWItemFeedCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWItemFeedCell.h"
#import "DWVideoView.h"
#import "DWConstants.h"

#define kImgTouchIcon				@"hand.png"
#define kImgTouchIcon230			@"hand_230.png"
#define kImgTouched					@"touched.png"
#define kImgPlay					@"play.png"
#define kImgShare					@"share.png"
#define kImgShare230				@"share_230.png"
#define kImgSeparator				@"hr_place_list.png"
#define kColorAttachmentBg			[UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor
#define kColorNoAttachmentBg		[UIColor colorWithRed:0.3490 green:0.3490 blue: 0.3490 alpha:1.0].CGColor
#define kFontItemUserName			[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
#define kFontAt						[UIFont fontWithName:@"HelveticaNeue" size:15]
#define kFontItemPlaceName			[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
#define kFontItemData				[UIFont fontWithName:@"HelveticaNeue" size:23]
#define kFontItemCreatedAt			[UIFont fontWithName:@"HelveticaNeue" size:15]
#define kFontItemTouchesCount		[UIFont fontWithName:@"HelveticaNeue" size:15]
#define kItemUserNameX				20
#define kItemUserNameY				13
#define kUnderlineYOffset			17
#define kUnderlineHeight			0.75
#define kAtXOffset					5
#define kAtWidth					13
#define kPlaceNameXOffset			5
#define kMaxPlaceNameWidth			305
#define kItemDataX					30
#define kItemDataY					40
#define kItemDataYOffset			2
#define kItemDataWidth				270
#define kItemDataHeight				240
#define kDetailsX					20
#define kDetailsY					285
#define kTouchesIconXOffset			4
#define kTouchesIconY				287
#define kDefaultTextHeight			20
#define kNormalAlpha				0.60
#define kHighlightAlpha				1.0
#define kNoAttachmentAlpha			1.0
#define kSelectionDelay				0.45
#define kTouchInterval				0.6
#define kAfterTouchFadeInerval		1.0
#define kNormalFadeInterval			0.5
#define kNoAnimationDuration		0.0
#define kCellAnimationDuration		0.65


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
		
		
		CGColorRef textColor = itemCell.attachmentType == kAttachmentNone ? 
								[UIColor colorWithRed:0.9019 green:0.9019 blue:0.9019 alpha:1.0].CGColor :
								[UIColor whiteColor].CGColor;
		//----------------------------------
		CGContextSetFillColorWithColor(context,textColor);
		
		[itemCell.itemUserName drawInRect:itemCell.userNameRect 
								 withFont:kFontItemUserName];
		
		CGContextFillRect(context,CGRectMake(itemCell.userNameRect.origin.x,
											 itemCell.userNameRect.origin.y+kUnderlineYOffset,
											 itemCell.userNameRect.size.width,
											 kUnderlineHeight));
		
		
		//----------------------------------
		CGContextSetFillColorWithColor(context,textColor);
		
		[@"at" drawInRect:itemCell.atRect
				 withFont:kFontAt];
		
		
		//----------------------------------	
		CGContextSetFillColorWithColor(context,textColor);
		
		
		[itemCell.itemPlaceName drawInRect:itemCell.placeNameRect
								  withFont:kFontItemPlaceName
							 lineBreakMode:UILineBreakModeTailTruncation];
		
		CGContextFillRect(context,CGRectMake(itemCell.placeNameRect.origin.x,
											 itemCell.placeNameRect.origin.y+kUnderlineYOffset,
											 itemCell.placeNameRect.size.width,
											 kUnderlineHeight));
		
		
		//----------------------------------	
		CGContextSetFillColorWithColor(context,textColor);
		
		
		[itemCell.itemData drawInRect:itemCell.dataRect 
							   withFont:kFontItemData
						  lineBreakMode:UILineBreakModeWordWrap
							  alignment:UITextAlignmentLeft];

		
		//----------------------------------	
		CGContextSetFillColorWithColor(context,textColor);
		
		[itemCell.itemDetails drawInRect:itemCell.detailsRect 
								withFont:kFontItemCreatedAt];
	}

	
	UIGraphicsPopContext();
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedCell

@synthesize itemID					= _itemID;
@synthesize placeButtonPressed		= _placeButtonPressed;
@synthesize userButtonPressed		= _userButtonPressed;
@synthesize itemData				= _itemData;
@synthesize itemPlaceName			= _itemPlaceName;
@synthesize itemUserName			= _itemUserName;
@synthesize itemCreatedAt			= _itemCreatedAt;
@synthesize itemDetails				= _itemDetails;
@synthesize highlightedAt			= _highlightedAt;
@synthesize userNameRect			= _userNameRect;
@synthesize atRect					= _atRect;
@synthesize placeNameRect			= _placeNameRect;
@synthesize dataRect				= _dataRect;
@synthesize detailsRect				= _detailsRect;
@synthesize delegate				= _delegate;
@synthesize attachmentType			= _attachmentType;

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
		itemImageLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNull null], @"onOrderIn",
										   [NSNull null], @"onOrderOut",
										   [NSNull null], @"sublayers",
										   [NSNull null], @"contents",
										   nil];
		[[self layer] addSublayer:itemImageLayer];
		
		touchIconImageLayer					= [CALayer layer];
		touchIconImageLayer.frame			= CGRectMake(295,292,13,15);
		touchIconImageLayer.contentsScale	= [[UIScreen mainScreen] scale];
		touchIconImageLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
											   [NSNull null], @"onOrderIn",
											   [NSNull null], @"onOrderOut",
											   [NSNull null], @"sublayers",
											   [NSNull null], @"contents",
											   [NSNull null], @"bounds",
											   nil];
		[[self layer] addSublayer:touchIconImageLayer];
		
		
		touchedImageLayer				= [CALayer layer];
		touchedImageLayer.frame			= CGRectMake(127,127,65,65);
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
		playImageLayer.contents			= (id)[UIImage imageNamed:kImgPlay].CGImage;
		playImageLayer.hidden			= YES;
		playImageLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   [NSNull null], @"onOrderIn",
										   [NSNull null], @"onOrderOut",
										   [NSNull null], @"sublayers",
										   [NSNull null], @"contents",
										   [NSNull null], @"bounds",
										   nil];
		[[self layer] addSublayer:playImageLayer];
		
		shareImageLayer						= [CALayer layer];
		shareImageLayer.frame				= CGRectMake(280,281,24,19);
		shareImageLayer.contentsScale		= [[UIScreen mainScreen] scale];
		shareImageLayer.actions				= [NSMutableDictionary dictionaryWithObjectsAndKeys:
											   [NSNull null], @"contents",
											   nil];
		[[self layer] addSublayer:shareImageLayer];
		
		
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
		
		
		CALayer *separatorLayer			= [CALayer layer];
		separatorLayer.frame			= CGRectMake(0,319,320,1);
		separatorLayer.contentsScale	= [[UIScreen mainScreen] scale];
		separatorLayer.contents			= (id)[UIImage imageNamed:kImgSeparator].CGImage;
		[[self layer] addSublayer:separatorLayer];
		
		
		
		
		placeButton						= [[[UIButton alloc] init] autorelease];
        //placeButton.backgroundColor		= [UIColor greenColor];
		
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
		//userButton.backgroundColor		= [UIColor greenColor];
		
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
		
		
		shareButton						= [[[UIButton alloc] init] autorelease];
		//shareButton.backgroundColor		= [UIColor greenColor];
		shareButton.frame				= CGRectMake(shareImageLayer.frame.origin.x - 7,
													 shareImageLayer.frame.origin.y - 6,
													 shareImageLayer.frame.size.width + 11,
													 shareImageLayer.frame.size.height + 11);
		
		[shareButton addTarget:self
					   action:@selector(didTouchUpOnShareButton:) 
			 forControlEvents:UIControlEventTouchUpInside];
		
		[self.contentView addSubview:shareButton];
		
        
        videoView           = [[[DWVideoView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)] autorelease];
        videoView.delegate  = self;
        [self addSubview:videoView];
										   
		
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
	self.itemDetails		= nil;
	self.highlightedAt		= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)resetItemDetailsPosition {
    CGSize detailsSize			= [self.itemDetails sizeWithFont:kFontItemCreatedAt];
	
	_detailsRect				= CGRectMake(kDetailsX,
											 kDetailsY,
											 detailsSize.width,
											 detailsSize.height);
}

//----------------------------------------------------------------------------------------------------
- (void)resetTouchImageIconPosition {
    touchIconImageLayer.frame	= CGRectMake(_detailsRect.origin.x+_detailsRect.size.width+kTouchesIconXOffset,
											 kTouchesIconY,
											 touchIconImageLayer.frame.size.width, 
											 touchIconImageLayer.frame.size.height);
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted				= NO;
    _isTouching                 = NO;
	_placeButtonPressed			= NO;
	_userButtonPressed			= NO;
	
	
	CGSize userNameSize			= [self.itemUserName sizeWithFont:kFontItemUserName];
	
	_userNameRect				= CGRectMake(kItemUserNameX,
											 kItemUserNameY,
											 userNameSize.width,
											 userNameSize.height);
	
	
	_atRect						= CGRectMake(_userNameRect.origin.x + _userNameRect.size.width + kAtXOffset,
											 kItemUserNameY,
											 kAtWidth,
											 kDefaultTextHeight);

	
	
	CGSize placeNameSize		= [self.itemPlaceName sizeWithFont:kFontItemPlaceName
										   constrainedToSize:CGSizeMake(kMaxPlaceNameWidth-(_atRect.origin.x + _atRect.size.width),
																		kDefaultTextHeight)
											   lineBreakMode:UILineBreakModeTailTruncation];
	
	_placeNameRect				= CGRectMake(_atRect.origin.x + _atRect.size.width + kPlaceNameXOffset,
											 kItemUserNameY,
											 placeNameSize.width,
											 placeNameSize.height);
		
	
	
	
	CGSize dataSize				= [self.itemData sizeWithFont:kFontItemData
											constrainedToSize:CGSizeMake(kItemDataWidth,kItemDataHeight)
												lineBreakMode:UILineBreakModeWordWrap];
	

	_dataRect					= CGRectMake(kItemDataX,
											 kItemDataY + (kItemDataHeight - dataSize.height) / 2 - kItemDataYOffset,
											 dataSize.width,
											 dataSize.height);
	
	
	
	[self resetItemDetailsPosition];

	 
	
	userButton.frame			= CGRectMake(_userNameRect.origin.x-4,
											 _userNameRect.origin.y-5,
											 _userNameRect.size.width+7,
											 _userNameRect.size.height+7);
	
	placeButton.frame			= CGRectMake(_placeNameRect.origin.x-4,
											 _placeNameRect.origin.y-5,
											 _placeNameRect.size.width+7,
											 _placeNameRect.size.height+7);
	
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kNoAnimationDuration]
					 forKey:kCATransactionAnimationDuration];

	itemImageLayer.opacity			= _attachmentType == kAttachmentNone ? kNoAttachmentAlpha : kNormalAlpha;	
	itemImageLayer.backgroundColor	= _attachmentType == kAttachmentNone ? kColorNoAttachmentBg : kColorAttachmentBg;
	playImageLayer.hidden			= _attachmentType != kAttachmentVideo;
	touchedImageLayer.hidden		= YES;
	
	shareImageLayer.hidden			= NO;
	shareImageLayer.contents		= (id)[UIImage imageNamed:_attachmentType == kAttachmentNone ? kImgShare230 : kImgShare].CGImage;
	
	touchIconImageLayer.hidden		= NO;
	touchIconImageLayer.contents	= (id)[UIImage imageNamed:_attachmentType == kAttachmentNone ? kImgTouchIcon230 : kImgTouchIcon].CGImage;
	
	[self resetTouchImageIconPosition];
    
	[CATransaction commit];
	
	[videoView stopPlayingVideo];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)shouldTouch {
    return [_delegate shouldTouchItemWithID:_itemID];
}

//----------------------------------------------------------------------------------------------------
- (void)testTouch {
    if(_highlighted) {
        _isTouching = YES;
        [self highlightCell];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)conditionalFadeWithDuration:(CGFloat)duration  {
    if([self shouldTouch]) {
        [self performSelector:@selector(touchCell) 
                   withObject:nil
                   afterDelay:duration];
    }
    else    {
        [self performSelector:@selector(fadeCell) 
                   withObject:nil
                   afterDelay:duration];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted 
			  animated:(BOOL)animated {
	
	if(highlighted && !_highlighted) {
        _highlighted = YES;
        
        [self performSelector:@selector(testTouch)
                   withObject:nil 
                   afterDelay:kTouchInterval];
	}
	else if(!highlighted && _highlighted) {
            _highlighted = _isTouching;
    }
}

//----------------------------------------------------------------------------------------------------
- (BOOL)isHighlighted {
    return _highlighted;
}

//----------------------------------------------------------------------------------------------------
- (void)createItemDetails {
	if(_itemTouchesCount)
		self.itemDetails = [NSString stringWithFormat:@"%@  |  %d",self.itemCreatedAt,_itemTouchesCount];
	else
		self.itemDetails = [NSString stringWithFormat:@"%@  |  ",self.itemCreatedAt];
}

//----------------------------------------------------------------------------------------------------
- (void)setItemImage:(UIImage*)itemImage {
	itemImageLayer.contents = (id)itemImage.CGImage;
}

//----------------------------------------------------------------------------------------------------
- (void)setDetails:(NSInteger)touchesCount 
	  andCreatedAt:(NSString*)createdAt {
	
	_itemTouchesCount	= touchesCount;
	self.itemCreatedAt	= createdAt;
	
	[self createItemDetails];
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[drawingLayer setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)touchCell {
	_itemTouchesCount++;
	[self createItemDetails];
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.5f] 
					 forKey:kCATransactionAnimationDuration];
	
    [self resetItemDetailsPosition];
    [self resetTouchImageIconPosition];
    
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
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kCellAnimationDuration] 
					 forKey:kCATransactionAnimationDuration];
	
	touchIconImageLayer.hidden	= YES;
	itemImageLayer.opacity		= kHighlightAlpha;
	
	if(_attachmentType == kAttachmentVideo)
		playImageLayer.hidden	= YES;
	
	shareImageLayer.hidden		= YES;
	
	[self redisplay];

	[CATransaction commit];
    
    if(_attachmentType == kAttachmentVideo)
        [videoView startPlayingVideoAtURL:[_delegate getVideoAttachmentURLForItemID:_itemID]];
    else
        [self conditionalFadeWithDuration:2.0];
}

//----------------------------------------------------------------------------------------------------
- (void)fadeCell {
    
    _highlighted				= NO;
    _isTouching                 = NO;
    
        	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kCellAnimationDuration] 
					 forKey:kCATransactionAnimationDuration];
	
	touchIconImageLayer.hidden	= NO;
	itemImageLayer.opacity		= kNormalAlpha;
	touchedImageLayer.hidden	= YES;
	
	if(_attachmentType == kAttachmentVideo)
		playImageLayer.hidden	= NO;
	
	shareImageLayer.hidden		= NO;
	
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

//----------------------------------------------------------------------------------------------------
- (void)didTouchUpOnShareButton:(UIButton*)button {
	[_delegate shareSelectedForItemID:_itemID];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark DWVideoViewDelegate

//----------------------------------------------------------------------------------------------------
- (void)playbackFinished {
    if(_isTouching)
        [self conditionalFadeWithDuration:0.0];
}

@end

