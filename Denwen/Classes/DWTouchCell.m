//
//  DWTouchCell.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTouchCell.h"
#import "DWConstants.h"

static NSString* const kImgSeparator	= @"hr_place_list.png";
static NSString* const kImgChevron		= @"chevron.png";

#define kAnimationDuration          0.05
#define kNoAnimationDuration		0.0
#define kFadeDelay                  0.3
#define kNormalAlpha                0.3
#define kNoAttachmentAlpha          1.0
#define kHighlightAlpha             0.2
#define kNoAttachmentHighlightAlpha 0.9           
#define kColorNormalBg              [UIColor colorWithRed:0.2627 green:0.2627 blue:0.2627 alpha:1.0].CGColor
#define kColorNoAttachmentBg        [UIColor colorWithRed:0.3490 green:0.3490 blue:0.3490 alpha:1.0].CGColor
#define kColorTextNormal            [UIColor whiteColor].CGColor
#define kColorTextNoAttachment      [UIColor colorWithRed:0.9019 green:0.9019 blue:0.9019 alpha:1.0].CGColor
#define kFontUserName               [UIFont fontWithName:@"HelveticaNeue-Bold" size:13]
#define kFontItemData               [UIFont fontWithName:@"HelveticaNeue" size:13]
#define kFontPlaceName              [UIFont fontWithName:@"HelveticaNeue" size:13]
#define kUserNameX                  74
#define kTopLineY                   11
#define kPlaceNameX                 74
#define kBottomLineY                29.5



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTouchCellDrawingLayer

@synthesize touchCell;

//----------------------------------------------------------------------------------------------------
- (void)drawInContext:(CGContextRef)context {
	
	UIGraphicsPushContext(context);
	
	
	CGContextSetFillColorWithColor(context,touchCell.hasAttachment ? kColorTextNormal : kColorTextNoAttachment);
    
    [touchCell.userName drawInRect:touchCell.userRect
                          withFont:kFontUserName];
    
    [touchCell.itemData drawInRect:touchCell.dataRect 
                          withFont:kFontItemData
                     lineBreakMode:UILineBreakModeTailTruncation];
    
    if(touchCell.hasQuote) {
        [@"\"" drawInRect:touchCell.quoteRect
                 withFont:kFontItemData];
    }
  
    [touchCell.placeData drawInRect:touchCell.placeRect
                           withFont:kFontPlaceName
                      lineBreakMode:UILineBreakModeTailTruncation];
	
	UIGraphicsPopContext();
}

@end



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTouchCell

@synthesize userName            = _userName;
@synthesize itemData			= _itemData;
@synthesize placeData           = _placeData;
@synthesize hasAttachment       = _hasAttachment;
@synthesize hasQuote            = _hasQuote;
@synthesize userRect            = _userRect;
@synthesize dataRect            = _dataRect;
@synthesize placeRect           = _placeRect;
@synthesize quoteRect           = _quoteRect;

//----------------------------------------------------------------------------------------------------
- (id)initWithStyle:(UITableViewCellStyle)style
	reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
				reuseIdentifier:reuseIdentifier];
    
	if (self) {
        
        self.clipsToBounds  = YES;
		CGRect frame        = CGRectMake(0,0,320,60);
        
        attachmentImageLayer                    = [CALayer layer];
		attachmentImageLayer.frame              = CGRectMake(60,-7.5,260,75);
		attachmentImageLayer.contentsScale      = [[UIScreen mainScreen] scale];
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
		chevronLayer.frame				= CGRectMake(308,24,6,11);
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
    self.userName       = nil;
	self.itemData		= nil;
    self.placeData      = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)reset {
	_highlighted        = NO;
    
    CGSize userSize     = [self.userName sizeWithFont:kFontUserName];
    
    _userRect           = CGRectMake(kUserNameX,
                                     kTopLineY,
                                     userSize.width,
                                     userSize.height);
    
    
    CGSize dataSize     = [self.itemData sizeWithFont:kFontItemData
                                    constrainedToSize:CGSizeMake(225 - _userRect.size.width,20)
                                        lineBreakMode:UILineBreakModeTailTruncation];
    
    _dataRect           = CGRectMake(_userRect.origin.x + _userRect.size.width,
                                     kTopLineY,
                                     dataSize.width,
                                     dataSize.height);
    
    CGSize quoteSize    = [@"\"" sizeWithFont:kFontItemData];
    
    _quoteRect          = CGRectMake(_dataRect.origin.x + _dataRect.size.width,
                                     kTopLineY,
                                     quoteSize.width,
                                     quoteSize.height);
    
    CGSize placeSize    = [self.placeData sizeWithFont:kFontPlaceName
                                     constrainedToSize:CGSizeMake(226,20)
                                         lineBreakMode:UILineBreakModeTailTruncation];
    
    _placeRect          = CGRectMake(kPlaceNameX,
                                     kBottomLineY,
                                     placeSize.width,
                                     placeSize.height);
    
    
    [CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kNoAnimationDuration]
					 forKey:kCATransactionAnimationDuration];		
    
	attachmentImageLayer.opacity            = _hasAttachment ? kNormalAlpha : kNoAttachmentAlpha;
    attachmentImageLayer.backgroundColor	= _hasAttachment ? kColorNormalBg : kColorNoAttachmentBg;
    
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
- (void)setPlaceName:(NSString*)placeName 
         andItemData:(NSString*)theItemData {

    self.placeData  = [NSString stringWithFormat:@"at %@",placeName];
             
    _hasQuote       = ![theItemData isEqualToString:kEmptyString];
    self.itemData   = _hasQuote ? 
                        [NSString stringWithFormat:@" touched \"%@",theItemData] :
                        [NSString stringWithString:@" touched your post"];
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
	attachmentImageLayer.opacity = _hasAttachment ? kHighlightAlpha : kNoAttachmentHighlightAlpha;
	[CATransaction commit];
}

//----------------------------------------------------------------------------------------------------
- (void)fadeCell {
	_highlighted = NO;
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:kAnimationDuration]
					 forKey:kCATransactionAnimationDuration];		
	attachmentImageLayer.opacity = _hasAttachment ? kNormalAlpha : kNoAttachmentAlpha;
	[CATransaction commit];
}

@end
