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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)download:(id)sender {
    NSArray *pictures = @[@"Tiger",@"Leopard",@"Snow Leopard",@"Lion",@"Mountain Lion",@"Maverick"];
    [pictures enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        Picture *picture = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:[ASCApp managedObjectContext]];
        [picture setTitle:title];
        [picture setPictureUrl:[NSString stringWithFormat:@""]];
    }];
    
    [ASCApp saveContext];
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
    
    return cell;
}
@end
