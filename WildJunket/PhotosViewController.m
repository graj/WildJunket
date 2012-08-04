//
//  SecondViewController.m
//  WildJunket
//
//  Created by David García Fernández on 16/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosViewController.h"
#import "FXImageView.h"
#import "SVProgressHUD.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define smugmugCat [NSURL URLWithString:@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.categories.get&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&NickName=wildjunket&pretty=true"]

@interface PhotosViewController ()
@property (nonatomic) NSMutableArray *items;
@end

@implementation PhotosViewController
@synthesize titulo;
@synthesize carousel;
@synthesize items;


#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil)
    {
        FXImageView *imageView = [[[FXImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)] autorelease];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.asynchronous = YES;
        imageView.reflectionScale = 0.5f;
        imageView.reflectionAlpha = 0.25f;
        imageView.reflectionGap = 10.0f;
        imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
        imageView.shadowBlur = 5.0f;
        view = imageView;
    }
    
    //show placeholder
    ((FXImageView *)view).processedImage = [UIImage imageNamed:@"placeholder.png"];
    
    //set image with URL. FXImageView will then download and process the image
    [(FXImageView *)view setImageWithContentsOfURL:[items objectAtIndex:index]];
    
    return view;
}

//Evento al mover el carousel
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    
}

- (void)viewDidLoad
{
    //No quiero la Nav Bar en esta vista
    self.navigationController.navigationBarHidden = YES;
    
    //tipo Wheel
    self.carousel.type = iCarouselTypeWheel;
    
    //Meter en items las urls con las imagenes de las categorias
    [self getImagesCategorias];
    
    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void) getImagesCategorias{

    //Llamada API de smugmug y tomar urls de las fotos de las categorías
    [SVProgressHUD showWithStatus:@"Loading WildJunket Photos..."];
	dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: smugmugCat];
        [self performSelectorOnMainThread:@selector(fetchedCatData:) withObject:data waitUntilDone:YES];
    });
    
    
}

-(void)fetchedCatData:(NSData *)responseData{
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData                           
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
    
#ifdef CONFIGURATION_Beta
    [TestFlight passCheckpoint:@"dataFromFSQ"];
#endif
    
    [SVProgressHUD dismiss];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    //Shows status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
	[super viewWillAppear:animated];
    
    
}

- (void)viewDidUnload
{
    
    
    [self setTitulo:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
            interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
            interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown );
}

@end
