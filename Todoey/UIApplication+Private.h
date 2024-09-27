//
//  UIApplication+Private.h
//  Todoey
//
//  Created by Omar Ashraf on 26/09/2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

#ifndef UIApplication_Private_h
#define UIApplication_Private_h

@import UIKit;

@interface UIApplication (Private)

- (void)_setAlternateIconName:(NSString *)alternateIconName
            completionHandler:(void (^)(NSError *error))completionHandler;


@end

#endif /* UIApplication_Private_h */
