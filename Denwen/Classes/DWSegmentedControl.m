//
//  DWSegmentedControl.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSegmentedControl.h"
#import "DWConstants.h"


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSegmentedControl

@synthesize buttons         =   _buttons;
@synthesize selectedIndex   =   _selectedIndex;

//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame 
   withSegmentsInfo:(NSArray*)segmentsInfo
		andDelegate:(id)theDelegate {
	
    self = [super initWithFrame:frame];
    
	if (self) {
		
		self.buttons			= [NSMutableArray array];
		_delegate				= theDelegate;
		
		NSInteger index			= 0;
		NSInteger nextTabX		= 0;
		
		for(NSDictionary *segmentInfo in segmentsInfo) {
			
			UIButton *button		= [UIButton buttonWithType:UIButtonTypeCustom];
			
			NSInteger buttonWidth	= [[segmentInfo objectForKey:kKeyWidth] integerValue];
			button.frame			= CGRectMake(nextTabX,0,buttonWidth,frame.size.height);
			
			nextTabX				+= buttonWidth;	
			
			[button setBackgroundImage:[UIImage imageNamed:[segmentInfo objectForKey:kKeyNormalImageName]]
							  forState:UIControlStateNormal];
			
			[button setBackgroundImage:[UIImage imageNamed:[segmentInfo objectForKey:kKeySelectedImageName]]
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
			
			if([[segmentInfo objectForKey:kKeyIsSelected] boolValue]) {
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
