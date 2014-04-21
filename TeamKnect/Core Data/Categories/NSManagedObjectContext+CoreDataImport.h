//
//  NSManagedObjectContext+CoreDataImport.h
//  TeamKnect
//
//  Created by Scott Grosch on 1/1/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

typedef void (^CoreDataImportError)(NSError *error);

@interface NSManagedObjectContext (CoreDataImport)

/**
 Creates new managed objects or updates existing ones in an efficient manner.
 @see https://developer.apple.com/library/mac/documentation/cocoa/conceptual/coredata/Articles/cdImporting.html#//apple_ref/doc/uid/TP40003174-SW1
 @param elementsFromWeb
 An array of JSON objects representing an NSManagedObject
 @param entityName
 The name of the NSManagedObject subclass represented by @c elementsFromWeb
 @return And @c NSDictionary of the @c NSManagedObjects keyed by the @c sql_ident as an @c NSNumber
 */
- (NSDictionary *)updateOrInsert:(const NSArray *const)elementsFromWeb entityName:(NSString *)entityName;


/**
 Creates new managed objects or updates existing ones in an efficient manner.
 @see https://developer.apple.com/library/mac/documentation/cocoa/conceptual/coredata/Articles/cdImporting.html#//apple_ref/doc/uid/TP40003174-SW1
 @param elementsFromWeb An array of JSON objects representing an NSManagedObject
 @param entityName The name of the NSManagedObject subclass represented by @c elementsFromWeb
 @param dateFormat The format of the date string to parse.
 @return And @c NSDictionary of the @c NSManagedObjects keyed by the @c sql_ident as an @c NSNumber
 */
- (NSDictionary *)updateOrInsert:(const NSArray *const)elementsFromWeb entityName:(NSString *)entityName dateFormat:(NSString *const)dateFormat;


- (void)updateOrInsertAsync:(const NSArray *const)data entityName:(NSString *)entityName onError:(CoreDataImportError)onError onCompletion:(dispatch_block_t)onCompletion;

@end
