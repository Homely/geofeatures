/*
*   GFMultiLineStringTests.m
*
*   Copyright 2015 Tony Stone
*
*   Licensed under the Apache License, Version 2.0 (the "License");
*   you may not use this file except in compliance with the License.
*   You may obtain a copy of the License at
*
*   http://www.apache.org/licenses/LICENSE-2.0
*
*   Unless required by applicable law or agreed to in writing, software
*   distributed under the License is distributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*   limitations under the License.
*
*   Created by Tony Stone on 04/14/2015.
*/

#import <GeoFeatures/GeoFeatures.h>
#import <XCTest/XCTest.h>

static NSDictionary * geoJSON1;
static NSDictionary * geoJSON2;
static NSDictionary * invalidGeoJSON;

//
// Static constructor
//
static __attribute__((constructor(101),used,visibility("internal"))) void staticConstructor (void) {
    geoJSON1       = @{@"type": @"MultiLineString", @"coordinates": @[@[@[@(100.0), @(0.0)],@[@(101.0), @(1.0)]], @[@[@(102.0), @(2.0)],@[@(103.0), @(3.0)]]]};
    geoJSON2       = @{@"type": @"MultiLineString", @"coordinates": @[@[@[@(103.0), @(2.0)],@[@(101.0), @(1.0)]], @[@[@(102.0), @(2.0)],@[@(103.0), @(3.0)]]]};
    invalidGeoJSON = @{@"type": @"MultiLineString", @"coordinates": @{}};
}

@interface GFMultiLineStringTests : XCTestCase
@end

@implementation GFMultiLineStringTests

#pragma mark - Test init

    - (void)testInit_NoThrow {
        XCTAssertNoThrow([[GFMultiLineString alloc] init]);
    }

    - (void)testInit_NotNil {
        XCTAssertNotNil([[GFMultiLineString alloc] init]);
    }

    - (void)testInit {
        XCTAssertEqualObjects([[[GFMultiLineString alloc] init] toWKTString], @"MULTILINESTRING()");
    }

#pragma mark - Test initWithGeoJSONGeometry

    - (void) testInitWithGeoJSONGeometry_WithValidGeoJSON {
        XCTAssertEqualObjects([[[GFMultiLineString alloc] initWithGeoJSONGeometry: geoJSON1] toWKTString], @"MULTILINESTRING((100 0,101 1),(102 2,103 3))");
    }

    - (void)testInitWithGeoJSONGeometry_WithInvalidGeoJSON {
        XCTAssertThrowsSpecificNamed([[GFMultiLineString alloc] initWithGeoJSONGeometry:  @{@"invalid": @{}}], NSException, NSInvalidArgumentException);
    }

#pragma mark - Test initWithWKT

    - (void) testInitWithWKT_WithValidWKT {
        XCTAssertEqualObjects([[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((100 0,101 1),(102 2,103 3))"] toWKTString], @"MULTILINESTRING((100 0,101 1),(102 2,103 3))");
    }

    - (void)testInitWithWKT_WithInvalidWKT {
        XCTAssertThrows([[GFMultiLineString alloc] initWithWKT: @"INVALID()"]);
    }

#pragma mark - Test copy

    - (void) testCopy {
        XCTAssertEqualObjects([[[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((100 0,101 1),(102 2,103 3))"] copy] toWKTString], @"MULTILINESTRING((100 0,101 1),(102 2,103 3))");
    }

#pragma mark - Test toGeoJSONGeometry

    - (void) testToGeoJSONGeometry {
        XCTAssertEqualObjects([[[GFMultiLineString alloc] initWithGeoJSONGeometry: geoJSON1] toGeoJSONGeometry], geoJSON1);
    }

#pragma mark - Test description

    - (void) testDescription_WithGeoJSON1 {
        XCTAssertEqualObjects([[[GFMultiLineString alloc] initWithGeoJSONGeometry: geoJSON1] description], @"MULTILINESTRING((100 0,101 1),(102 2,103 3))");
    }

    - (void) testDescription_WithGeoJSON2 {
        XCTAssertEqualObjects([[[GFMultiLineString alloc] initWithGeoJSONGeometry: geoJSON2] description], @"MULTILINESTRING((103 2,101 1),(102 2,103 3))");
    }

#pragma mark - Test mapOverlays

    - (void) testMapOverlays {
        
        NSArray * mapOverlays = [[[GFMultiLineString alloc] initWithGeoJSONGeometry: geoJSON1] mkMapOverlays];
        
        XCTAssertNotNil (mapOverlays);
        XCTAssertTrue   ([mapOverlays count] == 2);
        
        for (int i = 0; i < [mapOverlays count]; i++) {
            id mapOverlay = mapOverlays[i];
            
            XCTAssertTrue   ([mapOverlay isKindOfClass: [MKPolyline class]]);
            
            MKPolyline * polyline = mapOverlay;
            
            XCTAssertTrue   ([polyline pointCount] == 2);
        }
    }

#pragma mark - Test count

    - (void) testCount_WithEmptyMultiLineString {
        XCTAssertEqual([[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING()"] count], 0);
    }

    - (void) testCount_With1ElementMultiLineString {
        XCTAssertEqual([[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0))"] count], 1);
    }

    - (void) testCount_With2ElementMultiLineString {
        XCTAssertEqual([[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0),(5 0,10 0,5 -5,5 0))"] count], 2);
    }

#pragma mark - Test geometryAtIndex

    - (void) testGeometryAtIndex_With2ElementMultiLineStringAndIndex0 {
        XCTAssertEqualObjects([[[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0),(5 0,10 0,5 -5,5 0))"] geometryAtIndex: 0] toWKTString], @"LINESTRING(0 0,5 0)");
    }

    - (void) testGeometryAtIndex_With2ElementMultiLineStringAndIndex1 {
        XCTAssertEqualObjects([[[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0),(5 0,10 0,5 -5,5 0))"] geometryAtIndex: 1] toWKTString], @"LINESTRING(5 0,10 0,5 -5,5 0)");
    }

    - (void) testGeometryAtIndex_With2ElementMultiLineStringAndOutOfRangeIndex {
        XCTAssertThrowsSpecificNamed(([[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0))"] geometryAtIndex: 1]), NSException, NSRangeException);
    }

#pragma mark - Test firstGeometry

    - (void) testFirstGeometry_With2ElementMultiLineString {
        XCTAssertEqualObjects([[[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0),(5 0,10 0,5 -5,5 0))"] firstGeometry] toWKTString], @"LINESTRING(0 0,5 0)");
    }

    - (void) testFirstGeometry_WithEmptyMultiLineString_NoThrow {
        XCTAssertNoThrow([[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING()"] firstGeometry]);
    }

    - (void) testFirstGeometry_WithEmptyMultiLineString {
        XCTAssertEqualObjects([[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING()"] firstGeometry], nil);
    }

#pragma mark - Test lastGeometry

    - (void) testLastGeometry_With2ElementMultiLineString {
        XCTAssertEqualObjects([[[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0),(5 0,10 0,5 -5,5 0))"] lastGeometry] toWKTString], @"LINESTRING(5 0,10 0,5 -5,5 0)");
    }

    - (void) testLastGeometry_WithEmptyMultiLineString_NoThrow {
        XCTAssertNoThrow([[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING()"] lastGeometry]);
    }

    - (void) testLastGeometry_WithEmptyMultiLineString {
        XCTAssertEqualObjects([[[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING()"] lastGeometry], nil);
    }

#pragma mark - Test objectAtIndexedSubscript

    - (void) testObjectAtIndexedSubscript_With2ElementMultiLineStringAndIndex0_NoThrow {
        GFMultiLineString * multiLineString = [[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0),(5 0,10 0,5 -5,5 0))"];

        XCTAssertNoThrow(multiLineString[0]);
    }

    - (void) testObjectAtIndexedSubscript_With2ElementMultiLineStringAndIndex0 {
        GFMultiLineString * multiLineString = [[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0),(5 0,10 0,5 -5,5 0))"];

        XCTAssertEqualObjects([multiLineString[0] toWKTString], @"LINESTRING(0 0,5 0)");
    }

    - (void) testObjectAtIndexedSubscript_With2ElementMultiLineStringAndIndex1_NoThrow {
        GFMultiLineString * multiLineString = [[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0),(5 0,10 0,5 -5,5 0))"];

        XCTAssertNoThrow(multiLineString[1]);
    }

    - (void) testObjectAtIndexedSubscript_With2ElementMultiLineStringAndIndex1 {
        GFMultiLineString * multiLineString = [[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0),(5 0,10 0,5 -5,5 0))"];

        XCTAssertEqualObjects([multiLineString[1] toWKTString], @"LINESTRING(5 0,10 0,5 -5,5 0)");
    }

    - (void) testObjectAtIndexedSubscript_With2ElementMultiLineStringAndOutOfRangeIndex {
        GFMultiLineString * multiLineString = [[GFMultiLineString alloc] initWithWKT: @"MULTILINESTRING((0 0,5 0),(5 0,10 0,5 -5,5 0))"];

        XCTAssertThrowsSpecificNamed(multiLineString[2], NSException, NSRangeException);
    }

@end