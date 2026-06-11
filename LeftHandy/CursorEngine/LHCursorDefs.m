#import "LHCursorDefs.h"

NSString *LHDefaultCursors[] = {
    @"com.apple.coregraphics.Arrow",
    @"com.apple.coregraphics.IBeam",
    @"com.apple.coregraphics.IBeamXOR",
    @"com.apple.coregraphics.Alias",
    @"com.apple.coregraphics.Copy",
    @"com.apple.coregraphics.Move",
    @"com.apple.coregraphics.ArrowCtx",
    @"com.apple.coregraphics.Wait",
    @"com.apple.coregraphics.Empty",
    @"com.apple.coregraphics.ArrowS",
    @"com.apple.coregraphics.IBeamS",
    nil
};


BOOL LHIsTahoeOrLater(void) {
    static BOOL checked = NO;
    static BOOL isTahoe = NO;
    if (!checked) {
        NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
        isTahoe = (version.majorVersion >= 26);
        checked = YES;
    }
    return isTahoe;
}

NSArray *LHTahoeCursorAliasesForIdentifier(NSString *identifier) {
    if (!LHIsTahoeOrLater()) return nil;

    static NSDictionary *aliasMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aliasMap = @{
            @"com.apple.coregraphics.Arrow": @[ @"com.apple.coregraphics.ArrowS" ],
            @"com.apple.coregraphics.IBeam": @[ @"com.apple.coregraphics.IBeamS" ],
            @"com.apple.coregraphics.ArrowS": @[ @"com.apple.coregraphics.Arrow" ],
            @"com.apple.coregraphics.IBeamS": @[ @"com.apple.coregraphics.IBeam" ],
        };
    });

    return aliasMap[identifier];
}


NSArray *LHBrowserCursorAliasesForIdentifier(NSString *identifier) {
    static NSDictionary *browserAliasMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        browserAliasMap = @{
            @"com.apple.coregraphics.Arrow":    @[ @"com.apple.cursor.0" ],
            @"com.apple.cursor.0":              @[ @"com.apple.coregraphics.Arrow" ],
            @"com.apple.coregraphics.IBeam":    @[ @"com.apple.cursor.1" ],
            @"com.apple.cursor.1":              @[ @"com.apple.coregraphics.IBeam" ],
            @"com.apple.coregraphics.Alias":    @[ @"com.apple.cursor.2" ],
            @"com.apple.cursor.2":              @[ @"com.apple.coregraphics.Alias" ],
            @"com.apple.cursor.3":              @[ @"com.apple.coregraphics.NotAllowed" ],
            @"com.apple.coregraphics.Wait":     @[ @"com.apple.cursor.4" ],
            @"com.apple.cursor.4":              @[ @"com.apple.coregraphics.Wait" ],
            @"com.apple.coregraphics.Copy":     @[ @"com.apple.cursor.5" ],
            @"com.apple.cursor.5":              @[ @"com.apple.coregraphics.Copy" ],
            @"com.apple.cursor.7":              @[ @"com.apple.cursor.20" ],
            @"com.apple.cursor.8":              @[ @"com.apple.cursor.20" ],
            @"com.apple.cursor.20":             @[ @"com.apple.cursor.7" ],
            @"com.apple.cursor.9":              @[ @"com.apple.coregraphics.ScreenshotWindow" ],
            @"com.apple.cursor.10":             @[ @"com.apple.coregraphics.ScreenshotSelection" ],
            @"com.apple.cursor.11":             @[ @"com.apple.coregraphics.ClosedHand" ],
            @"com.apple.cursor.12":             @[ @"com.apple.coregraphics.OpenHand" ],
            @"com.apple.cursor.13":             @[ @"com.apple.coregraphics.PointingHand" ],
            @"com.apple.cursor.14":             @[ @"com.apple.coregraphics.CountingUpHand" ],
            @"com.apple.cursor.15":             @[ @"com.apple.coregraphics.CountingDownHand" ],
            @"com.apple.cursor.16":             @[ @"com.apple.coregraphics.CountingUpAndDownHand" ],
            @"com.apple.cursor.17":             @[ @"com.apple.coregraphics.ResizeLeft" ],
            @"com.apple.cursor.18":             @[ @"com.apple.coregraphics.ResizeRight" ],
            @"com.apple.cursor.19":             @[ @"com.apple.coregraphics.ResizeLeftRight" ],
            @"com.apple.cursor.21":             @[ @"com.apple.coregraphics.ResizeUp" ],
            @"com.apple.cursor.22":             @[ @"com.apple.coregraphics.ResizeDown" ],
            @"com.apple.cursor.23":             @[ @"com.apple.coregraphics.ResizeUpDown" ],
            @"com.apple.cursor.24":             @[ @"com.apple.coregraphics.ArrowCtx" ],
            @"com.apple.coregraphics.ArrowCtx": @[ @"com.apple.cursor.24" ],
            @"com.apple.cursor.25":             @[ @"com.apple.coregraphics.Poof" ],
            @"com.apple.cursor.26":             @[ @"com.apple.coregraphics.IBeamH" ],
            @"com.apple.cursor.27":             @[ @"com.apple.coregraphics.WindowResizeEast" ],
            @"com.apple.cursor.28":             @[ @"com.apple.coregraphics.WindowResizeEastWest" ],
            @"com.apple.cursor.29":             @[ @"com.apple.coregraphics.WindowResizeNortheast" ],
            @"com.apple.cursor.30":             @[ @"com.apple.coregraphics.WindowResizeNortheastSouthwest" ],
            @"com.apple.cursor.31":             @[ @"com.apple.coregraphics.WindowResizeNorth" ],
            @"com.apple.cursor.32":             @[ @"com.apple.coregraphics.WindowResizeNorthSouth" ],
            @"com.apple.cursor.33":             @[ @"com.apple.coregraphics.WindowResizeNorthwest" ],
            @"com.apple.cursor.34":             @[ @"com.apple.coregraphics.WindowResizeNorthwestSoutheast" ],
            @"com.apple.cursor.35":             @[ @"com.apple.coregraphics.WindowResizeSoutheast" ],
            @"com.apple.cursor.36":             @[ @"com.apple.coregraphics.WindowResizeSouth" ],
            @"com.apple.cursor.37":             @[ @"com.apple.coregraphics.WindowResizeSouthwest" ],
            @"com.apple.cursor.38":             @[ @"com.apple.coregraphics.WindowResizeWest" ],
            @"com.apple.coregraphics.Move":     @[ @"com.apple.cursor.39" ],
            @"com.apple.cursor.39":             @[ @"com.apple.coregraphics.Move" ],
            @"com.apple.cursor.40":             @[ @"com.apple.coregraphics.Help" ],
            @"com.apple.cursor.41":             @[ @"com.apple.coregraphics.Cell" ],
            @"com.apple.cursor.42":             @[ @"com.apple.coregraphics.ZoomIn" ],
            @"com.apple.cursor.43":             @[ @"com.apple.coregraphics.ZoomOut" ],
        };
    });

    return browserAliasMap[identifier];
}


NSData *lh_pngDataForImage(id image) {
    if (!image) return nil;

    CFTypeID typeID = CFGetTypeID((__bridge CFTypeRef)image);
    if (typeID == CGImageGetTypeID()) {
        CGImageRef obj = (__bridge CGImageRef)image;
        CFMutableDataRef mutableData = CFDataCreateMutable(kCFAllocatorDefault, 0);
        CGImageDestinationRef dest = CGImageDestinationCreateWithData(mutableData,
            (__bridge CFStringRef)UTTypePNG.identifier, 1, NULL);
        CGImageDestinationAddImage(dest, obj, NULL);
        CGImageDestinationFinalize(dest);
        CFRelease(dest);
        return CFBridgingRelease(mutableData);
    }

    if ([image isKindOfClass:[NSBitmapImageRep class]]) {
        return [(NSBitmapImageRep *)image representationUsingType:NSBitmapImageFileTypePNG
                                                      properties:@{}];
    }

    return nil;
}


@implementation NSBitmapImageRep (LHColorSpace)

- (NSBitmapImageRep *)lh_ensuredSRGBSpace {
    NSColorSpace *targetSpace = [NSColorSpace sRGBColorSpace];
    if (self.colorSpace != nil && self.colorSpace.numberOfColorComponents == 1) {
        targetSpace = [NSColorSpace genericGamma22GrayColorSpace];
    }
    NSBitmapImageRep *converted = [self bitmapImageRepByConvertingToColorSpace:targetSpace
                                                              renderingIntent:NSColorRenderingIntentDefault];
    return converted ?: self;
}

- (NSBitmapImageRep *)lh_retaggedSRGBSpace {
    NSColorSpace *targetSpace = [NSColorSpace sRGBColorSpace];
    if (self.colorSpace != nil && self.colorSpace.numberOfColorComponents == 1) {
        targetSpace = [NSColorSpace genericGamma22GrayColorSpace];
    }
    return [self bitmapImageRepByRetaggingWithColorSpace:targetSpace];
}

@end


BOOL LHIsRedPlaceholder(CGImageRef image) {
    if (!image) return YES;

    size_t w = CGImageGetWidth(image);
    size_t h = CGImageGetHeight(image);

    if (w > 32 || h > 32) return NO;

    CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    size_t bpr = w * 4;
    uint8_t *buf = calloc(h, bpr);
    CGContextRef ctx = CGBitmapContextCreate(buf, w, h, 8, bpr, cs,
                                             (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(ctx, CGRectMake(0, 0, w, h), image);

    BOOL allRed = YES;
    for (size_t i = 0; i < w * h && allRed; i++) {
        uint8_t r = buf[i * 4 + 0];
        uint8_t g = buf[i * 4 + 1];
        uint8_t b = buf[i * 4 + 2];
        uint8_t a = buf[i * 4 + 3];
        if (a == 0) continue;
        if (!(r == 255 && g == 0 && b == 0 && a == 255)) {
            allRed = NO;
        }
    }

    CGContextRelease(ctx);
    CGColorSpaceRelease(cs);
    free(buf);
    return allRed;
}


CGImageRef LHDownsampleSpriteSheetImage(CGImageRef spriteSheet, NSUInteger fromCount, NSUInteger toCount) {
    size_t width = CGImageGetWidth(spriteSheet);
    size_t totalHeight = CGImageGetHeight(spriteSheet);
    size_t frameHeight = totalHeight / fromCount;
    size_t newTotalHeight = frameHeight * toCount;

    CGContextRef ctx = CGBitmapContextCreate(NULL, width, newTotalHeight,
                                              CGImageGetBitsPerComponent(spriteSheet),
                                              0,
                                              CGImageGetColorSpace(spriteSheet),
                                              CGImageGetBitmapInfo(spriteSheet));
    if (!ctx) return NULL;

    double step = (double)(fromCount - 1) / (double)(toCount - 1);

    for (NSUInteger i = 0; i < toCount; i++) {
        NSUInteger sourceIndex = (NSUInteger)round((double)i * step);
        if (sourceIndex > fromCount - 1) sourceIndex = fromCount - 1;

        CGRect cropRect = CGRectMake(0, sourceIndex * frameHeight, width, frameHeight);
        CGImageRef frame = CGImageCreateWithImageInRect(spriteSheet, cropRect);
        if (frame) {
            CGRect dstRect = CGRectMake(0, i * frameHeight, width, frameHeight);
            CGContextDrawImage(ctx, dstRect, frame);
            CGImageRelease(frame);
        }
    }

    CGImageRef result = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return result;
}


static NSString *const kLHHIServicesCursorsPath =
    @"/System/Library/Frameworks/ApplicationServices.framework"
    @"/Versions/A/Frameworks/HIServices.framework"
    @"/Versions/A/Resources/cursors";

static NSDictionary<NSString *, NSString *> *LHCoreCursorToHIServicesMap(void) {
    static NSDictionary *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
            @"com.apple.cursor.2":  @"makealias",
            @"com.apple.cursor.3":  @"notallowed",
            @"com.apple.cursor.4":  @"busybutclickable",
            @"com.apple.cursor.5":  @"copy",
            @"com.apple.cursor.7":  @"cross",
            @"com.apple.cursor.8":  @"cross",
            @"com.apple.cursor.9":  @"screenshotwindow",
            @"com.apple.cursor.10": @"screenshotselection",
            @"com.apple.cursor.11": @"closedhand",
            @"com.apple.cursor.12": @"openhand",
            @"com.apple.cursor.13": @"pointinghand",
            @"com.apple.cursor.14": @"countinguphand",
            @"com.apple.cursor.15": @"countingdownhand",
            @"com.apple.cursor.16": @"countingupandownhand",
            @"com.apple.cursor.17": @"resizeleft",
            @"com.apple.cursor.18": @"resizeright",
            @"com.apple.cursor.19": @"resizeleftright",
            @"com.apple.cursor.20": @"cross",
            @"com.apple.cursor.21": @"resizeup",
            @"com.apple.cursor.22": @"resizedown",
            @"com.apple.cursor.23": @"resizeupdown",
            @"com.apple.cursor.24": @"contextualmenu",
            @"com.apple.cursor.25": @"poof",
            @"com.apple.cursor.26": @"ibeamvertical",
            @"com.apple.cursor.27": @"resizeeast",
            @"com.apple.cursor.28": @"resizeeastwest",
            @"com.apple.cursor.29": @"resizenortheast",
            @"com.apple.cursor.30": @"resizenortheastsouthwest",
            @"com.apple.cursor.31": @"resizenorth",
            @"com.apple.cursor.32": @"resizenorthsouth",
            @"com.apple.cursor.33": @"resizenorthwest",
            @"com.apple.cursor.34": @"resizenorthwestsoutheast",
            @"com.apple.cursor.35": @"resizesoutheast",
            @"com.apple.cursor.36": @"resizesouth",
            @"com.apple.cursor.37": @"resizesouthwest",
            @"com.apple.cursor.38": @"resizewest",
            @"com.apple.cursor.39": @"move",
            @"com.apple.cursor.40": @"help",
            @"com.apple.cursor.41": @"cell",
            @"com.apple.cursor.42": @"zoomin",
            @"com.apple.cursor.43": @"zoomout",
        };
    });
    return map;
}

static NSDictionary<NSString *, NSString *> *LHNamedCursorToHIServicesMap(void) {
    static NSDictionary *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
            @"com.apple.coregraphics.Alias":    @"makealias",
            @"com.apple.coregraphics.Copy":     @"copy",
            @"com.apple.coregraphics.ArrowCtx": @"contextualmenu",
            @"com.apple.coregraphics.Move":     @"move",
            @"com.apple.coregraphics.IBeam":    @"ibeamhorizontal",
            @"com.apple.coregraphics.IBeamXOR": @"ibeamhorizontal",
        };
    });
    return map;
}


static NSDictionary *LHCursorThemeFromHIServicesPDF(NSString *folderName) {
    NSString *cursorDir = [kLHHIServicesCursorsPath stringByAppendingPathComponent:folderName];
    NSString *pdfPath = [cursorDir stringByAppendingPathComponent:@"cursor.pdf"];
    NSString *infoPath = [cursorDir stringByAppendingPathComponent:@"info.plist"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) return nil;

    NSData *infoData = [NSData dataWithContentsOfFile:infoPath];
    if (!infoData) return nil;
    NSDictionary *info = [NSPropertyListSerialization propertyListWithData:infoData
                                                                  options:NSPropertyListImmutable
                                                                   format:NULL
                                                                    error:NULL];
    if (!info || ![info isKindOfClass:[NSDictionary class]]) return nil;

    CGFloat hotX = [info[@"hotx"] doubleValue];
    CGFloat hotY = [info[@"hoty"] doubleValue];
    NSInteger frames = [info[@"frames"] integerValue];
    if (frames < 1) frames = 1;
    CGFloat delay = [info[@"delay"] doubleValue];

    CGDataProviderRef provider = CGDataProviderCreateWithFilename(pdfPath.UTF8String);
    if (!provider) return nil;

    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
    CGDataProviderRelease(provider);
    if (!pdf) return nil;

    size_t pageCount = CGPDFDocumentGetNumberOfPages(pdf);
    if (pageCount == 0) {
        CGPDFDocumentRelease(pdf);
        return nil;
    }

    CGPDFPageRef page1 = CGPDFDocumentGetPage(pdf, 1);
    CGRect mediaBox = CGPDFPageGetBoxRect(page1, kCGPDFMediaBox);
    CGFloat pointsWide = mediaBox.size.width;
    CGFloat pointsHigh = mediaBox.size.height;

    if (frames > 1 && pageCount == 1) {
        pointsHigh = pointsHigh / frames;
    }

    int scales[] = { 1, 2 };
    int scaleCount = 2;
    NSMutableArray *imageReps = [NSMutableArray array];

    for (int s = 0; s < scaleCount; s++) {
        int scale = scales[s];
        NSUInteger imgW = (NSUInteger)(pointsWide * scale);
        NSUInteger totalH;

        if (frames > 1 && (NSInteger)pageCount >= frames) {
            totalH = (NSUInteger)(pointsHigh * scale * frames);
        } else if (frames > 1 && pageCount == 1) {
            totalH = (NSUInteger)(mediaBox.size.height * scale);
        } else {
            totalH = (NSUInteger)(pointsHigh * scale);
        }

        CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        CGContextRef ctx = CGBitmapContextCreate(NULL, imgW, totalH, 8,
                                                  imgW * 4, cs,
                                                  (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(cs);
        if (!ctx) continue;

        CGContextClearRect(ctx, CGRectMake(0, 0, imgW, totalH));

        if (frames > 1 && (NSInteger)pageCount >= frames) {
            for (NSInteger f = 0; f < frames && f < (NSInteger)pageCount; f++) {
                CGPDFPageRef page = CGPDFDocumentGetPage(pdf, f + 1);
                if (!page) continue;
                CGContextSaveGState(ctx);
                CGFloat yOffset = (frames - 1 - f) * pointsHigh * scale;
                CGContextTranslateCTM(ctx, 0, yOffset);
                CGContextScaleCTM(ctx, scale, scale);
                CGContextDrawPDFPage(ctx, page);
                CGContextRestoreGState(ctx);
            }
        } else {
            CGContextScaleCTM(ctx, scale, scale);
            CGContextDrawPDFPage(ctx, page1);
        }

        CGImageRef rendered = CGBitmapContextCreateImage(ctx);
        CGContextRelease(ctx);

        if (rendered) {
            [imageReps addObject:(__bridge_transfer id)rendered];
        }
    }

    CGPDFDocumentRelease(pdf);

    if (imageReps.count == 0) return nil;

    return @{
        @"FrameCount":      @(frames),
        @"FrameDuration":   @(delay),
        @"HotSpotX":        @(hotX),
        @"HotSpotY":        @(hotY),
        @"PointsWide":      @(pointsWide),
        @"PointsHigh":      @(pointsHigh),
        @"Representations": imageReps,
    };
}


CGError LHIsCursorRegistered(CGSConnectionID cid, char *cursorName, bool *registered) {
    size_t size = 0;
    CGError err = CGSGetRegisteredCursorDataSize(cid, cursorName, &size);
    *registered = !((BOOL)err) && size > 0;
    return err;
}


static BOOL LHFetchCursorImages(CGSConnectionID cid, NSString *identifier,
                                 CGSize *outSize, CGPoint *outHotSpot,
                                 NSUInteger *outFrameCount, CGFloat *outFrameDuration,
                                 CFArrayRef *outRepresentations) {
    CGError error;
    if (![identifier hasPrefix:@"com.apple.cursor."]) {
        bool registered = false;
        LHIsCursorRegistered(cid, (char *)identifier.UTF8String, &registered);
        if (!registered) return NO;
        error = CGSCopyRegisteredCursorImages(cid, (char *)identifier.UTF8String,
                                               outSize, outHotSpot, outFrameCount,
                                               outFrameDuration, outRepresentations);
    } else {
        int cursorID = [[identifier pathExtension] intValue];
        error = CoreCursorCopyImages(cid, cursorID,
                                      outRepresentations, outSize, outHotSpot,
                                      outFrameCount, outFrameDuration);
    }
    return (error == kCGErrorSuccess && *outRepresentations && CFArrayGetCount(*outRepresentations) > 0);
}


NSDictionary *LHCaptureCursorTheme(CGSConnectionID cid, NSString *identifier) {
    NSUInteger frameCount = 0;
    CGFloat frameDuration = 0.0;
    CGPoint hotSpot = CGPointZero;
    CGSize size = CGSizeZero;
    CFArrayRef representations = NULL;

    if (!LHFetchCursorImages(cid, identifier, &size, &hotSpot,
                              &frameCount, &frameDuration, &representations)) {
        return nil;
    }

    NSArray *cgImages = CFBridgingRelease(representations);
    CGImageRef firstImg = (__bridge CGImageRef)cgImages[0];

    BOOL isBadData = LHIsRedPlaceholder(firstImg);

    if (!isBadData) {
        size_t imgW = CGImageGetWidth(firstImg);
        size_t imgH = CGImageGetHeight(firstImg);
        if (imgH < (size_t)size.height || imgW < (size_t)size.width) {
            isBadData = YES;
            LHLog(LH_BOLD LH_YELLOW "  Degenerate image for %s: %zux%zu (expected >= %.0fx%.0f)" LH_RESET,
                  identifier.UTF8String, imgW, imgH, size.width, size.height);
        }
    }

    if (!isBadData && ![identifier hasPrefix:@"com.apple.cursor."]) {
        NSString *hiName = LHNamedCursorToHIServicesMap()[identifier];
        if (hiName) {
            isBadData = YES;
            LHLog(LH_BOLD LH_YELLOW "  Named cursor %s — forcing HIServices PDF (CGS data unreliable)" LH_RESET,
                  identifier.UTF8String);
        }
    }

    if (isBadData) {
        if ([identifier hasPrefix:@"com.apple.cursor."]) {
            float currentScale;
            CGSGetCursorScale(cid, &currentScale);
            if (currentScale > 1.0f) {
                LHLog(LH_BOLD LH_YELLOW "  Bad data for %s at %.0fx, retrying at 1x..." LH_RESET,
                      identifier.UTF8String, currentScale);
                CGSSetCursorScale(cid, 1.0f);

                NSUInteger retryFC = 0;
                CGFloat retryDur = 0.0;
                CGPoint retryHot = CGPointZero;
                CGSize retrySize = CGSizeZero;
                CFArrayRef retryReps = NULL;

                int cursorID = [[identifier pathExtension] intValue];
                CGError retryErr = CoreCursorCopyImages(cid, cursorID,
                    &retryReps, &retrySize, &retryHot, &retryFC, &retryDur);

                CGSSetCursorScale(cid, currentScale);

                if (retryErr == kCGErrorSuccess && retryReps && CFArrayGetCount(retryReps) > 0) {
                    NSArray *retryImages = CFBridgingRelease(retryReps);
                    CGImageRef retryFirst = (__bridge CGImageRef)retryImages[0];

                    if (!LHIsRedPlaceholder(retryFirst)) {
                        size_t rw = CGImageGetWidth(retryFirst);
                        size_t rh = CGImageGetHeight(retryFirst);
                        if (rh >= (size_t)retrySize.height && rw >= (size_t)retrySize.width) {
                            LHLog(LH_BOLD LH_GREEN "  1x retry succeeded for %s (%zux%zu)" LH_RESET,
                                  identifier.UTF8String, rw, rh);

                            return @{
                                @"FrameCount":       @(retryFC),
                                @"FrameDuration":    @(retryDur),
                                @"HotSpotX":         @(retryHot.x),
                                @"HotSpotY":         @(retryHot.y),
                                @"PointsWide":       @(retrySize.width),
                                @"PointsHigh":       @(retrySize.height),
                                @"Representations":  retryImages,
                            };
                        }
                    }
                } else {
                    if (retryReps) CFRelease(retryReps);
                }
            }
        }

        NSString *hiName = nil;
        if ([identifier hasPrefix:@"com.apple.cursor."]) {
            hiName = LHCoreCursorToHIServicesMap()[identifier];
        } else {
            hiName = LHNamedCursorToHIServicesMap()[identifier];
        }
        if (hiName) {
            LHLog(LH_BOLD LH_CYAN "  Falling back to HIServices/%s for %s" LH_RESET,
                  hiName.UTF8String, identifier.UTF8String);
            NSDictionary *hiTheme = LHCursorThemeFromHIServicesPDF(hiName);
            if (hiTheme) return hiTheme;
        }

        LHLog(LH_BOLD LH_RED "  All recovery failed for %s, skipping" LH_RESET,
              identifier.UTF8String);
        return nil;
    }

    return @{
        @"FrameCount":       @(frameCount),
        @"FrameDuration":    @(frameDuration),
        @"HotSpotX":         @(hotSpot.x),
        @"HotSpotY":         @(hotSpot.y),
        @"PointsWide":       @(size.width),
        @"PointsHigh":       @(size.height),
        @"Representations":  cgImages,
    };
}

