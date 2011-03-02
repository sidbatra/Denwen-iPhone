//
//  DWPlaceManager.m
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPlaceManager.h"


@implementation DWPlaceManager

@synthesize rowsFilled=_rowsFilled;


// Init the class along with its member variables 
//
- (id)initWithCapacity:(NSInteger)capacity {
	self = [super init];
	
	if(self != nil) {
		_capacity = capacity;
		_rowsFilled = 0;
		
		_places = [[NSMutableArray alloc] init];
		
		// Create a double array of places where each row can hold
		// multiple places. Each row represents a grouping like nearby, followed etc.
		//
		for(int i=0;i<_capacity;i++)
			[_places addObject:[[NSMutableArray alloc] init]];
		
		_filteredPlaces = [[NSMutableArray alloc] init];
	}
	return self;  
}


// Add the place at the given row and column
//
- (void)addPlace:(DWPlace*)place atRow:(NSInteger)row andColumn:(NSInteger)column {
	[[_places objectAtIndex:row] insertObject:place atIndex:column];
	place.pointerCount++;
}


// Retreive the place at the given index. 
//
- (DWPlace *)getPlaceAtRow:(NSInteger)row andColumn:(NSInteger)column {
	return column < [[_places objectAtIndex:row] count] ? [[_places objectAtIndex:row] objectAtIndex:column] : nil;
}

// Retrieve filtered place at the given index
//
- (DWPlace *)getFilteredPlace:(NSInteger)index {
	return [_filteredPlaces objectAtIndex:index];
}


// Returns the total number of places at the given row
//
- (NSInteger)totalPlacesAtRow:(NSInteger)row {
	return [[_places objectAtIndex:row] count];
}

// Returns the total number of filtered places
//
- (NSInteger)totalFilteredPlaces {
	return [_filteredPlaces count];
}


// Call the primary populatePlaces method with clearStatus as NO
//
- (void)populatePlaces:(NSArray*)places atIndex:(NSInteger)index {
	[self populatePlaces:places atIndex:index withClear:YES];
}

	
// Populate the places array from an array of places parsed from JSON
//
- (void)populatePlaces:(NSArray*)places atIndex:(NSInteger)index withClear:(BOOL)clearStatus {
	
	if(clearStatus)
		[self clearPlaces];
	
	_rowsFilled++;
	
	NSMutableArray *placesAtIndex = [_places objectAtIndex:index];
	
	for(NSDictionary *place in places) {
		DWPlace *new_place = (DWPlace*)[DWMemoryPool getOrSetObject:place atRow:PLACES_INDEX];
		[placesAtIndex addObject:new_place];
	}
}


// Populate the filtered places array from an array of places parsed from JSON
//
- (void)populateFilteredPlaces:(NSArray*)places {
	[self clearFilteredPlaces:NO];

	for(NSDictionary *place in places){
		DWPlace *new_place = (DWPlace*)[DWMemoryPool getOrSetObject:place atRow:PLACES_INDEX];
		[_filteredPlaces addObject:new_place];
	}
	
}


// Cleans the _places array
//
- (void)clearPlaces {
	if(_places && _rowsFilled >= _capacity) {
		_rowsFilled = 0;
		
		for(int i=0;i<_capacity;i++) {
			NSMutableArray *placesAtIndex = (NSMutableArray*)[_places objectAtIndex:i];
			
			for(DWPlace *place in placesAtIndex)
				[DWMemoryPool removeObject:place atRow:PLACES_INDEX];
			
			[placesAtIndex removeAllObjects];
		}
		
	}
}

// Cleans the _filteredPlaces array
//
- (void)clearFilteredPlaces:(BOOL)arePlacesLocal {
	
	//Release pointers if filtered places were pulled from the server
	//
	if(!arePlacesLocal) {
		for(DWPlace *place in _filteredPlaces)
			[DWMemoryPool removeObject:place atRow:PLACES_INDEX];
	}
	
	[_filteredPlaces removeAllObjects];
}



// Find places in the existing _places array that match the searchText
// and populate the _filteredPlaces array
//
- (void)filterPlacesForSearchText:(NSString*)searchText {
	
	// Remove old filtered places
	[self clearFilteredPlaces:YES];
	
	if(!_filteredPlaces)
		_filteredPlaces = [[NSMutableArray alloc] init];
	
	//A hash for the places found to prevent duplicates
	NSMutableDictionary *placesFound = [[NSMutableDictionary alloc] init];

	for(NSMutableArray *placesAtIndex in _places) {
		for (DWPlace *place in placesAtIndex) {
			NSComparisonResult result = [place.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
			
			if(result == NSOrderedSame || [place.name rangeOfString:searchText options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].length > 0) {
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



#pragma mark -
#pragma mark Memory management


// The usual cleanup
//
- (void)dealloc {
	
	for(NSMutableArray *placesAtIndex in _places) {
		
		for(DWPlace *place in placesAtIndex)
			[DWMemoryPool removeObject:place atRow:PLACES_INDEX];

		[placesAtIndex release];
	}
	
	[_places release];
	[_filteredPlaces release];
	
	[super dealloc];
}


@end
