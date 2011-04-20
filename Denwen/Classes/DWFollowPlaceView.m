//
//  DWFollowPlaceView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWFollowPlaceView.h"

static NSString* const kImgFollowButton                 = @"button_follow.png";
static NSString* const kImgFollowButtonActive           = @"button_follow_active.png";

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWFollowPlaceView


//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame andDelegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        [self createFollowButton];
        [self createFollowLabel];
        [self createFollowingCountLabel];
        
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
- (void)createFollowButton {    
    UIButton *followButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    followButton.frame      = CGRectMake(0, 0, 200, 44);
    
    [followButton setBackgroundImage:[UIImage imageNamed:kImgFollowButton]
                            forState:UIControlStateNormal];
    
    [followButton setBackgroundImage:[UIImage imageNamed:kImgFollowButtonActive]
                            forState:UIControlStateHighlighted];
    
    [followButton addTarget:self 
                     action:@selector(didTouchDownOnButton:) 
           forControlEvents:UIControlEventTouchDown];
    
    [followButton addTarget:self
                     action:@selector(didTouchUpInsideButton:) 
           forControlEvents:UIControlEventTouchUpInside];
    
    [followButton addTarget:self
                     action:@selector(didOtherTouchesToButton:) 
           forControlEvents:UIControlEventTouchUpOutside];
    
    [followButton addTarget:self
                     action:@selector(didOtherTouchesToButton:) 
           forControlEvents:UIControlEventTouchDragOutside];
    
    /*[followButton addTarget:self
                     action:@selector(didOtherTouchesToButton:)
           forControlEvents:UIControlEventTouchDragInside];*/
    
    [self addSubview:followButton];
}

//----------------------------------------------------------------------------------------------------
- (void)createFollowLabel {
    followLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 200, 18)];
    
    followLabel.userInteractionEnabled      = NO;
    followLabel.textColor                   = [UIColor whiteColor];
    followLabel.textAlignment               = UITextAlignmentCenter;
    followLabel.backgroundColor             = [UIColor clearColor];
    followLabel.font                        = [UIFont fontWithName:@"HelveticaNeue-Bold" 
                                                              size:16];
    
    [self addSubview:followLabel];
    [followLabel release];
}

//----------------------------------------------------------------------------------------------------
- (void)createFollowingCountLabel {
    followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, 200, 18)];
    
    followingCountLabel.userInteractionEnabled      = NO;
    followingCountLabel.textColor                   = [UIColor colorWithRed:255 
                                                                      green:255 
                                                                       blue:255 
                                                                      alpha:0.5];
    followingCountLabel.textAlignment               = UITextAlignmentCenter;
    followingCountLabel.backgroundColor             = [UIColor clearColor];
    followingCountLabel.font                        = [UIFont fontWithName:@"HelveticaNeue" 
                                                                      size:13];
    
    [self addSubview:followingCountLabel];
    [followingCountLabel release];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Update View Methods
- (void)updateTitle:(NSString *)title 
        andSubtitle:(NSString *)subtitle 
     andIsFollowing:(BOOL)isFollowing {
    
    followLabel.text            = title;
    followingCountLabel.text    = subtitle;
    _isFollowing                = isFollowing;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Button Touch Events
//----------------------------------------------------------------------------------------------------
- (void)didTouchDownOnButton:(UIButton*)button {
	followingCountLabel.textColor = [UIColor whiteColor]; 
}

//----------------------------------------------------------------------------------------------------
- (void)didTouchUpInsideButton:(UIButton*)button {
    if (_isFollowing) 
        [_delegate didTapUnfollow];
    else
        [_delegate didTapFollow];
    
    followingCountLabel.textColor = [UIColor colorWithRed:255 
                                                    green:255 
                                                     blue:255 
                                                    alpha:0.5]; 
}

//----------------------------------------------------------------------------------------------------
- (void)didOtherTouchesToButton:(UIButton*)button {
    followingCountLabel.textColor = [UIColor colorWithRed:255 
                                            green:255 
                                             blue:255 
                                            alpha:0.5]; 
}


@end
