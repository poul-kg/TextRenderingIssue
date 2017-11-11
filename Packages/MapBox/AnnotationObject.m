//
//  NewAnnotationObject.m
//  MapBoxTesting
//
//  Created by Dhvl's iMac on 23/08/17.
//  Copyright © 2017 Dhvl's iMac. All rights reserved.
//

#import "AnnotationObject.h"

@implementation AnnotationObject


- (id) initWithName:(NSString *)name latitude:(double)latitude longitude:(double)longitude identifier:(int)identifier fontColor:(NSString *)fontColor andBackgroundColor:(NSString *)bgColor {
    self = [super init];
    if (self) {
        self.name = name;
        self.latitude = latitude;
        self.longitude = longitude;
        self.identifier = identifier;
        self.fontColor = fontColor;
        self.bgColor = bgColor;
    }
    return self;
}

@end
