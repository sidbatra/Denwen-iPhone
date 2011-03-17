//
//  DWMessageCell.m
//  Denwen
//
//  Created by Deepak Rao on 2/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWMessageCell.h"


@implementation DWMessageCell


@synthesize customTextLabel;


#pragma mark -
#pragma mark Cell Lifecycle 


// Override the init method
//
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
		self.textLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
		self.textLabel.textAlignment = UITextAlignmentCenter;
		
		CGRect rect = CGRectMake(0,-5,self.contentView.frame.size.width,self.contentView.frame.size.height);
		self.customTextLabel = [[UILabel alloc] initWithFrame:rect];
		self.customTextLabel.hidden = YES;
		self.customTextLabel.font = [UIFont fontWithName:@"Helvetica" size:15];	
		self.customTextLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
		self.customTextLabel.backgroundColor = [UIColor clearColor];
		self.customTextLabel.textAlignment = UITextAlignmentCenter;
		[self.contentView addSubview:self.customTextLabel];
		[self.customTextLabel release];
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
