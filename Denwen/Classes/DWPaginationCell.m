//
//  DWPaginationCell.m
//  Denwen
//
//  Created by Siddharth Batra on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWPaginationCell.h"

@interface DWPaginationCell() 

- (void) createSpinner;
- (void) drawCellItems;

@end

@implementation DWPaginationCell


#pragma mark -
#pragma mark Cell Lifecycle 


// Override the init method
//
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self drawCellItems];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


#pragma mark -
#pragma mark Cell Creation 


// Creates a button which is used to display the spinner in the loading cell
//
- (void) createSpinner {
	CGRect rect     = CGRectMake((self.contentView.frame.size.width - SPINNER_HEIGHT)/2, 
                                 (kPaginationCellHeight-SPINNER_HEIGHT)/2, SPINNER_HEIGHT, SPINNER_HEIGHT); 
	spinner         = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //spinner.alpha   = 0.5;
	spinner.frame   = rect;
	
	[self.contentView addSubview:spinner];	
	[spinner release];
}

// Create a customized wireframe of the loading cell.
//
- (void) drawCellItems {
	[self createSpinner];	
}


// Display the spinner and hide the message
//
- (void)displayProcessingState {
	[spinner startAnimating];
}


#pragma mark -
#pragma mark Memory Management 


// The ususal memory cleanup
//
- (void)dealloc {
    [super dealloc];
}


@end
