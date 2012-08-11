//
//  SecondViewController.m
//  WildJunket
//
//  Created by David García Fernández on 16/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosViewController.h"
#import "SVProgressHUD.h"
#import "Album.h"
#import "CategoryPhotos.h"
#import "SubCategory.h"
#import "PhotosSubCatViewController.h"
#import "PhotosAlbumViewController.h"
#import "UIButton+WebCache.h"
#import "PhotosAllViewController.h"
#import <QuartzCore/QuartzCore.h> 
#include <stdlib.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define smugmugAlbums [NSURL URLWithString:@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.albums.get&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&NickName=wildjunket&pretty=true"]
#define portraitSize CGRectMake(0, 0, 250.0f, 250.0f)
#define landscapeSize CGRectMake(0, 0, 175.0f, 175.0f)
#define radiusPortrait 382.0f
#define radiusLandscape 312.0f


@interface PhotosViewController () <iCarouselDataSource, iCarouselDelegate>
@property (nonatomic, retain) iCarousel *carousel;
@property (nonatomic, retain) NSMutableArray *categories;
@property bool portrait;
@property (nonatomic) CGFloat radius;
@end

@implementation PhotosViewController
@synthesize titulo;
@synthesize carousel;
@synthesize portrait;
@synthesize radius;

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    
    //return the total number of items in the carousel
    return [self.categories count];
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
	
    [button setImageWithURL:[[self.categories objectAtIndex:index] thumbnailURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    
   
	return button;
    
}

//Evento al mover el carousel
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    int index = self.carousel.currentItemIndex;
    titulo.text=[[self.categories objectAtIndex:index] name];

}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        
        case iCarouselOptionRadius:
        {
            return self.radius;
        }
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
	CategoryPhotos *cat=[self.categories objectAtIndex:index];
    
    //Hacer esto para llamar al otro controller, hay que hacerlo programaticamente
    
    //Si tiene subcategorías se llama a estas
    if(cat.subCats.count>1){
    
        PhotosSubCatViewController *subCatVC = [[PhotosSubCatViewController alloc] initWithCategory:cat];
        subCatVC.navigationItem.title = cat.name;
    
        [self.navigationController pushViewController:subCatVC animated:YES];
    }
    //Si no se muestran los álbumes
    else{
        
        SubCategory *subCatAux=[cat.subCats objectAtIndex:0];
        
        if(subCatAux.albums.count>1){
            subCatAux.name=cat.name;
            PhotosAlbumViewController *albumVC = [[PhotosAlbumViewController alloc] initWithSubCategory:subCatAux];
            albumVC.navigationItem.title = cat.name;
        
            [self.navigationController pushViewController:albumVC animated:YES];
        }
        else{
            //Si solo tiene una subcategoría  solo un álbum pasa a las fotos
            Album* albumAux=[subCatAux.albums objectAtIndex:0];
            PhotosAllViewController *allVC = [[PhotosAllViewController alloc] initWithAlbum:albumAux];
            allVC.navigationItem.title = albumAux.name;
            allVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:allVC animated:YES];
            

        }
    }

}

#pragma mark -
#pragma mark view methods

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self checkOrientation];
    
    //Backgroud image
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"photosbackground.png"]];
    
    //No quiero la Nav Bar en esta vista
    self.navigationController.navigationBarHidden = YES;
    
    [self.titulo setHidden:YES];
    
    //Llamada API de smugmug y tomar urls de las fotos de las categorías
    [SVProgressHUD showWithStatus:@"Loading WildJunket Photos..."];
    
    
    dispatch_async(kBgQueue, ^{
        //Obtiene los datos de categorías, subcategorías y álbumes
        [self getDatosCategorias];
        
        //Meter en items las urls con las imagenes de las categorias
        [self getImagenesCategorias];
        
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
    
    //Offset
    CGSize offset = CGSizeMake(0.0f, 38.0f);
    self.carousel.contentOffset = offset;

    
    //add carousel to view
    [self.view addSubview:carousel];
        
    titulo.text=[[self.categories objectAtIndex:0] name];
    [self.titulo setHidden:NO];
    [SVProgressHUD dismiss];
}

-(void) getImagenesCategorias{
    
    //Instancio array de URL's
    int randomAlbum;
    int randomSubCat;
    SubCategory *subCatAux;
    Album *albumAux;
    NSString *urlStr;
    NSURL *url;

    dispatch_group_t group = dispatch_group_create();
    
    for (CategoryPhotos *cat in self.categories) {
        
                            
        //De una subcategoría random y un álbum random
        //Si tiene más de un elemento, si no cojo el primero
        if([cat.subCats count]>1)
            randomSubCat= arc4random() % ([cat.subCats count]-1);
        else
            randomSubCat=0;
        subCatAux=[cat.subCats objectAtIndex:randomSubCat];
        
        if([subCatAux.albums count]>1)
            randomAlbum=arc4random() % ([subCatAux.albums count]-1);
        else
            randomAlbum=0;
        albumAux=[subCatAux.albums objectAtIndex:randomAlbum];
        
        //Obtengo las fotos de ese álbum
        urlStr=[[[[@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.images.get&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&AlbumID=" stringByAppendingString:[[NSNumber numberWithInt:albumAux.idAlbum]stringValue]] stringByAppendingString:@"&AlbumKey="]stringByAppendingString:albumAux.key]stringByAppendingString:@"&pretty=true"];
        
        url=[NSURL URLWithString:urlStr];
        
        /*dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL: url];
            [self performSelectorOnMainThread:@selector(getPhotosResponse:) withObject:data waitUntilDone:YES];
        });*/
        
        dispatch_group_async(group, kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL: url];
            [self getPhotosResponse:data category:cat];
        });
        
    }
    
    //Espera hasta que el grupo de threads ha terminado
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    dispatch_release(group);
     
}

-(void) getPhotosResponse:(NSData *)responseData category:(CategoryPhotos*)category{
    //parse out the json data
    NSError* error;
    int randomImagen;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
   
    
    //Obtengo las imagenes
    NSMutableArray* imagenes = [[json objectForKey:@"Album"]objectForKey:@"Images"];
    
    if(imagenes.count>0) {
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
    
    if(urlImagen!=nil){
        [category setThumbnailPhotoURL:urlImagen];
    }
    }
}

-(void) getDatosCategorias{

   	
    NSData* data = [NSData dataWithContentsOfURL: smugmugAlbums];
    [self fetchedCatData:data];
       
}

-(void)fetchedCatData:(NSData *)responseData{
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData                           
                          options:kNilOptions
                          error:&error];
    
    
    Album* album;
    CategoryPhotos* category;
    SubCategory* subCategory;
    CategoryPhotos* categoryAux;
    SubCategory* subCategoryAux;
    int idAlbum;
    int idCat;
    int idSubCat;
    NSString* nameAlbum;
    NSString* nameCat;
    NSString* nameSubCat;
    NSString* key;
       
    //Instacio el array de las categorías
    self.categories=[[NSMutableArray alloc] init];
    
    //Obtengo los albumes
    NSMutableArray* albums = [json objectForKey:@"Albums"];
    
    for (int i=0; i<[albums count]; i++) {
                
        //Crea nuevo Album
        idAlbum=[[[albums objectAtIndex:i] objectForKey:@"id"] intValue];
        idCat=[[[[albums objectAtIndex:i] objectForKey:@"Category"] objectForKey:@"id"] intValue];
        idSubCat=[[[[albums objectAtIndex:i] objectForKey:@"SubCategory"] objectForKey:@"id"] intValue];
        nameAlbum=[[albums objectAtIndex:i] objectForKey:@"Title"];
        nameCat=[[[albums objectAtIndex:i] objectForKey:@"Category"] objectForKey:@"Name"];
        nameSubCat=[[[albums objectAtIndex:i] objectForKey:@"SubCategory"] objectForKey:@"Name"];
        key=[[albums objectAtIndex:i] objectForKey:@"Key"];
        
        album=[[Album alloc] init:idAlbum idCatParam:idCat idSubCatParam:idSubCat nameParam:nameAlbum keyParam:key];
        
        //Crear objeto Categoria
        category=[[CategoryPhotos alloc] init:idCat nameParam:nameCat];
        
        if(nameSubCat==nil)
            nameSubCat=nameAlbum;
        
        //Crear objeto Subcategoria
        subCategory=[[SubCategory alloc] init:idSubCat idCatParam:idCat nameParam:nameSubCat];
        
        //Comprobar si la categoría existe
        //Si la categoria no existe
        if(![self.categories containsObject:category]){
            [subCategory.albums addObject:album];
            [category.subCats addObject:subCategory];
            [self.categories addObject:category];
        }
        //Si existe compruebo que tiene subcategoria
        else if (![[[self.categories objectAtIndex:[self.categories indexOfObject:category]] subCats]containsObject:subCategory]){
            
            categoryAux=[self.categories objectAtIndex:[self.categories indexOfObject:category]];
            [subCategory.albums addObject:album];
            [categoryAux.subCats addObject:subCategory];
        }
        //Existen las dos
        else{
            categoryAux=[self.categories objectAtIndex:[self.categories indexOfObject:category]];
            subCategoryAux=[categoryAux.subCats objectAtIndex:[categoryAux.subCats indexOfObject:subCategory]];
            [subCategoryAux.albums addObject:album];
        }
                
        //NSLog(@"Iteracion: %d", i);
             
    }
    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    //Shows status bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    //No quiero la Nav Bar en esta vista
    self.navigationController.navigationBarHidden = YES;
    
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
        
        self.titulo.frame=CGRectMake(20, 20, 280.0f, 72.0f);
        
        [self.titulo setFont:[UIFont fontWithName:@"GillSans-Bold" size:30]];
               
    } else {
       //Landscape
        self.portrait=NO;
        self.radius=radiusLandscape;
        
        //Offset
        CGSize offset = CGSizeMake(0.0f, 28.0f);
        self.carousel.contentOffset = offset;
        
        self.titulo.frame=CGRectMake(20, -10, 440.0f, 72.0f);
        
        [self.titulo setFont:[UIFont fontWithName:@"GillSans-Bold" size:25]];
    }
}

- (void)viewDidUnload
{
    
    
    [self setTitulo:nil];
    self.carousel = nil;
    self.categories=nil;
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
