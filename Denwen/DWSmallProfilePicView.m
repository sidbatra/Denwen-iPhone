//
//  DWSmallUserImageView.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWSmallProfilePicView.h"


static NSString* const kImgOverlayImage = @"user_photo_gloss.png";


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWSmallProfilePicView


//----------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame andTarget:(id)target {
    self = [super initWithFrame:frame];
    
    if (self) {
        profilePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [profilePicButton addTarget:target 
                             action:@selector(didTapSmallUserImage:event:) 
                   forControlEvents:UIControlEventTouchUpInside];
        
        [profilePicButton setFrame:CGRectMake(0, -7, 60, 60)];
        [self addSubview:profilePicButton];
        
        UIImageView *profilePicOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        
        profilePicOverlay.image                     = [UIImage imageNamed:kImgOverlayImage];
        profilePicOverlay.userInteractionEnabled    = NO;
        
        [self addSubview:profilePicOverlay];
        [profilePicOverlay release];
    }
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
-(void)setProfilePicButtonBackgroundImage:(UIImage*)image {
    [profilePicButton setBackgroundImage:image 
                                forState:UIControlStateNormal];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav Stack Selectors
//----------------------------------------------------------------------------------------------------
- (void)shouldBeRemovedFromNav {
    
}

@end
