//
//  GDataXMLElement-Extras.h
//  RSSFun
//
//  Created by David Garcia on 04/07/2012.
//  Copyright 2012 David Garcia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@interface GDataXMLElement (Extras)

- (GDataXMLElement *)elementForChild:(NSString *)childName;
- (NSString *)valueForChild:(NSString *)childName;

@end
