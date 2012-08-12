//
//  FSQEntry.m
//  WildJunket
//
//  Created by david on 12/08/12.
//
//

#import "FSQEntry.h"

@implementation FSQEntry
@synthesize country=_country;
@synthesize photo=_photo;
@synthesize description=_description;
@synthesize city=_city;
@synthesize latitude=_latitue;
@synthesize longitude=_longitude;
@synthesize countryCode=_countryCode;

- (id)init:(NSString*)country city:(NSString*)city description:(NSString*)description photo:(NSURL*)photo latitude:(double)latitude longitude:(double)longitude countryCode:(NSString*)countryCode
{
    if ((self = [super init])) {
        self.latitude = latitude;
        self.longitude = longitude;
        self.country= [country copy];
        self.photo=[photo copy];
        self.description=[description copy];
        self.city= [city copy];
        self.countryCode=[countryCode copy];
        
    }
    return self;
}


@end
