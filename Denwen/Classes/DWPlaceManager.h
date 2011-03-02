//
//  DWPlaceManager.h
//  Denwen
//
//  Created by Deepak Rao on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWMemoryPool.h"
#import "DWPlace.h"
#import "DWURLConnection.h"

@protocol DWPlaceManagerDelegate;

@interface DWPlaceManager : NSObject {
	NSMutableArray *_places;
	NSMutableArray *_filteredPlaces;
	
	NSInteger _capacity;
	NSInteger _rowsFilled;
}

@property (readonly) NSInteger rowsFilled;


- (id)initWithCapacity:(NSInteger)capacity;

- (NSInteger)totalPlacesAtRow:(NSInteger)row;
- (NSInteger)totalFilteredPlaces;

- (void)addPlace:(DWPlace*)place atRow:(NSInteger)row andColumn:(NSInteger)column;

- (DWPlace *)getPlaceAtRow:(NSInteger)row andColumn:(NSInteger)column;
- (DWPlace *)getFilteredPlace:(NSInteger)index;

- (void)populatePlaces:(NSArray*)places atIndex:(NSInteger)index withClear:(BOOL)clearStatus;
- (void)populatePlaces:(NSArray*)places atIndex:(NSInteger)index;
- (void)populateFilteredPlaces:(NSArray*)places;

- (void)clearPlaces;
- (void)clearFilteredPlaces:(BOOL)arePlacesLocal;
- (void)filterPlacesForSearchText:(NSString*)searchText;



@end
