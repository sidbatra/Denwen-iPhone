//
//  DWPlacesManager.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWPlacesManager.h"
#import "DWMemoryPool.h"
#import "DWConstants.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWPlacesManager

//----------------------------------------------------------------------------------------------------
- (id)initWithCapacity:(NSInteger)capacity {
	self = [super init];
	
	if(self != nil) {
		
		_capacity		= capacity;
		_places			= [[NSMutableArray alloc] init];
		_filteredPlaces = [[NSMutableArray alloc] init];
		
		/** 
		 * Create a double array of places where each row can hold
		 * multiple places. Each row represents a grouping like nearby,followed etc.
		 */
		for(int i=0;i<_capacity;i++)
			[_places addObject:[NSMutableArray array]];
	}
	
	return self;  
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	
	for(NSMutableArray *placesAtIndex in _places) {
		
		for(DWPlace *place in placesAtIndex)
			[[DWMemoryPool sharedDWMemoryPool]  removeObject:place 
													   atRow:kMPPlacesIndex];
	}
	
	[_places			release];
	[_filteredPlaces	release];
	
	[super dealloc];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Count Retrieval

//----------------------------------------------------------------------------------------------------
- (NSInteger)totalPlacesAtRow:(NSInteger)row {
	return [[_places objectAtIndex:row] count];
}

//----------------------------------------------------------------------------------------------------
- (NSInteger)totalFilteredPlaces {
	return [_filteredPlaces count];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Place Retrieval

//----------------------------------------------------------------------------------------------------
- (DWPlace *)getPlaceAtRow:(NSInteger)row
				 andColumn:(NSInteger)column {
	
	return column < [[_places objectAtIndex:row] count] ? 
				[[_places objectAtIndex:row] objectAtIndex:column] : 
				nil;
}

//----------------------------------------------------------------------------------------------------
- (NSMutableArray*)getPlacesAtRow:(NSInteger)row {
	return (NSMutableArray*)[_places objectAtIndex:row];
}

//----------------------------------------------------------------------------------------------------
- (DWPlace *)getFilteredPlace:(NSInteger)index {
	return [_filteredPlaces objectAtIndex:index];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Populate places

//----------------------------------------------------------------------------------------------------
- (void)addPlace:(DWPlace*)place
		   atRow:(NSInteger)row
	   andColumn:(NSInteger)column {
	
	[[_places objectAtIndex:row] insertObject:place 
									  atIndex:column];
	place.pointerCount++;
}

//----------------------------------------------------------------------------------------------------
- (void)populatePlaces:(NSArray*)places 
			   atIndex:(NSInteger)index {
	
	[self populatePlaces:places
				 atIndex:index 
			   withClear:YES];
}

//----------------------------------------------------------------------------------------------------
- (void)populatePlaces:(NSArray*)places
			   atIndex:(NSInteger)index
			 withClear:(BOOL)clearStatus {
	
	if(clearStatus)
		[self clearPlacesAtIndex:index];
		
	NSMutableArray *placesAtIndex = [_places objectAtIndex:index];
	
	for(NSDictionary *place in places) {
		DWPlace *new_place = (DWPlace*)[[DWMemoryPool sharedDWMemoryPool]  getOrSetObject:place 
																					atRow:kMPPlacesIndex];
		[placesAtIndex addObject:new_place];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)populatePreParsedPlaces:(NSMutableArray*)places
						atIndex:(NSInteger)index
					  withClear:(BOOL)clearStatus {
	
	if(clearStatus)
		[self clearPlacesAtIndex:index];
	
	NSMutableArray *placesAtIndex = [_places objectAtIndex:index];
	
	for(DWPlace *place in places) {
		[placesAtIndex addObject:place];
		place.pointerCount++;
	}
}


//----------------------------------------------------------------------------------------------------
- (void)populateFilteredPlaces:(NSArray*)places {
	[self clearFilteredPlaces:NO];

	for(NSDictionary *place in places){
		DWPlace *new_place = (DWPlace*)[[DWMemoryPool sharedDWMemoryPool]  getOrSetObject:place 
																					atRow:kMPPlacesIndex];
		[_filteredPlaces addObject:new_place];
	}
	
}

//----------------------------------------------------------------------------------------------------
- (void)filterPlacesForSearchText:(NSString*)searchText {
	
	[self clearFilteredPlaces:YES];
	
	/**
	 * A hash for the places found to prevent duplicate search results
	 */
	NSMutableDictionary *placesFound = [[NSMutableDictionary alloc] init];
	
	for(NSMutableArray *placesAtIndex in _places) {
		for (DWPlace *place in placesAtIndex) {
			
			NSComparisonResult result = [place.name compare:searchText 
													options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) 
													  range:NSMakeRange(0, [searchText length])];
			
			if(result == NSOrderedSame || [place.name rangeOfString:searchText
															options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].length > 0) {
				NSString *key = [NSString stringWithFormat:@"%d",place.databaseID];
				
				if(![placesFound objectForKey:key]) {
					[_filteredPlaces addObject:place];
					[placesFound setObject:@"" forKey:key];
				}
			}
			
		} //Columns (places)
	} //Rows
	
	[placesFound release];
}


//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Clear places

//----------------------------------------------------------------------------------------------------
- (void)clearPlacesAtIndex:(NSInteger)index {
	if(_places && index < _capacity) {
		NSMutableArray *placesAtIndex = (NSMutableArray*)[_places objectAtIndex:index];
		
		for(DWPlace *place in placesAtIndex)
			[[DWMemoryPool sharedDWMemoryPool] removeObject:place 
													  atRow:kMPPlacesIndex];
		
		[placesAtIndex removeAllObjects];
	}
}

//----------------------------------------------------------------------------------------------------
- (void)clearPlaces {
	
	for(int i=0;i<_capacity;i++)
		[self clearPlacesAtIndex:i];
}

//----------------------------------------------------------------------------------------------------
- (void)clearFilteredPlaces:(BOOL)arePlacesLocal {
	
	/**
	 * Release memory pool pointers if filtered places were obtained externally
	 */
	if(!arePlacesLocal) {
		for(DWPlace *place in _filteredPlaces)
			[[DWMemoryPool sharedDWMemoryPool] removeObject:place 
													  atRow:kMPPlacesIndex];
	}
	
	[_filteredPlaces removeAllObjects];
}


@end
