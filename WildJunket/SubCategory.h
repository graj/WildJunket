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
    
}

@property (copy) NSString *name;
@property (copy) NSMutableArray *albums;
@property int *idCat;
@property int *idSubCat;

@end
