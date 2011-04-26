//
//  DWFollowPlaceView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTitleView.h"
#import "DWConstants.h"

static NSString* const kImgStaticButton                 = @"loading_bar_fail.png";
static NSString* const kImgStaticButtonActive           = @"static_button_active.png";
static NSString* const kImgDynamicButton                = @"button_follow.png";
static NSString* const kImgDynamicButtonActive          = @"button_follow_active.png";

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTitleView


//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame 
           delegate:(id)delegate 
          titleMode:(NSInteger)titleViewMode 
      andButtonType:(NSInteger)buttonType {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createUnderlayButtonWithType:buttonType];
        
        if (titleViewMode == kNavTitleAndSubtitleMode) {
            [self createTitleLabel];
            [self createSubtitleLabel];            
        }
        else    
            [self createStandaloneTitleLabel];            

        _delegate = delegate;
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
#pragma mark Private Methods
//----------------------------------------------------------------------------------------------------
- (void)createUnderlayButtonWithType:(NSInteger)buttonType {    
    underlayButton              = [UIButton buttonWithType:UIButtonTypeCustom];
    
    underlayButton.enabled      = NO;
    underlayButton.frame        = CGRectMake(0, 0, 200, 44);
    
    if (buttonType == kDWButtonTypeDynamic) {
        [underlayButton setBackgroundImage:[UIImage imageNamed:kImgDynamicButton]
                                  forState:UIControlStateNormal];
    
        [underlayButton setBackgroundImage:[UIImage imageNamed:kImgDynamicButtonActive]
                                  forState:UIControlStateHighlighted];
    }
    else {
        [underlayButton setBackgroundImage:[UIImage imageNamed:kImgStaticButton]
                                  forState:UIControlStateNormal];
        
        [underlayButton setBackgroundImage:[UIImage imageNamed:kImgStaticButtonActive]
                                  forState:UIControlStateHighlighted];
    }
    
    [underlayButton addTarget:self 
                       action:@selector(didTouchDownOnButton:) 
             forControlEvents:UIControlEventTouchDown];
    
    [underlayButton addTarget:self
                       action:@selector(didTouchUpInsideButton:) 
             forControlEvents:UIControlEventTouchUpInside];
    
    [underlayButton addTarget:self
                       action:@selector(didOtherTouchesToButton:) 
             forControlEvents:UIControlEventTouchUpOutside];
    
    [underlayButton addTarget:self
                       action:@selector(didOtherTouchesToButton:) 
             forControlEvents:UIControlEventTouchDragOutside];
    
    /*[underlayButton addTarget:self
                       action:@selector(didOtherTouchesToButton:)
             forControlEvents:UIControlEventTouchDragInside];*/
    
    [self addSubview:underlayButton];
}

//----------------------------------------------------------------------------------------------------
- (void)createTitleLabel {
    titleLabel                              = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 180, 18)];
    
    titleLabel.userInteractionEnabled       = NO;
    titleLabel.textColor                    = [UIColor whiteColor];
    titleLabel.textAlignment                = UITextAlignmentCenter;
    titleLabel.backgroundColor              = [UIColor clearColor];
    titleLabel.font                         = [UIFont fontWithName:@"HelveticaNeue-Bold" 
                                                              size:15];
    
    [self addSubview:titleLabel];
    [titleLabel release];
}

//----------------------------------------------------------------------------------------------------
- (void)createSubtitleLabel {
    subtitleLabel                           = [[UILabel alloc] initWithFrame:CGRectMake(10, 22, 180, 18)];
    
    subtitleLabel.userInteractionEnabled    = NO;
    subtitleLabel.textColor                 = [UIColor colorWithRed:255
                                                              green:255
                                                               blue:255
                                                              alpha:0.5];
    
    subtitleLabel.textAlignment             = UITextAlignmentCenter;
    subtitleLabel.backgroundColor           = [UIColor clearColor];
    subtitleLabel.font                      = [UIFont fontWithName:@"HelveticaNeue" 
                                                              size:13];
    
    [self addSubview:subtitleLabel];
    [subtitleLabel release];
}

//----------------------------------------------------------------------------------------------------
- (void)createStandaloneTitleLabel {
    standaloneTitleLabel                                = [[UILabel alloc] 
                                                           initWithFrame:CGRectMake(10, 12, 180, 18)];
    
    standaloneTitleLabel.userInteractionEnabled         = NO;
    standaloneTitleLabel.textColor                      = [UIColor whiteColor];
    standaloneTitleLabel.textAlignment                  = UITextAlignmentCenter;
    standaloneTitleLabel.backgroundColor                = [UIColor clearColor];
    standaloneTitleLabel.font                           = [UIFont fontWithName:@"HelveticaNeue-Bold" 
                                                                          size:17];
    
    [self addSubview:standaloneTitleLabel];
    [standaloneTitleLabel release];
}

//----------------------------------------------------------------------------------------------------
- (void)createSpinner {
	spinner			= [[UIActivityIndicatorView alloc] 
                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	spinner.frame	= CGRectMake(90,12,20,20);
    spinner.hidden  = YES;    
	
	[self addSubview:spinner];	
    [spinner release];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Button Touch Events
//----------------------------------------------------------------------------------------------------
- (void)titleViewButtonPressed {
    [_delegate didTapTitleView];
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchDownOnButton:(UIButton*)button {
	subtitleLabel.textColor = [UIColor whiteColor]; 
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchUpInsideButton:(UIButton*)button {
    subtitleLabel.textColor = [UIColor colorWithRed:255
                                         green:255 
                                          blue:255 
                                         alpha:0.5];
    [self titleViewButtonPressed];
}

//----------------------------------------------------------------------------------------------------
- (void)didOtherTouchesToButton:(UIButton*)button {
    subtitleLabel.textColor = [UIColor colorWithRed:255 
                                         green:255 
                                          blue:255 
                                         alpha:0.5]; 
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav Stack Selectors
//----------------------------------------------------------------------------------------------------
- (void)shouldBeRemovedFromNav {
    
}


@end
