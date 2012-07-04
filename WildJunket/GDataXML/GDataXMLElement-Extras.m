//
//  GDataXMLElement-Extras.h
//  RSSFun
//
//  Created by David Garcia on 04/07/2012.
//  Copyright 2012 David Garcia. All rights reserved.
//

#import "GDataXMLElement-Extras.h"

@implementation GDataXMLElement(Extras)

- (GDataXMLElement *)elementForChild:(NSString *)childName {
    NSArray *children = [self elementsForName:childName];            
    if (children.count > 0) {
        GDataXMLElement *childElement = (GDataXMLElement *) [children objectAtIndex:0];
        return childElement;
    } else return nil;
}

- (NSString *)valueForChild:(NSString *)childName {    
    return [[self elementForChild:childName] stringValue];    
}

@end