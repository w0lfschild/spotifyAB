//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Jun  3 2014 10:55:11).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

#import "NSApplicationDelegate.h"

@class ClientMenuHandler, NSTextField, SPTFullScreenBackdrop;

@interface ClientAppDelegate : NSObject <NSApplicationDelegate>
{
    BOOL appHasBeenCreated;
    BOOL shuttingDown;
    BOOL isFullscreen;
    SPTFullScreenBackdrop *fullscreen_toggle_button_;
    NSTextField *title_text_field_;
    ClientMenuHandler *menu_handler;
}

@property(readonly, getter=isFullscreen) BOOL isFullscreen; // @synthesize isFullscreen;
- (BOOL)applicationShouldHandleReopen:(id)arg1 hasVisibleWindows:(BOOL)arg2;
- (void)handleURLEvent:(id)arg1 withReplyEvent:(id)arg2;
- (void)applicationDidBecomeActive:(id)arg1;
- (void)showMainWindow;
- (void)applicationWillFinishLaunching:(id)arg1;
- (void)handleOpenApplicationEvent:(id)arg1 replyEvent:(id)arg2;
- (unsigned long long)applicationShouldTerminate:(id)arg1;
- (void)tryToTerminateApplication:(id)arg1;
- (void)updateMenu;
- (void)setLoggedIn:(id)arg1;
- (id)applicationDockMenu:(id)arg1;
- (void)preferredScrollerStyleChanged:(id)arg1;
- (void)willExitFull:(id)arg1;
- (void)willEnterFull:(id)arg1;
- (void)dealloc;
- (void)applicationDidChangeOcclusionState:(id)arg1;
- (void)setupScrollerStyleListener;
- (void)setupFullscreenSupportForWindow:(id)arg1;
- (void)createApp:(id)arg1;
- (void)createHiddenTitleFieldInWindow:(id)arg1;
- (BOOL)isShuttingDown;

@end

