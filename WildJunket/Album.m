//
//  Album.m
//  WildJunket
//
//  Created by david on 04/08/12.
//
//

#import "Album.h"

@implementation Album
@synthesize idAlbum=_idAlbum;
@synthesize idCat=_idCat;
@synthesize idSubCat=_idSubCat;
@synthesize name=_name;
@synthesize photos=_photos;
@synthesize key=_key;

- (id)init:(int)idAlbumParam idCatParam:(int)idCatParam idSubCatParam:(int)idSubCatParam nameParam:(NSString*)nameParam keyParam:(NSString*)keyParam
{
    if ((self = [super init])) {
        self.idAlbum = idAlbumParam;
        self.idCat = idCatParam;
        self.idSubCat = idSubCatParam;
        self.name = [nameParam copy];
        self.key= [keyParam copy];
        self.photos=[[NSMutableArray alloc] init];
        
    }
    return self;
}


@end
