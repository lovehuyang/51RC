//
//  UIImage+Size.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/28.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "UIImage+Size.h"

@implementation UIImage (Scale)

- (UIImage *)transformtoSize:(CGSize)newSize {
    return [self scaleToSize:self size:newSize];
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
