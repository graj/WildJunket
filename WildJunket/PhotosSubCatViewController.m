//
//  PhotosSubCatViewController.m
//  WildJunket
//
//  Created by David García Fernández on 16/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosSubCatViewController.h"
#import "SVProgressHUD.h"
#import "Album.h"
#import "CategoryPhotos.h"
#import "SubCategory.h"
#import "PhotosAlbumViewController.h"
#import "UIButton+WebCache.h"
#include <stdlib.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@interface PhotosSubCatViewController () <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic) iCarousel *carousel;
@property (nonatomic) NSMutableArray *items;

@end

@implementation PhotosSubCatViewController
@synthesize titulo;
@synthesize carousel;
@synthesize category=_category;

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    
    //return the total number of items in the carousel
    return [self.items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    
    UIButton *button = (UIButton *)view;
	if (button == nil)
	{
		//no button available to recycle, so create new one
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(0, 0, 200.0f, 200.0f);
		[button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
	}
	
    [button setImageWithURL:[self.items objectAtIndex:index] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    
	return button;
    
}

//Evento al mover el carousel
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    int index = self.carousel.currentItemIndex;
    titulo.text=[[self.category.subCats objectAtIndex:index] name];
    
}

#pragma mark -
#pragma mark Button tap event

- (void)buttonTapped:(UIButton *)sender
{
    //get item index for button
	NSInteger index = [carousel indexOfItemViewOrSubview:sender];
	SubCategory *subCat=[self.category.subCats objectAtIndex:index];
    
    //Hacer esto para llamar al otro controller, hay que hacerlo programaticamente
    
    PhotosAlbumViewController *albumVC = [[PhotosAlbumViewController alloc] initWithSubCategory:subCat];
    albumVC.navigationItem.title = subCat.name;
    
    [self.navigationController pushViewController:albumVC animated:YES];
    
}

#pragma mark -
#pragma mark view methods

- (id)initWithCategory:(CategoryPhotos*)category
{
    if ((self = [super init])) {
        self.category=category;
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    //tipo Wheel
    
    //No quiero la Nav Bar en esta vista
    self.navigationController.navigationBarHidden = NO;
    
    [self.titulo setHidden:YES];
    
    //Apariencia
    self.view.backgroundColor=[UIColor whiteColor];
    self.titulo.textColor=[UIColor blackColor];
    
    //Llamada API de smugmug y tomar urls de las fotos de las categorías
    [SVProgressHUD showWithStatus:[@"Loading " stringByAppendingString:self.category.name]];
    
    
    dispatch_async(kBgQueue, ^{
        
        //Meter en items las urls con las imagenes de las categorias
        [self getImagenesSubCategorias];
        
        [self performSelectorOnMainThread:@selector(createCarousel) withObject:nil waitUntilDone:YES];
        
#ifdef CONFIGURATION_Beta
        [TestFlight passCheckpoint:@"leidos datos smugmug"];
#endif
        
        
    });
    
}

-(void) createCarousel{
    //create carousel
    self.carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
    self.carousel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.carousel.type = iCarouselTypeWheel;
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    
    //add carousel to view
    [self.view addSubview:carousel];
    
    titulo.text=[[self.category.subCats objectAtIndex:0] name];
    [self.titulo setHidden:NO];
    [SVProgressHUD dismiss];
}

-(void) getImagenesSubCategorias{
    
    //Instancio array de URL's
    self.items=[[NSMutableArray alloc] init];
    
    int randomAlbum;
    Album *albumAux;
    NSString *urlStr;
    NSURL *url;
    
    for (SubCategory *cat in self.category.subCats) {
        
        //De un álbum random
        //Si tiene más de un elemento, si no cojo el primero
        if([cat.albums count]>1)
            randomAlbum=arc4random() % ([cat.albums count]-1);
        else
            randomAlbum=0;
        albumAux=[cat.albums objectAtIndex:randomAlbum];
        
        //Obtengo las fotos de ese álbum
        urlStr=[[[[@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.images.get&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&AlbumID=" stringByAppendingString:[[NSNumber numberWithInt:albumAux.idAlbum]stringValue]] stringByAppendingString:@"&AlbumKey="]stringByAppendingString:albumAux.key]stringByAppendingString:@"&pretty=true"];
        
        url=[NSURL URLWithString:urlStr];
        
        NSData* data = [NSData dataWithContentsOfURL: url];
        [self getPhotosResponse:data];
        
    }
    
}

-(void) getPhotosResponse:(NSData *)responseData{
    //parse out the json data
    NSError* error;
    int randomImagen;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    
    
    //Obtengo las imagenes
    NSMutableArray* imagenes = [[json objectForKey:@"Album"]objectForKey:@"Images"];
    if([imagenes count]>1)
        randomImagen = arc4random() % ([imagenes count]-1);
    else
        randomImagen=0;
    
    int imageID=[[[imagenes objectAtIndex:randomImagen]objectForKey:@"id"] intValue];
    NSString *imageKey=[[imagenes objectAtIndex:randomImagen]objectForKey:@"Key"];
    
    //Obtengo la url de la imagen random
    NSString *urlStr=[[[[@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.images.getURLs&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&ImageID=" stringByAppendingString:[[NSNumber numberWithInt:imageID]stringValue]] stringByAppendingString:@"&ImageKey="]stringByAppendingString:imageKey]stringByAppendingString:@"&pretty=true"];
    
    NSURL *url=[NSURL URLWithString:urlStr];
    NSData* dataImagen = [NSData dataWithContentsOfURL: url];
    
    json = [NSJSONSerialization
            JSONObjectWithData:dataImagen
            options:kNilOptions
            error:&error];
    
    NSURL *urlImagen = [NSURL URLWithString:[[json objectForKey:@"Image"]objectForKey:@"SmallURL"]];
    //Añado la url al array de URL's de categorías
    [self.items addObject:urlImagen];
    
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
    self.carousel = nil;
    self.category=nil;
    self.items=nil;
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

