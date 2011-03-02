//
//  TwitterRushViewController.m
//  TwitterRush

#import "TwitterRushViewController.h"
#import "SA_OAuthTwitterEngine.h"


/* Define the constants below with the Twitter 
   Key and Secret for your application. Create
   Twitter OAuth credentials by registering your
   application as an OAuth Client here: http://twitter.com/apps/new
 */

#define kOAuthConsumerKey				@"kC2Kv9gsqYdZGwHHzx4bTQ"	    //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret			@"CO7MYDyF2TyzBAVPzARIWt7GI6SLSb1fgAcMPhLgE"		//REPLACE With Twitter App OAuth Secret

@implementation TwitterRushViewController

@synthesize tweetTextField; 

#pragma mark Custom Methods

-(IBAction)updateTwitter:(id)sender
{
	//Dismiss Keyboard
	[tweetTextField resignFirstResponder];
	
	//Twitter Integration Code Goes Here
	[_engine sendUpdate:tweetTextField.text];
}

#pragma mark ViewController Lifecycle

- (void)viewDidAppear: (BOOL)animated {
		
	if(!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey    = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;	
	}
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
	
	if (controller){
		[self presentModalViewController: controller animated: YES];
	}

}
	   
- (void)viewDidUnload {	
	[tweetTextField release];
	tweetTextField = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[_engine release];
	[tweetTextField release];
    [super dealloc];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {

	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	NSLog(@"%@",[defaults objectForKey:@"authData"]);
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}



@end
