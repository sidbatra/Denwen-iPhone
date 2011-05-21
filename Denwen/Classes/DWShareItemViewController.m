//
//  DWShareItemViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWShareItemViewController.h"
#import "DWConstants.h"
#import "DWItem.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWShareItemViewController

@synthesize item                = _item;
@synthesize delegate            = _delegate;
@synthesize previewImageView    = _previewImageView;
@synthesize transImageView      = _transImageView;
@synthesize dataTextView        = _dataTextView;
@synthesize cancelButton        = _cancelButton;
@synthesize doneButton          = _doneButton;
@synthesize coverLabel          = _coverLabel;

//----------------------------------------------------------------------------------------------------
- (id)initWithItem:(DWItem*)theItem {
    self = [super init];
    
    if (self) {
        self.item   = theItem;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(itemAttachmentLoaded:) 
													 name:kNImgMediumAttachmentLoaded
												   object:nil];
    }
    
    return self;
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[UIApplication sharedApplication] setStatusBarStyle:kStatusBarStyle];
    
    self.item               = nil;
    self.previewImageView   = nil;
    self.transImageView     = nil;
    self.dataTextView       = nil;
    self.cancelButton       = nil;
    self.doneButton         = nil;
    self.coverLabel         = nil;
    
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    /**
	 * Commented out to prevent reloading upon a
	 * low memory warning
	 */
    //[super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.item.attachment) {
        [self.item startRemoteImagesDownload];
        
        if(self.item.attachment.previewImage)
            self.previewImageView.image = self.item.attachment.previewImage;
    }
    
    [self.dataTextView becomeFirstResponder];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidUnload {
    [super viewDidUnload];
}

//----------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications
//----------------------------------------------------------------------------------------------------
- (void)itemAttachmentLoaded:(NSNotification*)notification {
	
	NSDictionary *info		= [notification userInfo];
	NSInteger resourceID	= [[info objectForKey:kKeyResourceID] integerValue];
	
    if(self.item.attachment.databaseID != resourceID)
        return;
    
	self.previewImageView.image = [info objectForKey:kKeyImage];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions

//----------------------------------------------------------------------------------------------------
- (void)cancelButtonClicked:(id)sender {
    [_delegate sharingCancelled];
}

//----------------------------------------------------------------------------------------------------
- (void)doneButtonClicked:(id)sender {
    [_delegate sharingFinishedWithText:self.dataTextView.text];
}	


@end
