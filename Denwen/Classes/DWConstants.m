//
//  Constants.m
//  Copyright 2011 Denwen. All rights reserved.
//	

//#define PRODUCTION 1 


#import "DWConstants.h"


#ifdef PRODUCTION
	NSString* const kDenwenServer	= @"denwen.com";

	//----------------------------------------------------------------------------------------------------
	NSString* const kS3Policy		= @"eydleHBpcmF0aW9uJzogJzIwMTctMDItMDlUMDU6MDI6MzcuMDAwWicsCiAgICAgICAgJ2NvbmRpdGlvbnMnOiBbCiAgICAgICAgICB7J2J1Y2tldCc6ICdkZW53ZW4nfSwKICAgICAgICAgIHsnYWNsJzogJ3B1YmxpYy1yZWFkJ30sCiAgICAgICAgICBbJ2NvbnRlbnQtbGVuZ3RoLXJhbmdlJywgMCwgNTI0Mjg4MDBdLAogICAgICAgICAgWydzdGFydHMtd2l0aCcsICcka2V5JywgJyddLAogICAgICAgICAgWydzdGFydHMtd2l0aCcsICcnLCAnJ10KICAgICAgICBdCiAgICAgIH0=";
	NSString* const kS3Signature	= @"PG1k3sSsZe6FsxfcnqPobBWHKwc=";
	NSString* const kS3AccessID		= @"AKIAJWYCAWDPAAKLNKSQ";
	NSString* const kS3ACL			= @"public-read";
	NSString* const kS3Server		= @"http://denwen.s3.amazonaws.com/";
#else
	NSString* const kDenwenServer	= @"sbat.denwen.com";
	
	//----------------------------------------------------------------------------------------------------
	NSString* const kS3Policy		= @"eydleHBpcmF0aW9uJzogJzIwMTctMDEtMjRUMDQ6MjA6MjguMDAwWicsCiAgICAgICAgJ2NvbmRpdGlvbnMnOiBbCiAgICAgICAgICB7J2J1Y2tldCc6ICd0ZW53ZW4nfSwKICAgICAgICAgIHsnYWNsJzogJ3B1YmxpYy1yZWFkJ30sCiAgICAgICAgICBbJ2NvbnRlbnQtbGVuZ3RoLXJhbmdlJywgMCwgNTI0Mjg4MDBdLAogICAgICAgICAgWydzdGFydHMtd2l0aCcsICcka2V5JywgJyddLAogICAgICAgICAgWydzdGFydHMtd2l0aCcsICcnLCAnJ10KICAgICAgICBdCiAgICAgIH0=";
	NSString* const kS3Signature	= @"a5XAsCN6H/t4cv5MZ9/vuUOnc5s=";
	NSString* const kS3AccessID		= @"AKIAJWYCAWDPAAKLNKSQ";
	NSString* const kS3ACL			= @"public-read";
	NSString* const kS3Server		= @"http://tenwen.s3.amazonaws.com/";
#endif

//----------------------------------------------------------------------------------------------------
NSString* const kKeyStatus				= @"status";
NSString* const kKeyMessage				= @"message";
NSString* const kKeyBody				= @"body";
NSString* const kKeySuccess				= @"success";
NSString* const kKeyError				= @"error";
NSString* const kKeyErrorMessage		= @"errorMessage";
NSString* const kKeyErrorMessages		= @"error_messages";
NSString* const kKeyImage				= @"image";
NSString* const kKeyResourceID			= @"resourceID";
NSString* const kKeyPlaces				= @"places";
NSString* const kKeyPlace				= @"place";
NSString* const kKeyItems				= @"items";
NSString* const kKeyItem				= @"item";
NSString* const kKeyUsers				= @"users";
NSString* const kKeyUser				= @"user";
NSString* const kKeyID					= @"id";
NSString* const kKeyFilename			= @"filename";
NSString* const kKeyNotificationType	= @"notificationType";
NSString* const kKeyHasPhoto			= @"has_photo";
NSString* const kKeyFirstName			= @"first_name";
NSString* const kKeyLastName			= @"last_name";
NSString* const kKeyEmail				= @"email";
NSString* const kKeyPhoto				= @"photo";
NSString* const kKeySmallURL			= @"small_url";
NSString* const kKeyMediumURL			= @"medium_url";
NSString* const kKeyLargeURL			= @"large_url";
NSString* const kKeyIsProcessed			= @"is_processed";

//----------------------------------------------------------------------------------------------------
NSString* const kNPopularPlacesLoaded		= @"NPopularPlacesLoaded";
NSString* const kNPopularPlacesError		= @"NPopularPlacesError";
NSString* const kNNearbyPlacesLoaded		= @"NNearbyPlacesLoaded";
NSString* const kNNearbyPlacesError			= @"NNearbyPlacesError";
NSString* const kNUserPlacesLoaded			= @"NUserPlacesLoaded";
NSString* const kNUserPlacesError			= @"NUserPlacesError";
NSString* const kNSearchPlacesLoaded		= @"NSearchPlacesLoaded";
NSString* const kNSearchPlacesError			= @"NSearchPlacesError";
NSString* const kNPlaceLoaded				= @"NPlaceLoaded";
NSString* const kNPlaceError				= @"NPlaceError";
NSString* const kNPlaceUpdated				= @"NPlaceUpdated";
NSString* const kNPlaceUpdateError			= @"NPlaceUpdateError";
NSString* const kNNewPlaceCreated			= @"NNewPlaceCreated";
NSString* const kNNewPlaceError				= @"NNewPlaceError";
NSString* const kNNewPlaceParsed			= @"NNewPlaceParsed";
NSString* const kNNewFollowingCreated		= @"NNewFollowingCreated";
NSString* const kNNewFollowingError			= @"NNewFollowingError";
NSString* const kNFollowingDestroyed		= @"NFollowingDestroyed";
NSString* const kNFollowingDestroyError		= @"NFollowingDestroyError";
NSString* const kNUserLoaded				= @"NUserLoaded";
NSString* const kNUserError					= @"NUserError";
NSString* const kNUserUpdated				= @"NUserUpdated";
NSString* const kNUserUpdateError			= @"NUserUpdateError";
NSString* const kNFollowedItemsLoaded		= @"NFollowedItemsLoaded";
NSString* const kNFollowedItemsError		= @"NFollowedItemsError";
NSString* const kNNewItemCreated			= @"NNewItemCreated";
NSString* const kNNewItemError				= @"NNewItemError";
NSString* const kNNewItemParsed				= @"NNewItemParsed";
NSString* const kNNewUserCreated			= @"NNewUserCreated";
NSString* const kNNewUserError				= @"NNewUserError";	
NSString* const kNNewSessionCreated			= @"NNewSessionCreated";
NSString* const kNNewSessionError			= @"NNewSessionError";
NSString* const kNS3UploadDone				= @"NS3UploadDone";
NSString* const kNS3UploadError				= @"NS3UploadError";
NSString* const kNImgSmallUserLoaded		= @"NImgSmallUserLoaded";
NSString* const kNImgSmallUserError			= @"NImgSmallUserError";
NSString* const kNImgMediumUserLoaded		= @"NImgMediumUserLoaded";
NSString* const kNImgMediumUserError		= @"NImgMediumUserError";
NSString* const kNImgLargeUserLoaded		= @"NImgLargeUserLoaded";
NSString* const kNImgLargeUserError			= @"NImgLargeUserError";
NSString* const kNImgSmallPlaceLoaded		= @"NImgSmallPlaceLoaded";
NSString* const kNImgSmallPlaceError		= @"NImgSmallPlaceError";
NSString* const kNImgMediumPlaceLoaded		= @"NImgMediumPlaceLoaded";
NSString* const kNImgMediumPlaceError		= @"NImgMediumPlaceError";
NSString* const kNImgLargePlaceLoaded		= @"NImgLargePlaceLoaded";
NSString* const kNImgLargePlaceError		= @"NImgLargePlaceError";
NSString* const kNImgMediumAttachmentLoaded	= @"NImgMediumAttachmentLoaded";
NSString* const kNImgMediumAttachmentError	= @"NImgMediumAttachmentError";
NSString* const kNImgLargeAttachmentLoaded	= @"NImgLargeAttachmentLoaded";
NSString* const kNImgLargeAttachmentError	= @"NImgLargeAttachmentError";
NSString* const kNImgActualAttachmentLoaded	= @"NImgActualAttachmentLoaded";
NSString* const kNImgActualAttachmentError	= @"NImgActualAttachmentError";
NSString* const kNNewApplicationBadge		= @"NNewApplicationBadge"; 
NSString* const kNTabSelectionChanged		= @"NTabSelectionChanged";

//----------------------------------------------------------------------------------------------------
NSInteger const kPNLive			= 0;
NSInteger const kPNBackground	= 1;

//----------------------------------------------------------------------------------------------------
NSInteger const kImgSmallUser			= 0;
NSInteger const kImgMediumUser			= 1;
NSInteger const kImgLargeUser			= 2;
NSInteger const kImgSmallPlace			= 3;
NSInteger const kImgMediumPlace			= 4;
NSInteger const kImgLargePlace			= 5;
NSInteger const kImgMediumAttachment	= 6;
NSInteger const kImgLargeAttachment		= 7;
NSInteger const kImgActualAttachment	= 8;

//----------------------------------------------------------------------------------------------------
NSInteger const kTableViewAsData			= 0;
NSInteger const kTableViewAsSpinner			= 1;
NSInteger const kTableViewAsMessage			= 2;
NSInteger const kTableViewAsProfileMessage	= 3;

//----------------------------------------------------------------------------------------------------
NSInteger const kTVLoadingCellCount			= 5;
NSInteger const kTVLoadingCellHeight		= 74;
NSString* const kTVPaginationCellIdentifier = @"PaginationCell";
NSString* const kTVMessageCellIdentifier	= @"MessageCell";
NSString* const kTVLoadingCellIdentifier	= @"LoadingCell";
NSString* const kTVDefaultCellIdentifier	= @"Cell";

//----------------------------------------------------------------------------------------------------
NSInteger const kSegmentedPlacesViewWidth	= 320;
NSInteger const kSegmentedPlacesViewHeight	= 44;

//----------------------------------------------------------------------------------------------------
NSInteger const kLocFreshness				= 9;
NSInteger const kLocAccuracy				= 1100;
NSInteger const kLocRefreshDistance			= 750;
NSInteger const kLocFailSafeDuration		= 6;
NSInteger const kLocNearbyRadius			= 1200;

//----------------------------------------------------------------------------------------------------
NSInteger const kPagInitialPage		= 0;

//----------------------------------------------------------------------------------------------------
NSInteger const kMPTotalClasses			= 3;
NSInteger const kMPItemsIndex			= 0;
NSInteger const kMPPlacesIndex			= 1;
NSInteger const kMPUsersIndex			= 2;
NSInteger const kMPObjectUpdateInterval = 5;

//----------------------------------------------------------------------------------------------------
NSString* const kMsgNoPlacesNearby				= @"No places nearby";
NSString* const kMsgNoFollowPlacesCurrentUser	= @"You aren't following any places yet";
NSString* const kMsgNoFollowPlacesNormalUser	= @"This user isn't following any places yet";
NSString* const kMsgTakeFirstPhoto				= @"Take Photo";
NSString* const kMsgChooseFirstPhoto			= @"Choose Existing";
NSString* const kMsgTakeBetterPhoto				= @"Take Better Photo";
NSString* const kMsgChooseBetterPhoto			= @"Choose Better Photo";
NSString* const kMsgTakeMedia					= @"Take Photo or Video";
NSString* const kMsgChooseMedia					= @"Choose Existing";
NSString* const kMsgCancelPhoto					= @"Cancel";
NSString* const kMsgCancelMedia					= @"Cancel";

//----------------------------------------------------------------------------------------------------
NSString* const kImgGenericPlaceHolder = @"generic_placeholder.png";



//----------------------------------------------------------------------------------------------------
NSString* const kPlaceListViewControllerNib		= @"DWPlaceListViewController";
NSString* const kGenericBackButtonTitle			= @"Back";
NSInteger const kStatusBarStyle					= UIStatusBarStyleBlackOpaque;
NSInteger const kAttachmentHeight				= 196;
NSInteger const kAttachmentYPadding				= 10;
NSInteger const kURLTagMultipler				= 100;
NSInteger const kPaginationCellHeight			= 60;
NSInteger const kUserViewCellHeight				= 126;



/* File Types */
int const IMAGE = 0;
int const VIDEO = 1;


#ifdef PRODUCTION

/* Keys for third party services */

//Offical DENWEN app made by sbat
NSString * const TWITTER_OAUTH_CONSUMER_KEY = @"Y8wcijb0orzZSbkd3fQ4g";
NSString * const TWITTER_OAUTH_CONSUMER_SECRET = @"i7Oqqpy1I1ZycqRpJOSsBMylURsFlC2Qo7pQc0YbUzk";

//Official DENWEN facebook app made by sbat
NSString * const FACEBOOK_APP_ID = @"127979053940843";

#else

/* Keys for third party services */

//TENWEN app made by drao
NSString * const TWITTER_OAUTH_CONSUMER_KEY = @"kC2Kv9gsqYdZGwHHzx4bTQ";
NSString * const TWITTER_OAUTH_CONSUMER_SECRET = @"CO7MYDyF2TyzBAVPzARIWt7GI6SLSb1fgAcMPhLgE";

//TENWEN facebook app made by drao
NSString * const FACEBOOK_APP_ID = @"176869555684965";

#endif



/* Location manager constants */
int const LOCATION_FRESHNESS = 9;
int const LOCATION_ACCURACY = 1100;
int const LOCATION_REFRESH_DISTANCE = 750;
int const LOCATION_FAILSAFE_DURATION = 6;


/* max lengths for texts */
int const MAX_PLACE_NAME_LENGTH = 32;
int const MAX_POST_DATA_LENGTH = 180;
int const MAX_SHARE_DATA_LENGTH = 140;


/* JPEG compression */
float const JPEG_COMPRESSION = 0.6;

/* iPhone UI Attributes */
float const SCREEN_WIDTH = 320.0;
float const SCREEN_HEIGHT = 416.0;
float const SCREEN_ROTATED_WIDTH = 480.0;
float const SCREEN_ROTATED_HEIGHT = 256.0;

/* Back button title*/
NSString * const BACK_BUTTON_TITLE = @"Back";
NSString * const BACK_BUTTON_SELF_TITLE = @"Profile";

/* Tagbar titles and image names */
NSString * const PROFILE_TAB_NAME = @"Profile";
NSString * const PROFILE_TAB_IMAGE_NAME = @"profile.png";

/* placeholder images */
NSString * const PLACE_SMALL_PLACEHOLDER_IMAGE_NAME = @"place_small_placeholder.png";
NSString * const PLACE_MEDIUM_PLACEHOLDER_IMAGE_NAME = @"camera_button.png";
NSString * const PLACE_LARGE_PLACEHOLDER_IMAGE_NAME = @"place_placeholder.png";



NSString * const USER_PROFILE_CREATE_POST_IMAGE_NAME = @"create_post_user_profile.png";
NSString * const USER_PROFILE_CREATE_POST_HIGHLIGHTED_IMAGE_NAME = @"create_post_user_profile_on.png";
NSString * const USER_PROFILE_CREATE_PLACE_IMAGE_NAME = @"create_place_user_profile.png";
NSString * const USER_PROFILE_CREATE_PLACE_HIGHLIGHTED_IMAGE_NAME = @"create_place_user_profile_on.png";

NSString * const USER_PROFILE_BG_TEXTURE = @"user_profile_bg.png";
NSString * const PLACE_VIEW_FADE_IMAGE_NAME = @"refreshfade.png";
NSString * const TRANSPARENT_PLACEHOLDER_IMAGE_NAME = @"trans40.png";
NSString * const TRANSPARENT_BUTTON_BG_IMAGE_NAME = @"trans27.png";
NSString * const FOLLOW_BUTTON_BG_IMAGE_NAME = @"button_bg.png";
NSString * const FOLLOW_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME = @"button_bg_on.png";
NSString * const FOLLOWING_BUTTON_BG_IMAGE_NAME = @"following_place_profile.png";
NSString * const FOLLOWING_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME = @"following_place_profile_on.png";
NSString * const SHARE_PLACE_BUTTON_BG_IMAGE_NAME = @"share_place_profile.png";
NSString * const SHARE_PLACE_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME = @"share_place_profile_on.png";
NSString * const CHANGE_USER_PIC_IMAGE_NAME = @"changeuserpic.png";
NSString * const CHANGE_PLACE_PIC_IMAGE_NAME = @"changeplacepic.png";
NSString * const ARROW_BUTTON_USER_IMAGE_NAME = @"arrow_place_button.png";
NSString * const ARROW_BUTTON_PLACE_IMAGE_NAME = @"arrow_place_button.png";
NSString * const ARROW_BUTTON_IMAGE_NAME = @"arrow_button.png";

NSString * const MODALVIEW_BACKGROUND_IMAGE = @"modalview_bg.png";

NSString * const NEW_POST_TEXTVIEW_PLACEHOLDER_TEXT = @"What's going on here?";

/* Video attributes */
NSString * const VIDEO_TINY_PREVIEW_PLACEHOLDER_IMAGE_NAME = @"video_attach.png";
NSString * const VIDEO_PREVIEW_PLACEHOLDER_IMAGE_NAME = @"video_placeholder.png";
NSString * const VIDEO_PLAY_BUTTON_IMAGE_NAME = @"play.png";
int const VIDEO_MAX_DURATION = 45;

/* App UI Attributes */


// Feed table and cell related
int const FEED_TABLE_HEIGHT = 416;
int const DYNAMIC_CELL_HEIGHT_REFERENCE_WIDTH = 304;
int const USER_LABEL_PADDING = 5;
int const USER_NAME_PADDING = 5;
int const FOLLOW_PLACE_CELL_HEIGHT = 177;//141;
int const FOLLOW_CURRENT_USER_CELL_HEIGHT = 177;//141;//192;
int const SPINNER_HEIGHT = 20;
int const VIDEO_VIEW_SPINNER_SIDE = 25;



// Image sizes
int const SIZE_PLACE_SMALL_IMAGE = 75;
int const SIZE_PLACE_MEDIUM_IMAGE = 100;
int const SIZE_PLACE_LARGE_IMAGE = 320;
int const SIZE_PLACE_PRE_UPLOAD_IMAGE = 75;
int const SIZE_USER_SMALL_IMAGE = 30;
int const SIZE_USER_MEDIUM_IMAGE = 100;
int const SIZE_USER_PRE_UPLOAD_IMAGE = 75;
int const SIZE_ATTACHMENT_IMAGE = 250;
int const SIZE_ATTACHMENT_PRE_UPLOAD_IMAGE = 75;


NSString * const FOLLOW_PLACE_CELL_IDENTIFIER = @"FollowPlaceCell";
NSString * const USER_CELL_IDENTIFIER = @"UserCell";
NSString * const PIN_IDENTIFIER = @"PinIdentifier";



NSString * const DENWEN_URL_PREFIX = @"denwen://p/";
NSString * const FACEBOOK_URL_PREFIX = @"fb";

// Folders on S3
NSString * const S3_ITEMS_FOLDER = @"items";
NSString * const S3_USERS_FOLDER = @"user_photos";
NSString * const S3_PLACES_FOLDER = @"place_photos";


// JSON keys for models 
NSString * const PLACE_JSON_KEY = @"place";
NSString * const USER_JSON_KEY = @"user";
NSString * const ITEM_JSON_KEY = @"item";
NSString * const ATTACHMENT_JSON_KEY = @"attachment";
NSString * const ADDRESS_JSON_KEY = @"address";
NSString * const FOLLOWING_JSON_KEY = @"following";
NSString * const PHOTO_JSON_KEY = @"photo";
NSString * const ITEMS_JSON_KEY = @"items";
NSString * const PLACES_JSON_KEY = @"places";
NSString * const URLS_JSON_KEY = @"urls";
NSString * const ERROR_MESSAGES_JSON_KEY = @"error_messages";
NSString * const CONDENSED_DATA_JSON_KEY = @"condensed_data";
NSString * const CREATED_AT_JSON_KEY = @"created_at_timestamp";
NSString * const DATABASE_ID_JSON_KEY = @"id";




//Messages used across the apps
NSString * const FOLLOW_PLACES_MSG = @"Follow Place";
NSString * const UNFOLLOW_PLACES_MSG = @"Following";
NSString * const FOLLOW_LOGGEDOUT_MSG = @"Sign up to start following places";
NSString * const SHARE_LOGGEDOUT_MSG = @"Sign up to start sharing places";
NSString * const MAP_TOOLTIP_MSG = @"Hold and drag to move pin";
NSString * const LOADING_CELL_MSG = @"Loading...";
NSString * const PAGINATION_CELL_MSG = @"Load more...";
NSString * const FINDING_LOCALITY_MSG = @"Finding locality";
NSString * const EMPTY_POST_MSG = @"Post can't be empty";
NSString * const EMPTY_PLACENAME_MSG = @"Place name can't be empty";
NSString * const EMPTY_LOGIN_FIELDS_MSG = @"Please fill out all the required fields.";



//Different badge notifications types
NSString * const BADGE_NOTIFICATION_LIVE = @"b_live";
NSString * const BADGE_NOTIFICATION_BACKGROUND = @"b_back";


// Notification names
NSString * const N_LOCATION_CHANGED = @"LocationChanged";
NSString * const N_FOLLOWED_ITEMS_READ = @"FollowedItemsRead";
NSString * const N_FACEBOOK_URL_OPENED = @"FacebookURLOpened";
NSString * const N_DENWEN_URL_OPENED = @"DenwenURLOpened";
NSString * const N_USER_LOGS_IN = @"UserLogsIn";
NSString * const N_USER_LOGS_OUT = @"UserLogsOut";
NSString * const N_NEW_ITEM_CREATED = @"NewItemCreated";



@implementation DWConstants

@end
