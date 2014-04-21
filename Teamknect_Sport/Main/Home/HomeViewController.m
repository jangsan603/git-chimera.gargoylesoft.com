//
//  HomeViewController.m
//  TeamkNect
//
//  Created by Jangsan on 3/30/14.
//  Copyright (c) 2014 Jangsan. All rights reserved.
//
#import "Global.h"
#import "HomeImageView.h"
#import "HomeViewController.h"
#import "NewAdViewController.h"
#import "DashboardViewController.h"
#import "ImageDisplayViewController.h"
#import "AppDelegate.h"
#import "Person.h"



@interface HomeViewController () <HomeImageDelegate>

@end

@implementation HomeViewController

@synthesize  scrollView;
@synthesize viewCategory_1, viewCategory_2, viewCategory_3;
@synthesize imgCategoryView_1, imgCategoryView_2, imgCategoryView_3, imgCategoryView_4, imgCategoryView_5, imgCategoryView_6, imgCategoryView_7, imgCategoryView_8, imgCategoryView_9;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate    = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext        = appDelegate.managedObjectContext;
    NSFetchRequest *request     = [[NSFetchRequest alloc]init];
//     NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sport"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:appDelegate.managedObjectContext];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *mutableFetchResults = [[appDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//    NSString *str = [mutableFetchResults objectAtIndex:0];
    Person *person;

    if ([mutableFetchResults count] == 1) {
        person = [mutableFetchResults objectAtIndex:0];

    }
    else if([mutableFetchResults count] == 0)
    {
        NSLog(@"Error- No User \n");
      //  assert(![mutableFetchResults count]);
    }
    else{
        NSLog(@"Error- Multi User \n");
    }
    
    NSNumber *nub = person.latitude;
    
    
    [self imgViewLayout];
    globalSelectImgViewIndex = 0;           //global variable init.
    [self.navigationController setNavigationBarHidden:YES];
    
    CGFloat width   = 90;
    CGFloat height  = 140;
    CGFloat margin  = 13;
    CGFloat startX  = (self.view.frame.size.width - 3 * width - 2 * margin) *0.5;
    CGFloat startY  = 168;
    for (int i = 0; i<40; i++)
    {
        //---------category imageview (couple).
        int row             = i/3;
        int column          = i%3;
        CGFloat           x = startX + column * (width + margin);
        CGFloat           y = startY + row *   (height + margin);
        HomeImageView *homeImgView = [[HomeImageView alloc]initWithFrame:CGRectMake(x, y, 90, 140)];
        [self.scrollView addSubview:homeImgView];
        homeImgView.delegate           = self;
        homeImgView.homeImgSelectIndex = i;
    
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 17*140)];
    self.scrollView.contentSize = view.frame.size;

}

#pragma mark - image view select function.
- (void) btnCategory_1Clicked:(int)index
{
    globalSelectImgViewIndex = index;
    switch (globalSelectImgViewIndex)
    {
        case 0:            //----------my dashboard image.
        {
            DashboardViewController            *vc = [[DashboardViewController alloc]initWithNibName:@"DashboardViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:            //----------football     image.
        {
            ImageDisplayViewController          *vc = [[ImageDisplayViewController alloc]initWithNibName:@"ImageDisplayViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];

        }
            break;
        case 2:            //----------tennis       image.
        {
            ImageDisplayViewController          *vc = [[ImageDisplayViewController alloc]initWithNibName:@"ImageDisplayViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:            //----------soccer       image.
        {
            ImageDisplayViewController          *vc = [[ImageDisplayViewController alloc]initWithNibName:@"ImageDisplayViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:            //----------golf         image.
        {
            ImageDisplayViewController          *vc = [[ImageDisplayViewController alloc]initWithNibName:@"ImageDisplayViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:            //----------basketball   image.
        {
            ImageDisplayViewController          *vc = [[ImageDisplayViewController alloc]initWithNibName:@"ImageDisplayViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
            
            break;
            
        default:
            break;
    }

}

- (IBAction)btnMenuClicked:(id)sender
{
    [self.revealViewController revealToggleAnimated:YES];
}

- (IBAction)btnAddClicked:(id)sender
{
    NewAdViewController *vc = [[NewAdViewController alloc]init];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 8 imageview and ui view init.
- (void)imgViewLayout
{
    [viewCategory_1.layer setCornerRadius:5.0f];
    viewCategory_1.clipsToBounds = YES;
    [viewCategory_2.layer setCornerRadius:5.0f];
    viewCategory_2.clipsToBounds = YES;
    [viewCategory_3.layer setCornerRadius:5.0f];
    viewCategory_3.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
