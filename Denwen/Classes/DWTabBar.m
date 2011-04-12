//
//  DWTabBar.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTabBar.h"

static NSString* const kTBKeyWidth			= @"tabBarButtonWidth";
static NSString* const kTBKeySelected		= @"tabBarButtonSelected";
static NSString* const kTBKeySelectedImage	= @"tabBarButtonSelectedImage";
static NSString* const kTBKeyNormalImage	= @"tabBarButtonNormalImage";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTabBar

@synthesize buttons		= _buttons;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame 
		withTabInfo:(NSArray*)tabsInfo
		andDelegate:(id)theDelegate {
	
    self = [super initWithFrame:frame];
    
	if (self) {		
		_delegate				= theDelegate;
		
		self.buttons			= [NSMutableArray array];
		NSInteger index			= 0;
		NSInteger nextTabX		= 0;
		
		for(NSDictionary *tabInfo in tabsInfo) {
			
			UIButton *button		= [UIButton buttonWithType:UIButtonTypeCustom];
			
			NSInteger buttonWidth	= [[tabInfo objectForKey:kTBKeyWidth] integerValue];
			button.frame			= CGRectMake(nextTabX,0,buttonWidth,frame.size.height);
			
			nextTabX				+= buttonWidth;	
			
			[button setBackgroundImage:[UIImage imageNamed:[tabInfo objectForKey:kTBKeyNormalImage]]
							  forState:UIControlStateNormal];
			
			[button setBackgroundImage:[UIImage imageNamed:[tabInfo objectForKey:kTBKeySelectedImage]]
							  forState:UIControlStateSelected];
			
			[button addTarget:self 
					   action:@selector(didTouchDownOnButton:) 
			 forControlEvents:UIControlEventTouchDown];
			
			[button addTarget:self
					   action:@selector(didTouchUpInsideButton:) 
			 forControlEvents:UIControlEventTouchUpInside];
			
			[button addTarget:self
					   action:@selector(didOtherTouchesToButton:) 
			 forControlEvents:UIControlEventTouchUpOutside];
			
			[button addTarget:self
					   action:@selector(didOtherTouchesToButton:) 
			 forControlEvents:UIControlEventTouchDragOutside];
			
			[button addTarget:self
					   action:@selector(didOtherTouchesToButton:)
			 forControlEvents:UIControlEventTouchDragInside];
			
			if([[tabInfo objectForKey:kTBKeySelected] boolValue]) {
				button.selected = YES;
				_selectedIndex	= index;
			}
			
			[self.buttons	addObject:button];
			[self			addSubview:button];		
			
			index++;
		}
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}


@end
