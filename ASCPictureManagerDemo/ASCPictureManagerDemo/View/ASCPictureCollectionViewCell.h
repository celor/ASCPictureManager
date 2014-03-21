//
//  ASCPictureCollectionViewCell.h
//  ASCPictureManagerDemo
//
//  Created by Aurélien Scelles on 21/03/2014.
//  Copyright (c) 2014 Aurélien Scelles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASCPictureCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *legendLabel;
@property (strong, nonatomic) NSString *imageUrl;
@end
