//
//  SubCategorie.h
//  WildJunket
//
//  Created by david on 04/08/12.
//
//

#import <Foundation/Foundation.h>

@interface SubCategory : NSObject{
    int _idCat;
    int _idSubCat;
    NSString* _name;
    NSMutableArray* _albums;
    NSURL* _thumbnailURL;
    
}

@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableArray *albums;
@property (nonatomic) NSURL *thumbnailURL;
@property int idCat;
@property int idSubCat;

- (id)init:(int)idSubCatParam idCatParam:(int)idCatParam nameParam:(NSString*)nameParam;
-(void)setThumbnailPhotoURL:(NSURL *)thumbnailURL;

@end
