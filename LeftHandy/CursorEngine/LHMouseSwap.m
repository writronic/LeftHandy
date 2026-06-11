#import "LHMouseSwap.h"
#import "LHCursorDefs.h"
#import <ApplicationServices/ApplicationServices.h>

static CFMachPortRef sEventTap = NULL;
static CFRunLoopSourceRef sRunLoopSource = NULL;
static BOOL sIsRunning = NO;


static CGEventRef mouseSwapCallback(CGEventTapProxy proxy,
                                     CGEventType type,
                                     CGEventRef event,
                                     void *userInfo)
{
    if (type == kCGEventTapDisabledByTimeout || type == kCGEventTapDisabledByUserInput) {
        if (sEventTap) {
            CGEventTapEnable(sEventTap, true);
        }
        return event;
    }

    switch (type) {
        case kCGEventLeftMouseDown:
            CGEventSetType(event, kCGEventRightMouseDown);
            CGEventSetIntegerValueField(event, kCGMouseEventButtonNumber, kCGMouseButtonRight);
            break;

        case kCGEventLeftMouseUp:
            CGEventSetType(event, kCGEventRightMouseUp);
            CGEventSetIntegerValueField(event, kCGMouseEventButtonNumber, kCGMouseButtonRight);
            break;

        case kCGEventLeftMouseDragged:
            CGEventSetType(event, kCGEventRightMouseDragged);
            CGEventSetIntegerValueField(event, kCGMouseEventButtonNumber, kCGMouseButtonRight);
            break;

        case kCGEventRightMouseDown:
            CGEventSetType(event, kCGEventLeftMouseDown);
            CGEventSetIntegerValueField(event, kCGMouseEventButtonNumber, kCGMouseButtonLeft);
            break;

        case kCGEventRightMouseUp:
            CGEventSetType(event, kCGEventLeftMouseUp);
            CGEventSetIntegerValueField(event, kCGMouseEventButtonNumber, kCGMouseButtonLeft);
            break;

        case kCGEventRightMouseDragged:
            CGEventSetType(event, kCGEventLeftMouseDragged);
            CGEventSetIntegerValueField(event, kCGMouseEventButtonNumber, kCGMouseButtonLeft);
            break;

        default:
            break;
    }

    return event;
}


BOOL LHMouseSwapStart(void) {
    if (sIsRunning) {
        LHLog(LH_BOLD LH_YELLOW "Mouse swap already running" LH_RESET);
        return YES;
    }

    CGEventMask eventMask =
        (1 << kCGEventLeftMouseDown)  |
        (1 << kCGEventLeftMouseUp)    |
        (1 << kCGEventLeftMouseDragged) |
        (1 << kCGEventRightMouseDown) |
        (1 << kCGEventRightMouseUp)   |
        (1 << kCGEventRightMouseDragged);

    sEventTap = CGEventTapCreate(
        kCGHIDEventTap,
        kCGHeadInsertEventTap,
        kCGEventTapOptionDefault,
        eventMask,
        mouseSwapCallback,
        NULL
    );

    if (!sEventTap) {
        LHLog(LH_BOLD LH_RED "Failed to create EventTap — Accessibility permission required" LH_RESET);
        return NO;
    }

    sRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, sEventTap, 0);
    if (!sRunLoopSource) {
        LHLog(LH_BOLD LH_RED "Failed to create RunLoop source" LH_RESET);
        CFRelease(sEventTap);
        sEventTap = NULL;
        return NO;
    }

    CFRunLoopAddSource(CFRunLoopGetCurrent(), sRunLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(sEventTap, true);

    sIsRunning = YES;
    LHLog(LH_BOLD LH_GREEN "Mouse button swap started" LH_RESET);
    return YES;
}

void LHMouseSwapStop(void) {
    if (!sIsRunning) return;

    if (sEventTap) {
        CGEventTapEnable(sEventTap, false);
    }

    if (sRunLoopSource) {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), sRunLoopSource, kCFRunLoopCommonModes);
        CFRelease(sRunLoopSource);
        sRunLoopSource = NULL;
    }

    if (sEventTap) {
        CFRelease(sEventTap);
        sEventTap = NULL;
    }

    sIsRunning = NO;
    LHLog(LH_BOLD LH_GREEN "Mouse button swap stopped" LH_RESET);
}

BOOL LHMouseSwapIsRunning(void) {
    return sIsRunning;
}
