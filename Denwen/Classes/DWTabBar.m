//
//  DWTabBar.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTabBar.h"
#import "DWConstants.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTabBar

@synthesize buttons			= _buttons;
@synthesize selectedIndex	= _selectedIndex;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame 
		   withInfo:(NSArray*)tabsInfo
		andDelegate:(id)theDelegate {
	
    self = [super initWithFrame:frame];
    
	if (self) {		
		_delegate				= theDelegate;
		
		self.buttons			= [NSMutableArray array];
		NSInteger index			= 0;
		NSInteger nextTabX		= 0;
		
		for(NSDictionary *tabInfo in tabsInfo) {
			
			UIButton *button		= [UIButton buttonWithType:UIButtonTypeCustom];
			
			NSInteger buttonWidth	= [[tabInfo objectForKey:kKeyWidth] integerValue];
			button.frame			= CGRectMake(nextTabX,0,buttonWidth,frame.size.height);
			button.tag				= [[tabInfo objectForKey:kKeyTag] integerValue];
			
			nextTabX				+= buttonWidth;	
			
			[button setBackgroundImage:[UIImage imageNamed:[tabInfo objectForKey:kKeyNormalImageName]]
							  forState:UIControlStateNormal];
			
			[button setBackgroundImage:[UIImage imageNamed:[tabInfo objectForKey:kKeySelectedImageName]]
							  forState:UIControlStateSelected];
			
			if([tabInfo objectForKey:kKeyHighlightedImageName])
				[button setBackgroundImage:[UIImage imageNamed:[tabInfo objectForKey:kKeyHighlightedImageName]]
								  forState:UIControlStateHighlighted];
			
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
			
			if([[tabInfo objectForKey:kKeyIsSelected] boolValue]) {
				button.selected = YES;
				_selectedIndex	= index;
			}
			
			[self.buttons	addObject:button];
			[self			addSubview:button];		
			
			index++;
		}
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(requestTabBarIndexChange:) 
                                                     name:kNRequestTabBarIndexChange
                                                   object:nil];
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)selectButton:(UIButton*)selectedButton {
	
	NSInteger index = 0;
	NSInteger i		= 0;
	
	if(selectedButton.tag != kTabBarSpecialTag) {
		
		for (UIButton* button in self.buttons) {
			
			if(button == selectedButton) {
				button.selected = YES;
				index = i;
			}
			else {
				button.selected = NO;
			}
			
			
			button.highlighted = NO;
			i++;
		}
	}
	else {
		index = [self.buttons indexOfObject:selectedButton];
	}
	
	return index;
}

//----------------------------------------------------------------------------------------------------
- (void)buttonPressed:(UIButton*)button 
         withNavReset:(BOOL)navReset
           isExternal:(BOOL)isExternal {
    
	NSInteger oldIndex	= _selectedIndex;
	_selectedIndex		= [self selectButton:button];
	
	[_delegate selectedTabWithSpecialTab:button.tag == kTabBarSpecialTag
							modifiedFrom:oldIndex
									  to:_selectedIndex
                            withNavReset:isExternal ? navReset : _selectedIndex == oldIndex];
	
	if(button.tag == kTabBarSpecialTag)
		_selectedIndex = oldIndex;
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchDownOnButton:(UIButton*)button {
    [self buttonPressed:button 
           withNavReset:NO
             isExternal:NO];
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchUpInsideButton:(UIButton*)button {
	[self selectButton:button];
}

//----------------------------------------------------------------------------------------------------
- (void)didOtherTouchesToButton:(UIButton*)button {
	[self selectButton:button];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications

//----------------------------------------------------------------------------------------------------
- (void)requestTabBarIndexChange:(NSNotification*)notification {
    
    NSDictionary    *userInfo   =   [notification userInfo];
    NSInteger       newIndex    =   [[userInfo objectForKey:kKeyTabIndex] integerValue];
    BOOL            navReset    =   [[userInfo objectForKey:kKeyPopAll] boolValue];
    
    [self buttonPressed:[self.buttons objectAtIndex:newIndex]
           withNavReset:navReset
             isExternal:YES];
}


@end
