//
//  WBManagedObjectContext.m
//  weibo
//
//  Created by feng qijun on 8/27/12.
//  Copyright (c) 2012 feng qijun. All rights reserved.
//

#import "WBManagedObjectContext.h"

@interface WBManagedObjectContext()

@property(strong, readonly) NSManagedObjectModel *managedObjectModel;
@property(strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation WBManagedObjectContext

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;

+(WBManagedObjectContext *)sharedInstance
{
    static WBManagedObjectContext *sharedContext = nil;
    @synchronized(self){
        if (!sharedContext) {
            
            sharedContext = [[WBManagedObjectContext alloc] init];
        }
    }
    
    return sharedContext;
}



/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store
 coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in
 application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
    //                                               stringByAppendingPathComponent: @"Core_Data.sqlite"]];
    NSFileManager *sharedFM = [NSFileManager defaultManager];
    NSArray *availableURLs = [sharedFM URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    NSURL *appSupportDir = nil;
    NSURL *appDirectory = nil;
    
    if (availableURLs.count > 0) {
        appSupportDir = [availableURLs objectAtIndex:0];
    }
    
    if (appSupportDir) {
        NSString *appBundleId = [[NSBundle mainBundle] bundleIdentifier];
        appDirectory = [appSupportDir URLByAppendingPathComponent:appBundleId];
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [appDirectory.absoluteString
                                               stringByAppendingPathComponent: @"wbmessages.sqlite"]];
    
    if (![sharedFM fileExistsAtPath:storeUrl.absoluteString]) {
        NSError *error;
        [sharedFM createDirectoryAtPath:storeUrl.absoluteString
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:&error];
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil URL:storeUrl options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should
         not use this function in a shipping application, although it may be useful during
         development. If it is not possible to recover from the error, display an alert panel that
         instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object
         model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


@end
