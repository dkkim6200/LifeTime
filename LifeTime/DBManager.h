//
//  DBManager.h
//  CustomTableView
//
//  Created by Danny Lee on 2016-10-29.
//  Copyright © 2016 Appcoda. All rights reserved.
//

@interface DBManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;
-(NSArray *)loadDataFromDB:(NSString *)query;
-(void)executeQuery:(NSString *)query;

@end
