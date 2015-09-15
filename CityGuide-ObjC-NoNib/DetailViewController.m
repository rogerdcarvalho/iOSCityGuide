//
//  DetailViewController.m
//
//  Created by Roger Carvalho on 15/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

//Private properties, for use only within the object when processing views
@property() UITextView *sightDescription;
@property() UIImageView *sightImage;
@property() UIScrollView *scrollView;
@property() UIButton *showInMapButton;
@property() UIButton *navigateButton;
@property() CGFloat contentHeight;
@property() CGFloat heightOffset;

@end

@implementation DetailViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSight:(Sight *)sight
//Upon initialization, set the title and sight property
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {
        self.sight = sight;
        self.title = self.sight.name;
        
        return self;
    }
    
    else
    {
        return nil;
    }
    
}
- (void)viewDidLoad
//On iPhone, use viewDidLoad to kick off drawing, to make the view slide in smoothly with content already prepared
{
    [super viewDidLoad];
    if IPHONE
    {
        //Get full screen dimensions
        CGFloat fullWidth = self.navigationController.view.superview.frame.size.width;
        CGFloat fullHeight = self.navigationController.view.superview.frame.size.height;
        
        //Get the area of the screen that is used by the UINavigationBar. As this runs before the view appears, its frame area will still be the entire bounds.
        CGFloat tabBarheight =self.navigationController.tabBarController.tabBar.frame.size.height;
        CGFloat maxWidth;
        CGFloat contentStart;
        
       
        if (fullHeight > fullWidth)
        //The phone is running in portrait, with a status bar
        {
            maxWidth = fullWidth;
            contentStart = 0;
            self.heightOffset = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
            
        }
        else
        //The phone is running in landscape, without a status bar
        {
            maxWidth = fullHeight;
            contentStart = (fullWidth - maxWidth) / 2;
            self.heightOffset = self.navigationController.navigationBar.frame.size.height;
        }
        
        //Prepare a scrollview for the available screen real estate
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, maxWidth, fullHeight - tabBarheight)];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        
        //Draw the description of the sight. Disable scroll, as scrolling is handled by the parent. For now it appears right below the NavigationBar, as soon as the image is loaded it will be repositioned
        self.sightDescription = [[UITextView alloc]initWithFrame:CGRectMake(contentStart,self.heightOffset, maxWidth, fullHeight - self.heightOffset)];
        self.sightDescription.text = self.sight.longDesc;
        self.sightDescription.editable = NO;
        self.sightDescription.scrollEnabled = NO;
        
        //Make its height fit whatever the length of the text
        CGSize textHeight = [self.sightDescription sizeThatFits:CGSizeMake(maxWidth, MAXFLOAT)];
        self.sightDescription.frame = CGRectMake(contentStart, self.heightOffset, maxWidth, textHeight.height);

        
#warning Added the tabbarcontroller height to the contentheight to make it appear properly. Doesn't seem to make sense
        self.contentHeight = self.sightDescription.frame.size.height + self.heightOffset + tabBarheight;
        
        //If this view was not opened from the map, show a button to show the sight on the map
        if (self.navigationController.tabBarController.selectedIndex !=1)
        {
            
            //Get the size of the localized string
            CGSize stringsize = [NSLocalizedString(@"SHOW_IN_MAP_BUTTON", nil) sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]}];
            
            //Create the button in the center underneath the text
            self.showInMapButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.showInMapButton.frame= CGRectMake((((fullWidth - stringsize.width) / 2)-1), self.heightOffset + self.sightDescription.frame.size.height + BUTTON_MARGIN, stringsize.width, stringsize.height);
            
            //Set the title and target and add the view
            [self.showInMapButton setTitle:NSLocalizedString(@"SHOW_IN_MAP_BUTTON", nil)  forState:UIControlStateNormal];
            [self.showInMapButton addTarget:self action:@selector(showInMap) forControlEvents:UIControlEventTouchUpInside];
            self.contentHeight+=self.showInMapButton.frame.size.height + BUTTON_MARGIN * 2;
        }
        else
            //Show a navigate to button
        {
            //Get the size of the localized string
            CGSize stringsize = [NSLocalizedString(@"NAVIGATION_BUTTON", nil) sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]}];
            
            //Create the button in the center underneath the text
            self.showInMapButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.showInMapButton.frame= CGRectMake((((fullWidth - stringsize.width) / 2)-1),self.heightOffset + self.sightDescription.frame.size.height + BUTTON_MARGIN, stringsize.width, stringsize.height);
            
            //Set the title and target and add the view
            [self.showInMapButton setTitle:NSLocalizedString(@"NAVIGATION_BUTTON", nil)  forState:UIControlStateNormal];
            [self.showInMapButton addTarget:self action:@selector(navigate) forControlEvents:UIControlEventTouchUpInside];
            self.contentHeight+=self.showInMapButton.frame.size.height + BUTTON_MARGIN * 2;
            
        }
        
        //Set the background color to white, to allow proper animation effects when called
        self.scrollView.backgroundColor = [UIColor whiteColor];
        
        //Set the scrollview to accommodate the content height
        self.scrollView.contentSize=CGSizeMake(fullWidth,self.contentHeight);
        
        //Add the scrollview to the hierarchy and set it as the controllers view
        [self.scrollView addSubview:self.sightDescription];
        [self.scrollView addSubview:self.showInMapButton];
        self.view=self.scrollView;
        
        //Disable auto adjust insets, this messes with measurements and positioning
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        //Download the image
        [self.sight downloadImage:self toReference:self.sightImage];
        
    }
}
- (void)viewWillAppear:(BOOL)animated
//On iPad use viewWillAppear to kick off drawing, as we need the proper frame size of the modal view
{
    [super viewWillAppear:animated];

    if IPAD
    {
        // Override the right button to show a Done button, which is used to dismiss the modal view
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                               target:self
                                               action:@selector(dismissView:)];

        //Get modal screen dimensions
        CGFloat fullHeight = self.navigationController.view.superview.frame.size.height;
        CGFloat fullWidth = self.navigationController.view.superview.frame.size.width;
        
        //Get the height offset for the navigation bar
        self.heightOffset = self.navigationController.navigationBar.frame.size.height;

    
        //Prepare a scrollview for the available screen real estate (full width and height reduced by the tabbar on the bottom (the top is drawn below the navigation title bar to allow scrolling underneath it for the nice visual effect)
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, fullWidth, fullHeight)];
    
        //Set the background color to white, to allow proper animation effects when called
        self.scrollView.backgroundColor = [UIColor whiteColor];
    
        //Draw the description of the sight. Disable scroll, as scrolling is handled by the parent. For now it appears right below  the NavigationBar, as soon as the image is loaded it will be repositioned
        self.sightDescription = [[UITextView alloc]initWithFrame:CGRectMake(0, self.heightOffset, fullWidth, fullHeight - self.heightOffset)];
        self.sightDescription.text = self.sight.longDesc;
        self.sightDescription.editable = NO;
        self.sightDescription.scrollEnabled = NO;
    
        //Make its height fit whatever the length of the text
        CGSize textHeight = [self.sightDescription sizeThatFits:CGSizeMake(fullWidth, MAXFLOAT)];
        self.sightDescription.frame = CGRectMake(0, self.heightOffset, fullWidth, textHeight.height);
    
        #warning Added the tabbarcontroller height to the contentheight to make it appear properly. Doesn't seem to make sense
        self.contentHeight = self.heightOffset + self.sightDescription.frame.size.height;
        
        //Get the size of the localized string
        CGSize stringsize = [NSLocalizedString(@"NAVIGATION_BUTTON", nil) sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]}];
        
        //Create the button in the center underneath the text
        self.showInMapButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.showInMapButton.frame= CGRectMake((((fullWidth - stringsize.width) / 2)-1), self.heightOffset + self.sightDescription.frame.size.height + BUTTON_MARGIN, stringsize.width, stringsize.height);
        
        //Set the title and target and add the view
        [self.showInMapButton setTitle:NSLocalizedString(@"NAVIGATION_BUTTON", nil)  forState:UIControlStateNormal];
        [self.showInMapButton addTarget:self action:@selector(navigate) forControlEvents:UIControlEventTouchUpInside];
        self.contentHeight+=self.showInMapButton.frame.size.height + BUTTON_MARGIN * 2;
    
        //Set the scrollview to accommodate the content height
        self.scrollView.contentSize=CGSizeMake(fullWidth,self.contentHeight);
    
        //Add the scrollview to the hierarchy and set it as the controllers view
        [self.scrollView addSubview:self.sightDescription];
        [self.scrollView addSubview:self.showInMapButton];
        self.view=self.scrollView;
    
        //Disable auto adjust insets, this messes with measurements and positioning
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        //Download the image
        [self.sight downloadImage:self toReference:self.sightImage];
    }
    if IPHONE
    //To support orientation changes occurring on other tabs
    {
        [self updateViews];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
-(void)imageFinishedDownloading:(Sight*)sight andImage:(UIImage*)image toReference:(id)reference;
//When the image is ready, readjust view
{
    //Get full screen dimensions
    CGFloat fullHeight = self.navigationController.view.superview.frame.size.height;
    CGFloat fullWidth = self.navigationController.view.superview.frame.size.width;
    CGFloat maxWidth;
    CGFloat contentStart;
    
    //Prepare image
    self.sightImage = [[UIImageView alloc]initWithImage:image];
    CGFloat imgFactor = self.sightImage.frame.size.height / self.sightImage.frame.size.width;
    
    //Determine the width of the image. It should always fill the frame, unless the device is a phone running in landscape
    maxWidth = fullWidth;
    contentStart = 0;
    
    if IPHONE
    {
        if (fullWidth > fullHeight)
        {
            maxWidth = fullHeight;
            contentStart = (fullWidth - maxWidth) / 2;
        }
        
    }
    
    self.sightImage.frame = CGRectMake(contentStart, self.heightOffset, maxWidth, maxWidth * imgFactor);
    self.contentHeight+=self.sightImage.frame.size.height;
  
    //Readjust the textview
    self.sightDescription.frame = CGRectMake(contentStart, self.heightOffset + self.sightImage.frame.size.height, maxWidth,  self.sightDescription.frame.size.height);

    //Readjust the button view
    self.showInMapButton.frame = CGRectMake((((fullWidth - self.showInMapButton.frame.size.width) / 2)-1), self.heightOffset + self.sightDescription.frame.size.height + self.sightImage.frame.size.height, self.showInMapButton.frame.size.width, self.showInMapButton.frame.size.height);
    
    [self.view addSubview:self.sightImage];

    //Readjust the height of the scrollview to cope with the new layout.
    self.scrollView.contentSize=CGSizeMake(fullWidth,self.contentHeight);
    
}
-(void)navigate
{
    //Open an alert to let the user confirm they want to leave the app
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NAVIGATION_TITLE", nil) message:NSLocalizedString(@"NAVIGATION_CONFIRMATION_TEXT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL_BUTTON", nil)otherButtonTitles:NSLocalizedString(@"OK_BUTTON", nil), nil];
    [alertView show];

   }
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
//When the user has indicated they do want to leave the app to navigate
{
    if (buttonIndex == 1)
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.sight forKey:@"Data"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Navigate" object:nil userInfo:dictionary];

    }
}

-(void)showInMap
//When the user has indicated they want the Sight shown on the local map view
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.sight forKey:@"Data"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LaunchMap" object:nil userInfo:dictionary];
}
- (void)dismissView:(id)sender
//Closes this view when held in a modal controller
{
    
    // Call the delegate to dismiss the modal view
    [self.delegate dismissModal:self];
}
- (void)updateViews
//Updates the view to match the screen orientation (only relevant for iPhone)
{
    if IPHONE
    {
        CGFloat fullWidth = self.navigationController.view.superview.frame.size.width;
        CGFloat fullHeight = self.navigationController.view.superview.frame.size.height;
        CGFloat imgWidth = self.sightImage.frame.size.width;
        CGFloat imgHeight = self.sightImage.frame.size.height;
        CGFloat imgStartPosition;
        CGFloat maxWidth;
        
        if (fullWidth > fullHeight)
            //The phone is landscape
        {
            self.contentHeight -= self.heightOffset;
            self.heightOffset = self.navigationController.navigationBar.frame.size.height;
            self.contentHeight += self.heightOffset;
            imgStartPosition = (fullWidth - imgWidth) / 2;
            maxWidth = fullHeight;
            
        }
        else
            //The phone is portrait
        {
            self.contentHeight -= self.heightOffset;
            self.heightOffset = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
            self.contentHeight += self.heightOffset;
            imgStartPosition = 0;
            maxWidth = fullWidth;
        }
        
        //Update the scrollView frame
        CGFloat tabBarheight =self.navigationController.tabBarController.tabBar.frame.size.height;
        self.scrollView.frame = CGRectMake(0, 0, fullWidth, fullHeight-tabBarheight);
        
        //Set the image to the right position
        self.sightImage.frame = CGRectMake(imgStartPosition, self.heightOffset, imgWidth, imgHeight);
        
        //Set the description to the center of the screen and adjust height position
        CGFloat contentSize = self.heightOffset + self.sightImage.frame.size.height;
        CGFloat txtWidth = self.sightDescription.frame.size.width;
        CGFloat txtHeight = self.sightDescription.frame.size.height;
        self.sightDescription.frame = CGRectMake(imgStartPosition, contentSize, txtWidth, txtHeight);
        
        //Set the button to the center of the screen and adjust height position
        contentSize += txtHeight;
        CGFloat btnWidth = self.showInMapButton.frame.size.width;
        CGFloat btnHeight = self.showInMapButton.frame.size.height;
        CGFloat buttonStartPosition = (fullWidth - btnWidth) / 2;
        self.showInMapButton.frame = CGRectMake(buttonStartPosition, contentSize, btnWidth, btnHeight);
        
        //Update scrollview contentsize
        self.scrollView.contentSize=CGSizeMake(maxWidth,self.contentHeight);
        
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//Should only apply for iPhone, as for iPad the modal view size stays the same
{
    [self updateViews];
}

@end
