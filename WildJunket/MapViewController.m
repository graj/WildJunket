//
//  MapViewController.m
//  WildJunket
//
//  Created by David García Fernández on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define fsqAuth [NSURL URLWithString:@"https://api.foursquare.com/v2/users/self/checkins?oauth_token=KN4AYPARK5GJ4GRKE2F3GIQWPEKIDX3WJFAKW4TUOP2YU3CV&limit=1"]

#import "MapViewController.h"


@interface MapViewController ()

@end

@implementation MapViewController
@synthesize mapView=_mapview;

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
    
    
    NSString* country=[location objectForKey:@"country"];
    NSString* city=[location objectForKey:@"city"];
    
    NSString* latitude=[location objectForKey:@"lat"];
    NSString* longitude=[location objectForKey:@"lng"];
    
    NSLog(@"Pais: %@", country);
    NSLog(@"Ciudad: %@", city);
    NSLog(@"Lat: %@", latitude);
    NSLog(@"Long: %@", longitude);
    
    

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
