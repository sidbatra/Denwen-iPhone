//
//  DWWebViewController.h
//  Copyright 2011 Denwen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Display a URL in the iOS web view
 */
@interface DWWebViewController : UIViewController <UIWebViewDelegate> {
	UIWebView		*_webView;
	NSString		*_url;
}

/**
 * URL of the webpage
 */
@property (nonatomic,copy) NSString* url;

/**
 * iOS web view
 */
@property (nonatomic,retain) IBOutlet UIWebView *webView;

/**
 * Init with the url of the webpage to be opened
 */
- (id)initWithWebPageURL:(NSString*)theURL;

@end

