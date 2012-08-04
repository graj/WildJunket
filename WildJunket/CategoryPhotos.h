//
//  CategoryPhotos.h
//  WildJunket
//
//  Created by david on 04/08/12.
//
//

#import <Foundation/Foundation.h>

@interface CategoryPhotos : NSObject{
    int _idCat;
    NSString* _name;
    NSMutableArray* _subCats;
    
}

@property (copy) NSString *name;
@property (copy) NSMutableArray *subCats;
@property int *idCat;


@end
