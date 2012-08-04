//
//  Photo.h
//  WildJunket
//
//  Created by david on 04/08/12.
//
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject{
    int _idPhoto;
    int _idAlbum;
    NSString* _key;
    
}

@property (copy) NSString *key;
@property int *idPhoto;
@property int *idAlbum;


@end
