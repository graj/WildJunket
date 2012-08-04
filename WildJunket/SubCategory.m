//
//  SubCategorie.m
//  WildJunket
//
//  Created by david on 04/08/12.
//
//

#import "SubCategory.h"

@implementation SubCategory
@synthesize idCat=_idCat;
@synthesize idSubCat=_idSubCat;
@synthesize name=_name;
@synthesize albums=_albums;


- (id)init:(int)idSubCatParam idCatParam:(int)idCatParam nameParam:(NSString*)nameParam
{
    if ((self = [super init])) {
        self.idCat = idCatParam;
        self.name = [nameParam copy];
        self.idSubCat=idSubCatParam;
        self.albums=[[NSMutableArray alloc] init];
    }
    return self;
}


- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToSubCategory:other];
}

- (BOOL)isEqualToSubCategory:(SubCategory *)aSubCat {
    if (self == aSubCat)
        return YES;
    if (self.idSubCat!=aSubCat.idSubCat)
        return NO;
    
    return YES;
}


@end
