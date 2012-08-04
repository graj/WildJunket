//
//  Album.h
//  WildJunket
//
//  Created by david on 04/08/12.
//
//

#import <Foundation/Foundation.h>

@interface Album : NSObject{
    int _idCat;
    int _idSubCat;
    int _idAlbum;
    NSString* _key;
    NSString* _name;
    NSMutableArray* _photos;
    
}

@property (copy) NSString *key;
@property (copy) NSString *name;
@property (copy) NSMutableArray *photos;
@property int *idCat;
@property int *idSubCat;
@property int *idAlbum;

@end
