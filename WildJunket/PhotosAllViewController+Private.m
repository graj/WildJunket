//
//  PhotosAllViewController+Private.m
//  WildJunket
//
//  Created by david on 07/08/12.
//
//

#import "PhotosAllViewController+Private.h"
#import "Album.h"
#import "SVProgressHUD.h"
#import "Photo.h"
#import "SDWebImage/SDWebImageManager.h"


@implementation PhotosAllViewController (Private)


-(void)buildBarButtons
{
    UIBarButtonItem * reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Lay it!"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(animateReload)];
    
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: reloadButton, nil];
    
}

//Obtiene las imágenes
-(NSArray*)_imagesFromURL:(NSURL*)url item:(int)item
{
    images = [NSArray array];
   
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
           
        [manager downloadWithURL:url
                        delegate:self
                         options:0
                         success:^(UIImage *image)
         {
             
             //Mete aqui el resto de codigo
             images = [images arrayByAddingObject:image];
             
             UIImageView *imageView = [_items objectAtIndex:item];
             imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
             
             [self performSelector:@selector(animateUpdate:)
                        withObject:[NSArray arrayWithObjects:imageView, image, nil]
                        afterDelay:0.2 + (arc4random()%3) + (arc4random() %10 * 0.1)];
                    
             
         }
                         failure:nil];
   
    return images;
}


//Primer método llamado
- (void)_demoAsyncDataLoading
{
    _items = [NSArray array];
    _photosURL=[[NSMutableArray alloc] init];
    
    //Get urls de las fotos, smugmug
    NSString *urlStr;
    NSURL *url;
    
    
    //Obtengo las fotos de ese álbum
    urlStr=nil;
    urlStr=[[[[@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.images.get&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&AlbumID=" stringByAppendingString:[[NSNumber numberWithInt:_album.idAlbum]stringValue]] stringByAppendingString:@"&AlbumKey="]stringByAppendingString:_album.key]stringByAppendingString:@"&pretty=true"];
        
    
    url=[NSURL URLWithString:urlStr];
        
    NSData* data = [NSData dataWithContentsOfURL: url];
   
    int numPhotos=[self getnumeroPhotos:data];
    
    //load the placeholder image
    for (int i=0; i <numPhotos; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholderphotos.png"]];
        imageView.frame = CGRectMake(0, 0, 44, 44);
        imageView.clipsToBounds = YES;
        _items = [_items arrayByAddingObject:imageView];
    }
    
    [SVProgressHUD dismiss];
    
    [self reloadData];
    
    //Toma el url de cada foto y llama al método para bajarlas asíncronamente
    [self getPhotosResponse:data];
    
}

-(int)getnumeroPhotos:(NSData*)response{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:response
                          options:kNilOptions
                          error:&error];
    
    //Obtengo las imagenes
    NSMutableArray* imagenes = [[json objectForKey:@"Album"]objectForKey:@"Images"];
    return imagenes.count;
    
}


-(void) getPhotosResponse:(NSData *)responseData{
    //parse out the json data
    NSError* error;
    long long int imageID;
    NSString *imageKey;
    Photo* photoObj;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
        
    //Obtengo las imagenes
    NSMutableArray* imagenes = [[json objectForKey:@"Album"]objectForKey:@"Images"];
    for(int i=0; i<imagenes.count;i++){
        imageID=[[[imagenes objectAtIndex:i]objectForKey:@"id"] longLongValue];
        imageKey=[[imagenes objectAtIndex:i]objectForKey:@"Key"];
        
        //Obtengo la url de la imagen random
        NSString *urlStr=[[[[@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.images.getURLs&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&ImageID=" stringByAppendingString:[[NSNumber numberWithLongLong:imageID]stringValue]] stringByAppendingString:@"&ImageKey="]stringByAppendingString:imageKey]stringByAppendingString:@"&pretty=true"];
        
              
        NSURL *url=[NSURL URLWithString:urlStr];
        NSData* dataImagen = [NSData dataWithContentsOfURL: url];
        
        json = [NSJSONSerialization
                JSONObjectWithData:dataImagen
                options:kNilOptions
                error:&error];
        
        NSURL *urlImagen = [NSURL URLWithString:[[json objectForKey:@"Image"]objectForKey:@"ThumbURL"]];
        
        NSURL *urlShow = [NSURL URLWithString:[[json objectForKey:@"Image"]objectForKey:@"LargeURL"]];
        //Añado la url al array de URL's de categorías
        photoObj=[[Photo alloc] init:imageID idAlbum:self.album.idAlbum key:imageKey thumb:urlImagen showPhoto:urlShow];
        [_photosURL addObject:photoObj];
                
        //Llamada al método que baja la imagen asincronamente
        [self _imagesFromURL:urlImagen item:i];

    }
     
}

- (void) animateUpdate:(NSArray*)objects
{
    UIImageView *imageView = [objects objectAtIndex:0];
    UIImage* image = [objects objectAtIndex:1];
    [UIView animateWithDuration:0.5
                     animations:^{
                         imageView.alpha = 0.f;
                     } completion:^(BOOL finished) {
                         imageView.image = image;
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              imageView.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              NSArray *visibleRowInfos =  [self visibleRowInfos];
                                              for (BDRowInfo *rowInfo in visibleRowInfos) {
                                                  [self updateLayoutWithRow:rowInfo animiated:YES];
                                              }
                                          }];
                     }];
}



@end
