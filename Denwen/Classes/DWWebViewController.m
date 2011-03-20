//
//  DWWebViewController.m
//  Denwen
//
//  Created by Deepak Rao on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DWWebViewController.h"

@implementation DWWebViewController

@synthesize webView;

#pragma mark -
#pragma mark View lifecycle


// Init the view with initializations for the member variables
//
- (id)initWithResourceURL:(NSString*)theURL {
	self = [super init];
    
	if (self) {
		NSURL *url = [[NSURL alloc] initWithString:theURL];
		_request = [[NSURLRequest alloc] initWithURL:url];
		[url release];
	}
    
	return self;
}


// Setup the UI and begin downloading the URL
//
- (void)viewDidLoad {
	//self.navigationItem.titleView = [DWGUIManager navBarTitleLabel];
	
	webView.delegate = self;
	webView.scalesPageToFit =YES;
	[webView loadRequest:_request];
}


// Start the spinner when the file begins downloading
//
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[DWGUIManager showSpinnerInNav:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


// End the spinner and display a message if any error occurs during the download
//
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[DWGUIManager hideSpinnnerInNav:self];
	
	/*
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"There was an error in opening the url, please try again later"
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];	
	*/ 
}


// Event called when the web view finished loading request
//
-(void)webViewDidFinishLoad:(UIWebView *)webView{
	[DWGUIManager hideSpinnnerInNav:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}



#pragma mark -
#pragma mark Memory management


// The usual did receive memory warning
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// The usual memory cleanup
//
- (void)dealloc {
	[webView release];
	[_request release];
    [super dealloc];
}


@end