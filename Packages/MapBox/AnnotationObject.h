//
//  NewAnnotationObject.h
//  MapBoxTesting
//
//  Created by Dhvl's iMac on 23/08/17.
//  Copyright © 2017 Dhvl's iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnnotationObject : NSObject

@property (assign) double longitude;
@property (assign) double latitude;
@property (nonatomic, strong) NSString *name;
@property (assign) int identifier;
@property (nonatomic, strong) NSString *fontColor;
@property (nonatomic, strong) NSString *bgColor;


- (id) initWithName:(NSString *)name latitude:(double)latitude longitude:(double)longitude identifier:(int)identifier fontColor:(NSString *)fontColor andBackgroundColor:(NSString *)bgColor;


@end
