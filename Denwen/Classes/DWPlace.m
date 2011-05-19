//
//  DWPlace.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlace.h"
#import "DWAttachment.h"
#import "DWRequestsManager.h"
#import "DWMemoryPool.h"
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
@synthesize location			= _location;
@synthesize attachment			= _attachment;
@synthesize	town				= _town;
@synthesize state				= _state;
@synthesize country				= _country;

//----------------------------------------------------------------------------------------------------
- (id)init {
	self = [super init];
	
	if(self) {
	}
	
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (void)freeMemory {
}

//----------------------------------------------------------------------------------------------------
- (void)freeAttachment {
    
    
    if(self.attachment) {
        [[DWMemoryPool sharedDWMemoryPool]  removeObject:self.attachment 
                                                   atRow:kMPAttachmentSlicesIndex];
        
        self.attachment = nil;
    }
}

//----------------------------------------------------------------------------------------------------
-(void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	//NSLog(@"place released %d",_databaseID);
	
	self.name					= nil;
	self.hashedID				= nil;
	self.town					= nil;
	self.state					= nil;
	self.country				= nil;
	self.location				= nil;
    
    [self freeAttachment];
	
	[super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)populateAttachment:(NSDictionary*)attachment {
    self.attachment = (DWAttachment*)[[DWMemoryPool sharedDWMemoryPool]  getOrSetObject:attachment 
                                                                                  atRow:kMPAttachmentSlicesIndex];
}

//----------------------------------------------------------------------------------------------------
- (void)populate:(NSDictionary*)place {	
	[super populate:place];
	
	_databaseID				= [[place objectForKey:kKeyID] integerValue];
	
	self.name				= [place objectForKey:kKeyName];
	self.hashedID			= [place objectForKey:kKeyHashedID];
	_followersCount			= [[place objectForKey:kKeyFollowingsCount] integerValue];
	
    
    if([place objectForKey:kKeyLatitude])
        self.location = [[[CLLocation alloc] initWithLatitude:[[place objectForKey:kKeyLatitude]  floatValue] 
                                                    longitude:[[place objectForKey:kKeyLongitude] floatValue]] autorelease];
	
    
	NSDictionary *address = [place objectForKey:kKeyAddress];
	
	if (address) {
		_hasAddress		= YES;
		
		self.town		= [address objectForKey:kKeyShortTown];
		self.state		= [address objectForKey:kKeyShortState];
		self.country	= [address objectForKey:kKeyShortCountry];
	}
    
    
	if([place objectForKey:kKeyAttachment])
        [self populateAttachment:[place objectForKey:kKeyAttachment]];
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
    
    if([place objectForKey:kKeyFollowingsCount])
        _followersCount	= [[place objectForKey:kKeyFollowingsCount] integerValue];
    
    if([place objectForKey:kKeyLatitude])
        self.location = [[[CLLocation alloc] initWithLatitude:[[place objectForKey:kKeyLatitude]  floatValue] 
                                                    longitude:[[place objectForKey:kKeyLongitude] floatValue]] autorelease];
    
    NSDictionary *address = [place objectForKey:kKeyAddress];
    
    if(!_hasAddress && address) {
        _hasAddress		= YES;
        
        self.town		= [address objectForKey:kKeyShortTown];
        self.state		= [address objectForKey:kKeyShortState];
        self.country	= [address objectForKey:kKeyShortCountry];		
    }
    
    
    if([place objectForKey:kKeyAttachment]) {
       
        NSDictionary *attachment = [place objectForKey:kKeyAttachment];
        
        if(self.attachment) {
            
            if([[attachment objectForKey:kKeyID] integerValue] != self.attachment.databaseID) {
                [self freeAttachment];
                [self populateAttachment:attachment];
            }
        }
        else
            [self populateAttachment:attachment];
    }
    
    return YES;
}

//----------------------------------------------------------------------------------------------------
- (NSString*)displayAddress {
	NSString *address = nil;
    
	if(_hasAddress) {
        NSMutableString *result     = [NSMutableString stringWithString:@""];
        NSInteger parts             = 0;
        
        if(self.town && [self.town length] > 0) {
            [result appendString:self.town];
            parts++;
        }
        
        if(self.state && [self.state length] > 0) {
            
            if(parts == 1)
                [result appendString:@", "];
            
            [result appendString:self.state];
            
            parts++;
        }
        
        if(parts < 2 && self.country && [self.country length] > 0) {
            
            if(parts == 1)
                [result appendString:@", "];
            
            [result appendString:self.country];
        }
        
        address = [NSString stringWithString:result];
    }
	else
		address = kMsgFindingLocality;
	
	return address;
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)followersCount {
    return _followersCount;
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

@end
