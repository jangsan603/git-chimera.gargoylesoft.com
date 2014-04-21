//
//  NSManagedObjectContext+CoreDataImport.m
//  TeamKnect
//
//  Created by Scott Grosch on 1/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "NSManagedObjectContext+CoreDataImport.h"
#import "NSObject+importJSONDictionary.h"
#import "SQL.h"

@implementation NSManagedObjectContext (CoreDataImport)

- (BOOL)internalUpdateOrInsert:(const NSArray *const)elementsFromWeb entityName:(NSString *const)entityName moc:(NSManagedObjectContext *)managedObjectContext imported:(NSMutableDictionary *)importedObjects dateFormat:(NSString *const)dateFormat error:(NSError **)error {
    NSArray *data = [elementsFromWeb sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        const long a = [obj1[@"sql_ident"] longValue];
        const long b = [obj2[@"sql_ident"] longValue];

        if (a > b)
            return NSOrderedDescending;
        else if (a < b)
            return NSOrderedAscending;
        else
            return NSOrderedSame;
    }];

    __block BOOL saved = false;

    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        request.predicate = [NSPredicate predicateWithFormat:@"(sql_ident IN %@)", [data valueForKeyPath:@"sql_ident"]];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sql_ident" ascending:YES]];

        NSArray *existing = [managedObjectContext executeFetchRequest:request error:NULL];

        NSEnumerator *jsonEnumerator = [data objectEnumerator];
        NSEnumerator *matchingEnumerator = [existing objectEnumerator];

        NSDictionary *jsonObject;
        SQL *managedObject = [matchingEnumerator nextObject];

        while (jsonObject = [jsonEnumerator nextObject]) {
            BOOL isUpdate = YES;

            if ([managedObject.sql_ident longValue] != [jsonObject[@"sql_ident"] longValue]) {
                isUpdate = NO;
                managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedObjectContext];
            }

            [managedObject importJSONDictionary:jsonObject dateFormat:dateFormat];

            importedObjects[managedObject.sql_ident] = managedObject;

            if (isUpdate)
                managedObject = [matchingEnumerator nextObject];
        }

        // If we aren't storing the imported objects then we were doing an immediate save (i.e. non-async call)
        if (!importedObjects) {
            if ((saved = [managedObjectContext save:error])) {
                NSManagedObjectContext *parent = managedObjectContext.parentContext;

                [parent performBlockAndWait:^{
                    saved = [parent save:error];
                }];
            }
        }
    }];

    return saved;
}

- (void)updateOrInsertAsync:(const NSArray *const)elementsFromWeb entityName:(NSString *)entityName dateFormat:(NSString *const)dateFormat onError:(CoreDataImportError)onError onCompletion:(dispatch_block_t)onCompletion {
    if (elementsFromWeb.count == 0)
        return;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        importContext.parentContext = self;
        importContext.undoManager = nil;

        __block NSError *error;
        BOOL saved = [self internalUpdateOrInsert:elementsFromWeb entityName:entityName moc:importContext imported:nil dateFormat:dateFormat error:&error];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (saved) {
                if (onCompletion)
                    onCompletion();
            } else {
                if (onError)
                    onError(error);
            }
        });
    });
}

- (void)updateOrInsertAsync:(const NSArray *const)elementsFromWeb entityName:(NSString *)entityName onError:(CoreDataImportError)onError onCompletion:(dispatch_block_t)onCompletion {
    [self updateOrInsertAsync:elementsFromWeb entityName:entityName dateFormat:@"%Y-%m-%d" onError:onError onCompletion:onCompletion];
}

- (NSDictionary *)updateOrInsert:(const NSArray *const)elementsFromWeb entityName:(NSString *)entityName dateFormat:(NSString *const)dateFormat {
    if (elementsFromWeb.count == 0)
        return nil;

    NSMutableDictionary *ret = [NSMutableDictionary new];
    NSError *error = nil;

    [self internalUpdateOrInsert:elementsFromWeb entityName:entityName moc:self imported:ret dateFormat:dateFormat error:&error];
    if (error) {
        NSLog(@"%s: %@", __func__, error);
        return nil;
    }

    return ret;
}

- (NSDictionary *)updateOrInsert:(const NSArray *const)elementsFromWeb entityName:(NSString *)entityName {
    return [self updateOrInsert:elementsFromWeb entityName:entityName dateFormat:@"%Y-%m-%d"];
}

@end
