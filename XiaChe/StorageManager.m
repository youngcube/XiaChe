//
//  StorageManager.m
//  XiaChe
//
//  Created by cube on 3/16/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "StorageManager.h"

@interface StorageManager()
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSPersistentStore *persistentStore;
@end

@implementation StorageManager

+ (instancetype)sharedInstance
{
    static StorageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator){
        NSURL *fileURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"storyModel.sqlite"];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:fileURL
                                                        options:nil
                                                          error:nil];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel){
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StoryModel" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext){
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _managedObjectContext;
}

- (NSPersistentStore *)persistentStore
{
    if (!_persistentStore){
        NSURL *fileURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"storyModel.sqlite"];
        _persistentStore = [[NSPersistentStore alloc] initWithPersistentStoreCoordinator:self.persistentStoreCoordinator configurationName:nil URL:fileURL options:nil];
    }
    return _persistentStore;
}

- (void)removeAllData
{
//    [self.persistentStoreCoordinator removePersistentStore:self.persistentStore error:nil];
//    [[NSFileManager defaultManager] removeItemAtPath:self.persistentStore.URL.path error:nil];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [_managedObjectContext deleteObject:managedObject];
        
    }
    if (![_managedObjectContext save:&error]) {
        
    }
}

@end
