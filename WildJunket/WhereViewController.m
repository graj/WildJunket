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
#import "CenterCell.h"
#import "SDWebImage/SDWebImageManager.h"
#import "PopupViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "Reachability.h"


@interface WhereViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SDWebImageManager *manager;
@property NSString *countryCode;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end

@implementation WhereViewController
@synthesize fsqEntries=_fsqEntries;
@synthesize imageView,scrollView, locationManager, countryCode, manager;

-(BOOL)reachable {
    Reachability *r = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

- (void)initPaperFold
{
    _paperFoldView = [[PaperFoldView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width,[self.view bounds].size.height)];
    [_paperFoldView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:_paperFoldView];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,240,[self.view bounds].size.height)];
    _mapView.mapType=MKMapTypeHybrid;
    [_paperFoldView setRightFoldContentView:_mapView rightViewFoldCount:3 rightViewPullFactor:0.9];
    
    _centerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width, [self.view bounds].size.height)];
    [_centerTableView setRowHeight:[self.view bounds].size.height];
    _centerTableView.scrollEnabled=NO;
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
    NSString *date;
    
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
        date=[detalles objectForKey:@"createdAt"];
        
        fsqEntry=[[FSQEntry alloc] init:country city:city description:detalle photo:imagenURL latitude:latitude longitude:longitude countryCode:countryCodeFSQ date:date];
        
        [self.fsqEntries addObject:fsqEntry];

    }
    
#ifdef CONFIGURATION_Beta
    [TestFlight passCheckpoint:@"readedDataFromFSQ"];
#endif
    
    //Check the country codes
    NSString *lastCountryCode=[[self.fsqEntries objectAtIndex:0] countryCode];
    if([self.countryCode isEqualToString:lastCountryCode]){
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"What a casuality!"
                                  message:@"Woww we are in the same country!"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        
    }

    
    
    [SVProgressHUD dismiss];
    [self initPaperFold];

}

-(NSString*)getDateFromEpoch:(NSString*)epochTime{
    // (Step 1) Convert epoch time to SECONDS since 1970
    NSTimeInterval seconds = [epochTime doubleValue];
    //NSLog (@"Epoch time %@ equates to %qi seconds since 1970", epochTime, (long long) seconds);
    
    // (Step 2) Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    //NSLog (@"Epoch time %@ equates to UTC %@", epochTime, epochNSDate);
    
    // (Step 3) Use NSDateFormatter to display epochNSDate in local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, YYYY"];
    //NSLog (@"Epoch time %@ equates to %@", epochTime, [dateFormatter stringFromDate:epochNSDate]);
    
    return [dateFormatter stringFromDate:epochNSDate];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self reachable]) {
        self.manager = [SDWebImageManager sharedManager];
        
        [SVProgressHUD showWithStatus:@"Locating WildJunket guys..."];
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL: fsqAuth];
            [self performSelectorOnMainThread:@selector(getDatosFSQ:) withObject:data waitUntilDone:YES];
        });
        
        //Retrieving user location
        self.locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        
        //Comprueba si es la primera vez que se ejecuta la app
        if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                    objectForKey:@"Avalue"]]) {
            [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"Avalue"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            PopupViewController *popupController = [[PopupViewController alloc] initWithNibName:@"PopupViewController" bundle:nil];
            [self presentPopupViewController:popupController animationType:MJPopupViewAnimationSlideLeftRight];
            
        }

    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Connection"
                                  message:@"An Internet Connection is needed"                                      delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    
  
    
  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.paperFoldView=nil;
    self.mapView=nil;
    self.leftTableView=nil;
    self.centerTableView=nil;
    self.locationManager=nil;
    self.imageView=nil;
    self.scrollView=nil;
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
        return 1;
        
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
        cell.cityLabel.text=[[self.fsqEntries objectAtIndex:indexPath.row] city];
             
        return cell;
        
    }else{
        static NSString *identifier = @"CenterCell";
        CenterCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell)
        {
            
            cell = [[CenterCell alloc] initWithStyle:UITableViewCellStyleDefault                                           reuseIdentifier:identifier];
            
        }
        
        int selectedLeftIndex=_leftTableView.indexPathForSelectedRow.row;
        cell.countryLabel.text=[[self.fsqEntries objectAtIndex:selectedLeftIndex] country];
        cell.cityLabel.text=[[self.fsqEntries objectAtIndex:selectedLeftIndex] city];
        cell.dateLabel.text=[self getDateFromEpoch:[[self.fsqEntries objectAtIndex:selectedLeftIndex] date]];
        cell.descLabel.text=[[self.fsqEntries objectAtIndex:selectedLeftIndex] description];
        
        
        //Orientation
        if([[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationPortraitUpsideDown){
            
            [cell checkOrientations:YES];

        }
        else{
           [cell checkOrientations:NO];
        }
        
        
        
        //Imagen del checkin y scrollview
        
        self.scrollView=cell.scrollView;
        
        //Clean subviews
        NSArray *viewsToRemove = [self.scrollView subviews];
        for (UIView *v in viewsToRemove) [v removeFromSuperview];
             
        NSURL *url = [[self.fsqEntries objectAtIndex:selectedLeftIndex] photo];
        
        [manager downloadWithURL:url
                        delegate:self
                         options:0
                         success:^(UIImage *image)
         {
             self.imageView = [[UIImageView alloc] initWithImage:image];
             self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.scrollView.frame.size};
             [cell.scrollView addSubview:self.imageView];
             self.imageView.clipsToBounds=YES;
             self.imageView.contentMode=UIViewContentModeScaleAspectFill;
            
         }
                         failure:nil];
        
        self.scrollView.layer.cornerRadius = 15.0;
        self.scrollView.layer.masksToBounds = YES;
               
        // 2
        cell.scrollView.contentSize = cell.scrollView.frame.size;
        cell.scrollView.delegate=self;
        
        // 3
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        [cell.scrollView addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
        twoFingerTapRecognizer.numberOfTapsRequired = 1;
        twoFingerTapRecognizer.numberOfTouchesRequired = 2;
        [cell.scrollView addGestureRecognizer:twoFingerTapRecognizer];
        
        // 4
        CGRect scrollViewFrame = cell.scrollView.frame;
        CGFloat scaleWidth = scrollViewFrame.size.width / cell.scrollView.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / cell.scrollView.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        cell.scrollView.minimumZoomScale = minScale;
        cell.scrollView.backgroundColor=[UIColor blackColor];
        
        // 5
        cell.scrollView.maximumZoomScale = 2.0f;
        cell.scrollView.zoomScale = minScale;
        
        // 6
        [self centerScrollViewContents];
        
        [self updateMap];
        
        return cell;
         
    }  
    
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // 1
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    // 2
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that you want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_leftTableView){
      
        // restore to center
        [self.paperFoldView setPaperFoldState:PaperFoldStateDefault];
        [self.centerTableView reloadData];
        
    }
    else{
        // restore to center
        [self.paperFoldView setPaperFoldState:PaperFoldStateDefault];
    }
    
}

-(void)updateMap{
    
    int selectedLeftIndex=_leftTableView.indexPathForSelectedRow.row;
    CLLocationCoordinate2D centerCoord = {[[self.fsqEntries objectAtIndex:selectedLeftIndex] latitude], [[self.fsqEntries objectAtIndex:selectedLeftIndex] longitude]};
    [_mapView setCenterCoordinate:centerCoord zoomLevel:ZOOM_LEVEL animated:YES];

}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [_centerTableView reloadData];

}

- (void)getGoogleResponse:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    
    NSMutableArray *arr=[[[json objectForKey:@"results"]objectAtIndex:0]objectForKey:@"address_components"];
    
    NSDictionary *temp;
    NSMutableArray *arrTemp;
    NSString *strTemp;
    NSString *country;
    
    for (int i=0; i<[arr count]; i++) {
        temp=[arr objectAtIndex:i];
        arrTemp=[temp objectForKey:@"types"];
        for (int t=0; t<[arrTemp count]; t++) {
            strTemp=[arrTemp objectAtIndex:t];
            if([strTemp isEqualToString:@"country"])
            {
                //Lo he encontrado!!
                country=[temp objectForKey:@"short_name"];
                self.countryCode=country;
                break;
            }
        }
        
    }
    
#ifdef CONFIGURATION_Beta
    [TestFlight passCheckpoint:@"googleResponse"];
#endif
    
    NSLog(@"Country: %@", country);
    
    
}

#pragma mark locationmanager
// this delegate is called when the app successfully finds your current location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //Geocoding Block
    //Asking Google
    NSString *urlStr=[[[[@"http://maps.google.com/maps/api/geocode/json?latlng=" stringByAppendingString:[[NSNumber numberWithDouble:newLocation.coordinate.latitude]stringValue]] stringByAppendingString:@","]stringByAppendingString:[[NSNumber numberWithDouble:newLocation.coordinate.longitude]stringValue]]stringByAppendingString:@"&sensor=true&language=en"];
    
    NSURL *url=[NSURL URLWithString:urlStr];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: url];
        [self performSelectorOnMainThread:@selector(getGoogleResponse:) withObject:data waitUntilDone:NO];
    });
    
    [locationManager stopUpdatingLocation];
    
    
}

// this delegate method is called if an error occurs in locating your current location
- (void)locationManager:(CLLocationManager *)managerLoc didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
    NSLog(@"locationManager:%@ didFailWithError:%@", managerLoc, error);
}


#pragma mark paper fold delegate

- (void)paperFoldView:(id)paperFoldView didFoldAutomatically:(BOOL)automated toState:(PaperFoldState)paperFoldState
{
    NSLog(@"did transition to state %i", paperFoldState);
}

@end
