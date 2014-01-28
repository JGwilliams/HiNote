//
//  SSAppDelegate.m
//  HiNote
//
//  Created by Jonathan Gwilliams on 25/01/2014.
//  Copyright (c) 2014 Sane Studios. All rights reserved.
//

#import "SSAppDelegate.h"
#import "SSPreparingViewController.h"
#import "SSToDoListViewController.h"

NSString * const kICloudToken = @"kICloudToken";
NSString * const kICloudStorageActive = @"kICloudStorageActive";

NSString * const persistantStoreCreatedNotification = @"persistantStoreCreatedNotification";

@implementation SSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayTableView)
                                                 name:persistantStoreCreatedNotification object:nil];
    
    SSPreparingViewController * preparing = [[SSPreparingViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = preparing;
    [self.window makeKeyAndVisible];
    
    [self checkForICloudCompliance];
    
    return YES;
}



-(void) checkForICloudCompliance
{
    id iCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    if (iCloudToken) {
        NSData * tokenData = [NSKeyedArchiver archivedDataWithRootObject:iCloudToken];
        [[NSUserDefaults standardUserDefaults] setObject:tokenData forKey:kICloudToken];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kICloudToken];
    }
    
    if (iCloudToken && [[NSUserDefaults standardUserDefaults] objectForKey:kICloudStorageActive] == nil) {
        UIAlertView * invitation = [[UIAlertView alloc] initWithTitle:@"Storage Options"
                                                              message:@"Would you like your ToDo list made available to all your devices using iCloud?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Local Storage"
                                                    otherButtonTitles:@"Use iCloud", nil];
        [invitation show];
    } else {
        [self displayTableView];
    }
}



- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL useICloud = NO;
    if (buttonIndex == 1) useICloud = YES;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:useICloud]
                                              forKey:kICloudStorageActive];
    [self displayTableView];
}



- (void) displayTableView
{
    // Create the root view controller (no need for nib or bundle name; they default to the correct values)
    SSToDoListViewController * toDoList = [[SSToDoListViewController alloc] initWithNibName:nil bundle:nil];
    toDoList.context = self.managedObjectContext;
    [self.window setRootViewController:toDoList];
}



// TODO: general beautification

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}



- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}



#pragma mark - Core Data stack

- (void) mergeICloudUpdates:(NSNotification *)notification
{
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}



// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) return _managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator: coordinator];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeICloudUpdates:)
                                                    name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
        _managedObjectContext = context;
    }
    return _managedObjectContext;
}



// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) return _managedObjectModel;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HiNote" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}



// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if((_persistentStoreCoordinator != nil)) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString * iCloudEnabledAppID = @"HiNoteUbiquityID";
        NSString * dataFileName = @"database.sqlite";
        NSString * iCloudDataDirectoryName = @"data.nosync";
        NSString * iCloudLogsDirectoryName = @"logs";
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSURL * localStore = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dataFileName];
        NSURL * iCloud = [fileManager URLForUbiquityContainerIdentifier:nil];
        
        if (iCloud) {
            NSURL * iCloudLogsPath = [NSURL fileURLWithPath:[[iCloud path] stringByAppendingPathComponent:iCloudLogsDirectoryName]];
            if ([fileManager fileExistsAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]] == NO) {
                NSError *fileSystemError;
                [fileManager createDirectoryAtPath:[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]
                       withIntermediateDirectories:YES attributes:nil error:&fileSystemError];
                if(fileSystemError != nil) {
                    NSLog(@"Error creating database directory %@", fileSystemError);
                }
            }
            
            NSString *iCloudData = [[[iCloud path] stringByAppendingPathComponent:iCloudDataDirectoryName]
                                    stringByAppendingPathComponent:dataFileName];
            
            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
            [options setObject:iCloudEnabledAppID            forKey:NSPersistentStoreUbiquitousContentNameKey];
            [options setObject:iCloudLogsPath                forKey:NSPersistentStoreUbiquitousContentURLKey];
            
            [_persistentStoreCoordinator lock];
            [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                                                URL:[NSURL fileURLWithPath:iCloudData]
                                                            options:options error:nil];
            [_persistentStoreCoordinator unlock];
        }
        
        else {
            NSMutableDictionary *options = [NSMutableDictionary dictionary];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
            [options setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
            
            [_persistentStoreCoordinator lock];
            [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:localStore
                                                            options:options error:nil];
            [_persistentStoreCoordinator unlock];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:persistantStoreCreatedNotification object:self];
        });
    });
    
    return _persistentStoreCoordinator;
}

// TODO: data not persisted on first launch



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
