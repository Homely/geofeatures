/*
*   GFMultiPolygon.mm
*
*   Copyright 2015 The Climate Corporation
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
*   Created by Tony Stone on 6/4/15.
*
*   MODIFIED 2015 BY Tony Stone. Modifications licensed under Apache License, Version 2.0.
*
*/

#import <MapKit/MapKit.h>
#import "GFMultiPolygon.h"
#import "GFPolygon.h"

#include "GFGeometry+Protected.hpp"
#include "GFPolygon+Primitives.hpp"

#include "geofeatures/internal/MultiPolygon.hpp"
#include "geofeatures/internal/GeometryVariant.hpp"

#include <vector>

#include <boost/geometry/io/wkt/wkt.hpp>

namespace gf = geofeatures::internal;

@implementation GFMultiPolygon

#pragma mark - Construction

    - (instancetype) init {
        self = [super initWithCPPGeometryVariant: gf::MultiPolygon()];
        return self;
    }

    - (instancetype) initWithWKT: (NSString *) wkt {
        NSParameterAssert(wkt != nil);

        try {
            gf::MultiPolygon multiPolygon;

            boost::geometry::read_wkt([wkt cStringUsingEncoding: NSUTF8StringEncoding], multiPolygon);

            self = [super initWithCPPGeometryVariant: multiPolygon];

        } catch (std::exception & e) {
            @throw [NSException exceptionWithName:@"Exception" reason:[NSString stringWithUTF8String:e.what()] userInfo:nil];
        }
        return self;
    }

    - (instancetype) initWithGeoJSONGeometry:(NSDictionary *)jsonDictionary {
        NSParameterAssert(jsonDictionary != nil);

        id coordinates = jsonDictionary[@"coordinates"];

        if (!coordinates || ![coordinates isKindOfClass:[NSArray class]]) {
            @throw [NSException exceptionWithName:@"Invalid GeoJSON" reason:@"Invalid GeoJSON Geometry Object, no coordinates found or coordinates of an invalid type." userInfo:nil];
        }
        //
        // Note: Coordinates of a MultiPolygon are an
        // array of Polygon coordinate arrays:
        //
        //
        //  { "type": "MultiPolygon",
        //       "coordinates": [
        //            [
        //              [[102.0, 2.0], [103.0, 2.0], [103.0, 3.0], [102.0, 3.0], [102.0, 2.0]]
        //            ],
        //            [
        //              [[100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0]],
        //              [[100.2, 0.2], [100.8, 0.2], [100.8, 0.8], [100.2, 0.8], [100.2, 0.2]]
        //            ]
        //         ]
        //  }
        //
        gf::MultiPolygon multiPolygon;

        try {
            for (NSArray * polygon in coordinates) {
                multiPolygon.push_back(gf::GFPolygon::polygonWithGeoJSONCoordinates(polygon));
            }

        } catch (std::exception & e) {
            @throw [NSException exceptionWithName:@"Exception" reason: [NSString stringWithUTF8String: e.what()] userInfo:nil];
        }

        self = [super initWithCPPGeometryVariant: multiPolygon];
        return self;
    }

#pragma mark - Querying a GFMultiPolygon

    - (NSUInteger)count {

        try {
            const auto& multiPolygon = boost::polymorphic_strict_get<gf::MultiPolygon>(_members->geometryVariant);

            return multiPolygon.size();

        } catch (std::exception & e) {
            @throw [NSException exceptionWithName:@"Exception" reason: [NSString stringWithUTF8String: e.what()] userInfo:nil];
        }
    }

    - (GFPolygon *) geometryAtIndex: (NSUInteger) index {

        try {
            auto& multiPolygon = boost::polymorphic_strict_get<gf::MultiPolygon>(_members->geometryVariant);

            unsigned long size = multiPolygon.size();

            if (size == 0 || index > (size -1)) {
                @throw [NSException exceptionWithName: NSRangeException reason: @"Index out of range" userInfo: nil];
            }

            return [[GFPolygon alloc] initWithCPPGeometryVariant: multiPolygon.at(index)];

        } catch (std::exception & e) {
            @throw [NSException exceptionWithName:@"Exception" reason: [NSString stringWithUTF8String: e.what()] userInfo:nil];
        }
    }

    - (GFPolygon *) firstGeometry {

        try {
            const auto& multiPolygon = boost::polymorphic_strict_get<gf::MultiPolygon>(_members->geometryVariant);

            if (multiPolygon.size() == 0) {
                return nil;
            }

            return [[GFPolygon alloc] initWithCPPGeometryVariant: multiPolygon.front()];

        } catch (std::exception & e) {
            @throw [NSException exceptionWithName:@"Exception" reason: [NSString stringWithUTF8String: e.what()] userInfo:nil];
        }
    }

    - (GFPolygon *) lastGeometry {

        try {
            auto& multiPolygon = boost::polymorphic_strict_get<gf::MultiPolygon>(_members->geometryVariant);

            if (multiPolygon.size() == 0) {
                return nil;
            }

            return [[GFPolygon alloc] initWithCPPGeometryVariant: multiPolygon.back()];

        } catch (std::exception & e) {
            @throw [NSException exceptionWithName:@"Exception" reason: [NSString stringWithUTF8String: e.what()] userInfo:nil];
        }
    }

#pragma mark - Indexed Subscripting

    - (id) objectAtIndexedSubscript: (NSUInteger) index {

        const auto& multiPolygon = boost::polymorphic_strict_get<gf::MultiPolygon>(_members->geometryVariant);

        if (index >= multiPolygon.size())
            [NSException raise:NSRangeException format:@"Index %li is beyond bounds [0, %li].", (unsigned long) index, multiPolygon.size()];

        return [[GFPolygon alloc] initWithCPPGeometryVariant: multiPolygon[index]];
    }

#pragma mark - GeoJSON Output

    - (NSDictionary *) toGeoJSONGeometry {
        NSMutableArray * polygons = [[NSMutableArray alloc] init];

        try {
            auto& multiPolygon = boost::polymorphic_strict_get<gf::MultiPolygon>(_members->geometryVariant);

            for (auto it = multiPolygon.begin();  it != multiPolygon.end(); ++it ) {
                [polygons addObject: gf::GFPolygon::geoJSONCoordinatesWithPolygon(*it)];
            }
        } catch (std::exception & e) {
            @throw [NSException exceptionWithName:@"Exception" reason: [NSString stringWithUTF8String: e.what()] userInfo:nil];
        }
        return @{@"type": @"MultiPolygon", @"coordinates": polygons};
    }

#pragma mark - MapKit

    - (NSArray *) mkMapOverlays {
        NSMutableArray * mkPolygons = [[NSMutableArray alloc] init];
        
        try {
            auto& multiPolygon = boost::polymorphic_strict_get<gf::MultiPolygon>(_members->geometryVariant);

            for (auto it = multiPolygon.begin();  it != multiPolygon.end(); ++it ) {
                [mkPolygons addObject: gf::GFPolygon::mkOverlayWithPolygon(*it)];
            }
        } catch (std::exception & e) {
            @throw [NSException exceptionWithName:@"Exception" reason: [NSString stringWithUTF8String: e.what()] userInfo:nil];
        }
        return mkPolygons;
    }

@end