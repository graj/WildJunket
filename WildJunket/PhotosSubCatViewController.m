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
#import "PhotosAllViewController.h"
#import "UIButton+WebCache.h"
#include <stdlib.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define portraitSize CGRectMake(0, 0, 225.0f, 225.0f)
#define landscapeSize CGRectMake(0, 0, 150.0f, 150.0f)
#define radiusPortrait 382.0f
#define radiusLandscape 312.0f

@interface PhotosSubCatViewController () <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic) iCarousel *carousel;
@property bool portrait;
@property (nonatomic) CGFloat radius;
@end

@implementation PhotosSubCatViewController
@synthesize titulo;
@synthesize carousel;
@synthesize category=_category;
@synthesize portrait;
@synthesize radius;

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    
    //return the total number of items in the carousel
    return [self.category.subCats count];
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
	
    [button setImageWithURL:[[self.category.subCats objectAtIndex:index] thumbnailURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
      
    
	return button;
    
}

//Evento al mover el carousel
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    int index = self.carousel.currentItemIndex;
    titulo.text=[[self.category.subCats objectAtIndex:index] name];
    
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
	SubCategory *subCat=[self.category.subCats objectAtIndex:index];
    
    //Hacer esto para llamar al otro controller, hay que hacerlo programaticamente
    
    if(subCat.albums.count>1){
    
        PhotosAlbumViewController *albumVC = [[PhotosAlbumViewController alloc] initWithSubCategory:subCat];
        albumVC.navigationItem.title = subCat.name;
    
        [self.navigationController pushViewController:albumVC animated:YES];
    } else{
        
        //Si solo tiene álbumes es que ese es el álbum
        Album* albumAux=[subCat.albums objectAtIndex:0];
        PhotosAllViewController *allVC = [[PhotosAllViewController alloc] initWithAlbum:albumAux];
        allVC.navigationItem.title = albumAux.name;
        allVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:allVC animated:YES];

        
    }
    
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
    
    [self checkOrientation];
    
    //Backgroud image
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"photosbackground3.png"]];

    
    //Mostrar Nav Bar
    [self.navigationController setNavigationBarHidden: NO animated:YES];
    
    [self.titulo setHidden:YES];
    
    
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
    self.carousel.delegate = self;
    self.carousel.dataSource = self;
    self.carousel.type=iCarouselTypeCoverFlow2;
    
    //Offset
    CGSize offset = CGSizeMake(0.0f, 38.0f);
    self.carousel.contentOffset = offset;
    
    //add carousel to view
    [self.view addSubview:carousel];
    
    titulo.text=[[self.category.subCats objectAtIndex:0] name];
    [self.titulo setHidden:NO];
    [SVProgressHUD dismiss];
}

-(void) getImagenesSubCategorias{
       
    int randomAlbum;
    Album *albumAux;
    NSString *urlStr;
    NSURL *url;
    
    dispatch_group_t group = dispatch_group_create();
    
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
        
        dispatch_group_async(group, kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL: url];
            [self getPhotosResponse:data subCat:cat];
        });
        
    }
    
    //Espera hasta que el grupo de threads ha terminado
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_release(group);
    
}

-(void) getPhotosResponse:(NSData *)responseData subCat:(SubCategory*)subcat{
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
    if(urlImagen!=nil)
        [subcat setThumbnailPhotoURL:urlImagen];
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
        
        self.titulo.frame=CGRectMake(20, -12, 440.0f, 72.0f);
        
        [self.titulo setFont:[UIFont fontWithName:@"GillSans-Bold" size:23]];
    }
}

- (void)viewDidUnload
{
    
    
    [self setTitulo:nil];
    self.carousel = nil;
    self.category=nil;
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

