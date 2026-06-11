#pragma once

#import <Cocoa/Cocoa.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "CGSPrivateCursor.h"
#import "CGSPrivateAccessibility.h"

#define LHLog(format, ...) fprintf(stdout, format "\n", ## __VA_ARGS__)

#define LH_RESET   "\033[0m"
#define LH_RED     "\033[31m"
#define LH_GREEN   "\033[32m"
#define LH_YELLOW  "\033[33m"
#define LH_CYAN    "\033[36m"
#define LH_BOLD    "\033[1m"

static const float LHCursorRefreshScaleBump = 0.1f;
static const float LHDumpCursorScale = 2.0f;

extern NSString * _Nonnull LHDefaultCursors[];

NS_ASSUME_NONNULL_BEGIN

extern NSArray * _Nullable LHTahoeCursorAliasesForIdentifier(NSString *identifier);

extern NSArray * _Nullable LHBrowserCursorAliasesForIdentifier(NSString *identifier);

extern BOOL LHIsTahoeOrLater(void);

extern NSDictionary * _Nullable LHCaptureCursorTheme(CGSConnectionID cid, NSString *identifier);

extern BOOL LHIsRedPlaceholder(CGImageRef image);

extern NSData * _Nullable lh_pngDataForImage(id image);

extern CGImageRef _Nullable LHDownsampleSpriteSheetImage(CGImageRef spriteSheet, NSUInteger fromCount, NSUInteger toCount);

@interface NSBitmapImageRep (LHColorSpace)
- (NSBitmapImageRep *)lh_ensuredSRGBSpace;
- (NSBitmapImageRep *)lh_retaggedSRGBSpace;
@end

NS_ASSUME_NONNULL_END

