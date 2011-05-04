//
//  DWDoneButtonView.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWDoneButtonView.h"


@implementation DWDoneButtonView

static NSString* const kImgDoneButton = @"button_blue.png";

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame andTarget:(id)target {
    self = [super initWithFrame:frame];
    
    if (self) {
        doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [doneButton addTarget:target
                       action:@selector(didTapDoneButton:event:) 
             forControlEvents:UIControlEventTouchUpInside];
        
        [doneButton setFrame:CGRectMake(0, 0, 60, 44)];
        
        [doneButton setBackgroundImage:[UIImage imageNamed:kImgDoneButton] 
                              forState:UIControlStateNormal];
        [self addSubview:doneButton];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav Stack Selectors
//----------------------------------------------------------------------------------------------------
- (void)shouldBeRemovedFromNav {
    
}

@end
