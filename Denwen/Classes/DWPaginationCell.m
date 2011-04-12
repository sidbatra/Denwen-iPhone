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
- (void) createMessageLabel;
- (void) drawCellItems;

@end

@implementation DWPaginationCell

@synthesize isInLoadingState=_isInLoadingState;


#pragma mark -
#pragma mark Cell Lifecycle 


// Override the init method
//
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self drawCellItems];
		_isInLoadingState = NO;
    }
    return self;
}


#pragma mark -
#pragma mark Cell Creation 


// Creates a button which is used to display the spinner in the loading cell
//
- (void) createSpinner {
	CGRect rect = CGRectMake((self.contentView.frame.size.width - SPINNER_HEIGHT)/2, 
							 (kPaginationCellHeight-SPINNER_HEIGHT)/2, SPINNER_HEIGHT, SPINNER_HEIGHT); 
	spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.frame = rect;
	
	[self.contentView addSubview:spinner];	
	[spinner release];
}


// Creates a message for the Pagination text
//
- (void) createMessageLabel {
	CGRect rect = CGRectMake(112, 18, 120, 22);
	messageLabel = [[UILabel alloc] initWithFrame:rect];	
	messageLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];	
	messageLabel.textColor = [UIColor colorWithRed:0.098 green:0.333 blue:0.559 alpha:1.0];
	messageLabel.highlightedTextColor = [UIColor whiteColor];
	messageLabel.textAlignment = UITextAlignmentLeft;
	
	[self.contentView addSubview:messageLabel];
	[messageLabel release];
}


// Create a customized wireframe of the loading cell.
//
- (void) drawCellItems {
	[self createMessageLabel];
	[self createSpinner];	
}


// Display the steady state showing a message asking user to click
//
- (void)displaySteadyState {
	_isInLoadingState = NO;
	spinner.hidden = YES;
	[spinner stopAnimating];
	messageLabel.text = PAGINATION_CELL_MSG;
}


// Display the spinner and hide the message
//
- (void)displayProcessingState {
	_isInLoadingState = YES;
	[spinner startAnimating];
	spinner.hidden = NO;
	messageLabel.text = @"";
}


#pragma mark -
#pragma mark Memory Management 


// The ususal memory cleanup
//
- (void)dealloc {
    [super dealloc];
}


@end
