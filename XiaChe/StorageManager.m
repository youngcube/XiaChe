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

- (void)saveContext
{
    if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:nil]){
        abort();
    }
}

- (instancetype)init
{
    if (self = [super init]){
        [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification* note) {
                                                          NSManagedObjectContext *moc = _managedObjectContext;
                                                          if (note.object != moc) {
                                                              [moc performBlock:^(){
                                                                  [moc mergeChangesFromContextDidSaveNotification:note];
                                                              }];
                                                          }
                                                      }];
    }
    return self;
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

- (NSManagedObjectContext *)newPrivate
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = _persistentStoreCoordinator;
    return context;
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
    NSFetchRequest *requestList = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityList = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:self.managedObjectContext];
    [requestList setEntity:entityList];
    
    NSError *error;
    NSArray *itemList = [_managedObjectContext executeFetchRequest:requestList error:&error];
    NSFetchRequest *requestDetail = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDetail = [NSEntityDescription entityForName:@"FunDetail" inManagedObjectContext:self.managedObjectContext];
    [requestDetail setEntity:entityDetail];
    
    NSArray *itemDetail = [_managedObjectContext executeFetchRequest:requestDetail error:&error];
    
    for (NSManagedObject *managedObject in itemList) {
        [_managedObjectContext deleteObject:managedObject];
    }
    
    for (NSManagedObject *managedObject in itemDetail) {
        [_managedObjectContext deleteObject:managedObject];
    }

    if (![_managedObjectContext save:&error]) {
        
    }
}

@end
