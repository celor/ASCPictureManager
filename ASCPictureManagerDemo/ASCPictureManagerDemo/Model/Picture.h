//
//  Picture.h
//  ASCPictureManagerDemo
//
//  Created by Aurélien Scelles on 21/03/2014.
//  Copyright (c) 2014 Aurélien Scelles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Picture : NSManagedObject

@property (nonatomic, retain) NSString * pictureUrl;
@property (nonatomic, retain) NSString * title;

@end
