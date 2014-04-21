//
//  GSEventEditorTypePickerViewController.m
//  TeamKnect
//
//  Created by Scott Grosch on 2/16/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "GSEventEditorTypePickerViewController.h"

@interface GSEventEditorTypePickerViewController ()
@property (nonatomic, strong) NSArray *tableData;
@end

@implementation GSEventEditorTypePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableArray *mutable = [NSMutableArray arrayWithArray:@[@"Game", @"Training", @"Tournament", @"Meeting", @"Social", @"Meet"]];
    [mutable sortUsingSelector:@selector(compare:)];

    [mutable addObject:@"Other"];

    self.tableData = mutable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
    
    cell.textLabel.text = self.tableData[indexPath.row];
    
    return cell;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(UITableViewCell *)sender {
    const NSIndexPath *const indexPath = [self.tableView indexPathForCell:sender];
    self.type = self.tableData[indexPath.row];
    
    return YES;
}

@end
