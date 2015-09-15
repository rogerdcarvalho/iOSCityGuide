//
//  WebViewController.m
//
//  Created by Roger Carvalho on 15/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property UITextView *loadingView;
@property NSTimer *loadingTimer;
@end

@implementation WebViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//Upon initialization, set the title
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {
        self.title = NSLocalizedString(@"WEB_TITLE", nil);
        return self;
    }
    
    else
    {
        return nil;
    }
    
}
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andURL:(NSURLRequest *)urlRequest
//When this class opens links, it calls itself with a new URL request
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {
        
        self.title = NSLocalizedString(@"WEB_TITLE", nil);
        self.urlRequest = urlRequest;

        return self;
    }
    
    else
    {
        return nil;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat fullHeight = self.navigationController.view.superview.frame.size.height;
    CGFloat fullWidth = self.navigationController.view.superview.frame.size.width;
    
    //Indicate that the webview is loading
    self.loadingView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, fullWidth, fullHeight)];
    self.loadingView.text = NSLocalizedString(@"LOADING_TITLE", nil);
    [self.view addSubview:self.loadingView];
    
    self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                         target:self
                                                       selector:@selector(animateLoading:)
                                                       userInfo:self.loadingView
                                                        repeats:YES];

    
    if (!self.webView)
    {
        //Initialize the webview
        //Check if there is a status bar
        CGFloat heightOffset;
        if ([UIApplication sharedApplication].isStatusBarHidden)
        {
            heightOffset = self.navigationController.navigationBar.frame.size.height;
        }
        else
        {
            heightOffset = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
        }

        CGRect frame = CGRectMake(0, 0, fullWidth, fullHeight - self.navigationController.tabBarController.tabBar.frame.size.height);

        self.webView = [[UIWebView alloc] initWithFrame:frame];
        [self.webView.scrollView setContentInset:UIEdgeInsetsMake(heightOffset, 0, 0, 0)];
        [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(heightOffset, 0, 0, 0)];
        [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

        //Autoresizemask
       self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.webView.scalesPageToFit = YES;

    }
    
    self.webView.delegate = self;
    if (!self.urlRequest)
    {
        //Open the default URL
        NSString *urlString = NSLocalizedString(@"DEFAULT_URL", nil);;
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];

    }
    else
    {
        //Open the URL requested
        [self.webView loadRequest:self.urlRequest];
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Check orientation changes
    [self updateViews];
    
    //Reload webpage
    if (!self.urlRequest)
    {
        //Open the default URL
        NSString *urlString = NSLocalizedString(@"DEFAULT_URL", nil);;
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        
    }
    else
    {
        //Open the URL requested
        [self.webView loadRequest:self.urlRequest];
    }
    
}

#pragma mark Webview delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (!navigationType == UIWebViewNavigationTypeLinkClicked)
    {
    
        return YES;
    }
    else
    //If the user tapped on a link, open an new view
    {
        WebViewController *newPage = [[WebViewController alloc] initWithNibName:nil bundle:nil andURL:request];
        [self.navigationController pushViewController:newPage animated:true];
        return NO;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView;
{
    if (webView.isLoading)
    //Handles in-page redirects and/or frames, wait until the page is fully loaded.
    {
        return;
    }
    else
    {
        NSLog(@"Webview finished loading");

        //Set the title to the webpage title and truncate if required
        NSString *pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        if (pageTitle.length > 10)
        {
            self.title = [[pageTitle substringToIndex:10] stringByAppendingString:@"..."];
        }
        else
        {
            self.title = pageTitle;
        }

        //Ensure the tab bar title remains unchanged
        self.navigationController.tabBarItem.title = NSLocalizedString(@"WEB_TITLE", nil);
        
        //Stop the timer, remove the loading view and show the webpage
        
        if (self.loadingView.window != nil)
        {
            [self.loadingTimer invalidate];
            [self.loadingView removeFromSuperview];
            [self.view addSubview:self.webView];
        }
        
    }
}
#pragma mark helper methods

-(void) animateLoading:(NSTimer *)timer
//Helper method, this animates the loading indicator to let users know the data is loading. It should be called at an interval
{
    UITextView *textView = [timer userInfo];
    NSInteger minimumLength = NSLocalizedString(@"LOADING_TITLE", nil).length;
    NSInteger currentLength = textView.text.length;
    NSInteger numDots = currentLength - minimumLength;
    
    switch (numDots)
    {
        case 3:
            
            textView.text = NSLocalizedString(@"LOADING_TITLE", nil);
            
            break;
        default:
            
            textView.text = [textView.text stringByAppendingString:@"."];
            
            break;
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//The orientation changed
{
    [self updateViews];
    
}
-(void)updateViews
//Ensures the views work within the current orientation
{
    //Get the screen dimensions
    CGFloat fullHeight = self.navigationController.view.superview.frame.size.height;
    CGFloat fullWidth = self.navigationController.view.superview.frame.size.width;
    CGFloat heightOffset;
    
    //Check if there is a status bar
    if ([UIApplication sharedApplication].isStatusBarHidden)
    {
        heightOffset = self.navigationController.navigationBar.frame.size.height;
    }
    else
    {
        heightOffset = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    }
    
    CGRect frame = CGRectMake(0, 0, fullWidth, fullHeight - self.navigationController.tabBarController.tabBar.frame.size.height);
    
    self.webView.frame = frame;
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(heightOffset, 0, 0, 0)];
    [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(heightOffset, 0, 0, 0)];
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

}

@end
