//
//  CustomAnnotationView.m
//  MapTextingObjectiveC
//
//  Created by Dhvl's iMac on 23/08/17.
//  Copyright © 2017 Dhvl's iMac. All rights reserved.
//

#import "CustomAnnotationView.h"

@implementation CustomAnnotationView {
    UILabel * nameLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        nameLabel = [[UILabel alloc] init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        nameLabel = [[UILabel alloc] init];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setParametersWithName:(NSString *)name fontColor:(NSString *)fontColor andColor:(NSString *)colorCode {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    NSAttributedString *userNameString = [[NSAttributedString alloc] initWithString:name attributes:attrsDictionary];
    
    NSMutableAttributedString * finalString = [[NSMutableAttributedString alloc] initWithAttributedString:userNameString];
    nameLabel.font = [UIFont fontWithName:@"neon-icon-font" size:20];
    NSString *string2 = name;
    NSScanner *scanner = [NSScanner scannerWithString:string2];
    unsigned int code;
    [scanner scanHexInt:&code];
    NSString *string3 = [NSString stringWithFormat:@"%C", (unsigned short)code];
    NSLog(@"string3: %@", string3);
    nameLabel.text = string3;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    if (fontColor != NULL) {
        nameLabel.textColor = [self colorFromHexString:[NSString stringWithFormat:@"%@", fontColor]];
    }
    else {
        nameLabel.textColor = [UIColor whiteColor];
    }
    nameLabel.userInteractionEnabled = NO;
    nameLabel.frame = CGRectMake(0, 0, 40, 40);
    [self addSubview:nameLabel];
    self.frame = CGRectMake(0, 0, nameLabel.frame.size.width, nameLabel.frame.size.height);
    if (colorCode != NULL) {
        nameLabel.backgroundColor = [self colorFromHexString:[NSString stringWithFormat:@"%@", colorCode]];
    }
    else {
        nameLabel.backgroundColor = [self colorFromHexString:@"#FF6266"];
    }
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.cornerRadius = 20;
    self.layer.borderWidth = 3;
    self.layer.masksToBounds = YES;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


@end
