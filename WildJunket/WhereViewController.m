//
//  WhereViewController.m
//  WildJunket
//
//  Created by david on 12/08/12.
//
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define fsqAuth [NSURL URLWithString:@"https://api.foursquare.com/v2/users/self/checkins?oauth_token=KN4AYPARK5GJ4GRKE2F3GIQWPEKIDX3WJFAKW4TUOP2YU3CV&limit=4&v=20120608"]

#define ZOOM_LEVEL 10

#import "WhereViewController.h"
#import "SVProgressHUD.h"
#import "UIView+Screenshot.h"
#import "FSQEntry.h"
#import "CountryCodeCell.h"

@interface WhereViewController ()

@end

@implementation WhereViewController
@synthesize fsqEntries=_fsqEntries;

- (void)initPaperFold
{
    _paperFoldView = [[PaperFoldView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width,[self.view bounds].size.height)];
    [_paperFoldView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:_paperFoldView];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,240,[self.view bounds].size.height)];
    [_paperFoldView setRightFoldContentView:_mapView rightViewFoldCount:3 rightViewPullFactor:0.9];
    
    _centerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width,[self.view bounds].size.height)];
    [_centerTableView setRowHeight:120];
    [_paperFoldView setCenterContentView:_centerTableView];
    [_centerTableView setDelegate:self];
    [_centerTableView setDataSource:self];
    
    _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,100,[self.view bounds].size.height)];
    [_leftTableView setRowHeight:100];
    [_leftTableView setDataSource:self];
    [_leftTableView setDelegate:self];
    [_paperFoldView setLeftFoldContentView:_leftTableView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(-1,0,1,[self.view bounds].size.height)];
    [_paperFoldView.contentView addSubview:line];
    [line setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake([self.view bounds].size.width,0,1,[self.view bounds].size.height)];
    [_paperFoldView.contentView addSubview:line2];
    [line2 setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight];
    [line2 setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1]];
    
    [_paperFoldView setDelegate:self];
    
    // you may want to disable dragging to preserve tableview swipe functionality
    
    // disable left fold
    //[_paperFoldView setEnableLeftFoldDragging:NO];
    
    // disable right fold
    //[_paperFoldView setEnableRightFoldDragging:NO];
}

-(void)getDatosFSQ:(NSData*)responseData{
    //Obtiene los datos de FSQ, parsea  y setean en fqlEntries array
    
    
    NSError* error;
    NSDictionary* location;
    NSURL *imagenURL;
    NSDictionary* detalles;
    NSString* detalle;
    NSString* countryCodeFSQ;
    NSString* country;
    NSString* city;
    double latitude;
    double longitude;
    FSQEntry *fsqEntry;
    
    self.fsqEntries=[[NSMutableArray alloc] init];
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    NSMutableArray *items=[[[json objectForKey:@"response"]objectForKey:@"checkins"]objectForKey:@"items"];
    
    for(int i=0; i<items.count; i++){
        
        location = [[[items objectAtIndex:i]objectForKey:@"venue"]objectForKey:@"location"];
        
        //Comprobar que tiene foto, si no, usar el placeholder
        @try {
            imagenURL=[NSURL URLWithString:[[[[[items objectAtIndex:i]objectForKey:@"photos"]objectForKey:@"items"]objectAtIndex:0]objectForKey:@"url"]];
            
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
                
        detalles=[items objectAtIndex:i];
        
        detalle=[detalles objectForKey:@"shout"];
        countryCodeFSQ=[location objectForKey:@"cc"];
        country=[location objectForKey:@"country"];
        city=[location objectForKey:@"city"];
        
        latitude=[[location objectForKey:@"lat"] doubleValue];
        longitude=[[location objectForKey:@"lng"] doubleValue];
        
        fsqEntry=[[FSQEntry alloc] init:country city:city description:detalle photo:imagenURL latitude:latitude longitude:longitude countryCode:countryCodeFSQ];
        
        [self.fsqEntries addObject:fsqEntry];

    }
    
#ifdef CONFIGURATION_Beta
    [TestFlight passCheckpoint:@"readedDataFromFSQ"];
#endif
    
    [SVProgressHUD dismiss];
    [self initPaperFold];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [SVProgressHUD showWithStatus:@"Locating WildJunket guys..."];
	dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: fsqAuth];
        [self performSelectorOnMainThread:@selector(getDatosFSQ:) withObject:data waitUntilDone:YES];
    });

	
    
  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.paperFoldView=nil;
    self.mapView=nil;
    self.leftTableView=nil;
    self.centerTableView=nil;
    self.locationManager=nil;    
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //left tableview
    if(tableView==_leftTableView){
        return self.fsqEntries.count;
    }else{
        return 0;
        
    }
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView==_leftTableView){
        static NSString *identifier = @"CountryCodeCell";
        CountryCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
        if (!cell)
        {
            
            cell = [[CountryCodeCell alloc] initWithStyle:UITableViewCellStyleDefault                                           reuseIdentifier:identifier];
            
        }

        //left tableview
        cell.primaryLabel.text=[[self.fsqEntries objectAtIndex:indexPath.row] countryCode];
             
        return cell;
        
    }else{
        return nil;
    }
  
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        // unfold left view
        [self.paperFoldView setPaperFoldState:PaperFoldStateLeftUnfolded];
    }
    else if (indexPath.row==1)
    {
        // unfold right view
        [self.paperFoldView setPaperFoldState:PaperFoldStateRightUnfolded];
    }
    else if (indexPath.row==2)
    {
        // restore to center
        [self.paperFoldView setPaperFoldState:PaperFoldStateDefault];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark paper fold delegate

- (void)paperFoldView:(id)paperFoldView didFoldAutomatically:(BOOL)automated toState:(PaperFoldState)paperFoldState
{
    NSLog(@"did transition to state %i", paperFoldState);
}

@end
