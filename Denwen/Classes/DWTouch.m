//
//  DWTouch.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWTouch.h"
#import "DWAttachment.h"
#import "DWUser.h"
#import "DWMemoryPool.h"
#import "DWConstants.h"

static NSInteger const kItemDataSummaryLength   = 15;

//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWTouch

@synthesize databaseID  = _databaseID;
@synthesize itemData    = _itemData;
@synthesize placeName   = _placeName;
@synthesize attachment  = _attachment;
@synthesize user        = _user;


//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
	}
	
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	
	self.itemData		= nil;
    self.placeName      = nil;
    
    
    if(self.attachment) {
        
        [[DWMemoryPool sharedDWMemoryPool]  removeObject:self.attachment 
                                                   atRow:kMPAttachmentSlicesIndex];
        
        self.attachment = nil;
    }
	
    
	if(self.user) {
    
        [[DWMemoryPool sharedDWMemoryPool]  removeObject:self.user
                                                   atRow:kMPUsersIndex];
		
		self.user = nil;
	}
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)populate:(NSDictionary*)touch {

	_databaseID				= [[touch objectForKey:kKeyID] integerValue];

    self.user               = (DWUser*)[[DWMemoryPool sharedDWMemoryPool]  getOrSetObject:[touch objectForKey:kKeyUser]
                                                                                    atRow:kMPUsersIndex];
    
    NSDictionary *item      = [touch objectForKey:kKeyItem];
    self.itemData           = [item objectForKey:kKeyData];
    self.placeName          = [[item objectForKey:kKeyPlace] objectForKey:kKeyName];
    
    if ([item objectForKey:kKeyAttachment])
        self.attachment     = (DWAttachment*)[[DWMemoryPool sharedDWMemoryPool]  getOrSetObject:[item objectForKey:kKeyAttachment] 
                                                                                          atRow:kMPAttachmentSlicesIndex];
}

//----------------------------------------------------------------------------------------------------
- (void)startDownloadingImages {
    [self.user startSmallPreviewDownload];
    
    if(self.attachment)
        [self.attachment startSliceDownload];
}

//----------------------------------------------------------------------------------------------------
- (NSString*)itemDataSummary {
    NSString* summary = [self.itemData substringToIndex:MIN(kItemDataSummaryLength,[self.itemData length])];
    return [NSString stringWithFormat:@"\"%@\"",[summary length] < [self.itemData length] ? 
                                                    [NSString stringWithFormat:@"%@...",summary] : 
                                                    summary];
}

//----------------------------------------------------------------------------------------------------
- (NSString*)displayText {
    NSString *text = nil;
    
    if(self.attachment)
        text = [NSString stringWithFormat:@"%@ touched your post at %@",self.user.firstName,self.placeName];
    else
        text = [NSString stringWithFormat:@"%@ touched %@ at %@",self.user.firstName,[self itemDataSummary],self.placeName];
    
    return text;
}

@end
