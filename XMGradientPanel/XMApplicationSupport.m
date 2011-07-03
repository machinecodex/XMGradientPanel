//
//  XMApplicationSupport.m
//  DateLine 2
//
//  Created by Alex Clarke on 26/04/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import "XMApplicationSupport.h"


@implementation XMApplicationSupport

#pragma mark -
#pragma mark Application Support

+ (NSString *) existingPathAtPath:(NSString *)path {
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	
    NSError * err = nil;
	if (![fileManager fileExistsAtPath:path isDirectory:NULL])
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
    
    if (err) NSLog(@"Error: %@", err);
	    
	return path;
}

+ (NSString *) applicationSupportFolderPath {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString * basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
	NSString * appName = [[[NSBundle mainBundle] executablePath] lastPathComponent];
    
	return [self existingPathAtPath:[basePath stringByAppendingPathComponent:appName]];
}

+ (NSString *) applicationSupportSubfolderPath:(NSString *)folderName {
    
    NSString * appSupport = [self applicationSupportFolderPath];
    return [self existingPathAtPath:[appSupport stringByAppendingPathComponent:folderName]];
}

+ (NSString *) gradientsFolderName {
    
    return @"Gradients";
}

+ (NSString *) gradientsFileName {
    
    return @"gradients";
}

+ (NSString *) gradientsFolderPath {
    
    return [self applicationSupportSubfolderPath:[self gradientsFolderName]];
}

+ (NSString *) gradientsFilePath {
    
    return [[self gradientsFolderPath] stringByAppendingPathComponent:[self gradientsFileName]];
}

@end
