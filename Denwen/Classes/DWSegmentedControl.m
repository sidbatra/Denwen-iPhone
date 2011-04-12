//
//  DWSegmentedControl.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSegmentedControl.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSegmentedControl

@synthesize buttons = _buttons;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame withImageNamesForSegments:(NSArray*)images 
  withSelectedIndex:(NSInteger)theSelectedIndex
		andDelegate:(id)theDelegate {
	
    self = [super initWithFrame:frame];
    
	if (self) {
		
		assert([images count] % 2 == 0);
		
		_selectedIndex			= theSelectedIndex;
		_delegate				= theDelegate;
		
		NSInteger totalButtons	= [images count] / 2;
		NSInteger segmentWidth	= frame.size.width / totalButtons;
		
		self.buttons			= [NSMutableArray arrayWithCapacity:totalButtons];
		
		 
		for(NSInteger i=0 ;i<[images count];i+=2) {
			
			UIButton *button	= [UIButton buttonWithType:UIButtonTypeCustom];
			
			button.frame		= CGRectMake(i/2 * segmentWidth,0,segmentWidth,frame.size.height);
			
			[button setBackgroundImage:[UIImage imageNamed:[images objectAtIndex:i]]
							  forState:UIControlStateNormal];
			
			[button setBackgroundImage:[UIImage imageNamed:[images objectAtIndex:i+1]]
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
			
			if(i/2==_selectedIndex)
				button.selected = YES;
			
			[self.buttons	addObject:button];
			[self			addSubview:button];
		}
    }
	
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.buttons = nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)selectButton:(UIButton*)selectedButton {
	
	NSInteger index = 0;
	NSInteger i		= 0;
	
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
	
	return index;
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchDownOnButton:(UIButton*)button {
	
	NSInteger oldIndex	= _selectedIndex;
	_selectedIndex		= [self selectButton:button];
	
	if(_selectedIndex != oldIndex)
		[_delegate selectedSegmentModifiedFrom:oldIndex 
											to:_selectedIndex];
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchUpInsideButton:(UIButton*)button {
	[self selectButton:button];
}

//----------------------------------------------------------------------------------------------------
- (void)didOtherTouchesToButton:(UIButton*)button {
	[self selectButton:button];
}

@end
