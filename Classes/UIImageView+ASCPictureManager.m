//
//  UIImageView+ASCPictureManager.m
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

#import "UIImageView+ASCPictureManager.h"
#import <objc/runtime.h>
@implementation UIImageView (ASCPictureManager)

-(NSString *)imageUrl {
    return (NSString *)objc_getAssociatedObject(self, @selector(imageUrl));
}

-(void)setImageUrl:(NSString *)imgUrl{
    objc_setAssociatedObject(self, @selector(imageUrl), imgUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)setPicture:(NSManagedObject *)picture
{
    if (picture
        && [[ASCPictureManager sharedManager] entityName]
	    && [[ASCPictureManager sharedManager] urlKeyValue]
	    && [picture.entity.name isEqualToString:[[ASCPictureManager sharedManager] entityName]]
	    && [picture.entity.attributesByName objectForKey:[[ASCPictureManager sharedManager] urlKeyValue]])
    {
        [self setImageUrl:[picture valueForKey:[[ASCPictureManager sharedManager] urlKeyValue]]];
        __weak typeof(self) weakSelf = self;
        [picture observeDownloadWithBlock:^(UIImage *image, NSString *urlString) {
            if ([[weakSelf imageUrl] isEqualToString:urlString]) {
                [weakSelf setImage:image];
            }
        }];
    }
}

-(void)setPictureWithUrl:(NSString *)pictureUrl
{
    if (pictureUrl) {
        
        [self setImageUrl:pictureUrl];
        __weak typeof(self) weakSelf = self;
        [pictureUrl observeDownloadWithBlock:^(UIImage *image, NSString *urlString) {
            if ([[weakSelf imageUrl] isEqualToString:urlString]) {
                [weakSelf setImage:image];
            }
        }];
    }
    
}
@end
