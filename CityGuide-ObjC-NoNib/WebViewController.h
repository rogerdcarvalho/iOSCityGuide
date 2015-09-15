//
//  WebViewController.h
//
//  Created by Roger Carvalho on 15/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

/*
This view controller handles external navigation of a webpage. It loads the page that is indicated in the Constants.h

The designated initializer is:

 -(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 
It will load the webpage configured. Any link tapped on the webpage will spawn a new view, so this view is best used for web pages that don't deep link more than 3 levels. Ideally it would be used with very simple websites that offer an extension to general UX of the app with a similar look and feel.
 */

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>

//Public properties, any other object can access this controllers webview and URLrequest. They can also see if the view is currently loading or not
@property() UIWebView *webView;
@property() NSURLRequest *urlRequest;
@property() BOOL loading;

//Webview Delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidFinishLoad:(UIWebView *)webView;

@end
