//
//  DWWebViewController.m
//  Copyright 2011 Denwen. All rights reserved.
//

#import "DWWebViewController.h"
#import "DWGUIManager.h"



//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------
@implementation DWWebViewController

@synthesize webView		= _webView;
@synthesize url			= _url;

//----------------------------------------------------------------------------------------------------
- (id)initWithWebPageURL:(NSString*)theURL {
	self = [super init];
    
	if (self) {
		self.url = theURL;
	}
    
	return self;
}

//----------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------------------------------------------------------------------
- (void)dealloc {
	self.webView	= nil;
	self.url		= nil;
	
    [super dealloc];
}

//----------------------------------------------------------------------------------------------------
- (void)viewDidLoad {
	self.webView.delegate			= self;
	self.webView.scalesPageToFit	= YES;
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
	
	[DWGUIManager showSpinnerInNav:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

//----------------------------------------------------------------------------------------------------
- (void)webViewDidStartLoad:(UIWebView *)webView {
}

//----------------------------------------------------------------------------------------------------
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[DWGUIManager hideSpinnnerInNav:self];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

//----------------------------------------------------------------------------------------------------
-(void)webViewDidFinishLoad:(UIWebView *)webView{
	[DWGUIManager hideSpinnnerInNav:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end