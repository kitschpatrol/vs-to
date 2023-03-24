//
//  FinderSync.m
//  cd to finder menu item
//
//  Created by Yuji on 2018/09/20.
//

#import "FinderSync.h"

@interface FinderSync ()

@property NSURL *myFolderURL;

@end

@implementation FinderSync

- (instancetype)init {
    self = [super init];

    NSLog(@"%s launched from %@ ; compiled at %s", __PRETTY_FUNCTION__, [[NSBundle mainBundle] bundlePath], __TIME__);

    // Set up the directory we are syncing.
    self.myFolderURL = [NSURL fileURLWithPath:[@"~" stringByExpandingTildeInPath]];
    [FIFinderSyncController defaultController].directoryURLs = [NSSet setWithObject:self.myFolderURL];

    // Set up images for our badge identifiers. For demonstration purposes, this uses off-the-shelf images.
    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed: NSImageNameColorPanel] label:@"Status One" forBadgeIdentifier:@"One"];
    [[FIFinderSyncController defaultController] setBadgeImage:[NSImage imageNamed: NSImageNameCaution] label:@"Status Two" forBadgeIdentifier:@"Two"];
    
    return self;
}

#pragma mark - Primary Finder Sync protocol methods

- (void)beginObservingDirectoryAtURL:(NSURL *)url {
    // The user is now seeing the container's contents.
    // If they see it in more than one view at a time, we're only told once.
    NSLog(@"beginObservingDirectoryAtURL:%@", url.filePathURL);
}


- (void)endObservingDirectoryAtURL:(NSURL *)url {
    // The user is no longer seeing the container's contents.
    NSLog(@"endObservingDirectoryAtURL:%@", url.filePathURL);
}

- (void)requestBadgeIdentifierForURL:(NSURL *)url {
    NSLog(@"requestBadgeIdentifierForURL:%@", url.filePathURL);
    
    // For demonstration purposes, this picks one of our two badges, or no badge at all, based on the filename.
    NSInteger whichBadge = [url.filePathURL hash] % 3;
    NSString* badgeIdentifier = @[@"", @"One", @"Two"][whichBadge];
    [[FIFinderSyncController defaultController] setBadgeIdentifier:badgeIdentifier forURL:url];
}

#pragma mark - Menu and toolbar item support

- (NSString *)toolbarItemName {
    return @"cd to this folder";
}

- (NSString *)toolbarItemToolTip {
    return @"cd to this folder";
}

- (NSImage *)toolbarItemImage {
    if(@available(macOS 11,*)){
        return [NSImage imageWithSystemSymbolName:@"chevron.forward.2" accessibilityDescription:@"open terminal on this folder"];
    }else{
        NSImage* image=[NSImage imageNamed:@"foo"];
        image.template=YES;
        return image;
    }
}

- (NSMenu *)menuForMenuKind:(FIMenuKind)whichMenu {
    // Produce a menu for the extension.
    [[NSWorkspace sharedWorkspace] openFile:@"" withApplication:@"cd to"];

    return nil;
}

- (IBAction)sampleAction:(id)sender {
    NSURL* target = [[FIFinderSyncController defaultController] targetedURL];
    NSArray* items = [[FIFinderSyncController defaultController] selectedItemURLs];

    NSLog(@"sampleAction: menu item: %@, target = %@, items = ", [sender title], [target filePathURL]);
    [items enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"    %@", [obj filePathURL]);
    }];
}

@end

