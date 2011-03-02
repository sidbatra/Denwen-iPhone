//
//  DWPopularItemsViewController.h
//  Denwen
//
//  Created by Siddharth Batra on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWItemFeedViewController.h"



@interface DWPopularItemsViewController : DWItemFeedViewController {
}

- (id)initWithDelegate:(id)delegate;

- (void)viewIsSelected;
- (void)viewIsDeselected;


@end