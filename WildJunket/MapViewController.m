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


@interface MapViewController ()

@end

@implementation MapViewController
@synthesize mapView=_mapview;
@synthesize country=_country;
@synthesize city=_city;
@synthesize imagen=_imagen;

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
	dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: fsqAuth];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
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

        
    NSString* country=[location objectForKey:@"country"];
    NSString* city=[location objectForKey:@"city"];
    
    NSString* latitude=[location objectForKey:@"lat"];
    NSString* longitude=[location objectForKey:@"lng"];
    
    [self setMapDetails:latitude longitude:longitude country:country city:city imageURL:imagenURL];
    
}

-(void)setMapDetails:(NSString *) latitude longitude:(NSString *) longitude country:(NSString *) country city:(NSString *) city imageURL:(NSString*)imageURL{
    
    //Imagen del checkin
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:urlData];
    self.imagen.image = image;
    
    
    [self.city setText:city];
    [self.country setText:country];
    CLLocationCoordinate2D centerCoord = {[latitude doubleValue], [longitude doubleValue]};
    [self.mapView setCenterCoordinate:centerCoord zoomLevel:ZOOM_LEVEL animated:YES];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
