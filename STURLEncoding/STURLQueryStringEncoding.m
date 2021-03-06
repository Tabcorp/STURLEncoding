//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2012-2016 Scott Talbot.
//

#import <STURLEncoding/STURLQueryStringEncoding.h>
#import <STURLEncoding/STURLEncoding.h>


@implementation STURLQueryStringEncoding

#pragma mark - Query String Building

+ (NSString *)queryStringFromComponents:(STURLQueryStringComponents *)components {
	return [self queryStringFromComponents:components options:0 keyComparator:nil];
}
+ (NSString *)queryStringFromComponents:(STURLQueryStringComponents *)components keyComparator:(STURLQueryStringEncodingKeyComparator)keyComparator {
	return [self queryStringFromComponents:components options:0 keyComparator:keyComparator];
}
+ (NSString *)queryStringFromComponents:(STURLQueryStringComponents *)components options:(STURLQueryStringEncodingOptions)options {
	return [self queryStringFromComponents:components options:options keyComparator:nil];
}
+ (NSString *)queryStringFromComponents:(STURLQueryStringComponents *)components options:(STURLQueryStringEncodingOptions)options keyComparator:(STURLQueryStringEncodingKeyComparator)keyComparator {
	NSMutableString *queryString = NSMutableString.string;

	if (!keyComparator) {
		keyComparator = [^NSComparisonResult(NSString *a, NSString *b) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wassign-enum"
			return [a compare:b options:NSCaseInsensitiveSearch|NSNumericSearch|NSDiacriticInsensitiveSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch];
#pragma clang diagnostic pop
		} copy];
	}
	NSArray<NSString *> *keys = [components.allKeys sortedArrayUsingComparator:keyComparator];
	for (NSString *key in keys) {
		NSArray<NSString *> *strings = [components stringsForKey:key];
		if (strings.count == 0) {
			continue;
		}
		if (strings.count == 1) {
			if (queryString.length) {
				[queryString appendString:@"&"];
			}
			NSString * const string = strings.lastObject;
			[queryString appendFormat:@"%@=%@", [STURLEncoding stringByURLEncodingString:key], [STURLEncoding stringByURLEncodingString:string]];
		} else {
			NSString *serializedKey = [STURLEncoding stringByURLEncodingString:key];
			if ((options & STURLQueryStringEncodingOptionsBareDuplicateKeys) == 0) {
				serializedKey = [serializedKey stringByAppendingString:@"[]"];
			}
			for (NSString *string in strings) {
				if (queryString.length) {
					[queryString appendString:@"&"];
				}
				[queryString appendFormat:@"%@=%@", serializedKey, [STURLEncoding stringByURLEncodingString:string]];
			}
		}
	}
	return queryString;
}


#pragma mark - Query String Decoding

+ (STURLQueryStringComponents *)componentsFromQueryString:(NSString *)string {
	return [self componentsFromQueryString:string error:NULL];
}

+ (STURLQueryStringComponents *)componentsFromQueryString:(NSString *)string error:(NSError *__autoreleasing *)error {
	NSCharacterSet *separatorsCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
	NSCharacterSet *equalsCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"="];
	NSCharacterSet *separatorsOrEqualsCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;="];

	NSScanner *scanner = [NSScanner scannerWithString:string];

	STMutableURLQueryStringComponents *components = [[STMutableURLQueryStringComponents alloc] init];

	while (!scanner.atEnd) {
		NSString *key = nil, *value = @"";
		if (![scanner scanUpToCharactersFromSet:separatorsOrEqualsCharacterSet intoString:&key]) {
			if (error) {
				*error = [NSError errorWithDomain:kSTURLEncodingErrorDomain code:STURLEncodingErrorCodeUnknown userInfo:nil];
			}
			return nil;
		}
		if ([scanner scanCharactersFromSet:equalsCharacterSet intoString:NULL]) {
			[scanner scanUpToCharactersFromSet:separatorsCharacterSet intoString:&value];
		}
		if (!scanner.atEnd) {
			[scanner scanCharactersFromSet:separatorsCharacterSet intoString:NULL];
		}

		NSString *decodedKey = [STURLEncoding stringByURLDecodingString:key];
		if (key.length && !decodedKey.length) {
			if (error) {
				*error = [NSError errorWithDomain:kSTURLEncodingErrorDomain code:STURLEncodingErrorCodeUnknown userInfo:nil];
			}
			return nil;
		}

		NSString *decodedValue = [STURLEncoding stringByURLDecodingString:value];
		if (value.length && !decodedValue.length) {
			if (error) {
				*error = [NSError errorWithDomain:kSTURLEncodingErrorDomain code:STURLEncodingErrorCodeUnknown userInfo:nil];
			}
			return nil;
		}
		if ([decodedKey hasSuffix:@"[]"]) {
			decodedKey = [decodedKey substringToIndex:decodedKey.length - 2];
		}

		[components addString:decodedValue forKey:decodedKey];
	}

	return components.copy;
}

@end
