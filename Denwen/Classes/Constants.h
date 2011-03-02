//
//  Constants.h
//  Denwen
//
//  Created by Siddharth Batra on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int const IMAGE;
extern int const VIDEO;

extern NSString * const SUCCESS_STATUS;
extern NSString * const ERROR_STATUS;

extern NSString * const CURRENT_USER_KEY;

extern NSString * const TWITTER_OAUTH_CONSUMER_KEY;
extern NSString * const TWITTER_OAUTH_CONSUMER_SECRET;

extern NSString * const FACEBOOK_APP_ID;

extern int const LOCATION_FRESHNESS;
extern int const LOCATION_ACCURACY;
extern int const LOCATION_REFRESH_DISTANCE;
extern int const LOCATION_FAILSAFE_DURATION;
extern int const LOCATION_NEARBY_RADIUS;

extern int const SEARCH_INSTANCE_ID;

extern int const SELECTED_ITEMS_INDEX;
extern int const SELECTED_PLACES_INDEX;

extern int const MAX_PLACE_NAME_LENGTH;
extern int const MAX_POST_DATA_LENGTH;
extern int const MAX_SHARE_DATA_LENGTH;

extern int const CACHE_INTERNAL;
extern int const MAX_CACHE_ITEM_SIZE;

extern int const ITEMS_PER_PAGE;
extern int const PLACES_PER_PAGE;

extern int const POOL_OBJECT_UPDATE_INTERVAL;

extern float const JPEG_COMPRESSION;

extern float const SCREEN_WIDTH;
extern float const SCREEN_HEIGHT;
extern float const SCREEN_ROTATED_WIDTH;
extern float const SCREEN_ROTATED_HEIGHT;

extern NSString * const BACK_BUTTON_SELF_TITLE;
extern NSString * const BACK_BUTTON_TITLE;

extern NSString * const POSTS_TAB_NAME;
extern NSString * const PROFILE_TAB_NAME;
extern NSString * const PLACES_TAB_NAME;
extern NSString * const POSTS_TAB_IMAGE_NAME;
extern NSString * const PROFILE_TAB_IMAGE_NAME;
extern NSString * const PLACES_TAB_IMAGE_NAME;

extern NSString * const GENERIC_PLACEHOLDER_IMAGE_NAME;

extern NSString * const PLACE_SMALL_PLACEHOLDER_IMAGE_NAME;
extern NSString * const PLACE_MEDIUM_PLACEHOLDER_IMAGE_NAME;
extern NSString * const PLACE_LARGE_PLACEHOLDER_IMAGE_NAME;

extern NSString * const USER_SMALL_PLACEHOLDER_IMAGE_NAME;
extern NSString * const USER_MEDIUM_PLACEHOLDER_IMAGE_NAME;
extern NSString * const USER_SIGNED_IN_MEDIUM_PLACEHOLDER_IMAGE_NAME;
extern NSString * const USER_LARGE_PLACEHOLDER_IMAGE_NAME;
extern NSString * const CHANGE_PIC_IMAGE_NAME;
extern NSString * const USER_PROFILE_CREATE_POST_IMAGE_NAME;
extern NSString * const USER_PROFILE_CREATE_POST_HIGHLIGHTED_IMAGE_NAME;
extern NSString * const USER_PROFILE_CREATE_PLACE_IMAGE_NAME;
extern NSString * const USER_PROFILE_CREATE_PLACE_HIGHLIGHTED_IMAGE_NAME;

extern NSString * const NEW_POST_TEXTVIEW_PLACEHOLDER_TEXT;

extern NSString * const USER_PROFILE_BG_TEXTURE;
extern NSString * const TRANSPARENT_PLACEHOLDER_IMAGE_NAME;
extern NSString * const TRANSPARENT_BUTTON_BG_IMAGE_NAME;
extern NSString * const FOLLOW_BUTTON_BG_IMAGE_NAME;
extern NSString * const FOLLOW_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME;
extern NSString * const FOLLOWING_BUTTON_BG_IMAGE_NAME;
extern NSString * const FOLLOWING_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME;
extern NSString * const SHARE_PLACE_BUTTON_BG_IMAGE_NAME;
extern NSString * const SHARE_PLACE_BUTTON_BG_HIGHLIGHTED_IMAGE_NAME;
extern NSString * const ARROW_BUTTON_IMAGE_NAME;
extern NSString * const MODALVIEW_BACKGROUND_IMAGE;

extern int const FEED_TABLE_HEIGHT;
extern int const DYNAMIC_CELL_HEIGHT_REFERENCE_WIDTH;
extern int const MAX_DYNAMIC_CELL_HEIGHT;
extern int const ATTACHMENT_HEIGHT;
extern int const ATTACHMENT_Y_PADDING;
extern int const USER_LABEL_PADDING;
extern int const USER_NAME_PADDING;
extern int const PLACE_FEED_CELL_HEIGHT;
extern int const FOLLOW_PLACE_CELL_HEIGHT;
extern int const FOLLOW_CURRENT_USER_CELL_HEIGHT;
extern int const FOLLOW_USER_CELL_HEIGHT;
extern int const LOADING_CELL_HEIGHT;
extern int const LOADING_CELL_COUNT;
extern int const SPINNER_HEIGHT;
extern int const SPINNER_CELL_INDEX;
extern int const MESSAGE_CELL_INDEX;
extern int const PAGINATION_CELL_HEIGHT;


extern int const SIZE_PLACE_SMALL_IMAGE;
extern int const SIZE_PLACE_MEDIUM_IMAGE;
extern int const SIZE_PLACE_LARGE_IMAGE;
extern int const SIZE_PLACE_PRE_UPLOAD_IMAGE;
extern int const SIZE_USER_SMALL_IMAGE;
extern int const SIZE_USER_MEDIUM_IMAGE;
extern int const SIZE_USER_PRE_UPLOAD_IMAGE;
extern int const SIZE_ATTACHMENT_IMAGE;
extern int const SIZE_ATTACHMENT_PRE_UPLOAD_IMAGE;



extern NSString * const DEFAULT_CELL_IDENTIFIER;
extern NSString * const ITEM_FEED_CELL_IDENTIFIER;
extern NSString * const PLACE_FEED_CELL_IDENTIFIER;
extern NSString * const FOLLOW_PLACE_CELL_IDENTIFIER;
extern NSString * const LOADING_CELL_IDENTIFIER;
extern NSString * const USER_CELL_IDENTIFIER;
extern NSString * const MESSAGE_CELL_IDENTIFIER;
extern NSString * const PIN_IDENTIFIER;
extern NSString * const STATIC_PIN_IDENTIFIER;
extern NSString * const PAGINATION_CELL_IDENTIFIER;


extern int const TOTAL_POOL_CLASSES;
extern int const ITEMS_INDEX;
extern int const PLACES_INDEX;
extern int const USERS_INDEX;

extern int const NEARBY_INDEX;
extern int const FOLLOWED_INDEX;
extern int const POPULAR_INDEX;

extern int const NEARBY_PLACES_INDEX;
extern int const POPULAR_PLACES_INDEX;

extern NSString * const NEARBY_TITLE;
extern NSString * const FOLLOWED_TITLE;
extern NSString * const POPULAR_TITLE;

extern int const SEGMENTED_VIEW_WIDTH;
extern int const SEGMENTED_VIEW_HEIGHT;
extern NSString * const SEGMENTED_VIEW_BACKGROUND_IMAGE_NAME;
extern int const SEGMENTED_PLACES_CONTROL_WIDTH;
extern int const SEGMENTED_PLACES_CONTROL_HEIGHT;
extern int const SEGMENTED_ITEMS_CONTROL_WIDTH;
extern int const SEGMENTED_ITEMS_CONTROL_HEIGHT;
extern NSString * const SEGMENTED_CONTROL_POPULAR_ON_IMAGE_NAME;
extern NSString * const SEGMENTED_CONTROL_POPULAR_OFF_IMAGE_NAME;
extern NSString * const SEGMENTED_CONTROL_NEARBY_ON_IMAGE_NAME;
extern NSString * const SEGMENTED_CONTROL_NEARBY_OFF_IMAGE_NAME;



extern int const INITIAL_PAGE_FOR_REQUESTS;

extern NSString * const NEARBY_ITEMS_URI;
extern NSString * const FOLLOWED_ITEMS_URI;
extern NSString * const POPULAR_ITEMS_URI;
extern NSString * const NEARBY_PLACES_URI;
extern NSString * const FOLLOWED_PLACES_URI;
extern NSString * const POPULAR_PLACES_URI;
extern NSString * const SEARCH_PLACES_URI;
extern NSString * const LOGIN_URI;
extern NSString * const SIGNUP_URI;
extern NSString * const FOLLOWINGS_DELETE_URI;
extern NSString * const FOLLOWINGS_URI;
extern NSString * const PLACE_SHOW_URI;
extern NSString * const USER_SHOW_URI;
extern NSString * const ITEMS_URI;
extern NSString * const PLACES_URI;
extern NSString * const VISITS_URI;

extern NSString * const POST_STRING;
extern NSString * const GET_STRING;
extern NSString * const PUT_STRING;
extern NSString * const DELETE_STRING;

extern NSString * const S3_UPLOAD_POLICY;
extern NSString * const S3_UPLOAD_SIGNATURE;
extern NSString * const S3_ACCESS_ID;
extern NSString * const S3_ACL;
extern NSString * const S3_SERVER;

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

extern int const URL_TAG_MULTIPLIER;

extern NSString * const ENCRYPTION_PHRASE;

extern NSString * const FOLLOW_PLACES_MSG;
extern NSString * const UNFOLLOW_PLACES_MSG;
extern NSString * const NO_ITEMS_NEARBY_MSG;
extern NSString * const NO_PLACES_NEARBY_MSG;
extern NSString * const FOLLOW_LOGGEDOUT_MSG;
extern NSString * const SHARE_LOGGEDOUT_MSG;
extern NSString * const FOLLOW_NO_PLACES_SELF_MSG;
extern NSString * const FOLLOW_NO_PLACES_MSG;
extern NSString * const USER_SIGNED_IN_NO_ITEMS_MSG;
extern NSString * const MAP_TOOLTIP_MSG;
extern NSString * const LOADING_CELL_MSG;
extern NSString * const PAGINATION_CELL_MSG;
extern NSString * const FINDING_LOCALITY_MSG;
extern NSString * const FIRST_TAKE_PHOTO_MSG;
extern NSString * const FIRST_CHOOSE_PHOTO_MSG;
extern NSString * const BETTER_TAKE_PHOTO_MSG;
extern NSString * const BETTER_CHOOSE_PHOTO_MSG;
extern NSString * const CANCEL_PHOTO_MSG;
extern NSString * const EMPTY_POST_MSG;
extern NSString * const EMPTY_PLACENAME_MSG;
extern NSString * const EMPTY_LOGIN_FIELDS_MSG;



extern NSInteger const TABLE_VIEW_AS_DATA;
extern NSInteger const TABLE_VIEW_AS_SPINNER;
extern NSInteger const TABLE_VIEW_AS_MESSAGE;
extern NSInteger const TABLE_VIEW_AS_PROFILE_MESSAGE;

extern NSString * const BADGE_NOTIFICATION_LIVE;
extern NSString * const BADGE_NOTIFICATION_BACKGROUND;

extern NSString * const N_LOCATION_CHANGED;
extern NSString * const N_TAB_BAR_SELECTION_CHANGED;
extern NSString * const N_FOLLOWED_ITEMS_READ;
extern NSString * const N_FOLLOWED_ITEMS_LOADED;
extern NSString * const N_NEW_APPLICATION_BADGE_NUMBER;
extern NSString * const N_FACEBOOK_URL_OPENED;
extern NSString * const N_ATTACHMENT_PREVIEW_DONE;
extern NSString * const N_USER_LOGS_IN;
extern NSString * const N_USER_LOGS_OUT;
extern NSString * const N_NEW_ITEM_CREATED;
extern NSString * const N_NEW_PLACE_CREATED;
extern NSString * const N_SMALL_PLACE_PREVIEW_DONE;
extern NSString * const N_MEDIUM_PLACE_PREVIEW_DONE;
extern NSString * const N_LARGE_PLACE_PREVIEW_DONE;
extern NSString * const N_SMALL_USER_PREVIEW_DONE;
extern NSString * const N_MEDIUM_USER_PREVIEW_DONE;


@interface Constants : NSObject {

}

@end
