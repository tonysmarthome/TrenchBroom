/*
Copyright (C) 2010-2012 Kristian Duske

This file is part of TrenchBroom.

TrenchBroom is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

TrenchBroom is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with TrenchBroom.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "BoundsRenderer.h"
#import <OpenGL/gl.h>
#import "Brush.h"
#import "Camera.h"
#import "GLFontManager.h"
#import "GLString.h"
#import "GLUtils.h"

@implementation BoundsRenderer

- (id)initWithCamera:(Camera *)theCamera fontManager:(GLFontManager *)theFontManager {
    NSAssert(theCamera != nil, @"camera must not be nil");
    NSAssert(theFontManager != nil, @"font manager must not be nil");
    
    if ((self = [self init])) {
        camera = [theCamera retain];
        fontManager = [theFontManager retain];
        boundsSet = NO;
        valid = NO;
        insets = NSMakeSize(1, 1);
    }
    
    return self;
}

- (void)setBounds:(TBoundingBox *)theBounds {
    if (theBounds == NULL) {
        boundsSet = NO;
    } else {
        bounds = *theBounds;
        boundsSet = YES;
    }
    valid = NO;
}

- (void)renderColor:(const TVector4f *)theColor {
    if (!boundsSet)
        return;
    
    TVector3f cPos, center, size, diff;
    cPos = *[camera position];
    centerOfBounds(&bounds, &center);
    sizeOfBounds(&bounds, &size);
    subV3f(&center, &cPos, &diff);

    if (!valid) {
        NSFont* font = [NSFont systemFontOfSize:9];
        for (int i = 0; i < 3; i++) {
            [glStrings[i] release];
            glStrings[i] = nil;
        }
            
        glStrings[0] = [[fontManager createGLString:[NSString stringWithFormat:@"%.0f", size.x] font:font] retain];
        glStrings[1] = [[fontManager createGLString:[NSString stringWithFormat:@"%.0f", size.y] font:font] retain];
        glStrings[2] = [[fontManager createGLString:[NSString stringWithFormat:@"%.0f", size.z] font:font] retain];
        valid = YES;
    }

    int maxi = 3;
    TVector3f gv[3][4];

    // X guide
    if (diff.y >= 0) {
        gv[0][0] = bounds.min;
        gv[0][0].y -= 5;
        gv[0][1] = gv[0][0];
        gv[0][1].y -= 5;
        gv[0][2] = gv[0][1];
        gv[0][2].x = bounds.max.x;
        gv[0][3] = gv[0][0];
        gv[0][3].x = bounds.max.x;
    } else {
        gv[0][0] = bounds.min;
        gv[0][0].y = bounds.max.y + 5;
        gv[0][1] = gv[0][0];
        gv[0][1].y += 5;
        gv[0][2] = gv[0][1];
        gv[0][2].x = bounds.max.x;
        gv[0][3] = gv[0][0];
        gv[0][3].x = bounds.max.x;
    }
    
    // Y guide
    if (diff.x >= 0) {
        gv[1][0] = bounds.min;
        gv[1][0].x -= 5;
        gv[1][1] = gv[1][0];
        gv[1][1].x -= 5;
        gv[1][2] = gv[1][1];
        gv[1][2].y = bounds.max.y;
        gv[1][3] = gv[1][0];
        gv[1][3].y = bounds.max.y;
    } else {
        gv[1][0] = bounds.min;
        gv[1][0].x = bounds.max.x + 5;
        gv[1][1] = gv[1][0];
        gv[1][1].x += 5;
        gv[1][2] = gv[1][1];
        gv[1][2].y = bounds.max.y;
        gv[1][3] = gv[1][0];
        gv[1][3].y = bounds.max.y;
    }
    
    if (diff.z >= 0)
        for (int i = 0; i < 2; i++)
            for (int j = 0; j < 4; j++)
                gv[i][j].z = bounds.max.z;

    // Z Guide
    if (cPos.x <= bounds.min.x && cPos.y <= bounds.max.y) {
        gv[2][0] = bounds.min;
        gv[2][0].x -= 3.5f;
        gv[2][0].y = bounds.max.y + 3.5f;
        gv[2][1] = gv[2][0];
        gv[2][1].x -= 3.5f;
        gv[2][1].y += 3.5f;
        gv[2][2] = gv[2][1];
        gv[2][2].z = bounds.max.z;
        gv[2][3] = gv[2][0];
        gv[2][3].z = bounds.max.z;
    } else if (cPos.x <= bounds.max.x && cPos.y >= bounds.max.y) {
        gv[2][0] = bounds.max;
        gv[2][0].x += 3.5f;
        gv[2][0].y += 3.5f;
        gv[2][1] = gv[2][0];
        gv[2][1].x += 3.5f;
        gv[2][1].y += 3.5f;
        gv[2][2] = gv[2][1];
        gv[2][2].z = bounds.min.z;
        gv[2][3] = gv[2][0];
        gv[2][3].z = bounds.min.z;
    } else if (cPos.x >= bounds.max.x && cPos.y >= bounds.min.y) {
        gv[2][0] = bounds.max;
        gv[2][0].y = bounds.min.y;
        gv[2][0].x += 3.5f;
        gv[2][0].y -= 3.5f;
        gv[2][1] = gv[2][0];
        gv[2][1].x += 3.5f;
        gv[2][1].y -= 3.5f;
        gv[2][2] = gv[2][1];
        gv[2][2].z = bounds.min.z;
        gv[2][3] = gv[2][0];
        gv[2][3].z = bounds.min.z;
    } else if (cPos.x >= bounds.min.x && cPos.y <= bounds.min.y) {
        gv[2][0] = bounds.min;
        gv[2][0].x -= 3.5f;
        gv[2][0].y -= 3.5f;
        gv[2][1] = gv[2][0];
        gv[2][1].x -= 3.5f;
        gv[2][1].y -= 3.5f;
        gv[2][2] = gv[2][1];
        gv[2][2].z = bounds.max.z;
        gv[2][3] = gv[2][0];
        gv[2][3].z = bounds.max.z;
    } else {
        // above, inside or below, don't render Z guide
        maxi = 2;
    }
    
    // initialize the stencil buffer to cancel out the guides in those areas where the strings will be rendered
    glPolygonMode(GL_FRONT, GL_FILL);
    glClear(GL_STENCIL_BUFFER_BIT);
    glColorMask(NO, NO, NO, NO);
    glEnable(GL_STENCIL_TEST);
    glStencilFunc(GL_ALWAYS, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
    
    BOOL depth = glIsEnabled(GL_DEPTH_TEST);
    if (depth)
        glDisable(GL_DEPTH_TEST);
    
    TVector3f p[3];
    for (int i = 0; i < maxi; i++) {
        subV3f(&gv[i][2], &gv[i][1], &p[i]);
        scaleV3f(&p[i], 0.5f, &p[i]);
        addV3f(&gv[i][1], &p[i], &p[i]);

        float dist = [camera distanceTo:&p[i]];
        float factor = dist / 300;
        NSSize size = [glStrings[i] size];
        
        glPushMatrix();
        glTranslatef(p[i].x, p[i].y, p[i].z);
        [camera setBillboardMatrix];
        glScalef(factor, factor, 0);
        glTranslatef(-size.width / 2, -size.height / 2, 0);
        [glStrings[i] renderBackground:insets];
        glPopMatrix();
    }
    
    glColorMask(YES, YES, YES, YES);
    glStencilFunc(GL_NOTEQUAL, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    
    if (depth)
        glEnable(GL_DEPTH_TEST);
    
    for (int i = 0; i < 3; i++) {
        glColor4f(theColor->x, theColor->y, theColor->z, theColor->w);
        
        glBegin(GL_LINE_STRIP);
        for (int j = 0; j < 4; j++)
            glVertexV3f(&gv[i][j]);
        glEnd();
    }

    glDisable(GL_STENCIL_TEST);
    
    [fontManager activate];
    for (int i = 0; i < maxi; i++) {
        glColor4f(theColor->x, theColor->y, theColor->z, theColor->w);
        
        float dist = [camera distanceTo:&p[i]];
        float factor = dist / 300;
        NSSize size = [glStrings[i] size];
        
        glPushMatrix();
        glTranslatef(p[i].x, p[i].y, p[i].z);
        [camera setBillboardMatrix];
        glScalef(factor, factor, 0);
        glTranslatef(-size.width / 2, -size.height / 2, 0);
        [glStrings[i] render];
        glPopMatrix();
    }
    [fontManager deactivate];
}

- (void)dealloc {
    for (int i = 0; i < 3; i++)
        [glStrings[i] release];

    [fontManager release];
    [camera release];
    [super dealloc];
}

@end