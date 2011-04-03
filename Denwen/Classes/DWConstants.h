//
//  DWConstants.h
//  Copyright 2011 Denwen. All rights reserved.
//	

#import <Foundation/Foundation.h>


extern NSString* const kDenwenServer;

/**
 * Configuration for uploading to Amazon S3
 */
extern NSString* const kS3Policy;
extern NSString* const kS3Signature;
extern NSString* const kS3AccessID;
extern NSString* const kS3ACL;
extern NSString* const kS3Server;

/**
 * Keys used for objects in JSON and custom dictionaties
 */
extern NSString* const kKeyStatus;
extern NSString* const kKeyMessage;
extern NSString* const kKeyBody;
extern NSString* const kKeySuccess;
extern NSString* const kKeyError;
extern NSString* const kKeyErrorMessage;
extern NSString* const kKeyErrorMessages;
extern NSString* const kKeyImage;
extern NSString* const kKeyResourceID;
extern NSString* const kKeyPlaces;
extern NSString* const kKeyPlace;
extern NSString* const kKeyItems;
extern NSString* const kKeyItem;
extern NSString* const kKeyUsers;
extern NSString* const kKeyUser;
extern NSString* const kKeyID;
extern NSString* const kKeyFilename;
extern NSString* const kKeyNotificationType;
extern NSString* const kKeyHasPhoto;
extern NSString* const kKeyFirstName;
extern NSString* const kKeyLastName;
extern NSString* const kKeyEmail;
extern NSString* const kKeyPhoto;
extern NSString* const kKeySmallURL;
extern NSString* const kKeyMediumURL;
extern NSString* const kKeyLargeURL;
extern NSString* const kKeyIsProcessed;

/**
 * Notification names
 */
extern NSString* const kNPopularPlacesLoaded;
extern NSString* const kNPopularPlacesError;
extern NSString* const kNNearbyPlacesLoaded;
extern NSString* const kNNearbyPlacesError;
extern NSString* const kNUserPlacesLoaded;
extern NSString* const kNUserPlacesError;
extern NSString* const kNSearchPlacesLoaded;
extern NSString* const kNSearchPlacesError;
extern NSString* const kNPlaceLoaded;
extern NSString* const kNPlaceError;
extern NSString* const kNPlaceUpdated;
extern NSString* const kNPlaceUpdateError;
extern NSString* const kNNewPlaceCreated;
extern NSString* const kNNewPlaceError;
extern NSString* const kNNewPlaceParsed;
extern NSString* const kNNewFollowingCreated;
extern NSString* const kNNewFollowingError;
extern NSString* const kNFollowingDestroyed;
extern NSString* const kNFollowingDestroyError;
extern NSString* const kNUserLoaded;
extern NSString* const kNUserError;
extern NSString* const kNUserUpdated;
extern NSString* const kNUserUpdateError;
extern NSString* const kNFollowedItemsLoaded;
extern NSString* const kNFollowedItemsError;
extern NSString* const kNNewItemCreated;
extern NSString* const kNNewItemError;
extern NSString* const kNNewItemParsed;
extern NSString* const kNNewUserCreated;
extern NSString* const kNNewUserError;
extern NSString* const kNNewSessionCreated;
extern NSString* const kNNewSessionError;
extern NSString* const kNS3UploadDone;
extern NSString* const kNS3UploadError;
extern NSString* const kNImgSmallUserLoaded;
extern NSString* const kNImgSmallUserError;
extern NSString* const kNImgMediumUserLoaded;
extern NSString* const kNImgMediumUserError;
extern NSString* const kNImgLargeUserLoaded;
extern NSString* const kNImgLargeUserError;
extern NSString* const kNImgSmallPlaceLoaded;
extern NSString* const kNImgSmallPlaceError;
extern NSString* const kNImgMediumPlaceLoaded;
extern NSString* const kNImgMediumPlaceError;
extern NSString* const kNImgLargePlaceLoaded;
extern NSString* const kNImgLargePlaceError;
extern NSString* const kNImgMediumAttachmentLoaded;
extern NSString* const kNImgMediumAttachmentError;
extern NSString* const kNImgLargeAttachmentLoaded;
extern NSString* const kNImgLargeAttachmentError;
extern NSString* const kNImgActualAttachmentLoaded;
extern NSString* const kNImgActualAttachmentError;
extern NSString* const kNNewApplicationBadge;
extern NSString* const kNTabSelectionChanged;

/**
 * Push notifcation types
 */
extern NSInteger const kPNLive;
extern NSInteger const kPNBackground;

/**
 * Different use cases for UITableVIiew
 */
extern NSInteger const kTableViewAsData;
extern NSInteger const kTableViewAsSpinner;
extern NSInteger const kTableViewAsMessage;
extern NSInteger const kTableViewAsProfileMessage;

/**
 * Table view UI
 */
extern NSInteger const kTVLoadingCellCount;
extern NSInteger const kTVLoadingCellHeight;
extern NSString* const kTVPaginationCellIdentifier;
extern NSString* const kTVMessageCellIdentifier;
extern NSString* const kTVLoadingCellIdentifier;
extern NSString* const kTVDefaultCellIdentifier;



/**
 * Segmented Control 
 */
extern NSInteger const kSegmentedPlacesViewWidth;
extern NSInteger const kSegmentedPlacesViewHeight;

/**
 * Location
 */
extern NSInteger const kLocFreshness;
extern NSInteger const kLocAccuracy;
extern NSInteger const kLocRefreshDistance;
extern NSInteger const kLocFailSafeDuration;
extern NSInteger const kLocNearbyRadius;

/**
 * Pagination
 */
extern NSInteger const kPagInitialPage;

/**
 * Memory Pool
 */
extern NSInteger const kMPTotalClasses;
extern NSInteger const kMPItemsIndex;
extern NSInteger const kMPPlacesIndex;
extern NSInteger const kMPUsersIndex;
extern NSInteger const kMPObjectUpdateInterval;


/**
 * Messages
 */
extern NSString* const kMsgNoPlacesNearby;
extern NSString* const kMsgNoFollowPlacesCurrentUser;
extern NSString* const kMsgNoFollowPlacesNormalUser;
extern NSString* const kMsgTakeFirstPhoto;
extern NSString* const kMsgChooseFirstPhoto;
extern NSString* const kMsgTakeBetterPhoto;
extern NSString* const kMsgChooseBetterPhoto;
extern NSString* const kMsgTakeMedia;
extern NSString* const kMsgChooseMedia;
extern NSString* const kMsgCancelPhoto;
extern NSString* const kMsgCancelMedia;

/**
 * Images
 */
extern NSString* const kImgGenericPlaceHolder;


/**
 * Misc App UI
 */
extern NSString* const kPlaceListViewControllerNib;
extern NSString* const kGenericBackButtonTitle;
extern NSInteger const kStatusBarStyle;
extern NSInteger const kAttachmentHeight;
extern NSInteger const kAttachmentYPadding;
extern NSInteger const kURLTagMultipler;
extern NSInteger const kPaginationCellHeight;
extern NSInteger const kUserViewCellHeight;




extern int const IMAGE;
extern int const VIDEO;


extern NSString * const TWITTER_OAUTH_CONSUMER_KEY;
extern NSString * const TWITTER_OAUTH_CONSUMER_SECRET;

extern NSString * const FACEBOOK_APP_ID;

extern int const LOCATION_FRESHNESS;
extern int const LOCATION_ACCURACY;
extern int const LOCATION_REFRESH_DISTANCE;
extern int const LOCATION_FAILSAFE_DURATION;



extern int const MAX_PLACE_NAME_LENGTH;
extern int const MAX_POST_DATA_LENGTH;
extern int const MAX_SHARE_DATA_LENGTH;


extern float const JPEG_COMPRESSION;

extern float const SCREEN_WIDTH;
extern float const SCREEN_HEIGHT;
extern float const SCREEN_ROTATED_WIDTH;
extern float const SCREEN_ROTATED_HEIGHT;

extern NSString * const BACK_BUTTON_SELF_TITLE;
extern NSString * const BACK_BUTTON_TITLE;

extern NSString * const PROFILE_TAB_NAME;
extern NSString * const PROFILE_TAB_IMAGE_NAME;


extern NSString * const PLACE_SMALL_PLACEHOLDER_IMAGE_NAME;
extern NSString * const PLACE_MEDIUM_PLACEHOLDER_IMAGE_NAME;
extern NSString * const PLACE_LARGE_PLACEHOLDER_IMAGE_NAME;


extern NSString * const CHANGE_USER_PIC_IMAGE_NAME;
extern NSString * const CHANGE_PLACE_PIC_IMAGE_NAME;
extern NSString * const USER_PROFILE_CREATE_POST_IMAGE_NAME;
extern NSString * const USER_PROFILE_CREATE_POST_HIGHLIGHTED_IMAGE_NAME;
extern NSString * const USER_PROFILE_CREATE_PLACE_IMAGE_NAME;
extern NSString * const USER_PROFILE_CREATE_PLACE_HIGHLIGHTED_IMAGE_NAME;

extern NSString * const NEW_POST_TEXTVIEW_PLACEHOLDER_TEXT;

extern NSString * const USER_PROFILE_BG_TEXTURE;
extern NSString * const PLACE_VIEW_FADE_IMAGE_NAME;
extern NSString * const TRANSPARENT_PLACEHOLDER_IMAGE_NAME;
extern NSString * const TRANSPARENT_BUTTON_BG_IMAGE_NAME;
extern NSString * const FOLLOW_BUTTON_BG_IMAGE_NAME;
extern NSString * const FOLLOW_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME;
extern NSString * const FOLLOWING_BUTTON_BG_IMAGE_NAME;
extern NSString * const FOLLOWING_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME;
extern NSString * const SHARE_PLACE_BUTTON_BG_IMAGE_NAME;
extern NSString * const SHARE_PLACE_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME;
extern NSString * const ARROW_BUTTON_USER_IMAGE_NAME;
extern NSString * const ARROW_BUTTON_PLACE_IMAGE_NAME;
extern NSString * const ARROW_BUTTON_IMAGE_NAME;

extern NSString * const MODALVIEW_BACKGROUND_IMAGE;

extern NSString * const VIDEO_TINY_PREVIEW_PLACEHOLDER_IMAGE_NAME;
extern NSString * const VIDEO_PREVIEW_PLACEHOLDER_IMAGE_NAME;
extern NSString * const VIDEO_PLAY_BUTTON_IMAGE_NAME;
extern int const VIDEO_MAX_DURATION;

extern int const FEED_TABLE_HEIGHT;
extern int const DYNAMIC_CELL_HEIGHT_REFERENCE_WIDTH;
extern int const USER_LABEL_PADDING;
extern int const USER_NAME_PADDING;
extern int const FOLLOW_PLACE_CELL_HEIGHT;
extern int const FOLLOW_CURRENT_USER_CELL_HEIGHT;
extern int const SPINNER_HEIGHT;
extern int const VIDEO_VIEW_SPINNER_SIDE;


extern int const SIZE_PLACE_SMALL_IMAGE;
extern int const SIZE_PLACE_MEDIUM_IMAGE;
extern int const SIZE_PLACE_LARGE_IMAGE;
extern int const SIZE_PLACE_PRE_UPLOAD_IMAGE;
extern int const SIZE_USER_SMALL_IMAGE;
extern int const SIZE_USER_MEDIUM_IMAGE;
extern int const SIZE_USER_PRE_UPLOAD_IMAGE;
extern int const SIZE_ATTACHMENT_IMAGE;
extern int const SIZE_ATTACHMENT_PRE_UPLOAD_IMAGE;


extern NSString * const FOLLOW_PLACE_CELL_IDENTIFIER;
extern NSString * const USER_CELL_IDENTIFIER;
extern NSString * const STATIC_PIN_IDENTIFIER;

extern NSString * const DENWEN_URL_PREFIX;
extern NSString * const FACEBOOK_URL_PREFIX;



extern NSString * const S3_ITEMS_FOLDER;
extern NSString * const S3_USERS_FOLDER;
extern NSString * const S3_PLACES_FOLDER;

extern NSString * const PLACE_JSON_KEY;
extern NSString * const USER_JSON_KEY;
extern NSString * const ITEM_JSON_KEY;
extern NSString * const ATTACHMENT_JSON_KEY;
extern NSString * const ADDRESS_JSON_KEY;
extern NSString * const FOLLOWING_JSON_KEY;
extern NSString * const PHOTO_JSON_KEY;
extern NSString * const ITEMS_JSON_KEY;
extern NSString * const PLACES_JSON_KEY;
extern NSString * const ERROR_MESSAGES_JSON_KEY;
extern NSString * const CONDENSED_DATA_JSON_KEY;
extern NSString * const CREATED_AT_JSON_KEY;
extern NSString * const DATABASE_ID_JSON_KEY;
extern NSString * const URLS_JSON_KEY;


extern NSString * const FOLLOW_PLACES_MSG;
extern NSString * const UNFOLLOW_PLACES_MSG;
extern NSString * const FOLLOW_LOGGEDOUT_MSG;
extern NSString * const SHARE_LOGGEDOUT_MSG;
extern NSString * const MAP_TOOLTIP_MSG;
extern NSString * const LOADING_CELL_MSG;
extern NSString * const PAGINATION_CELL_MSG;
extern NSString * const FINDING_LOCALITY_MSG;
extern NSString * const EMPTY_POST_MSG;
extern NSString * const EMPTY_PLACENAME_MSG;
extern NSString * const EMPTY_LOGIN_FIELDS_MSG;


extern NSString * const BADGE_NOTIFICATION_LIVE;
extern NSString * const BADGE_NOTIFICATION_BACKGROUND;

extern NSString * const N_LOCATION_CHANGED;
extern NSString * const N_FOLLOWED_ITEMS_READ;
extern NSString * const N_FACEBOOK_URL_OPENED;
extern NSString * const N_DENWEN_URL_OPENED;
extern NSString * const N_USER_LOGS_IN;
extern NSString * const N_USER_LOGS_OUT;
extern NSString * const N_NEW_ITEM_CREATED;



@interface DWConstants : NSObject {

}

@end
