//
//  DWProfilePicViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWProfilePicViewController.h"
#import "DWImageView.h"
#import "DWConstants.h"
#import "DWGUIManager.h"
#import "DWRequestsManager.h"

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWProfilePicViewController

@synthesize user                    = _user;
@synthesize userProfileTitleView    = _userProfileTitleView;

//----------------------------------------------------------------------------------------------------
- (id)initWithUser:(DWUser*)user andDelegate:(id)delegate {
    self = [super init];
    
	if (self) {
		self.user           = user;
		_key                = [[NSDate date] timeIntervalSince1970];
        _delegate           = delegate;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageLoaded:) 
													 name:kNImgActualUserImageLoaded
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(imageError:) 
													 name:kNImgActualUserImageError
												   object:nil];
	}
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.user = nil;
	
    [super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark View Lifecycle
//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	[super viewDidLoad];
    
	[[DWRequestsManager sharedDWRequestsManager] getImageAt:self.user.largeURL
											 withResourceID:_key
										successNotification:kNImgActualUserImageLoaded
										  errorNotification:kNImgActualUserImageError];
	
	self.navigationItem.leftBarButtonItem   = [DWGUIManager customBackButton:_delegate];
    self.navigationItem.rightBarButtonItem  = nil;
    self.navigationItem.titleView           = nil;    
}

//----------------------------------------------------------------------------------------------------
-(UIView *)viewForZoomingInScrollView:(UIScrollView*)scrollView {
	return ((DWImageView*)self.view).imageView;
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications
//----------------------------------------------------------------------------------------------------
- (void)imageLoaded:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
    
	if(resourceID == _key) {
		[(DWImageView*)self.view setupImageView:(UIImage*)[info objectForKey:kKeyImage]];
        
        [self.userProfileTitleView showUserStateFor:[self.user fullName] 
                                   andIsCurrentUser:[self.user isCurrentUser]];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)imageError:(NSNotification*)notification {
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
    
	if(resourceID == _key) {
        [self.userProfileTitleView showUserStateFor:[self.user fullName] 
                                   andIsCurrentUser:[self.user isCurrentUser]];
	}
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark FullScreenMode
//----------------------------------------------------------------------------------------------------
- (void)requiresFullScreenMode {
    
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Nav Stack Selectors
//----------------------------------------------------------------------------------------------------
- (void)willShowOnNav {
    if (!self.userProfileTitleView ) 
        self.userProfileTitleView = [[[DWUserProfileTitleView alloc] 
                                      initWithFrame:CGRectMake(kNavTitleViewX, 0,
                                                               kNavTitleViewWidth,kNavTitleViewHeight) 
                                           delegate:self 
                                          titleMode:kNavStandaloneTitleMode 
                                      andButtonType:kDWButtonTypeStatic] autorelease];
    
    [self.navigationController.navigationBar addSubview:self.userProfileTitleView];  
    [self.userProfileTitleView showProcessingState];
}

@end
