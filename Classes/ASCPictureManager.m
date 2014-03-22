//
//  ASCPictureManager.m
//  Portfolio
//
//  Created by Aurélien Scelles on 15/03/2014.
//  Copyright (c) 2014 celor
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "ASCPictureManager.h"
#import <CoreData/CoreData.h>

@interface ASCImageCache : NSCache
+ (ASCImageCache *)sharedCache;
- (UIImage *)cachedImageForURLString:(NSString *)url;
- (void)cacheImage:(UIImage *)image
      forURLString:(NSString *)url;
@end

@interface ASCPictureManager () <NSFetchedResultsControllerDelegate>
{
	NSFetchedResultsController *_fetchedController;
	NSMutableDictionary *_callbackBlocks;
	NSMutableArray *_requestURLBlocks;
}

@end
@implementation ASCPictureManager


+ (ASCPictureManager *)sharedManager {
	static ASCPictureManager *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    instance = [self new];
	});

	return instance;
}

- (void)initialize {
	if (!_managedObjectContext || !_entityName || !_urlKeyValue) {
		return;
	}

	_fetchedController = ({
	                          NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:_entityName];
	                          [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:_urlKeyValue ascending:NO]]];
	                          NSFetchedResultsController *resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	                          [resultController setDelegate:self];
	                          [resultController performFetch:nil];
	                          resultController;
						  });
	if (!_requestURLBlocks) {
		_requestURLBlocks = [NSMutableArray new];
	}
	[_requestURLBlocks removeAllObjects];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	if (_entityName
	    && _urlKeyValue
	    && [anObject isKindOfClass:[NSManagedObject class]]
	    && [[anObject entity].name isEqualToString:_entityName]
	    && [[anObject entity].attributesByName objectForKey:_urlKeyValue]) {
		NSString *urlValue = [anObject valueForKey:_urlKeyValue];
		if (![_requestURLBlocks containsObject:urlValue]) {
			[_requestURLBlocks addObject:urlValue];
			NSURL *url = [NSURL URLWithString:urlValue];
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			    if (url) {
			        [[NSThread currentThread] setName:[NSString stringWithFormat:@"ASCPictureManagerDownload.%@", url.host]];
			        NSData *imageData = [NSData dataWithContentsOfURL:url];
			        UIImage *img = [UIImage imageWithData:imageData];
			        img = [UIImage imageWithCGImage:img.CGImage scale:[UIScreen mainScreen].scale orientation:img.imageOrientation];
                    
			        [[ASCImageCache sharedCache] cacheImage:img forURLString:urlValue];
			        [_requestURLBlocks removeObject:urlValue];
			        NSMutableArray *callbacks = [_callbackBlocks objectForKey:urlValue];
			        if (callbacks) {
			            [callbacks enumerateObjectsUsingBlock: ^(ASCImageSuccessBlock imageBlock, NSUInteger idx, BOOL *stop) {
			                dispatch_async(dispatch_get_main_queue(), ^{
			                    imageBlock(img,urlValue);
							});
						}];
					}
				}
			    [_callbackBlocks removeObjectForKey:urlValue];
			});
		}
	}
}

- (void)setEntityName:(NSString *)entityName {
	_entityName = entityName;
	[self initialize];
}

- (void)setUrlKeyValue:(NSString *)urlKeyValue {
	_urlKeyValue = urlKeyValue;
	[self initialize];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	_managedObjectContext = managedObjectContext;
	[self initialize];
}

- (void)observeDownloadForPicture:(NSManagedObject *)picture withBlock:(ASCImageSuccessBlock)successBlock {
	if (_entityName
	    && _urlKeyValue
	    && [picture.entity.name isEqualToString:_entityName]
	    && [picture.entity.attributesByName objectForKey:_urlKeyValue]) {
		NSString *urlValue = [picture valueForKey:_urlKeyValue];
		UIImage *image = [[ASCImageCache sharedCache] cachedImageForURLString:urlValue];
		if (image) {
			if (successBlock) {
				successBlock(image,urlValue);
			}
		}
		else {
			if (!_callbackBlocks) {
				_callbackBlocks = [NSMutableDictionary new];
			}
			NSMutableArray *callbacks = [_callbackBlocks objectForKey:urlValue];
			if (!callbacks) {
				callbacks = [NSMutableArray new];
			}
			[callbacks addObject:successBlock];
			[_callbackBlocks setObject:callbacks forKey:urlValue];
		}
	}
}

@end

#pragma mark -
@implementation NSManagedObject (ASCPictureManager)

- (void)observeDownloadWithBlock:(ASCImageSuccessBlock)successBlock {
	[[ASCPictureManager sharedManager] observeDownloadForPicture:self withBlock:successBlock];
}

@end

#pragma mark -
@implementation ASCImageCache

+ (ASCImageCache *)sharedCache {
	static ASCImageCache *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    instance = [[self alloc] init];
	});

	return instance;
}

- (id)init {
	self = [super init];
	if (self) {
		NSString *pathFolder = [[NSString alloc] initWithFormat:@"%@/images", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]];
		BOOL directory;
		BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:pathFolder isDirectory:&directory];
		if (!exist || !directory) {
			[[NSFileManager defaultManager] createDirectoryAtPath:pathFolder withIntermediateDirectories:NO attributes:nil error:NULL];
		}
		__weak typeof(self) weakSelf = self;

		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock: ^(NSNotification *__unused notification) {
		    [weakSelf removeAllObjects];
		}];
	}
	return self;
}

- (id)objectForKey:(id)key {
	UIImage *object = [super objectForKey:key];
	if (!object) {
		object = [self savedObjectForKey:key];
	}
	return object;
}

static inline NSString *ImageSavePathFromKey(NSString *key) {
    
    if ([NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)]) {
        
        return [[NSString alloc] initWithFormat:@"%@/images/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject], [[[key dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0] stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    }
    else {
        NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        const uint8_t* input = (const uint8_t*)[keyData bytes];
        NSInteger length = [keyData length];
        
        static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
        
        NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
        uint8_t* output = (uint8_t*)data.mutableBytes;
        
        NSInteger i;
        for (i=0; i < length; i += 3) {
            NSInteger value = 0;
            NSInteger j;
            for (j = i; j < (i + 3); j++) {
                value <<= 8;
                
                if (j < length) {
                    value |= (0xFF & input[j]);
                }
            }
            
            NSInteger theIndex = (i / 3) * 4;
            output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
            output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
            output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
            output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
        }
        return [[NSString alloc] initWithFormat:@"%@/images/%@", [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject], [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    }
}

- (id)savedObjectForKey:(id)key {
	UIImage *object = nil;
	NSData *data = [NSData dataWithContentsOfFile:ImageSavePathFromKey(key)];
	if (data) {
		object = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
	}
	return object;
}

- (BOOL)objectForKey:(id)key success:(void (^)(UIImage *image))success {
	id object = [super objectForKey:key];
	if (object) {
		success(object);
		return YES;
	}
	if ([[NSFileManager defaultManager] fileExistsAtPath:ImageSavePathFromKey(key)]) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^()
		{
		    success([self savedObjectForKey:key]);
		});

		return YES;
	}
	return NO;
}

- (void)setObject:(id)obj forKey:(id)key {
	dispatch_async(dispatch_queue_create("SaveImageQueue", DISPATCH_QUEUE_CONCURRENT), ^()
	{
	    if (![[NSFileManager defaultManager] fileExistsAtPath:ImageSavePathFromKey(key)] && [obj isKindOfClass:[UIImage class]]) {
	        [UIImagePNGRepresentation(obj) writeToFile:ImageSavePathFromKey(key) atomically:YES];
		}
	});
	[super setObject:obj forKey:key];
}

- (UIImage *)cachedImageForURLString:(NSString *)url {
	return [self objectForKey:url];
}

- (void)cacheImage:(UIImage *)image
      forURLString:(NSString *)url {
	if (image && url) {
		[self setObject:image forKey:url];
	}
}

@end
