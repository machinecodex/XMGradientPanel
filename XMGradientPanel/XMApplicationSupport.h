//
//  XMApplicationSupport.h
//  DateLine 2
//
//  Created by Alex Clarke on 26/04/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XMApplicationSupport : NSObject {

}

+ (NSString *) existingPathAtPath:(NSString *)path;
+ (NSString *) applicationSupportFolderPath;
+ (NSString *) applicationSupportSubfolderPath:(NSString *)folderName;

+ (NSString *) gradientsFilePath;

@end
