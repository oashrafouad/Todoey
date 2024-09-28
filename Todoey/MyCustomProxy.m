//
//  MyCustomProxy.m
//  AnimatedAppIcons
//
//  Created by Bryce Pauken on 5/25/24.
//

#import "MyCustomProxy.h"
#import <objc/runtime.h>

@implementation MyCustomProxy

+ (nonnull id)customProxyForCurrentProcess {
    Class LSApplicationProxyClass = NSClassFromString(@"LSApplicationProxy");
    SEL selector = NSSelectorFromString(@"bundleProxyForCurrentProcess");
    if ([LSApplicationProxyClass respondsToSelector:selector]) {
        return ((id (*)(id, SEL))[LSApplicationProxyClass methodForSelector:selector])(LSApplicationProxyClass, selector);
    }
    return nil;
}

@end