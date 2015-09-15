//
//  ListViewController.m
//
//  Created by Roger Carvalho on 15/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()
@property BOOL dataAvailable;
@property NSTimer *loadingTimer;
@end

@implementation ListViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//Upon initialization, set the title
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {

        self.title =  NSLocalizedString(@"SIGHTS_TITLE", nil);
        

        //Subscribe to the notificationcenter to receive a message when the sightsDatabase is ready
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData:) name:@"DataReady" object:nil];

        return self;
    }
    
    else
    {
        return nil;
    }

}

- (void)loadData:(NSNotification *)note
//Once the app notifies this view that a sightsDatabase is ready, start create a tableview with the data
{
    //Take the sights dictionary from the notification and prepare a local array to build the table
    NSDictionary *sights = [[note userInfo] valueForKey:@"Data"];
    self.sightsCategoryReferences = [[NSMutableArray alloc] init];

    //For each sight category, create a section reference
    for (NSDictionary* key in sights)
    {
        [self.sightsCategoryReferences addObject:[sights objectForKey:key]];
    }
    

    //Set the local property to the dictionary of sights
    self.sights =sights;
    self.dataAvailable = YES;
    
    //Reload tableview
    [self.tableView reloadData];
    [self.loadingTimer invalidate];

}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    //We assume this view will load before the sightsDatabase is ready. Therefore load an empty table informing the user the data is loading
    self.dataAvailable = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // In the current implementation, all sights are listed as one list. In the future, we may want to create sight categories, which we can use as sections here
    return self.sightsCategoryReferences.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (self.dataAvailable)
    {
        //Return however many sights are available
        NSDictionary *sightsCategory =[self.sightsCategoryReferences[section] objectForKey:@"items"];
        NSInteger sightCount = [sightsCategory count];
        return sightCount;
    }
    else
    {
        //The sightsDatabase is not ready yet. Only show 1 row informing the user that the data is loading
        return 1;
    }
}

#pragma mark - Table view delegate methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *category = [self.sightsCategoryReferences objectAtIndex:section];
    NSString *categoryName = [category objectForKey:@"name"];
    return categoryName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   //Load data of a given cell
    
    //Initialize cell
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    if (self.dataAvailable)
    //The data is ready to be displayed
    {
        //Look up which sight should be in this cell, and get the data from the Collection object
        NSDictionary *currentCategory = [self.sightsCategoryReferences objectAtIndex:indexPath.section];
        NSDictionary *sights = [currentCategory objectForKey:@"items"];
        NSArray *keys = [sights allKeys];
        Sight *sight = [sights objectForKey:keys[indexPath.row]];
        //Sight *sight = self.sightsReferences[indexPath.row];
              
        //Set the title and description.
        cell.textLabel.text = sight.name;
        cell.detailTextLabel.text = sight.shortDesc;
#warning For future implementation: Some text is truncated. Change the cell layout to accomodate more lines.
    }
    else
    {
        //The data is not ready yet. Inform the user that data is loading
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"LOADING_TITLE", nil);
            
            self.loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(animateLoading:)
                                           userInfo:cell
                                            repeats:YES];

        }

    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//When a user selects a given row, open up the listview
{
    //Get the sight the user selected
    NSDictionary *currentCategory = self.sightsCategoryReferences[indexPath.section];
    NSDictionary *sights = [currentCategory objectForKey:@"items"];
    NSArray *keys = [sights allKeys];
    Sight *sight = [sights objectForKey:keys[indexPath.row]];
    
    if IPHONE
    //On iPhone, push detailview controller
    {
        //Open listview
        DetailViewController *vc = [[DetailViewController alloc] initWithNibName:nil bundle:nil andSight:sight];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    //On iPad, show the sight on the map
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissPopover" object:nil userInfo:nil];
        
        //Show on the map
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:sight forKey:@"Data"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LaunchMap" object:nil userInfo:dictionary];

    }
   
}

#pragma mark - Helper methods

-(void) animateLoading:(NSTimer *)timer
//Helper method, this animates the loading indicator to let users know the data is loading. It should be called at an interval
{
    UITableViewCell *cell = [timer userInfo];
    NSInteger minimumLength = NSLocalizedString(@"LOADING_TITLE", nil).length;
    NSInteger currentLength = cell.textLabel.text.length;
    NSInteger numDots = currentLength - minimumLength;
    
    switch (numDots)
    {
        case 3:
            
            cell.textLabel.text = NSLocalizedString(@"LOADING_TITLE", nil);
            
        break;
        default:
            
            cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@"."];
            
        break;
    }
}
@end
