//
//  DWItemFeedCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWItemFeedCell.h"
#import "DWVideoView.h"
#import "DWConstants.h"

#define kImgTouchIcon                       @"hand.png"
#define kImgTouchIcon230                    @"hand_230.png"
#define kImgTouched                         @"touched.png"
#define kImgPlay                            @"play.png"
#define kImgShare                           @"share.png"
#define kImgShare230                        @"share_230.png"
#define kImgHalo                            @"halo.png"
#define kImgSeparator                       @"hr_place_list.png"
#define kColorAttachmentBg                  [UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor
#define kColorNoAttachmentBg                [UIColor colorWithRed:0.3490 green:0.3490 blue:0.3490 alpha:1.0].CGColor
#define kColorNoAttachmentHighlightBg       [UIColor colorWithRed:0.5450 green:0.5450 blue:0.5450 alpha:1.0].CGColor
#define kFontItemUserName                   [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
#define kFontItemUserNameDisabled           [UIFont fontWithName:@"HelveticaNeue" size:15]
#define kFontAt                             [UIFont fontWithName:@"HelveticaNeue" size:15]
#define kFontItemPlaceName                  [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
#define kFontItemPlaceNameDisabled          [UIFont fontWithName:@"HelveticaNeue" size:15]
#define kFontItemData                       [UIFont fontWithName:@"HelveticaNeue" size:23]
#define kFontItemCreatedAt                  [UIFont fontWithName:@"HelveticaNeue" size:15]
#define kFontItemTouchesCount               [UIFont fontWithName:@"HelveticaNeue" size:15]
#define kItemUserNameX                      20
#define kItemUserNameY                      13
#define kUnderlineYOffset                   17
#define kUnderlineHeight                    0.75
#define kAtXOffset                          5
#define kAtWidth                            13
#define kPlaceNameXOffset                   5
#define kMaxPlaceNameWidth                  305
#define kItemDataX                          30
#define kItemDataXSubTitleOffset            10
#define kItemDataY                          40
#define kItemDataYOffset                    2
#define kItemDataYSubtitleOffset            55
#define kItemDataWidth                      270
#define kItemDataHeight                     240
#define kItemDataSubtitleHeightThreshold    56
#define kDetailsX                           20
#define kDetailsY                           285
#define kTouchesIconXOffset                 4
#define kTouchesIconY                       287
#define kTouchesIconWidth                   13
#define kDefaultTextHeight                  20
#define kNormalAlpha                        0.60
#define kHighlightAlpha                     1.0
#define kNoAttachmentAlpha                  1.0
#define kSelectionDelay                     0.45
#define kTouchInterval                      0.6
#define kAfterTouchFadeInerval              1.0
#define kNormalFadeInterval                 0.5
#define kNoAnimationDuration                0.0
#define kCellAnimationDuration              0.12



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItemFeedCellDrawingLayer

@synthesize itemCell;

//----------------------------------------------------------------------------------------------------
- (id<CAAction>)actionForKey:(NSString *)key {
	
	if([key isEqualToString:@"contents"] && (itemCell.userButtonPressed || itemCell.placeButtonPressed))
        return nil;
    
	return [super actionForKey:key];
}

//----------------------------------------------------------------------------------------------------
- (void)drawInContext:(CGContextRef)context {
	
	UIGraphicsPushContext(context);
    
    BOOL isTextOnly = [itemCell attachmentType] == kAttachmentNone;
    
    CGColorRef textColor = [UIColor colorWithRed:1.0
                                           green:1.0
                                            blue:1.0
                                           alpha:1.0].CGColor;
    
	
	if(![itemCell isHighlighted]) {
		
		//----------------------------------
        CGColorRef userColor = itemCell.userButtonPressed ? 
                                [UIColor colorWithRed:0.8 
                                                green:0.8 
                                                 blue:0.8
                                                alpha:1.0].CGColor : 
                                textColor;
        
		CGContextSetFillColorWithColor(context,userColor);
		
		[itemCell.itemUserName drawInRect:itemCell.userNameRect 
								 withFont:itemCell.userButtonDisabled ? kFontItemUserNameDisabled : kFontItemUserName];
		
        if(![itemCell userButtonDisabled])
            CGContextFillRect(context,CGRectMake(itemCell.userNameRect.origin.x,
                                                 itemCell.userNameRect.origin.y+kUnderlineYOffset,
                                                 itemCell.userNameRect.size.width,
                                                 kUnderlineHeight));
		
		
		//----------------------------------
		CGContextSetFillColorWithColor(context,textColor);
		
		[@"at" drawInRect:itemCell.atRect
				 withFont:kFontAt];
		
		
		//----------------------------------	
        CGColorRef placeColor = itemCell.placeButtonPressed ? 
                                [UIColor colorWithRed:0.8
                                                green:0.8
                                                 blue:0.8
                                                alpha:1.0].CGColor : 
                                textColor;
        
		CGContextSetFillColorWithColor(context,placeColor);
		
		
		[itemCell.itemPlaceName drawInRect:itemCell.placeNameRect
								  withFont:itemCell.placeButtonDisabled ? kFontItemPlaceNameDisabled : kFontItemPlaceName
							 lineBreakMode:UILineBreakModeTailTruncation];
		
        if(![itemCell placeButtonDisabled])
            CGContextFillRect(context,CGRectMake(itemCell.placeNameRect.origin.x,
                                                 itemCell.placeNameRect.origin.y+kUnderlineYOffset,
                                                 itemCell.placeNameRect.size.width,
                                                 kUnderlineHeight));
		

		
		//----------------------------------	
		CGContextSetFillColorWithColor(context,textColor);
        
		[itemCell.itemCreatedAt drawInRect:itemCell.createdAtRect 
                                  withFont:kFontItemCreatedAt];
	}
    
    
    //----------------------------------
    if(![itemCell isHighlighted] || isTextOnly) {
        
        CGColorRef dataColor = isTextOnly && ![itemCell isHighlighted] ? 
                                [UIColor colorWithRed:0.9019 green:0.9019 blue:0.9019 alpha:1.0].CGColor :
                                textColor;

        CGContextSetFillColorWithColor(context,dataColor);
        
        [itemCell.itemData drawInRect:itemCell.dataRect 
                             withFont:kFontItemData
                        lineBreakMode:UILineBreakModeWordWrap
                            alignment:UITextAlignmentLeft];
    }
    
    
    //----------------------------------
    if(![itemCell isHighlighted] || itemCell.isTouching) {
        CGContextSetFillColorWithColor(context,textColor);
        
        [itemCell.itemTouchesCountString drawInRect:itemCell.touchesCountRect
                                           withFont:kFontItemTouchesCount];
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
@synthesize isTouching              = _isTouching;
@synthesize placeButtonDisabled     = _placeButtonDisabled;
@synthesize userButtonDisabled      = _userButtonDisabled;
@synthesize itemData				= _itemData;
@synthesize itemPlaceName			= _itemPlaceName;
@synthesize itemUserName			= _itemUserName;
@synthesize itemCreatedAt			= _itemCreatedAt;
@synthesize itemDetails				= _itemDetails;
@synthesize itemTouchesCountString  = _itemTouchesCountString;
@synthesize highlightedAt			= _highlightedAt;
@synthesize userNameRect			= _userNameRect;
@synthesize atRect					= _atRect;
@synthesize placeNameRect			= _placeNameRect;
@synthesize dataRect				= _dataRect;
@synthesize touchesCountRect        = _touchesCountRect;
@synthesize createdAtRect           = _createdAtRect;
@synthesize delegate				= _delegate;
@synthesize attachmentType			= _attachmentType;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
				reuseIdentifier:reuseIdentifier];
    
	if (self) {
        
        self.clipsToBounds  = YES;
        
		CGRect frame = CGRectMake(0,0,320,320);
        
        
        UITapGestureRecognizer *singleTap   = [[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                       action:@selector(handleTapGesture:)] autorelease];
        singleTap.numberOfTapsRequired      = 1;
        singleTap.delegate                  = self;
        [self addGestureRecognizer:singleTap];
        
        
                                  
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
		touchIconImageLayer.frame			= CGRectMake(295,292,kTouchesIconWidth,15);
		touchIconImageLayer.contentsScale	= [[UIScreen mainScreen] scale];
		touchIconImageLayer.actions			= [NSMutableDictionary dictionaryWithObjectsAndKeys:
											   [NSNull null], @"onOrderIn",
											   [NSNull null], @"onOrderOut",
											   [NSNull null], @"sublayers",
											   [NSNull null], @"contents",
											   [NSNull null], @"bounds",
											   nil];
		[[self layer] addSublayer:touchIconImageLayer];
		
		
		
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
		
		[self addSubview:placeButton];
		
		
		
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
		
		[self addSubview:userButton];
		
		
		shareButton						= [[[UIButton alloc] init] autorelease];
		//shareButton.backgroundColor		= [UIColor greenColor];
		shareButton.frame				= CGRectMake(shareImageLayer.frame.origin.x - 7,
													 shareImageLayer.frame.origin.y - 6,
													 shareImageLayer.frame.size.width + 11,
													 shareImageLayer.frame.size.height + 11);
		
		[shareButton addTarget:self
					   action:@selector(didTouchUpOnShareButton:) 
			 forControlEvents:UIControlEventTouchUpInside];
		
        self.contentView.backgroundColor = [UIColor clearColor];
		[self addSubview:shareButton];
		
        
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
	self.itemData               = nil;
	self.itemPlaceName          = nil;
	self.itemUserName           = nil;
	self.itemCreatedAt          = nil;
	self.itemDetails            = nil;
	self.highlightedAt          = nil;
    self.itemTouchesCountString = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)resetItemNavigation {
    CGSize userNameSize			= [self.itemUserName sizeWithFont:_userButtonDisabled ? kFontItemUserNameDisabled : kFontItemUserName];
	
	_userNameRect				= CGRectMake(kItemUserNameX,
											 kItemUserNameY,
											 userNameSize.width,
											 userNameSize.height);
	
	
	_atRect						= CGRectMake(_userNameRect.origin.x + _userNameRect.size.width + kAtXOffset,
											 kItemUserNameY,
											 kAtWidth,
											 kDefaultTextHeight);
    
	
	
	CGSize placeNameSize		= [self.itemPlaceName sizeWithFont:_placeButtonDisabled ? kFontItemPlaceNameDisabled : kFontItemPlaceName
										   constrainedToSize:CGSizeMake(kMaxPlaceNameWidth-(_atRect.origin.x + _atRect.size.width),
																		kDefaultTextHeight)
											   lineBreakMode:UILineBreakModeTailTruncation];
	
	_placeNameRect				= CGRectMake(_atRect.origin.x + _atRect.size.width + kPlaceNameXOffset,
											 kItemUserNameY,
											 placeNameSize.width,
											 placeNameSize.height);

}

//----------------------------------------------------------------------------------------------------
- (void)resetItemDetailsPosition {
    
    self.itemTouchesCountString     = _itemTouchesCount ? [NSString stringWithFormat:@"%d",_itemTouchesCount] : @"";
    
    
    CGSize touchesCountSize         = [self.itemTouchesCountString sizeWithFont:kFontItemTouchesCount];
    
    _touchesCountRect               = CGRectMake(kDetailsX,
                                                 kDetailsY,
                                                 touchesCountSize.width,
                                                 touchesCountSize.height);
}

//----------------------------------------------------------------------------------------------------
- (void)resetTouchImageIconPosition {
    touchIconImageLayer.frame	= CGRectMake(_touchesCountRect.origin.x+_touchesCountRect.size.width+kTouchesIconXOffset,
											 kTouchesIconY,
											 touchIconImageLayer.frame.size.width, 
											 touchIconImageLayer.frame.size.height);
}

//----------------------------------------------------------------------------------------------------
- (void)resetCreatedAtPosition {
    CGSize createdAtSize            = [self.itemCreatedAt sizeWithFont:kFontItemCreatedAt];
    
    _createdAtRect                  = CGRectMake(touchIconImageLayer.frame.origin.x+touchIconImageLayer.frame.size.width,
                                                 kDetailsY,
                                                 createdAtSize.width,
                                                 createdAtSize.height);
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted				= NO;
    _isTouching                 = NO;
	_placeButtonPressed			= NO;
	_userButtonPressed			= NO;
    _placeButtonDisabled        = NO;
    _userButtonDisabled         = NO;
    
		
	[self resetItemNavigation];	
	
	
	CGSize dataSize				= [self.itemData sizeWithFont:kFontItemData
											constrainedToSize:CGSizeMake(kItemDataWidth,kItemDataHeight)
												lineBreakMode:UILineBreakModeWordWrap];
	
    if(dataSize.height <= kItemDataSubtitleHeightThreshold) {
        _dataRect                   = CGRectMake(kItemDataX-kItemDataXSubTitleOffset,
                                                 320 - kItemDataYSubtitleOffset - dataSize.height,
                                                 dataSize.width,
                                                 dataSize.height);
    }
    else {
        _dataRect					= CGRectMake(kItemDataX,
                                                 kItemDataY + (kItemDataHeight - dataSize.height) / 2 - kItemDataYOffset,
                                                 dataSize.width,
                                                 dataSize.height);
    }
	
	
	
	[self resetItemDetailsPosition];

	 
	
	userButton.frame			= CGRectMake(_userNameRect.origin.x-4,
											 _userNameRect.origin.y-5,
											 _userNameRect.size.width+7,
											 _userNameRect.size.height+7);
    userButton.enabled          = YES;
	
	placeButton.frame			= CGRectMake(_placeNameRect.origin.x-4,
											 _placeNameRect.origin.y-5,
											 _placeNameRect.size.width+7,
											 _placeNameRect.size.height+7);
    placeButton.enabled         = YES;
	
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kNoAnimationDuration]
					 forKey:kCATransactionAnimationDuration];

	itemImageLayer.opacity			= _attachmentType == kAttachmentNone ? kNoAttachmentAlpha : kNormalAlpha;	
	itemImageLayer.backgroundColor	= _attachmentType == kAttachmentNone ? kColorNoAttachmentBg : kColorAttachmentBg;
	//playImageLayer.hidden			= _attachmentType != kAttachmentVideo;
    
	
	shareImageLayer.hidden			= NO;
	shareImageLayer.contents		= (id)[UIImage imageNamed:_attachmentType == kAttachmentNone ? kImgShare230 : kImgShare].CGImage;
	
	touchIconImageLayer.hidden		= NO;
	touchIconImageLayer.contents	= (id)[UIImage imageNamed:_attachmentType == kAttachmentNone ? kImgTouchIcon230 : kImgTouchIcon].CGImage;
	
	[self resetTouchImageIconPosition];
    [self resetCreatedAtPosition];
    
	[CATransaction commit];
	
	[videoView stopPlayingVideo];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)shouldTouch {
    return [_delegate shouldTouchItemWithID:_itemID];
}

//----------------------------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted 
			  animated:(BOOL)animated {
	/*
	if(highlighted && !_highlighted) {
        _highlighted = YES;
        
        [self performSelector:@selector(testTouch)
                   withObject:nil 
                   afterDelay:kTouchInterval];
	}
	else if(!highlighted && _highlighted) {
            _highlighted = _isTouching;
    }
     */
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
- (void)setDetails:(NSInteger)touchesCount 
	  andCreatedAt:(NSString*)createdAt {
	
	_itemTouchesCount               = touchesCount;
	self.itemCreatedAt              = [NSString stringWithFormat:@"  |  %@",createdAt];
}

//----------------------------------------------------------------------------------------------------
- (void)setPlaceButtonAsDisabled {
    _placeButtonDisabled    = YES;
    placeButton.enabled     = NO;
    
    [self resetItemNavigation];
    
    [self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)setUserButtonAsDisabled {
    _userButtonDisabled     = YES;
    userButton.enabled      = NO;
    
    [self resetItemNavigation];
    
    [self redisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)redisplay {
	[drawingLayer setNeedsDisplay];
}

//----------------------------------------------------------------------------------------------------
- (void)touchCell {
	_itemTouchesCount++;
    _isTouching = YES;
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.5f] 
					 forKey:kCATransactionAnimationDuration];
	
    touchIconImageLayer.hidden = NO;
    [self resetItemDetailsPosition];
    [self resetTouchImageIconPosition];
    [self resetCreatedAtPosition];
    [self redisplay];
    	
	[CATransaction commit];
    
	[self performSelector:@selector(finishTouchCell) 
			   withObject:nil
			   afterDelay:1.0];
}

//----------------------------------------------------------------------------------------------------
- (void)finishTouchCell {
    _isTouching = NO;
    
   // if(_attachmentType != kAttachmentNone) {
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.5f] 
                         forKey:kCATransactionAnimationDuration];
        
        [self redisplay];
        touchIconImageLayer.hidden = _highlighted;
        
        [CATransaction commit];	
   // }
}

//----------------------------------------------------------------------------------------------------
- (void)highlightCell {	
    
    BOOL isTextOnly = _attachmentType == kAttachmentNone;
    
    if([self shouldTouch])
        _isTouching = YES;
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kCellAnimationDuration] 
					 forKey:kCATransactionAnimationDuration];
	
	touchIconImageLayer.hidden      = !_isTouching;
	itemImageLayer.opacity          = isTextOnly ? kNoAttachmentAlpha : kHighlightAlpha;
    itemImageLayer.backgroundColor  = isTextOnly ? kColorNoAttachmentHighlightBg : kColorAttachmentBg;
	
	//if(_attachmentType == kAttachmentVideo)
	//	playImageLayer.hidden	= YES;
	
	shareImageLayer.hidden		= YES;
	
	[self redisplay];

	[CATransaction commit];
    
    if(_attachmentType == kAttachmentVideo)
        [videoView startPlayingVideoAtURL:[_delegate getVideoAttachmentURLForItemID:_itemID]];
    
    if([self shouldTouch]) {
        [_delegate cellTouched:_itemID];
        [self touchCell];
    }
}

//----------------------------------------------------------------------------------------------------
- (void)fadeCell {
    
    BOOL isTextOnly             = _attachmentType == kAttachmentNone;
    _highlighted				= NO;
    
        	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kCellAnimationDuration] 
					 forKey:kCATransactionAnimationDuration];
	
	touchIconImageLayer.hidden      = NO;
	itemImageLayer.opacity          = kNormalAlpha;
    itemImageLayer.opacity          = isTextOnly ? kNoAttachmentAlpha : kNormalAlpha;
    itemImageLayer.backgroundColor  = isTextOnly ? kColorNoAttachmentBg : kColorAttachmentBg;
	
	//if(_attachmentType == kAttachmentVideo)
	//	playImageLayer.hidden	= NO;
	
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
    [self fadeCell];
}

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark UIGestureRecognizerDelegate

//----------------------------------------------------------------------------------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer 
       shouldReceiveTouch:(UITouch *)touch {
    
    return ![touch.view isKindOfClass:[UIButton class]];
}

//----------------------------------------------------------------------------------------------------
- (void)handleTapGesture:(UITapGestureRecognizer*)recognizer {    
    
    //CGPoint location             = [recognizer locationInView:self];
    
    _highlighted = !_highlighted;
    
    if(!_highlighted) {
        [videoView stopPlayingVideo];
        [self fadeCell];
    }
    else
        [self highlightCell];    
}

@end

