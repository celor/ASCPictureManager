//
//  ASCPictureCollectionViewCell.m
//  ASCPictureManagerDemo
//
//  Created by Aurélien Scelles on 21/03/2014.
//  Copyright (c) 2014 Aurélien Scelles. All rights reserved.
//

#import "ASCPictureCollectionViewCell.h"

@implementation ASCPictureCollectionViewCell

-(void)awakeFromNib
{
    self.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.contentView.layer.borderWidth = 1;
}
-(void)prepareForReuse
{
    self.imageView.image = nil;
}
@end
