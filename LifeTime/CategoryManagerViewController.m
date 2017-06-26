//
//  AddCategoryViewController.m
//  LifeTime
//
//  Created by Daekun Kim on 2017-06-24.
//  Copyright © 2017 DaekunKim. All rights reserved.
//

#import "CategoryManagerViewController.h"
#import "DBManager.h"

@interface CategoryManagerViewController ()

@end

@implementation CategoryManagerViewController

- (void)printDB {
    DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
    NSString *query = [NSString stringWithFormat:@"%@", @"SELECT * FROM categories ORDER BY cat_order"];
    NSLog(@"%@", [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
        NSString *query = [NSString stringWithFormat:@"%@", @"SELECT * FROM categories"];
        NSArray *result = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
        
        return result.count;
    }
    else if (section == 1) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
        NSString *query = [NSString stringWithFormat:@"%@", @"SELECT * FROM categories ORDER BY cat_order"];
        NSArray *result = [[NSArray alloc] initWithArray:[dbManager loadDataFromDB:query]];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"category"];
        UILabel *labelTitle = [cell textLabel];
        [labelTitle setText:[[result objectAtIndex:[indexPath row]] objectAtIndex:1]];
        
        return cell;
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"add_category"];
        
        return cell;
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return YES;
    } else if (indexPath.section == 1) {
        return NO;
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return YES;
    } else if (indexPath.section == 1) {
        return NO;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
        NSString *query = [NSString stringWithFormat:@"DELETE FROM categories WHERE name=\"%@\"", [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
        [dbManager executeQuery:query];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        for (int i = 0; i < [tableView numberOfRowsInSection:0]; i++) {
            UITableViewCell *curCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
            NSString *query = [NSString stringWithFormat:@"UPDATE categories SET cat_order=%d WHERE name=\"%@\"", i, curCell.textLabel.text];
            [dbManager executeQuery:query];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Add Category"
                                                                       message:@"Enter new category name."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *categoryTextField) {
            categoryTextField.placeholder = @"Category Name";
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:cancelAction];
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  NSString *categoryName = [alert.textFields objectAtIndex:0].text;
                                                                  
                                                                  DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
                                                                  NSString *query = [NSString stringWithFormat:@"INSERT INTO categories (name) VALUES (\"%@\")", categoryName];
                                                                  [dbManager executeQuery:query];
                                                                  
                                                                  [tableView reloadData];
                                                              }];
        [alert addAction:doneAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)editButtonPressed:(id)sender{
    if(self.editing) {
        for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
            UITableViewCell *curCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            
            DBManager *dbManager = [[DBManager alloc] initWithDatabaseFilename:@"lifetime_db.db"];
            NSString *query = [NSString stringWithFormat:@"UPDATE categories SET cat_order=%d WHERE name=\"%@\"", i, curCell.textLabel.text];
            [dbManager executeQuery:query];
        }
        
        [super setEditing:NO animated:YES];
        [self setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                              target:nil
                                                                                              action:@selector(editButtonPressed:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                              target:nil
                                                                                              action:@selector(doneButtonPressed:)];
    }
    else {
        [super setEditing:YES animated:YES];
        [self setEditing:YES animated:YES];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                              target:nil
                                                                                              action:@selector(editButtonPressed:)];
    }
}

@end
