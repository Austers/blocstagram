//
//  DataSource.h
//  Blocstagram
//
//  Created by Richie Austerberry on 19/10/2014.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Media;

@interface DataSource : NSObject

+(instancetype) sharedInstance;
@property (nonatomic, strong, readonly) NSArray *mediaItems;

-(void) deleteMediaItems:(Media *)item;

@end
