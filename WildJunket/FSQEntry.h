//
//  FSQEntry.h
//  WildJunket
//
//  Created by david on 12/08/12.
//
//

#import <Foundation/Foundation.h>

@interface FSQEntry : NSObject{
    NSString *_country;
    NSString *_city;
    NSString *_description;
    NSURL *_photo;
    double _latitue;
    double _longitude;
    NSString *_countryCode;
}

@property (nonatomic) NSString *country;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *description;
@property (nonatomic) NSString *countryCode;
@property (nonatomic) NSURL *photo;
@property double latitude;
@property double longitude;

- (id)init:(NSString*)country city:(NSString*)city description:(NSString*)description photo:(NSURL*)photo latitude:(double)latitude longitude:(double)longitude countryCode:(NSString*)countryCode;

@end
