//
//  ASCViewController.m
//  ASCPictureManagerDemo
//
//  Created by Aurélien Scelles on 21/03/2014.
//  Copyright (c) 2014 Aurélien Scelles. All rights reserved.
//

#import "ASCViewController.h"
#import "ASCPictureCollectionViewCell.h"
#import "ASCPictureManager.h"
#import "ASCAppDelegate.h"
#define ASCApp (ASCAppDelegate *)[UIApplication sharedApplication].delegate

#import "Picture.h"


@interface ASCViewController () <UICollectionViewDataSource>
{
    IBOutlet NSLayoutConstraint *_downloadButtonHeight;
    NSMutableArray *_pictures;
    IBOutlet UICollectionView *_collectionView;
}
@end

@implementation ASCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[ASCPictureManager sharedManager] setManagedObjectContext:[ASCApp managedObjectContext]];
    [[ASCPictureManager sharedManager] setEntityName:@"Picture"];
    [[ASCPictureManager sharedManager] setUrlKeyValue:@"pictureUrl"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)download:(id)sender {
    NSArray *pictures = @[@"Tiger",@"Leopard",@"Snow Leopard",@"Lion",@"Mountain Lion",@"Maverick"];
    _pictures = [NSMutableArray new];
    [pictures enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        Picture *picture = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:[ASCApp managedObjectContext]];
        [picture setTitle:title];
        [picture setPictureUrl:[NSString stringWithFormat:@"https://raw.githubusercontent.com/celor/ASCPictureManager/master/Images/%@.jpg",[title stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        [_pictures addObject:picture];
    }];
    
    [_collectionView reloadData];
    [ASCApp saveContext];
    [UIView animateWithDuration:.3 animations:^{
        _downloadButtonHeight.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_pictures count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ASCPictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    Picture *picure =[_pictures objectAtIndex:indexPath.row];
    [cell.legendLabel setText:picure.title];
    cell.imageUrl = picure.pictureUrl;
    [picure observeDownloadWithBlock:^(UIImage *image,NSString *url) {
        if ([cell.imageUrl isEqualToString:url]) {
            [cell.imageView setImage:image];
        }
    }];
    
    return cell;
}
@end
