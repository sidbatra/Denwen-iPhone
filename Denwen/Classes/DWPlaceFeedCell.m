//
//  DWPlaceFeedCell.m
//  Denwen
//
//  Created by Deepak Rao on 1/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPlaceFeedCell.h"

@interface DWPlaceFeedCell() 

- (void) createPlaceName;
- (void) createPlaceImage;
- (void) createPlaceDetails;
- (void) drawCellItems;

@end

@implementation DWPlaceFeedCell

@synthesize placeName, placeImage,placeDetails;


#pragma mark -
#pragma mark Cell Lifecycle 


// Override the init method
//
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		[self drawCellItems];
    }
    return self;
}



#pragma mark -
#pragma mark Cell Creation 


// Creates a label which is used to display place name in the place feed cell
//
- (void) createPlaceName {
	CGRect rect = CGRectMake(64, 7, 230, 22); //self.contentView.frame.size.width - 56
	placeName = [[UILabel alloc] initWithFrame:rect];
	
	placeName.lineBreakMode = UILineBreakModeTailTruncation;
	placeName.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];	
	placeName.textColor = [UIColor blackColor];
	placeName.highlightedTextColor = [UIColor whiteColor];
		
	[self.contentView addSubview:placeName];
	[placeName release];
}


// Creates an Imageview which is used to display the place image in the place feed cell
//
- (void) createPlaceImage {
	CGRect rect = CGRectMake(0, 0, 55, 55); 
	placeImage = [[UIImageView alloc] initWithFrame:rect];
	[self.contentView addSubview:placeImage];	
	[placeImage release];
}


// Creates a label which is used to display place details
// like city or country in the place feed cell
//
- (void) createPlaceDetails {
	CGRect rect = CGRectMake(64, 31, 230, 16); //NOTE: WIDTH is correct, dont change
	placeDetails = [[UILabel alloc] initWithFrame:rect];
	
	placeDetails.lineBreakMode = UILineBreakModeTailTruncation;
	placeDetails.font = [UIFont fontWithName:@"Helvetica" size:13];	
	placeDetails.textColor = [UIColor colorWithRed:0.1411 green:0.4392 blue:0.8470 alpha:1.0];
	placeDetails.highlightedTextColor = [UIColor whiteColor];
	
	[self.contentView addSubview:placeDetails];
	[placeDetails release];
}


// Create a customized wireframe of the place feed cell.
//
- (void) drawCellItems {
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[self createPlaceName];
	[self createPlaceImage];
	[self createPlaceDetails];
}



#pragma mark -
#pragma mark Memory management


// The usual memory cleanup
//
- (void)dealloc {
    [super dealloc];
}


@end
