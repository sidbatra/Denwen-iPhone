//
//  DWMessageCell.m
//  Denwen
//
//  Created by Deepak Rao on 2/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWMessageCell.h"


@implementation DWMessageCell


#pragma mark -
#pragma mark Cell Lifecycle 


// Override the init method
//
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
		self.textLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
		self.textLabel.textAlignment = UITextAlignmentCenter;
	}
	
    return self;
}



#pragma mark -
#pragma mark Memory Management 


// The ususal memory cleanup
//
- (void)dealloc {
    [super dealloc];
}


@end
