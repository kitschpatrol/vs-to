//
//  main.m
//  vs to ...
//
//  Adapted by Eric Mika from "cd to..." created by James Tuley on 2/16/07.
//  Copyright Jay Tuley 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Finder.h"

NSString* getPathForFinderItem(FinderItem *item) {
    NSURL* url =[NSURL URLWithString:item.URL];
    NSError* error;
    NSData* bookmark = [NSURL bookmarkDataWithContentsOfURL:url error:nil];
    NSURL* fullUrl = [NSURL URLByResolvingBookmarkData:bookmark
                                               options:NSURLBookmarkResolutionWithoutUI
                                         relativeToURL:nil
                                   bookmarkDataIsStale:nil
                                                 error:&error];
    if(fullUrl != nil){
        url = fullUrl;
    }
    NSString* path = [[url path] stringByExpandingTildeInPath];
    return path;
}

NSArray<NSString*>* getPathsSelectedInFrontFinderWindow() {
    FinderApplication* finder =
    [SBApplication applicationWithBundleIdentifier:@"com.apple.finder"];
    
    SBElementArray* selection = [[finder selection] get];
    
    
    
    if ([selection count] == 0) {
        // Pass the finder window path if no files are selected
        FinderItem *window = [[[[finder FinderWindows] firstObject] target] get];
        NSString* path = getPathForFinderItem(window);
        return [NSArray arrayWithObject:path];
    }
    else {
        // URL-ify all selected items in foreground window
        NSMutableArray *paths = [NSMutableArray array];
        for (FinderItem *item in selection) {
            NSString* path = getPathForFinderItem(item);
            [paths addObject:path];
        }
        return [NSArray arrayWithArray:paths];
    }
}


int main(int argc, char *argv[])
{
    @autoreleasepool{
        NSArray* paths;
        @try{
            paths = getPathsSelectedInFrontFinderWindow();
        }@catch(id ex){
            // Default to opening the desktop if we somehow don't have a finder window open (unlikely!)
            paths = [NSArray arrayWithObject:[@"~/Desktop" stringByExpandingTildeInPath]];
        }
        
        @try{
            [[NSTask launchedTaskWithLaunchPath:@"/usr/local/bin/code"
                                      arguments:[@[@"-n"] arrayByAddingObjectsFromArray:paths]] waitUntilExit];;
            
            // Alternate approach launching Visual Studio Code directly may be used if you haven't installed the code tool
            // doesn't work as well when selecting a mix of files and folders
            // NSTask* task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open"
            // arguments:[@[@"-n", @"-b", @"com.microsoft.VSCode", @"--args"] arrayByAddingObjectsFromArray:paths]];
        }
        @catch(id ex) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSAlertStyleCritical];
            [alert setMessageText:@"Are you sure the Visual Studio Code command line tool is installed and available at “/usr/local/bin/code”?"];
            [alert addButtonWithTitle:@"I’ll Check"];
            [alert runModal];
        }
    }
    return 0;
}
