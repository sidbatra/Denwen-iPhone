//
//  DWItem.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWItem.h"
#import "DWMemoryPool.h"
#import "DWConstants.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWItem

@synthesize data				= _data;
@synthesize touchesCount		= _touchesCount;
@synthesize attachment			= _attachment;
@synthesize place				= _place;
@synthesize user				= _user;
@synthesize urls				= _urls;
@synthesize fromFollowedPlace	= _fromFollowedPlace;
@synthesize usesMemoryPool		= _usesMemoryPool;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self != nil) {
		_fromFollowedPlace	= NO;
		_usesMemoryPool		= YES;
	}
	
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (void)freeMemory {
	[self.attachment freeMemory];
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	
	//NSLog(@"item being removed - %d",_databaseID);
	
	self.data		= nil;
	self.urls		= nil;
	self.attachment = nil;
	
	if(self.place) {
		
		if(_usesMemoryPool)
			[[DWMemoryPool sharedDWMemoryPool]  removeObject:_place atRow:kMPPlacesIndex];
		
		self.place = nil;
	}
	
	if(self.user) {
		
		if(_usesMemoryPool)
			[[DWMemoryPool sharedDWMemoryPool]  removeObject:_user atRow:kMPUsersIndex];
		
		self.user = nil;
	}
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (BOOL)hasAttachment {
	return self.attachment != nil;
}

//----------------------------------------------------------------------------------------------------
- (void)touchesCountDelta:(NSInteger)delta {
	_touchesCount += delta;
}

//----------------------------------------------------------------------------------------------------
- (NSString*)createdTimeAgoInWords {
	
	NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:_createdAtTimestamp];
    NSDate *todayDate	= [NSDate date];
    NSInteger ti		= [todayDate timeIntervalSinceDate:createdDate];
    	
	if (ti < 60) {
		if (ti <= 1) 
			return @"1 second ago";
		
        return [NSString stringWithFormat:@"%d seconds ago", ti];
    } 
	else if (ti < 3600) {
        int diff = round(ti / 60);
		
		if (diff == 1)
			return @"1 minute ago";	
		
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } 
	else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
		
		if (diff == 1) 
			return @"1 hour ago";
        
		return [NSString stringWithFormat:@"%d hours ago", diff];
    } 
	else {
		NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[outputFormatter setDateFormat:@"d MMM"];
		
		NSString *outputString = [NSString stringWithString:[outputFormatter stringFromDate:createdDate]];
		
		return outputString;
    }
}

//----------------------------------------------------------------------------------------------------
- (void)populate:(NSDictionary*)item {
	[super populate:item];

	_databaseID				= [[item objectForKey:kKeyID] integerValue];
	_touchesCount			= [[item objectForKey:kKeyTouchesCount] integerValue];
	_createdAtTimestamp		= [[item objectForKey:kKeyCreatedAt] doubleValue];	
	self.data				= [item objectForKey:kKeyCondensedData];
	
	
	if ([item objectForKey:kKeyAttachment]) {
		self.attachment = [[[DWAttachment alloc] init] autorelease];
		[self.attachment populate:[item objectForKey:kKeyAttachment]];
	}
	
	self.place = (DWPlace*)[[DWMemoryPool sharedDWMemoryPool]  getOrSetObject:[item objectForKey:kKeyPlace] 
												  atRow:kMPPlacesIndex];

	self.user = (DWUser*)[[DWMemoryPool sharedDWMemoryPool]  getOrSetObject:[item objectForKey:kKeyUser]
												atRow:kMPUsersIndex];
	
	NSArray *urlsArray = [item objectForKey:kKeyURLs];
	
	if ([urlsArray count])
		self.urls = urlsArray;
}

//----------------------------------------------------------------------------------------------------
- (void)update:(NSDictionary*)item {

	float interval = -[self.updatedAt timeIntervalSinceNow];
	
	if(interval > kMPObjectUpdateInterval) {
		
		_touchesCount = [[item objectForKey:kKeyTouchesCount] integerValue];
		
		[_place update:[item objectForKey:kKeyPlace]];
		[_user	update:[item objectForKey:kKeyUser]];
				
		if([self hasAttachment])
			[_attachment update:[item objectForKey:kKeyAttachment]];
		
		[self refreshUpdatedAt];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)startRemoteImagesDownload {
	if (self.attachment)
		[self.attachment startPreviewDownload];
	
	/*if(self.user)
		[self.user startSmallPreviewDownload];*/
}

@end
