//
//  DWImageViewController.h
//  Denwen
//
//  Created by Denwen on 9/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  DWImageViewController which wraps around GImageView to present a controller for 
//  viewing images
//

#import <UIKit/UIKit.h>

#import "DWRequestsManager.h"
#import "DWImageView.h"
#import "DWCache.h"
#import "DWGUIManager.h"
#import "DWConstants.h"

@interface DWImageViewController : UIViewController<UIScrollViewDelegate> {
	NSString *url;
	NSInteger key;
}

- (id)initWithImageURL:(NSString*)theURL;

@end
