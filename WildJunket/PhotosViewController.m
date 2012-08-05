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
#import "Album.h"
#import "CategoryPhotos.h"
#import "SubCategory.h"
#include <stdlib.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define smugmugAlbums [NSURL URLWithString:@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.albums.get&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&NickName=wildjunket&pretty=true"]

@interface PhotosViewController ()
@property (nonatomic) NSMutableArray *items;
@property (nonatomic) NSMutableArray *categories;
@end

@implementation PhotosViewController
@synthesize titulo;
@synthesize carousel;


#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    
    
    //Llamada API de smugmug y tomar urls de las fotos de las categorías
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    //Obtiene los datos de categorías, subcategorías y álbumes
    [self getDatosCategorias];
    
    //Meter en items las urls con las imagenes de las categorias
    [self getImagenesCategorias];
    
    
#ifdef CONFIGURATION_Beta
    [TestFlight passCheckpoint:@"leidos datos smugmug"];
#endif
    
    [SVProgressHUD dismiss];
    
 
    //return the total number of items in the carousel
    return [self.items count];
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
    [(FXImageView *)view setImageWithContentsOfURL:[self.items objectAtIndex:index]];
    
    return view;
}

//Evento al mover el carousel
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    
}

#pragma mark -
#pragma mark view methods

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    //tipo Wheel
    
    //No quiero la Nav Bar en esta vista
    self.navigationController.navigationBarHidden = YES;

    self.carousel.type = iCarouselTypeWheel;

}

-(void) getImagenesCategorias{
    
    //Instancio array de URL's
    self.items=[[NSMutableArray alloc] init];
    
    int randomAlbum;
    int randomSubCat;
    SubCategory *subCatAux;
    Album *albumAux;
    NSString *urlStr;
    NSURL *url;
    
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
    
    NSString *urlImagen=[[json objectForKey:@"Image"]objectForKey:@"ThumbURL"];
    
    //Añado la url al array de URL's de categorías
    [self.items addObject:urlImagen];    

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
    
	[super viewWillAppear:animated];
   
}

- (void)viewDidUnload
{
    
    
    [self setTitulo:nil];
    self.carousel = nil;
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
