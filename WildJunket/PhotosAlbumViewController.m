//
//  PhotosAlbumViewController.m
//  WildJunket
//
//  Created by david on 07/08/12.
//
//


#import "PhotosAlbumViewController.h"
#import "SVProgressHUD.h"
#import "Album.h"
#import "CategoryPhotos.h"
#import "PhotosAllViewController.h"
#import "SubCategory.h"
#import "UIButton+WebCache.h"
#include <stdlib.h>
#include "Reachability.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define portraitSize CGRectMake(0, 0, 225.0f, 225.0f)
#define landscapeSize CGRectMake(0, 0, 150.0f, 150.0f)
#define radiusPortrait 382.0f
#define radiusLandscape 312.0f

@interface PhotosAlbumViewController () <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic) iCarousel *carousel;
@property bool portrait;
@property (nonatomic) CGFloat radius;
@end

@implementation PhotosAlbumViewController
@synthesize titulo;
@synthesize carousel;
@synthesize subCategory=_subCategory;
@synthesize portrait;
@synthesize radius;

-(BOOL)reachable {
    Reachability *r = [Reachability reachabilityWithHostName:@"google.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    
    //return the total number of items in the carousel
    return [self.subCategory.albums count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    
    UIButton *button = (UIButton *)view;
	if (button == nil)
	{
		//no button available to recycle, so create new one
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		if(portrait)
            button.frame = portraitSize;
        else
            button.frame = landscapeSize;
        button.imageView.layer.cornerRadius = 10.0;
        button.imageView.layer.masksToBounds = YES;
		[button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	}
    
    [button setImageWithURL:[[self.subCategory.albums objectAtIndex:index] thumbnailURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
	return button;
    
}

//Evento al mover el carousel
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    int index = self.carousel.currentItemIndex;
    titulo.text=[[self.subCategory.albums objectAtIndex:index] name];
    
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
            
        case iCarouselOptionRadius:
        {
            return self.radius;
        }
        case iCarouselOptionFadeMin:
            return -0.2;
        case iCarouselOptionFadeMax:
            return 0.2;
        case iCarouselOptionFadeRange:
            return 2.0;
        default:
        {
            return value;
        }
    }
}

#pragma mark -
#pragma mark Button tap event

- (void)buttonTapped:(UIButton *)sender
{
    //get item index for button
	NSInteger index = [carousel indexOfItemViewOrSubview:sender];
	Album *album=[self.subCategory.albums objectAtIndex:index];
    
    //Hacer esto para llamar al otro controller, hay que hacerlo programaticamente
    
    PhotosAllViewController *allVC = [[PhotosAllViewController alloc] initWithAlbum:album];
    allVC.navigationItem.title = album.name;
    allVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:allVC animated:YES];
    
}

#pragma mark -
#pragma mark view methods

- (id)initWithSubCategory:(SubCategory*)subCategory
{
    if ((self = [super init])) {
        self.subCategory=subCategory;
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    //Backgroud image
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"photosbackground3.png"]];

    [self checkOrientation];
    
    //No quiero la Nav Bar en esta vista
    self.navigationController.navigationBarHidden = NO;
    
    [self.titulo setHidden:YES];
    
    //Apariencia
    if([self reachable]){
        //Llamada API de smugmug y tomar urls de las fotos de las categorías
        [SVProgressHUD showWithStatus:[@"Loading " stringByAppendingString:self.subCategory.name]];
        
        
        dispatch_async(kBgQueue, ^{
            
            //Meter en items las urls con las imagenes de las categorias
            [self getImagenesSubCategorias];
            
            [self performSelectorOnMainThread:@selector(createCarousel) withObject:nil waitUntilDone:YES];
            
#ifdef CONFIGURATION_Beta
            [TestFlight passCheckpoint:@"leidos datos smugmug"];
#endif
            
            
        });
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Connection"
                                  message:@"An Internet Connection is needed"                                      delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
   
}

-(void) createCarousel{
    //create carousel
    self.carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
    self.carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.carousel.type = iCarouselTypeCoverFlow2;
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    
    //Offset
    CGSize offset = CGSizeMake(0.0f, 38.0f);
    self.carousel.contentOffset = offset;
    
    //add carousel to view
    [self.view addSubview:carousel];
    
    titulo.text=[[self.subCategory.albums objectAtIndex:0] name];
    [self.titulo setHidden:NO];
    [SVProgressHUD dismiss];
}

-(void) getImagenesSubCategorias{
    
    NSString *urlStr;
    NSURL *url;
    
    dispatch_group_t group = dispatch_group_create();
    
    for (Album *alb in self.subCategory.albums) {
                 
        //Obtengo las fotos de ese álbum
        urlStr=[[[[@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.images.get&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&AlbumID=" stringByAppendingString:[[NSNumber numberWithInt:alb.idAlbum]stringValue]] stringByAppendingString:@"&AlbumKey="]stringByAppendingString:alb.key]stringByAppendingString:@"&pretty=true"];
        
        url=[NSURL URLWithString:urlStr];
        
        dispatch_group_async(group, kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL: url];
            [self getPhotosResponse:data album:alb];
        });
        
    }
    
    //Espera hasta que el grupo de threads ha terminado
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_release(group);
    
}

-(void) getPhotosResponse:(NSData *)responseData album:(Album*)album{
    //parse out the json data
    NSError* error;
    int randomImagen;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    
    
    //Obtengo las imagenes
    NSMutableArray* imagenes = [[json objectForKey:@"Album"]objectForKey:@"Images"];
    
    if(imagenes.count>0){
    if([imagenes count]>1)
        randomImagen = arc4random() % ([imagenes count]-1);
    else
        randomImagen=0;
    
    long long int imageID=[[[imagenes objectAtIndex:randomImagen]objectForKey:@"id"] longLongValue];
    NSString *imageKey=[[imagenes objectAtIndex:randomImagen]objectForKey:@"Key"];
    
    //Obtengo la url de la imagen random
    NSString *urlStr=[[[[@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.images.getURLs&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&ImageID=" stringByAppendingString:[[NSNumber numberWithLongLong:imageID]stringValue]] stringByAppendingString:@"&ImageKey="]stringByAppendingString:imageKey]stringByAppendingString:@"&pretty=true"];
    
    
    
    NSURL *url=[NSURL URLWithString:urlStr];
    NSData* dataImagen = [NSData dataWithContentsOfURL: url];
    
    json = [NSJSONSerialization
            JSONObjectWithData:dataImagen
            options:kNilOptions
            error:&error];
    
    NSURL *urlImagen = [NSURL URLWithString:[[json objectForKey:@"Image"]objectForKey:@"SmallURL"]];
    //Añado la url al array de URL's de categorías
    if(urlImagen!=nil)
        [album setThumbnailPhotoURL:urlImagen];
    }
    else{
        //Si un álbum no tiene fotos se borra
        [self.subCategory.albums removeObject:album];
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    //Shows status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [self checkOrientation];
    [self.carousel reloadData];
    
	[super viewWillAppear:animated];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    [self checkOrientation];
    [self.carousel reloadData];
    
}

-(void)checkOrientation{
    
    if([[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation]==UIInterfaceOrientationPortraitUpsideDown){
        
        //Portrait
        self.portrait=YES;
        self.radius=radiusPortrait;
        
        //Offset
        CGSize offset = CGSizeMake(0.0f, 38.0f);
        self.carousel.contentOffset = offset;
        
        self.titulo.frame=CGRectMake(20, 6, 280.0f, 72.0f);
        
        [self.titulo setFont:[UIFont fontWithName:@"GillSans-Bold" size:26]];
        
    } else {
        //Landscape
        self.portrait=NO;
        self.radius=radiusLandscape;
        
        //Offset
        CGSize offset = CGSizeMake(0.0f, 28.0f);
        self.carousel.contentOffset = offset;
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && IS_IPHONE_5){
            self.titulo.frame=CGRectMake(20, -10, 528.0f, 72.0f);
        }
        else{
            self.titulo.frame=CGRectMake(20, -10, 440.0f, 72.0f);
        }
        
        [self.titulo setFont:[UIFont fontWithName:@"GillSans-Bold" size:23]];
    }
}


- (void)viewDidUnload
{
    
    
    [self setTitulo:nil];
    self.carousel = nil;
    self.subCategory=nil;
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
