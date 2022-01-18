//
//  RainbowLoggerTests.m
//  RainbowLoggerTests
//
//  Created by Paige Sun on 1/5/22.
//  Copyright © 2022 Paige Sun. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FiltersData.h"

@interface FiltersDataTests : XCTestCase

@end

/*
 Hardened Runtime (which allows this app to run command line scripts)
 must be disabled for tests to run without code signing:
 - Go to RainbowLogger Target
 - Build Settings
 - Set "Enable Hardened Runtime" to NO.
 - Don't forget to set it back to YES when you're done testing.
 **/
@implementation FiltersDataTests
Filter *noneFilter;
Filter *mustContain1;
Filter *mustContain2;
Filter *mustNotContain3;
Filter *mustNotContain4;
Filter *containsAny5;
Filter *containsAny6;
Filter *containsOnly7;
Filter *containsOnly8;

- (void)setUp {
  noneFilter = [[Filter alloc] initWithCondition:FilterConditionColorContainingText text:@"None" colorTag:0 isEnabled:YES];
  mustContain1 = [[Filter alloc] initWithCondition:FilterConditionMustContain text:@"MustContain1" colorTag:0 isEnabled:YES];
  mustContain2 = [[Filter alloc] initWithCondition:FilterConditionMustContain text:@"MustContain2" colorTag:0 isEnabled:YES];
  mustNotContain3 = [[Filter alloc] initWithCondition:FilterConditionMustNotContain text:@"MustNotContain3" colorTag:0 isEnabled:YES];
  mustNotContain4 = [[Filter alloc] initWithCondition:FilterConditionMustNotContain text:@"MustNotContain4" colorTag:0 isEnabled:YES];
  containsAny5 = [[Filter alloc] initWithCondition:FilterConditionContainsAny text:@"ContainsAny5" colorTag:0 isEnabled:YES];
  containsAny6 = [[Filter alloc] initWithCondition:FilterConditionContainsAny text:@"ContainsAny6" colorTag:0 isEnabled:YES];
  containsOnly7 = [[Filter alloc] initWithCondition:FilterConditionContainsOnly text:@"ContainsOnly7" colorTag:0 isEnabled:YES];
  containsOnly8 = [[Filter alloc] initWithCondition:FilterConditionContainsOnly text:@"ContainsOnly8" colorTag:0 isEnabled:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark - Empty

- (void)testSummaryText_emptyFilters {
  NSArray<Filter*> *filters = @[];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"");
}

#pragma mark - Must Contain

- (void)testSummaryText_singleMustContain {
  NSArray<Filter*> *filters = @[mustContain1];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Conditions: (MustContain1)");
}

- (void)testSummaryText_multipleMustContain {
  NSArray<Filter*> *filters = @[mustContain1, mustContain2];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Conditions: (MustContain1 AND MustContain2)");
}

- (void)testSummaryText_multipleMustContain_withNotContain {
  NSArray<Filter*> *filters = @[mustContain1, mustContain2, mustNotContain3];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Conditions: (MustContain1 AND MustContain2 AND NOT MustNotContain3)");
}

#pragma mark - Must Not Contain
- (void)testSummaryText_singleMustNotContain {
  NSArray<Filter*> *filters = @[mustNotContain3];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Conditions: (NOT MustNotContain3)");
}

- (void)testSummaryText_multipleMustNotContain {
  NSArray<Filter*> *filters = @[mustNotContain3, mustNotContain4];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Conditions: (NOT MustNotContain3 AND NOT MustNotContain4)");
}

#pragma mark - Contains Any

- (void)testSummaryText_singleContainsAny {
  NSArray<Filter*> *filters = @[containsAny5];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Conditions: ContainsAny5");
}

- (void)testSummaryText_multipleContainsAny {
  NSArray<Filter*> *filters = @[containsAny5, containsAny6];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Conditions: ContainsAny5 OR ContainsAny6");
}

#pragma mark - Contains Only

- (void)testSummaryText_singleContainsOnly {
  NSArray<Filter*> *filters = @[containsOnly7];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Only Conditions: ContainsOnly7");
}

- (void)testSummaryText_multipleContainsOnly {
  NSArray<Filter*> *filters = @[containsOnly7, containsOnly8];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Only Conditions: ContainsOnly7 OR ContainsOnly8");
}

#pragma mark - Mixed with Contains Only
- (void)testSummaryText_multipleContains_withContainsOnly {
  NSArray<Filter*> *filters = @[mustContain1, mustContain2, mustNotContain3, containsOnly7, mustNotContain4, containsAny5, containsAny6];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Only Conditions: ContainsOnly7");
  
  NSArray<Filter*> *filters2 = @[containsAny5, mustContain1, containsOnly7, mustContain2, mustNotContain3, containsAny6, containsOnly8, mustNotContain4];
  NSString *summary2 = [self getSummaryTextForFilters:filters2];
  XCTAssertEqualObjects(summary2, @"Logs displayed above pass Filter Only Conditions: ContainsOnly7 OR ContainsOnly8");
}

#pragma mark - Mixed without Contains Only

- (void)testSummaryText_multipleMustContain_multipleContainsAny {
  NSArray<Filter*> *filters = @[mustContain1, mustContain2, mustNotContain3, mustNotContain4, containsAny5, containsAny6];
  NSString *summary = [self getSummaryTextForFilters:filters];
  XCTAssertEqualObjects(summary, @"Logs displayed above pass Filter Conditions: (MustContain1 AND MustContain2 AND NOT MustNotContain3 AND NOT MustNotContain4) OR ContainsAny5 OR ContainsAny6");
  
  NSArray<Filter*> *filters2 = @[containsAny5, mustContain1, mustContain2, mustNotContain3, containsAny6, mustNotContain4];
  NSString *summary2 = [self getSummaryTextForFilters:filters2];
  XCTAssertEqualObjects(summary2, @"Logs displayed above pass Filter Conditions: (MustContain1 AND MustContain2 AND NOT MustNotContain3 AND NOT MustNotContain4) OR ContainsAny5 OR ContainsAny6");
}

-(NSString *)getSummaryTextForFilters:(NSArray<Filter*>*)filters {
  FiltersData *filtersData = [[FiltersData alloc] init];
  [filtersData setFilters:^NSArray<Filter *> * _Nonnull(NSArray<Filter *> * _Nonnull currentFilters) {
    return filters;
  }];
  
  return [[filtersData getFiltersSummary] string];
}

@end
