//
//  DWPlace.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlace.h"
#import "DWAttachment.h"
#import "DWRequestsManager.h"
#import "UIImage+ImageProcessing.h"
#import "DWConstants.h"

static NSString* const kImgSmallPlaceHolder = @"place_small_placeholder.png";
static NSString* const kImgLargePlaceHolder = @"place_placeholder.png";
static NSString* const kMsgFindingLocality	= @"Finding locality";



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlace

@synthesize name				= _name;
@synthesize hashedID			= _hashedID;
@synthesize lastItemData		= _lastItemData;
@synthesize location			= _location;
@synthesize attachment			= _attachment;
@synthesize	town				= _town;
@synthesize state				= _state;
@synthesize country				= _country;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self != nil) {
	}
	
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (void)freeMemory {
	self.attachment.sliceImage = nil;
}

//----------------------------------------------------------------------------------------------------
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	//NSLog(@"place released %d",_databaseID);
	
	self.name					= nil;
	self.hashedID				= nil;
	self.lastItemData			= nil;
	self.town					= nil;
	self.state					= nil;
	self.country				= nil;
	self.location				= nil;
	self.attachment				= nil;
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)populate:(NSDictionary*)place {	
	[super populate:place];
	
	_databaseID				= [[place objectForKey:kKeyID] integerValue];
	
	self.name				= [place objectForKey:kKeyName];
	self.hashedID			= [place objectForKey:kKeyHashedID];
	_followersCount			= [[place objectForKey:kKeyFollowingsCount] integerValue];
	
	self.location = [[[CLLocation alloc] initWithLatitude:[[place objectForKey:kKeyLatitude]  floatValue] 
												longitude:[[place objectForKey:kKeyLongitude] floatValue]] autorelease];
	
	NSDictionary *address = [place objectForKey:kKeyAddress];
	
	if (address) {
		_hasAddress		= YES;
		
		self.town		= [address objectForKey:kKeyShortTown];
		self.state		= [address objectForKey:kKeyShortState];
		self.country	= [address objectForKey:kKeyShortCountry];
	}
	
	NSDictionary *item = [place objectForKey:kKeyItem];
	
	if(item) {
		_lastItemDatabaseID	= [[item objectForKey:kKeyID] integerValue];
		self.lastItemData	= [item objectForKey:kKeyData];
				
		NSDictionary *itemAttachment = [item objectForKey:kKeyAttachment];	
		
		if(itemAttachment) {
			self.attachment = [[[DWAttachment alloc] init] autorelease];
			[self.attachment populate:itemAttachment];
		}
	}
}

//----------------------------------------------------------------------------------------------------
- (BOOL)update:(NSDictionary*)place {
    if(![super update:place])
        return NO;
    		
    NSString *newName = [place objectForKey:kKeyName];
     
     if(![self.name isEqualToString:newName])
         self.name = newName;
    
    NSString *newHashedID = [place objectForKey:kKeyHashedID];
    
    if(![self.hashedID isEqualToString:newHashedID])
        self.hashedID = newHashedID;
    
    _followersCount		= [[place objectForKey:kKeyFollowingsCount] integerValue];
    
    NSDictionary *address = [place objectForKey:kKeyAddress];
    
    if(!_hasAddress && address) {
        _hasAddress		= YES;
        
        self.town		= [address objectForKey:kKeyShortTown];
        self.state		= [address objectForKey:kKeyShortState];
        self.country	= [address objectForKey:kKeyShortCountry];		
    }
    
    NSDictionary *item = [place objectForKey:kKeyItem];
    
    if(item) {
        NSInteger newItemDatabaseID	= [[item objectForKey:kKeyID] integerValue];

        if(newItemDatabaseID != _lastItemDatabaseID) {
            
            _lastItemDatabaseID	= newItemDatabaseID;
            self.lastItemData	= [item objectForKey:kKeyData];
            
            
            NSDictionary *itemAttachment = [item objectForKey:kKeyAttachment];	
            
            if(itemAttachment) {
                self.attachment = [[[DWAttachment alloc] init] autorelease];
                [self.attachment populate:itemAttachment];
            }
            else
                self.attachment = nil;
        }
    }
    
    return YES;
}

//----------------------------------------------------------------------------------------------------
- (NSString*)displayAddress {
	NSString *result = nil;
	
	if(_hasAddress)
		result = [NSString stringWithFormat:@"%@, %@",self.town,self.state];
	else
		result = kMsgFindingLocality;
	
	return result;
}

//----------------------------------------------------------------------------------------------------
- (NSString*)titleText {
	NSString *text = nil;
	
	if(_followersCount == 0)
		text = [NSString stringWithFormat:@"%@",_name];
	else if(_followersCount == 1)
		text = [NSString stringWithFormat:@"%d is following",_followersCount];
	else
		text = [NSString stringWithFormat:@"%d are following",_followersCount];
	
	return text;
}

//----------------------------------------------------------------------------------------------------
- (NSString*)sliceText {
	return [self.lastItemData substringToIndex:MIN(20,self.lastItemData.length)];
}

//----------------------------------------------------------------------------------------------------
- (void)updateFollowerCount:(NSInteger)delta {
	_followersCount += delta;
}

//----------------------------------------------------------------------------------------------------
- (void)startPreviewDownload {
	if(self.attachment)
		[self.attachment startSliceDownload];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Notifications



@end
