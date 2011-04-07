//
//  DWPlacesManager.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWPlace.h"

/**
 * Manages groups of places and abstracts their memeory management, retreival
 * and local filtering
 */
@interface DWPlacesManager : NSObject {
	NSMutableArray	*_places;
	NSMutableArray	*_filteredPlaces;
	
	NSInteger		_capacity;
}

/**
 * Init and capacity indicates the different grouping or types of places
 * the places manager will be used to hold. Eg: - followed places, nearby places
 */
- (id)initWithCapacity:(NSInteger)capacity;

/**
 * Returns total number of places at a particular row
 * (row represents a grouping)
 */
- (NSInteger)totalPlacesAtRow:(NSInteger)row;

/**
 * Returns total number of places found after running a filter operation
 */
- (NSInteger)totalFilteredPlaces;

/**
 * Retrieve place for a aprticular grouping at a particular column
 */
- (DWPlace*)getPlaceAtRow:(NSInteger)row 
				 andColumn:(NSInteger)column;

/**
 * Retrieve the entire array of places for a group
 */
- (NSMutableArray*)getPlacesAtRow:(NSInteger)row;

/**
 * Retreive a filtered place at the given index
 */
- (DWPlace *)getFilteredPlace:(NSInteger)index;

/**
 * Insert a place for a particular grouping (row) at a particular column
 */
- (void)addPlace:(DWPlace*)place 
		   atRow:(NSInteger)row
	   andColumn:(NSInteger)column;

/**
 * Populate a whole array of places at the given index. clearStatus
 * indicates whether the results are added incrementally or not
 */
- (void)populatePlaces:(NSArray*)places 
			   atIndex:(NSInteger)index
			 withClear:(BOOL)clearStatus;

/**
 * Overload for the generic populate places with clearStatus 
 * set to YES by default
 */
- (void)populatePlaces:(NSArray*)places 
			   atIndex:(NSInteger)index;

/**
 * Populate an entire of array of pre parsed places at the given row.
 * clearStatus indicates appending or replacing.
 * The entries are references to tbe memory pool so reference counts are incremented
 */
- (void)populatePreParsedPlaces:(NSMutableArray*)places
						atIndex:(NSInteger)index
					  withClear:(BOOL)clearStatus;

/**
 * Populate filtered places externally 
 */
- (void)populateFilteredPlaces:(NSArray*)places;

/**
 * Populate filtered places internally by searching for
 * the given search term
 */
- (void)filterPlacesForSearchText:(NSString*)searchText;

/**
 * Clear places for all the groupings
 */
- (void)clearPlaces;

/**
 * Clear places for aa particular grouping
 */
- (void)clearPlacesAtIndex:(NSInteger)index;

/**
 * Clear the filtered places list. arePlacesLocal checks if the
 * results were populated externally or internally. Results populated
 * externally via the populateFilteredPlaces method are also
 * cleared form the memory pool whereas local results populated via 
 * filterPlacesForSearchText are also obtained via the memory pool
 * but _places is assumed to always have a copy so they aren't cleared
 * from the memory pool
 */
- (void)clearFilteredPlaces:(BOOL)arePlacesLocal;

@end
