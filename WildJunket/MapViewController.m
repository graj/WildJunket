//
//  MapViewController.m
//  WildJunket
//
//  Created by David García Fernández on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define fsqAuth [NSURL URLWithString:@"https://api.foursquare.com/v2/users/self/checkins?oauth_token=KN4AYPARK5GJ4GRKE2F3GIQWPEKIDX3WJFAKW4TUOP2YU3CV&limit=1&v=20120608"]

#define ZOOM_LEVEL 10

#import "MapViewController.h"
#import "SVProgressHUD.h"


@interface MapViewController ()
@property (nonatomic, strong) UIImageView *imageView;

- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end

@implementation MapViewController
@synthesize mapView=_mapview;
@synthesize country=_country;
@synthesize city=_city;
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize description=_descripcion;
@synthesize dataView = _dataView;
@synthesize locationManager;
@synthesize countryCode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
   
    [super viewDidLoad];
    
    //Data background
    UIImage *img = [UIImage imageNamed:@"mapviewbackground.png"];
    CGSize imgSize = self.dataView.frame.size;
    
    UIGraphicsBeginImageContext( imgSize );
    [img drawInRect:CGRectMake(0,0,imgSize.width,imgSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.dataView.backgroundColor = [UIColor colorWithPatternImage:newImage];
    
    [SVProgressHUD showWithStatus:@"Locating WildJunket guys..."];
	dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: fsqAuth];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
    //Retrieving user location
    self.locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    //Geocoding Block
        
    
    /*[self.geoCoder reverseGeocodeLocation: locationManager.location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         
         //Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         //String to hold address
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         
         //Print the location to console
         NSLog(@"I am currently at %@",locatedAt);
         
         NSString *country = placemark.country;
         
         NSLog(@"City: %@",country);
         
                  
                 
     }];*/

    
}

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
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error 
{
    [locationManager stopUpdatingLocation];
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
}




- (void)viewWillAppear:(BOOL)animated
{
   
    //Shows status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
	[super viewWillAppear:animated];
    

}

- (void)getGoogleResponse:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    //NSString* countryCode = [[[[[json objectForKey:@"results"]objectAtIndex:0]objectForKey:@"address_components"]objectAtIndex:6]objectForKey:@"short_name"];
    
    
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
            }
        }
        
    }
    NSLog(@"Country: %@", country);
   
    
}


- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions 
                          error:&error];
    
    NSDictionary* location = [[[[[[json objectForKey:@"response"]objectForKey:@"checkins"]objectForKey:@"items"]objectAtIndex:0]objectForKey:@"venue"]objectForKey:@"location"];
    
    NSString *imagenURL=[[[[[[[[json objectForKey:@"response"]objectForKey:@"checkins"]objectForKey:@"items"]objectAtIndex:0]objectForKey:@"photos"]objectForKey:@"items"]objectAtIndex:0]objectForKey:@"url"];
    
    NSDictionary* detalles=[[[[json objectForKey:@"response"]objectForKey:@"checkins"]objectForKey:@"items"]objectAtIndex:0];

    NSString* detalle=[detalles objectForKey:@"shout"];
    NSString* countryCodeFSQ=[location objectForKey:@"cc"];
    NSString* country=[location objectForKey:@"country"];
    NSString* city=[location objectForKey:@"city"];
    
    NSString* latitude=[location objectForKey:@"lat"];
    NSString* longitude=[location objectForKey:@"lng"];
    
    [self setMapDetails:latitude longitude:longitude country:country city:city detalle:detalle imageURL:imagenURL];
    [SVProgressHUD dismiss];
    
    //Check the country codes
    if([self.countryCode isEqualToString:countryCodeFSQ]){
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"What a casuality!"
                                  message:@"Woww we are in the same country!"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];

    }
    
}

-(void)setMapDetails:(NSString *) latitude longitude:(NSString *) longitude country:(NSString *) country city:(NSString *) city detalle:(NSString *) detalle imageURL:(NSString*)imageURL{
    
    //Imagen del checkin
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:urlData];
    
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
    [self.scrollView addSubview:self.imageView];
    
    // 2
    self.scrollView.contentSize = image.size;
    
    // 3
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    // 4
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.backgroundColor=[UIColor blackColor];
    
    // 5
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale = minScale;
    
    // 6
    [self centerScrollViewContents];

    
       
    //Texts and map
    [self.city setText:city];
    [self.country setText:country];
    [self.description setText:detalle];
    CLLocationCoordinate2D centerCoord = {[latitude doubleValue], [longitude doubleValue]};
    [self.mapView setCenterCoordinate:centerCoord zoomLevel:ZOOM_LEVEL animated:YES];

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

- (void)viewDidUnload
{
    [locationManager stopUpdatingLocation];
    [self setDataView:nil];
    [self setLocationManager:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
            interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown );}


@end
