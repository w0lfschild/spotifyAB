//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Jun  3 2014 10:55:11).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSWindow.h"

@class NSImageView, NSProgressIndicator, NSTextView;

@interface MigrationProgressWindow : NSWindow
{
    NSImageView *_imageView;
    NSProgressIndicator *_progressBar;
    NSTextView *_messageText;
    NSTextView *_informativeText;
    struct CacheMigrator *_migrator;
}

- (void)update:(id)arg1;
- (void)start:(struct CacheMigrator *)arg1;
- (id)init;

@end

