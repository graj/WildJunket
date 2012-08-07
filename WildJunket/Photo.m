//
//  Photo.m
//  WildJunket
//
//  Created by david on 04/08/12.
//
//

#import "Photo.h"

@implementation Photo

@synthesize key=_key;
@synthesize idAlbum=_idAlbum;
@synthesize idPhoto=_idPhoto;
@synthesize thumb=_thumb;
@synthesize showPhoto=_showPhoto;

- (id)init:(int)idPhoto idAlbum:(int)idAlbum key:(NSString*)key thumb:(NSURL*)thumb showPhoto:(NSURL*)showPhoto
{
    if ((self = [super init])) {
        self.idAlbum = idAlbum;
        self.idPhoto = idPhoto;
        self.key= [key copy];
        self.thumb=[thumb copy];
        self.showPhoto=[showPhoto copy];
        
    }
    return self;
}

@end
