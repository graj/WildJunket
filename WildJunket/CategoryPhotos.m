//
//  CategoryPhotos.m
//  WildJunket
//
//  Created by david on 04/08/12.
//
//

#import "CategoryPhotos.h"

@implementation CategoryPhotos
@synthesize idCat=_idCat;
@synthesize name=_name;
@synthesize subCats=_subCats;
@synthesize thumbnailURL=_thumbnailURL;


- (id)init:(int)idCatParam nameParam:(NSString*)nameParam
{
    if ((self = [super init])) {
        self.idCat = idCatParam;
        self.name = [nameParam copy];
        self.subCats=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)setThumbnailPhotoURL:(NSURL *)thumbnailURL{
    self.thumbnailURL=thumbnailURL;
}



- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToCategory:other];
}

- (BOOL)isEqualToCategory:(CategoryPhotos *)aCat {
    if (self == aCat)
        return YES;
    if (self.idCat!=aCat.idCat)
        return NO;
    
    return YES;
}


@end
