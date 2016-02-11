//
//  main.m
//  spotiHack
//
//  Created by Wolfgang Baird on 2/5/16.
//  Copyright © 2016 Wolfgang Baird. All rights reserved.
//

#import "main.h"

struct TrackMetadata;

main *plugin;
NSArray *menuItems;
NSImage *myImage;
//NSUserDefaults *sharedPrefs;
//NSDictionary *sharedDict;
bool showArt = true;
bool muteAds = true;
int iconArt = 0;

@implementation main

+ (main*) sharedInstance
{
    static main* plugin = nil;
    
    if (plugin == nil)
        plugin = [[main alloc] init];
    
    return plugin;
}

+ (void)load
{
    plugin = [main sharedInstance];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [plugin pollThread];
        dispatch_async(dispatch_get_main_queue(), ^{
            //
        });
    });
    NSApplication *application = [NSApplication sharedApplication];
    NSMenu *menu = application.windowsMenu;
    
    NSMenuItem *mainItem = [[NSMenuItem alloc] init];
    [mainItem setTitle:@"spotifyAB"];
    
    NSMenu *submenu = [[NSMenu alloc] init];
    [submenu addItemWithTitle:@"Mute Audio Ads" action:@selector(setMuting:) keyEquivalent:@""];
    [[submenu addItemWithTitle:@"Disable icon art" action:@selector(setIconArt:) keyEquivalent:@""] setTarget:plugin];
    [[submenu addItemWithTitle:@"Stock icon art" action:@selector(setIconArt:) keyEquivalent:@""] setTarget:plugin];
    [[submenu addItemWithTitle:@"Tilted icon art" action:@selector(setIconArt:) keyEquivalent:@""] setTarget:plugin];
    [[submenu addItemWithTitle:@"Circular icon art" action:@selector(setIconArt:) keyEquivalent:@""] setTarget:plugin];
    
    if (menuItems == nil)
        menuItems = [submenu itemArray];
    
    [mainItem setSubmenu:submenu];
    
//    NSMenuItem *myitem = [[NSMenuItem alloc] initWithTitle:@"spotifyAB" action:@selector(wb_refreshmyTabs) keyEquivalent:@"X"];
//    [myitem setKeyEquivalentModifierMask: NSCommandKeyMask];
//    [myitem setTarget:plugin];
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:mainItem];
    NSLog(@"spotiHack loaded...");
}

- (IBAction)setMuting:(id)sender
{
    
}

- (IBAction)setIconArt:(id)sender
{
    if ([menuItems containsObject:sender])
    {
        if ([menuItems indexOfObject:sender] == 2)
            iconArt = 2;
        if ([menuItems indexOfObject:sender] == 3)
            iconArt = 1;
        if ([menuItems indexOfObject:sender] == 4)
            iconArt = 0;
        
        if ([menuItems indexOfObject:sender] == 1)
        {
            [NSApp setApplicationIconImage:nil];
            showArt = !showArt;
            [[menuItems objectAtIndex:1] setState:!showArt];
        }
        
        if ([menuItems indexOfObject:sender] >= 2)
        {
            NSImage *modifiedIcon = [plugin createIconImage:myImage :iconArt];
            [NSApp setApplicationIconImage:modifiedIcon];
        }
    }
}

- (NSString*) runCommand:(NSString*)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    //    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

- (NSImage*)imageRotatedByDegrees:(CGFloat)degrees :(NSImage*)img
{
    NSSize    size = [img size];
    NSSize    newSize = NSMakeSize( size.width + 40,
                                   size.height + 40 );
    
//    NSSize rotatedSize = NSMakeSize(img.size.height, img.size.width) ;
    NSImage* rotatedImage = [[NSImage alloc] initWithSize:newSize] ;
    
    NSAffineTransform* transform = [NSAffineTransform transform] ;
    
    // In order to avoid clipping the image, translate
    // the coordinate system to its center
//    [transform translateXBy:+img.size.width/2
//                        yBy:+img.size.height/2] ;
    
    [transform translateXBy:img.size.width / 2
                        yBy:img.size.height / 2];
    
    // then rotate
    [transform rotateByDegrees:degrees] ;
    
    // Then translate the origin system back to
    // the bottom left
    [transform translateXBy:-size.width/2
                        yBy:-size.height/2] ;
    
//
    
    [rotatedImage lockFocus] ;
    [transform concat] ;
    [img drawAtPoint:NSMakePoint(15,10)
             fromRect:NSZeroRect
            operation:NSCompositeCopy
             fraction:1.0] ;
    [rotatedImage unlockFocus] ;
    
    return rotatedImage;
}

- (CGImageRef)createCGImageFromFile:(NSString*)path
{
    // Get the URL for the pathname passed to the function.
    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageRef        myImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[2];
    CFTypeRef         myValues[2];
    
    // Set up options if you want them. The options here are for
    // caching the image in a decoded form and for using floating-point
    // values if the image format supports them.
    myKeys[0] = kCGImageSourceShouldCache;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceShouldAllowFloat;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    // Create the dictionary
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   & kCFTypeDictionaryValueCallBacks);
    // Create an image source from the URL.
    myImageSource = CGImageSourceCreateWithURL((CFURLRef)url, myOptions);
    CFRelease(myOptions);
    // Make sure the image source exists before continuing
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    // Create an image from the first item in the image source.
    myImage = CGImageSourceCreateImageAtIndex(myImageSource,
                                              0,
                                              NULL);
    
    CFRelease(myImageSource);
    // Make sure the image exists before continuing
    if (myImage == NULL){
        fprintf(stderr, "Image not created from image source.");
        return NULL;
    }
    
    return myImage;
}

- (NSImage*)createIconImage:(NSImage*)stockCover :(int)resultType
{
    // 0 = rounded
    // 1 = tilded
    // 2 = square
//    NSString *myLittleCLIToolPath = NSProcessInfo.processInfo.arguments[0];
    NSString *maskPath = @"/Library/Application Support/SIMBL/Plugins/spotiHack.bundle/Contents/Resources/ModernMask.tif";
    NSString *overlayPath = @"/Library/Application Support/SIMBL/Plugins/spotiHack.bundle/Contents/Resources/ModernOverlay.png";
    NSImage *resultIMG = [[NSImage alloc] init];
    
    if (resultType == 0)
    {
        [[stockCover TIFFRepresentation] writeToFile:@"/tmp/spotifyCover.tif" atomically:YES];
        CGImageRef imgRef = [plugin createCGImageFromFile:@"/tmp/spotifyCover.tif"];
//        CGImageRef maskRef = [plugin createCGImageFromFile:@"/Users/w0lf/Desktop/ModernMask.tif"];
        CGImageRef maskRef = [plugin createCGImageFromFile:maskPath];
        CGImageRef actualMask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                                  CGImageGetHeight(maskRef),
                                                  CGImageGetBitsPerComponent(maskRef),
                                                  CGImageGetBitsPerPixel(maskRef),
                                                  CGImageGetBytesPerRow(maskRef),
                                                  CGImageGetDataProvider(maskRef), NULL, false);
        CGImageRef masked = CGImageCreateWithMask(imgRef, actualMask);
        NSImage *rounded = [[NSImage alloc] initWithCGImage:masked size:NSZeroSize];
        NSImage *background = rounded;
//        NSImage *overlay = [[NSImage alloc] initByReferencingFile:@"/Users/w0lf/Desktop/ModernOverlay.png"];
        NSImage *overlay = [[NSImage alloc] initByReferencingFile:overlayPath];
        NSImage *newImage = [[NSImage alloc] initWithSize:[background size]];
        [newImage lockFocus];
        CGRect newImageRect = CGRectZero;
        newImageRect.size = [newImage size];
        [background drawInRect:newImageRect];
        [overlay drawInRect:newImageRect];
        [newImage unlockFocus];
        resultIMG = newImage;
    }
    else if (resultType == 1)
    {
        NSSize dims = [[NSApp dockTile] size];
        dims.width *= 0.9;
        dims.height *= 0.9;
        NSImage *smallImage = [[NSImage alloc] initWithSize: dims];
        [smallImage lockFocus];
        [stockCover setSize: dims];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [stockCover drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, dims.width, dims.height) operation:NSCompositeCopy fraction:1.0];
        [smallImage unlockFocus];
        smallImage = [plugin imageRotatedByDegrees:15.00 :smallImage];
        resultIMG = smallImage;
    }
    else
    {
        resultIMG = stockCover;
    }
    return resultIMG;
}

- (void)pollThread
{
    // playerState
    // 1 playing
    // 2 paused
    usleep(10000000);
    ClientApplication *thisApp = [NSApplication sharedApplication];
    NSString *currentTrack = [[NSString alloc] init];
    NSImage *trackImage = [[NSImage alloc] init];
    NSNumber *appVolume = [thisApp soundVolume];
    bool imageFetched = false;
    bool isAD = false;
    bool isMuted = false;
    bool isPaused = false;
    
    while (true) {
        NSNumber *playState = thisApp.playerState;
        if ([playState isEqualToNumber:[NSNumber numberWithInt:2]]) {
            [NSApp setApplicationIconImage:nil];
            [[NSApp dockTile] setBadgeLabel:nil];
            isPaused = true;
            if (isMuted)
            {
                isMuted = false;
                [thisApp setSoundVolume:appVolume];
            }
        } else {
            SPAppleScriptTrack *track = [thisApp currentTrack];
            NSString *trackURL = track.spotifyURL;
            
            NSRange range = [trackURL rangeOfString:@"spotify:ad"];
            if(range.location != NSNotFound) {
                isAD = true;
            } else {
                isAD = false;
            }
            
            if (isAD)
            {
                if (!isMuted)
                {
                    isMuted = true;
                    appVolume = [thisApp soundVolume];
                    [thisApp setSoundVolume:[NSNumber numberWithInt:0]];
                    [[NSApp dockTile] setBadgeLabel:@"Muted"];
                    [NSApp setApplicationIconImage:nil];
                }
            } else {
                if (isMuted)
                {
                    isMuted = false;
                    [thisApp setSoundVolume:appVolume];
                    [[NSApp dockTile] setBadgeLabel:nil];
                }
                
                if (showArt)
                {
                    if (![currentTrack isEqualToString:trackURL])
                    {
                        currentTrack = [NSString stringWithFormat:@"%@", trackURL];
                        NSString *combinedURL = [NSString stringWithFormat:@"https://embed.spotify.com/oembed/?url=%@", trackURL];
                        NSURL *targetURL = [NSURL URLWithString:combinedURL];
                        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
                        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                        NSString *fixedString = [dataString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                        fixedString = [fixedString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        NSArray *urlComponents = [fixedString componentsSeparatedByString:@","];
                        NSString *iconURL = @"";
                        if ([urlComponents count] >= 7)
                            iconURL = [urlComponents objectAtIndex:7];
                        NSArray *iconComponents = [iconURL componentsSeparatedByString:@":"];
                        NSString *iconURLFixed = [NSString stringWithFormat:@"https:%@", [iconComponents lastObject]];
                        myImage = [[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconURLFixed]]];
                        NSLog(@"%@", iconURLFixed);
                        
                        if ( myImage )
                        {
                            NSImage *modifiedIcon = [plugin createIconImage:myImage :iconArt];
                            [NSApp setApplicationIconImage:modifiedIcon];
                            trackImage = modifiedIcon;
                            imageFetched = true;
                        } else {
                            imageFetched = false;
                        }
                    } else {
                        if (imageFetched)
                            if (isPaused) {
                                [NSApp setApplicationIconImage:trackImage];
                            }
                    }
                }
            }
            isPaused = false;
            usleep(3000000);
        }
    }
}

@end

