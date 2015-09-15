#ifndef Constants_h
#define Constants_h

//Whether the app should load a local JSON file or get it from an NSURL request. ONLY ONE SHOULD BE UNCOMMENTED!!
#define JSON_LOCATION_LOCAL     //To get json data online, comment this out
//#define JSON_LOCATION_ONLINE    //To get json data online, uncomment this

#define JSON_URL @"sights.json" //To get json data online, change this to the URL String

// Timeout for most network requests (in seconds)
#define REQUEST_TIMEOUT 15
#define BASE_LATITUDE 34.0878
#define BASE_LONGITUDE -118.3722
#define BASE_RADIUS 15000.0
#define BUTTON_MARGIN 10
#define FONT_SIZE 17.0
#define IPHONE (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
#define IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

#endif
