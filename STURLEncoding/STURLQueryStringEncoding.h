//
//  STURLQueryStringEncoding.h
//  STURLEncoding
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2013 Scott Talbot. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface STURLQueryStringComponents : NSObject<NSCopying,NSMutableCopying>
+ (instancetype)components;
- (BOOL)containsKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSArray *)stringsForKey:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString *)key;
@end

@interface STMutableURLQueryStringComponents : STURLQueryStringComponents
- (void)setString:(NSString *)string forKey:(NSString *)key;
- (void)addString:(NSString *)string forKey:(NSString *)key;
- (void)setStrings:(NSArray *)strings forKey:(NSString *)key;
- (void)removeStringsForKey:(NSString *)key;
@end


@interface STURLQueryStringEncoding : NSObject { }

#pragma mark - Query String Building

+ (NSString *)queryStringFromComponents:(STURLQueryStringComponents *)components;


#pragma mark - Query String Decoding

+ (STURLQueryStringComponents *)componentsFromQueryString:(NSString *)string;
+ (STURLQueryStringComponents *)componentsFromQueryString:(NSString *)string error:(NSError * __autoreleasing *)error;

@end
