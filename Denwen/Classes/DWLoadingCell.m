//
//  DWLoadingCell.m
//  Denwen
//
//  Created by Deepak Rao on 2/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWLoadingCell.h"

@interface DWLoadingCell() 

- (void) createSpinner;
- (void) createMessageLabel;
- (void) drawCellItems;

@end

@implementation DWLoadingCell

@synthesize spinner,messageLabel;


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


// Creates a button which is used to display the spinner in the loading cell
//
- (void) createSpinner {
	CGRect rect = CGRectMake(111, (kTVLoadingCellHeight-SPINNER_HEIGHT)/2, SPINNER_HEIGHT, SPINNER_HEIGHT); 
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.frame = rect;
	
	[self.contentView addSubview:spinner];	
	[spinner release];
}


// Creates a message label for the loading text
//
- (void) createMessageLabel {
	CGRect rect = CGRectMake(137, (kTVLoadingCellHeight-SPINNER_HEIGHT)/2 - 1, 0, 17);
	messageLabel = [[UILabel alloc] initWithFrame:rect];	
	messageLabel.font = [UIFont fontWithName:@"Helvetica" size:17];	
	messageLabel.textColor = [UIColor colorWithRed:0.5294 green:0.5294 blue:0.5294 alpha:1.0];
	messageLabel.textAlignment = UITextAlignmentLeft;
	messageLabel.text = LOADING_CELL_MSG;
	[messageLabel sizeToFit];
	
	[self.contentView addSubview:messageLabel];
	[messageLabel release];
}


// Create a customized wireframe of the loading cell.
//
- (void) drawCellItems {
	[self createSpinner];
	[self createMessageLabel];
}


#pragma mark -
#pragma mark Memory Management 


// The ususal memory cleanup
//
- (void)dealloc {
    [super dealloc];
}


@end
