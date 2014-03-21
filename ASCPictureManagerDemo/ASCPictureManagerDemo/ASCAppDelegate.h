//
//  ASCAppDelegate.h
//  ASCPictureManagerDemo
//
//  Created by Aurélien Scelles on 21/03/2014.
//  Copyright (c) 2014 Aurélien Scelles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
