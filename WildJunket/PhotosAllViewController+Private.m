//
//  PhotosAllViewController+Private.m
//  WildJunket
//
//  Created by david on 07/08/12.
//
//

#import "PhotosAllViewController+Private.h"
#import "Album.h"
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
-(NSArray*)_imagesFromBundle
{
    images = [NSArray array];
    
       
    NSLog(@"Start creating images");
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
    for (int i=0; i< _photosURL.count; i++) {
        
        [manager downloadWithURL:[_photosURL objectAtIndex:i]
                        delegate:self
                         options:0
                         success:^(UIImage *image)
         {
             
             //Mete aqui el resto de codigo
             images = [images arrayByAddingObject:image];
             
             
             
             
             
         }
                         failure:nil];

        /*UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [_photosURL objectAtIndex:i]]];
        if (image) {
            images = [images arrayByAddingObject:image];
        }*/
    }
    
    NSLog(@"Finish creating images");
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
    
    NSLog(@"Start getting photos ids");
    
    //Obtengo las fotos de ese álbum
    urlStr=[[[[@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.images.get&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&AlbumID=" stringByAppendingString:[[NSNumber numberWithInt:_album.idAlbum]stringValue]] stringByAppendingString:@"&AlbumKey="]stringByAppendingString:_album.key]stringByAppendingString:@"&pretty=true"];
        
    url=[NSURL URLWithString:urlStr];
        
    NSData* data = [NSData dataWithContentsOfURL: url];
    
    
    NSLog(@"Finish  photos ids");
    [self getPhotosResponse:data];
       
    //load the placeholder image
    for (int i=0; i <_photosURL.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.png"]];
        imageView.frame = CGRectMake(0, 0, 44, 44);
        imageView.clipsToBounds = YES;
        _items = [_items arrayByAddingObject:imageView];
    }
    [self reloadData];
    
    NSArray *imagesShow = [self _imagesFromBundle];
    for (int i = 0; i < imagesShow.count; i++) {
        UIImageView *imageView = [_items objectAtIndex:i];
        UIImage *image = [imagesShow objectAtIndex:i];
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        
        [self performSelector:@selector(animateUpdate:)
                   withObject:[NSArray arrayWithObjects:imageView, image, nil]
                   afterDelay:0.2 + (arc4random()%3) + (arc4random() %10 * 0.1)];
    }
}


-(void) getPhotosResponse:(NSData *)responseData{
    //parse out the json data
    NSError* error;
    int imageID;
    NSString *imageKey;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    NSLog(@"Start getting photos urls");
    
    //Obtengo las imagenes
    NSMutableArray* imagenes = [[json objectForKey:@"Album"]objectForKey:@"Images"];
    for(int i=0; i<imagenes.count;i++){
        imageID=[[[imagenes objectAtIndex:i]objectForKey:@"id"] intValue];
        imageKey=[[imagenes objectAtIndex:i]objectForKey:@"Key"];
        
        //Obtengo la url de la imagen random
        NSString *urlStr=[[[[@"http://api.smugmug.com/services/api/json/1.3.0/?method=smugmug.images.getURLs&APIKey=bLmbO3nV8an2YhQpMogzNKA0toTHbfGU&ImageID=" stringByAppendingString:[[NSNumber numberWithInt:imageID]stringValue]] stringByAppendingString:@"&ImageKey="]stringByAppendingString:imageKey]stringByAppendingString:@"&pretty=true"];
        
        NSURL *url=[NSURL URLWithString:urlStr];
        NSData* dataImagen = [NSData dataWithContentsOfURL: url];
        
        json = [NSJSONSerialization
                JSONObjectWithData:dataImagen
                options:kNilOptions
                error:&error];
        
        NSURL *urlImagen = [NSURL URLWithString:[[json objectForKey:@"Image"]objectForKey:@"ThumbURL"]];
        //Añado la url al array de URL's de categorías
        [_photosURL addObject:urlImagen];

    }
    
    
    NSLog(@"Finish getting photos urls");
  
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
