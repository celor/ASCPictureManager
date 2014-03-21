//
//  ASCPictureManager.h
//  Portfolio
//
//  Created by Aurélien Scelles on 15/03/2014.
//  Copyright (c) 2014 Aurélien Scelles. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^ASCImageSuccessBlock)(UIImage *image);
@interface ASCPictureManager : NSObject

@property (nonatomic,strong) NSString *entityName;
@property (nonatomic,strong) NSString *urlKeyValue;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedManager;

@end

@interface NSManagedObject (ASCPictureManager)
- (void)observeDownloadWithBlock:(ASCImageSuccessBlock)successBlock;

@end
