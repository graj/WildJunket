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
    NSURL* _thumb;
    NSURL* _showPhoto;
    
}

@property (nonatomic) NSString *key;
@property (nonatomic) NSURL *thumb;
@property (nonatomic) NSURL *showPhoto;
@property int idPhoto;
@property int idAlbum;

- (id)init:(int)idPhoto idAlbum:(int)idAlbum key:(NSString*)key thumb:(NSURL*)thumb showPhoto:(NSURL*)showPhoto;

@end
