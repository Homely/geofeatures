/*
*   GFPointAbstract.mm
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
*   Created by Tony Stone on 6/6/15.
*
*   MODIFIED 2015 BY Tony Stone. Modifications licensed under Apache License, Version 2.0.
*
*/

#import "GFPointAbstract.h"
#import <MapKit/MapKit.h>

@implementation GFPointAbstract

    - (instancetype) init {
        NSAssert(![self isMemberOfClass: [GFPointAbstract class]], @"Abstract class %@ can not be instantiated.  Please use one of the subclasses instead.", NSStringFromClass([self class]));
        return nil;
    }

@end