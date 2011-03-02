//
//  DWWebViewController.h
//  Denwen
//
//  Created by Deepak Rao on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWGUIManager.h"


@interface DWWebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webView;
	NSURLRequest *_request;
}

@property (nonatomic,retain) IBOutlet UIWebView *webView;

- (id)initWithResourceURL:(NSString*)theURL;

@end

