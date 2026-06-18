#import "LHCursorFlip.h"
#import "LHCursorDefs.h"

static const NSUInteger LHMaxFrameCount = 24;

static NSDictionary *sCapturedCursors = nil;


static NSDictionary *LHProcessCapturedCursor(NSDictionary *theme) {
    if (!theme) return nil;
    NSUInteger fc = [theme[@"FrameCount"] unsignedIntegerValue];
    if (fc <= LHMaxFrameCount) return theme;

    LHLog(LH_BOLD LH_YELLOW "  Downsampling: %lu frames -> %lu frames" LH_RESET,
          (unsigned long)fc, (unsigned long)LHMaxFrameCount);

    NSMutableDictionary *processed = theme.mutableCopy;
    CGFloat fd = [theme[@"FrameDuration"] doubleValue];
    CGFloat adjustedDuration = fd * ((CGFloat)fc / (CGFloat)LHMaxFrameCount);
    processed[@"FrameCount"] = @(LHMaxFrameCount);
    processed[@"FrameDuration"] = @(adjustedDuration);

    NSArray *representations = theme[@"Representations"];
    NSMutableArray *newReps = [NSMutableArray array];
    for (id imageObj in representations) {
        CGImageRef spriteSheet = (__bridge CGImageRef)imageObj;
        CGImageRef downsampled = LHDownsampleSpriteSheetImage(spriteSheet, fc, LHMaxFrameCount);
        if (downsampled) {
            [newReps addObject:(__bridge_transfer id)downsampled];
        } else {
            [newReps addObject:imageObj];
        }
    }
    processed[@"Representations"] = newReps;
    return processed;
}


BOOL LHCursorRequiresFlip(NSString *identifier) {
    static NSSet *excludedFromFlip = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        excludedFromFlip = [NSSet setWithArray:@[
            @"com.apple.cursor.29",
            @"com.apple.cursor.33",
            @"com.apple.cursor.35",
            @"com.apple.cursor.37",
            @"com.apple.cursor.30",
            @"com.apple.cursor.34",
            @"com.apple.coregraphics.Wait"
        ]];
    });
    return ![excludedFromFlip containsObject:identifier];
}


static BOOL LHRegisterCursor(NSUInteger frameCount, CGFloat frameDuration,
                               CGPoint hotSpot, CGSize size,
                               NSArray *images, NSString *ident) {
    if (frameCount > LHMaxFrameCount || frameCount < 1) return NO;

    const char *identifier = ident.UTF8String;
    int seed = 0;
    CGError err = CGSRegisterCursorWithImages(CGSMainConnectionID(),
                                               (char *)identifier,
                                               true, true, size, hotSpot,
                                               frameCount, frameDuration,
                                               (__bridge CFArrayRef)images, &seed);
    if (err != kCGErrorSuccess) return NO;

    int activateSeed = 0;
    CGSSetRegisteredCursor(CGSMainConnectionID(), (char *)identifier, &activateSeed);

    NSArray *tahoeAliases = LHTahoeCursorAliasesForIdentifier(ident);
    for (NSString *alias in tahoeAliases) {
        int aliasSeed = 0;
        CGError aliasErr = CGSRegisterCursorWithImages(CGSMainConnectionID(),
                                                        (char *)alias.UTF8String,
                                                        true, true, size, hotSpot,
                                                        frameCount, frameDuration,
                                                        (__bridge CFArrayRef)images, &aliasSeed);
        if (aliasErr == kCGErrorSuccess) {
            int aSeed = 0;
            CGSSetRegisteredCursor(CGSMainConnectionID(), (char *)alias.UTF8String, &aSeed);
        }
    }

    NSArray *browserAliases = LHBrowserCursorAliasesForIdentifier(ident);
    for (NSString *bAlias in browserAliases) {
        if (sCapturedCursors[bAlias] != nil) {
            continue;
        }
        int bSeed = 0;
        CGError bErr = CGSRegisterCursorWithImages(CGSMainConnectionID(),
                                                     (char *)bAlias.UTF8String,
                                                     true, true, size, hotSpot,
                                                     frameCount, frameDuration,
                                                     (__bridge CFArrayRef)images, &bSeed);
        if (bErr == kCGErrorSuccess) {
            int baSeed = 0;
            CGSSetRegisteredCursor(CGSMainConnectionID(), (char *)bAlias.UTF8String, &baSeed);
        }
    }

    return YES;
}


static BOOL LHApplyCursorForIdentifier(NSDictionary *cursor, NSString *identifier, BOOL flip) {
    if (!cursor || !identifier) return NO;

    NSNumber *frameCount    = cursor[@"FrameCount"];
    NSNumber *frameDuration = cursor[@"FrameDuration"];
    CGPoint hotSpot         = CGPointMake([cursor[@"HotSpotX"] doubleValue],
                                          [cursor[@"HotSpotY"] doubleValue]);
    CGSize size             = CGSizeMake([cursor[@"PointsWide"] doubleValue],
                                         [cursor[@"PointsHigh"] doubleValue]);
    NSArray *reps           = cursor[@"Representations"];
    NSMutableArray *images  = [NSMutableArray array];

    BOOL applyFlip = flip && LHCursorRequiresFlip(identifier);

    if (applyFlip) {
        hotSpot.x = size.width - hotSpot.x - 1;
    }

    for (id object in reps) {
        CFTypeID type = CFGetTypeID((__bridge CFTypeRef)object);
        NSBitmapImageRep *rep;
        if (type == CGImageGetTypeID()) {
            rep = [[NSBitmapImageRep alloc] initWithCGImage:(__bridge CGImageRef)object];
        } else {
            rep = [[NSBitmapImageRep alloc] initWithData:object];
        }
        if (!rep) continue;
        rep = [rep lh_retaggedSRGBSpace];

        if (!applyFlip) {
            if (type == CGImageGetTypeID()) {
                [images addObject:object];
                continue;
            }
            [images addObject:(__bridge id)[rep CGImage]];
        } else {
            NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                              pixelsWide:rep.pixelsWide
                                                                              pixelsHigh:rep.pixelsHigh
                                                                           bitsPerSample:8
                                                                         samplesPerPixel:4
                                                                                hasAlpha:YES
                                                                                isPlanar:NO
                                                                          colorSpaceName:NSDeviceRGBColorSpace
                                                                             bytesPerRow:4 * rep.pixelsWide
                                                                            bitsPerPixel:32];
            NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep:newRep];
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:ctx];
            NSAffineTransform *transform = [NSAffineTransform transform];
            [transform translateXBy:rep.pixelsWide yBy:0];
            [transform scaleXBy:-1 yBy:1];
            [transform concat];
            [rep drawInRect:NSMakeRect(0, 0, rep.pixelsWide, rep.pixelsHigh)
                   fromRect:NSZeroRect
                  operation:NSCompositingOperationSourceOver
                   fraction:1.0
             respectFlipped:NO
                      hints:nil];
            [NSGraphicsContext restoreGraphicsState];
            [images addObject:(__bridge id)[newRep CGImage]];
        }
    }

    return LHRegisterCursor(frameCount.unsignedIntegerValue, frameDuration.doubleValue,
                            hotSpot, size, images, identifier);
}


BOOL LHCaptureSystemCursors(void) {
    @autoreleasepool {
        CGSConnectionID cid = CGSMainConnectionID();
        NSMutableDictionary *cursors = [NSMutableDictionary dictionary];

        float originalScale = 1.0f;
        CGSGetCursorScale(cid, &originalScale);
        CGSSetCursorScale(cid, LHDumpCursorScale);
        CGSHideCursor(cid);

        NSSet *namedSkipSet = [NSSet setWithArray:@[
            @"com.apple.coregraphics.IBeamXOR",
            @"com.apple.coregraphics.Empty",
        ]];
        NSSet *coreSkipSet = [NSSet setWithArray:@[
            @"com.apple.cursor.0",
            @"com.apple.cursor.1",
            @"com.apple.cursor.6",
            @"com.apple.cursor.8",
        ]];

        NSUInteger i = 0;
        NSString *key = nil;
        while ((key = LHDefaultCursors[i]) != nil) {
            if (![namedSkipSet containsObject:key]) {
                NSDictionary *theme = LHProcessCapturedCursor(LHCaptureCursorTheme(cid, key));
                if (theme) {
                    cursors[key] = theme;
                    LHLog(LH_BOLD LH_GREEN "Captured: %s" LH_RESET, key.UTF8String);
                } else {
                    LHLog(LH_BOLD LH_YELLOW "Missing: %s" LH_RESET, key.UTF8String);
                }
            }
            i++;
        }

        for (int x = 0; x <= MC_MAX_CORE_CURSOR_ID; x++) {
            NSString *cursorKey = [NSString stringWithFormat:@"com.apple.cursor.%d", x];
            if ([coreSkipSet containsObject:cursorKey]) continue;

            CoreCursorSet(cid, x);
            NSDictionary *theme = LHProcessCapturedCursor(LHCaptureCursorTheme(cid, cursorKey));
            if (theme) {
                cursors[cursorKey] = theme;
            } else {
                LHLog(LH_BOLD LH_YELLOW "Missing: %s" LH_RESET, cursorKey.UTF8String);
            }
        }

        CGSShowCursor(cid);
        CGSSetCursorScale(cid, originalScale);

        sCapturedCursors = [cursors copy];
        LHLog(LH_BOLD LH_GREEN "Captured %lu cursors" LH_RESET, (unsigned long)cursors.count);
        return cursors.count > 0;
    }
}

BOOL LHApplyFlippedCursors(void) {
    if (!sCapturedCursors) {
        LHLog(LH_BOLD LH_RED "No captured cursors — call LHCaptureSystemCursors first" LH_RESET);
        return NO;
    }

    @autoreleasepool {
        CGSConnectionID cid = CGSMainConnectionID();
        CoreCursorUnregisterAll(cid);
        for (int x = 0; x <= MC_MAX_CORE_CURSOR_ID; x++) {
            CoreCursorSet(cid, x);
        }

        NSUInteger applied = 0;
        for (NSString *key in sCapturedCursors) {
            if (LHApplyCursorForIdentifier(sCapturedCursors[key], key, YES)) {
                applied++;
            }
        }

        LHLog(LH_BOLD LH_GREEN "Applied %lu flipped cursors" LH_RESET, (unsigned long)applied);
        return applied > 0;
    }
}

BOOL LHRestoreCursors(void) {
    if (!sCapturedCursors) return NO;

    @autoreleasepool {
        CGSConnectionID cid = CGSMainConnectionID();
        CoreCursorUnregisterAll(cid);
        for (int x = 0; x <= MC_MAX_CORE_CURSOR_ID; x++) {
            CoreCursorSet(cid, x);
        }

        NSUInteger restored = 0;
        for (NSString *key in sCapturedCursors) {
            if (LHApplyCursorForIdentifier(sCapturedCursors[key], key, NO)) {
                restored++;
            }
        }

        CGSSetSystemDefinedCursor(cid, 0);
        LHLog(LH_BOLD LH_GREEN "Restored %lu cursors" LH_RESET, (unsigned long)restored);
        return restored > 0;
    }
}

void LHFinalizeCursorApply(void) {
    CGSSetDockCursorOverride(CGSMainConnectionID(), true);

    float scale;
    CGSGetCursorScale(CGSMainConnectionID(), &scale);
    CGSSetCursorScale(CGSMainConnectionID(), scale + LHCursorRefreshScaleBump);
    CGSSetCursorScale(CGSMainConnectionID(), scale);

    CGSSetSystemDefinedCursor(CGSMainConnectionID(), 0);
}

void LHForceCursorVisualRefresh(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSPoint loc = [NSEvent mouseLocation];
        NSRect windowRect = NSMakeRect(loc.x, loc.y, 1, 1);
        
        NSWindow *invisibleWindow = [[NSWindow alloc] initWithContentRect:windowRect 
                                                                styleMask:NSWindowStyleMaskBorderless 
                                                                  backing:NSBackingStoreBuffered 
                                                                    defer:NO];
        [invisibleWindow setReleasedWhenClosed:NO];
        [invisibleWindow setOpaque:NO];
        [invisibleWindow setBackgroundColor:[NSColor clearColor]];
        [invisibleWindow setIgnoresMouseEvents:NO];
        [invisibleWindow setLevel:NSFloatingWindowLevel];
        [invisibleWindow setHasShadow:NO];
        
        [invisibleWindow orderFront:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [invisibleWindow close];
        });
    });
}
