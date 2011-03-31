//
//  Constants.m
//  Copyright 2011 Denwen. All rights reserved.
//	

#define PRODUCTION 1 


#import "Constants.h"


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
NSString* const kKeyStatus			= @"status";
NSString* const kKeyMessage			= @"message";
NSString* const kKeyBody			= @"body";
NSString* const kKeySuccess			= @"success";
NSString* const kKeyError			= @"error";
NSString* const kKeyErrorMessage	= @"errorMessage";
NSString* const kKeyErrorMessages	= @"error_messages";
NSString* const kKeyImage			= @"image";
NSString* const kKeyResourceID		= @"resourceID";
NSString* const kKeyPlaces			= @"places";
NSString* const kKeyPlace			= @"place";
NSString* const kKeyFilename		= @"filename";

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
NSInteger const kSegmentedPlacesViewWidth	= 320;
NSInteger const kSegmentedPlacesViewHeight	= 44;





/* File Types */
int const IMAGE = 0;
int const VIDEO = 1;

/* Status messages received from the server */
NSString * const SUCCESS_STATUS = @"success";
NSString * const ERROR_STATUS = @"error";

/* Key used in NSUSerDefaults to store the current user object*/
NSString * const CURRENT_USER_KEY = @"signedin_user_";



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
int const LOCATION_NEARBY_RADIUS = 1200;

/* instances ID for request managers and url connections*/
int const SEARCH_INSTANCE_ID = 99;

/* selected segmented indices */
int const SELECTED_ITEMS_INDEX = 1;
int const SELECTED_PLACES_INDEX = 0;

/* max lengths for texts */
int const MAX_PLACE_NAME_LENGTH = 32;
int const MAX_POST_DATA_LENGTH = 180;
int const MAX_SHARE_DATA_LENGTH = 140;


/* Caching */
int const CACHE_INTERNAL = 259200.0; //3 days in seconds ; 1DAY = 86400 seconds
int const MAX_CACHE_ITEM_SIZE = 838861;//1MB = 1048576 BYTES; 

/* Paging constants */
int const ITEMS_PER_PAGE = 20;
int const PLACES_PER_PAGE = 20;

/* Minimum time elapsed for a pool object to update from its JSON */
int const POOL_OBJECT_UPDATE_INTERVAL = 5;

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
NSString * const POSTS_TAB_NAME = @"Feed";
NSString * const PROFILE_TAB_NAME = @"Profile";
NSString * const PLACES_TAB_NAME = @"Places";
NSString * const POSTS_TAB_IMAGE_NAME = @"posts.png";
NSString * const PROFILE_TAB_IMAGE_NAME = @"profile.png";
NSString * const PLACES_TAB_IMAGE_NAME = @"places.png";

/* placeholder images */
NSString * const GENERIC_PLACEHOLDER_IMAGE_NAME = @"generic_placeholder.png";
NSString * const PLACE_SMALL_PLACEHOLDER_IMAGE_NAME = @"place_small_placeholder.png";
NSString * const PLACE_MEDIUM_PLACEHOLDER_IMAGE_NAME = @"camera_button.png";
NSString * const PLACE_LARGE_PLACEHOLDER_IMAGE_NAME = @"place_placeholder.png";

NSString * const USER_SMALL_PLACEHOLDER_IMAGE_NAME = @"user_small_placeholder.png";
NSString * const USER_MEDIUM_PLACEHOLDER_IMAGE_NAME = @"user_medium_placeholder.png";
NSString * const USER_SIGNED_IN_MEDIUM_PLACEHOLDER_IMAGE_NAME = @"profile_button.png";
NSString * const USER_LARGE_PLACEHOLDER_IMAGE_NAME = @"place_placeholder.png";
NSString * const USER_PROFILE_CREATE_POST_IMAGE_NAME = @"create_post_user_profile.png";
NSString * const USER_PROFILE_CREATE_POST_HIGHLIGHTED_IMAGE_NAME = @"create_post_user_profile_on.png";
NSString * const USER_PROFILE_CREATE_PLACE_IMAGE_NAME = @"create_place_user_profile.png";
NSString * const USER_PROFILE_CREATE_PLACE_HIGHLIGHTED_IMAGE_NAME = @"create_place_user_profile_on.png";

NSString * const USER_PROFILE_BG_TEXTURE = @"user_profile_bg.png";
NSString * const PLACE_VIEW_FADE_IMAGE_NAME = @"refreshfade.png";
NSString * const USER_VIEW_FADE_IMAGE_NAME = @"userprofilefade.png";
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

int const STATUS_BAR_STYLE = UIStatusBarStyleBlackOpaque;

// Feed table and cell related
int const FEED_TABLE_HEIGHT = 416;
int const DYNAMIC_CELL_HEIGHT_REFERENCE_WIDTH = 304;
int const MAX_DYNAMIC_CELL_HEIGHT = 2000;
int const ATTACHMENT_HEIGHT = 196;
int const ATTACHMENT_Y_PADDING = 10;
int const USER_LABEL_PADDING = 5;
int const USER_NAME_PADDING = 5;
int const PLACE_FEED_CELL_HEIGHT = 56;
int const FOLLOW_PLACE_CELL_HEIGHT = 177;//141;
int const FOLLOW_CURRENT_USER_CELL_HEIGHT = 177;//141;//192;
int const FOLLOW_USER_CELL_HEIGHT = 126;
int const LOADING_CELL_HEIGHT = 74;
int const LOADING_CELL_COUNT = 5;
int const SPINNER_HEIGHT = 20;
int const VIDEO_VIEW_SPINNER_SIDE = 25;
int const SPINNER_CELL_INDEX = 2;
int const SPINNER_CELL_PLACE_INDEX = 1;
int const MESSAGE_CELL_INDEX = 2;
int const MESSAGE_CELL_PLACE_INDEX = 1;
int const PAGINATION_CELL_HEIGHT = 60;


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


NSString * const DEFAULT_CELL_IDENTIFIER = @"Cell";
NSString * const ITEM_FEED_CELL_IDENTIFIER = @"ItemFeedCell";
NSString * const PLACE_FEED_CELL_IDENTIFIER = @"PlaceFeedCell";
NSString * const FOLLOW_PLACE_CELL_IDENTIFIER = @"FollowPlaceCell";
NSString * const LOADING_CELL_IDENTIFIER = @"LoadingCell";
NSString * const USER_CELL_IDENTIFIER = @"UserCell";
NSString * const MESSAGE_CELL_IDENTIFIER = @"MessageCell";
NSString * const PIN_IDENTIFIER = @"PinIdentifier";
NSString * const STATIC_PIN_IDENTIFIER = @"StaticPinIdentifier";
NSString * const PAGINATION_CELL_IDENTIFIER = @"PaginationCell";


// Indices used in the memory pool and other pool constants
int const TOTAL_POOL_CLASSES = 3;
int const ITEMS_INDEX = 0;
int const PLACES_INDEX = 1;
int const USERS_INDEX = 2;


// Names and indices for the segmented controller options

int const NEARBY_INDEX = 0;
int const FOLLOWED_INDEX = 1;
int const POPULAR_INDEX = 1;


int const POPULAR_PLACES_INDEX = 0;
int const NEARBY_PLACES_INDEX = 1;


NSString * const NEARBY_TITLE = @"Nearby";
NSString * const FOLLOWED_TITLE = @"Followed";
NSString * const POPULAR_TITLE = @"Popular";

// Segment controller title view
int const SEGMENTED_VIEW_WIDTH = 320;
int const SEGMENTED_VIEW_HEIGHT = 44;
int const SEGMENTED_PLACES_CONTROL_WIDTH = 320;
int const SEGMENTED_PLACES_CONTROL_HEIGHT = 44;
NSString * const SEGMENTED_VIEW_BACKGROUND_IMAGE_NAME = @"segmented_view_bg.png";
NSString * const SEGMENTED_CONTROL_POPULAR_ON_IMAGE_NAME = @"popular_on.png";
NSString * const SEGMENTED_CONTROL_POPULAR_OFF_IMAGE_NAME = @"popular_off.png";
NSString * const SEGMENTED_CONTROL_NEARBY_ON_IMAGE_NAME = @"nearby_on.png";
NSString * const SEGMENTED_CONTROL_NEARBY_OFF_IMAGE_NAME = @"nearby_off.png";

// Init value of the page parameter in requests
int const INITIAL_PAGE_FOR_REQUESTS = 0;


NSString * const DENWEN_URL_PREFIX = @"denwen://p/";
NSString * const FACEBOOK_URL_PREFIX = @"fb";






// Request types
NSString * const POST_STRING = @"POST";
NSString * const GET_STRING = @"GET";
NSString * const PUT_STRING = @"PUT";
NSString * const DELETE_STRING = @"DELETE";

// Folders on S3
NSString * const S3_ITEMS_FOLDER = @"items";
NSString * const S3_USERS_FOLDER = @"user_photos";
NSString * const S3_PLACES_FOLDER = @"place_photos";




#ifdef PRODUCTION

// Constants needed in the POST request sent to AWS 
NSString * const S3_UPLOAD_POLICY = @"eydleHBpcmF0aW9uJzogJzIwMTctMDItMDlUMDU6MDI6MzcuMDAwWicsCiAgICAgICAgJ2NvbmRpdGlvbnMnOiBbCiAgICAgICAgICB7J2J1Y2tldCc6ICdkZW53ZW4nfSwKICAgICAgICAgIHsnYWNsJzogJ3B1YmxpYy1yZWFkJ30sCiAgICAgICAgICBbJ2NvbnRlbnQtbGVuZ3RoLXJhbmdlJywgMCwgNTI0Mjg4MDBdLAogICAgICAgICAgWydzdGFydHMtd2l0aCcsICcka2V5JywgJyddLAogICAgICAgICAgWydzdGFydHMtd2l0aCcsICcnLCAnJ10KICAgICAgICBdCiAgICAgIH0=";
NSString * const S3_UPLOAD_SIGNATURE = @"PG1k3sSsZe6FsxfcnqPobBWHKwc=";
NSString * const S3_ACCESS_ID = @"AKIAJWYCAWDPAAKLNKSQ";
NSString * const S3_ACL = @"public-read";
NSString * const S3_SERVER = @"http://denwen.s3.amazonaws.com/";

#else

// Constants needed in the POST request sent to AWS 
NSString * const S3_UPLOAD_POLICY = @"eydleHBpcmF0aW9uJzogJzIwMTctMDEtMjRUMDQ6MjA6MjguMDAwWicsCiAgICAgICAgJ2NvbmRpdGlvbnMnOiBbCiAgICAgICAgICB7J2J1Y2tldCc6ICd0ZW53ZW4nfSwKICAgICAgICAgIHsnYWNsJzogJ3B1YmxpYy1yZWFkJ30sCiAgICAgICAgICBbJ2NvbnRlbnQtbGVuZ3RoLXJhbmdlJywgMCwgNTI0Mjg4MDBdLAogICAgICAgICAgWydzdGFydHMtd2l0aCcsICcka2V5JywgJyddLAogICAgICAgICAgWydzdGFydHMtd2l0aCcsICcnLCAnJ10KICAgICAgICBdCiAgICAgIH0=";
NSString * const S3_UPLOAD_SIGNATURE = @"a5XAsCN6H/t4cv5MZ9/vuUOnc5s=";
NSString * const S3_ACCESS_ID = @"AKIAJWYCAWDPAAKLNKSQ";
NSString * const S3_ACL = @"public-read";
NSString * const S3_SERVER = @"http://tenwen.s3.amazonaws.com/";

#endif



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

// Urls
int const URL_TAG_MULTIPLIER = 100;

//Cryptography
NSString * const ENCRYPTION_PHRASE = @"9u124hgd35677";

//Messages used across the apps
NSString * const FOLLOW_PLACES_MSG = @"Follow Place";
NSString * const UNFOLLOW_PLACES_MSG = @"Following";
NSString * const NO_ITEMS_NEARBY_MSG = @"No items nearby";
NSString * const NO_PLACES_NEARBY_MSG = @"No places nearby";
NSString * const FOLLOW_LOGGEDOUT_MSG = @"Sign up to start following places";
NSString * const SHARE_LOGGEDOUT_MSG = @"Sign up to start sharing places";
NSString * const FOLLOW_NO_PLACES_SELF_MSG = @"You aren't following any places yet";
NSString * const FOLLOW_NO_PLACES_MSG = @"This user isn't following any places yet";
NSString * const USER_SIGNED_IN_NO_ITEMS_MSG = @"Everything you post shows up here";
NSString * const MAP_TOOLTIP_MSG = @"Hold and drag to move pin";
NSString * const LOADING_CELL_MSG = @"Loading...";
NSString * const PAGINATION_CELL_MSG = @"Load more...";
NSString * const FINDING_LOCALITY_MSG = @"Finding locality";
NSString * const EMPTY_POST_MSG = @"Post can't be empty";
NSString * const EMPTY_PLACENAME_MSG = @"Place name can't be empty";
NSString * const EMPTY_LOGIN_FIELDS_MSG = @"Please fill out all the required fields.";


//Camera related action sheet messages 
NSString * const FIRST_TAKE_PHOTO_MSG = @"Take Photo";
NSString * const FIRST_CHOOSE_PHOTO_MSG = @"Choose Existing";
NSString * const BETTER_TAKE_PHOTO_MSG = @"Take Better Photo";
NSString * const BETTER_CHOOSE_PHOTO_MSG = @"Choose Better Photo";
NSString * const TAKE_MEDIA_MSG = @"Take Photo or Video";
NSString * const CHOOSE_MEDIA_MSG = @"Choose Existing";
NSString * const CANCEL_PHOTO_MSG = @"Cancel";
NSString * const CANCEL_MEDIA_MSG = @"Cancel";

//Integers signifying different use cases of table views
NSInteger const TABLE_VIEW_AS_DATA = 0;
NSInteger const TABLE_VIEW_AS_SPINNER = 1;
NSInteger const TABLE_VIEW_AS_MESSAGE = 2;
NSInteger const TABLE_VIEW_AS_PROFILE_MESSAGE = 3;

//Different badge notifications types
NSString * const BADGE_NOTIFICATION_LIVE = @"b_live";
NSString * const BADGE_NOTIFICATION_BACKGROUND = @"b_back";


// Notification names
NSString * const N_LOCATION_CHANGED = @"LocationChanged";
NSString * const N_TAB_BAR_SELECTION_CHANGED = @"TabBarSelectionChanged";
NSString * const N_FOLLOWED_ITEMS_READ = @"FollowedItemsRead";
NSString * const N_FOLLOWED_ITEMS_LOADED = @"FollowedItemsLoaded";
NSString * const N_PLACE_FOLLOWED = @"PlaceFollowed";
NSString * const N_PLACE_UNFOLLOWED = @"PlaceUnfollowed";
NSString * const N_NEW_APPLICATION_BADGE_NUMBER = @"NewApplicationBadgeNumber";
NSString * const N_FACEBOOK_URL_OPENED = @"FacebookURLOpened";
NSString * const N_DENWEN_URL_OPENED = @"DenwenURLOpened";
NSString * const N_USER_LOGS_IN = @"UserLogsIn";
NSString * const N_USER_LOGS_OUT = @"UserLogsOut";
NSString * const N_NEW_ITEM_CREATED = @"NewItemCreated";
NSString * const N_NEW_PLACE_CREATED = @"NewPlaceCreated";



@implementation Constants

@end
