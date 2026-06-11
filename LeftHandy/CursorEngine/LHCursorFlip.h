#pragma once
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern BOOL LHCaptureSystemCursors(void);

extern BOOL LHApplyFlippedCursors(void);

extern BOOL LHRestoreCursors(void);

extern void LHFinalizeCursorApply(void);

extern void LHForceCursorVisualRefresh(void);

extern BOOL LHCursorRequiresFlip(NSString *identifier);

NS_ASSUME_NONNULL_END
