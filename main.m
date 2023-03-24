//
//  main.m
//  vs to ...
//
//  Created by James Tuley on 2/16/07.
//  Copyright Jay Tuley 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Finder.h"

NSString* getPathToFrontFinderWindow(){
	
	FinderApplication* finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.Finder"];
    
	FinderItem *target = [(NSArray*)[[finder selection]get] firstObject];
    if (target == nil){
        target = [[[[finder FinderWindows] firstObject] target] get];
    }
	
	NSURL* url =[NSURL URLWithString:target.URL];
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

    BOOL isDir = NO;
   [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];

    
    
	if(!isDir){
		path = [path stringByDeletingLastPathComponent];
	}

	return path;
}



int main(int argc, char *argv[])
{
    @autoreleasepool{
        NSString* path;
        @try{
            path = getPathToFrontFinderWindow();
        }@catch(id ex){
            path =[@"~/Desktop" stringByExpandingTildeInPath];
        }
        
        [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/open" arguments:@[@"-n", @"-b" ,@"com.microsoft.VSCode", @"--args", path]] waitUntilExit];
          
        
//        [[NSWorkspace sharedWorkspace] openFile:path withApplication:@"Terminal"];
    }
    return 0;
}



