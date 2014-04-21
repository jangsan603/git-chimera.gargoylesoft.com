
/*

  Copyright (c) 2014 Jangsan  <Jangsan603@hotmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 Original code:
 Copyright (c) 2014 Jangsan  <Jangsan603@hotmail.com>
 
*/

#import "RearViewController.h"
#import "SWRevealViewController.h"
#import "NewAdViewController.h"
#import "DashboardViewController.h"
#import "MyBoughtViewController.h"
#import "MyWantViewController.h"
#import "MyAlertsViewController.h"
#import "MyMessagesViewController.h"
#import "MyAccountViewController.h"
#import "HomeViewController.h"
#import "MyLocationViewController.h"

@interface RearViewController()

@end

@implementation RearViewController

@synthesize rearTableView = _rearTableView;
@synthesize btnMenu;
@synthesize imgStar_1, imgStar_2, imgStar_3, imgStar_4, imgStar_5, imgUserPhoto;
@synthesize lblUserName;

#pragma mark - View lifecycle


- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = NSLocalizedString(@"Rear View", nil);
    [imgUserPhoto.layer setCornerRadius:40.0];
    imgUserPhoto.clipsToBounds = YES;
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier   = @"Cell";
	UITableViewCell *cell             = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIImageView     *imgView          = [[UIImageView alloc]initWithFrame:CGRectMake(15, 17, 15, 15)];
    UILabel         *lblText          = [[UILabel alloc]initWithFrame:CGRectMake(45, 5, 200,40)];
    lblText.font                      = [UIFont fontWithName:@"System Bold" size:17];
    lblText.backgroundColor           = [UIColor clearColor];
    lblText.textColor                 = [UIColor colorWithRed:0 green:0.235 blue:0.431 alpha:1.0];
    [tableView setSeparatorColor:[UIColor clearColor]];
    NSInteger row                     = indexPath.row;
	
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}
	
	if (row == 0)
	{
        lblText.text       = @"New Add";
        imgView.image      = [UIImage imageNamed:@"tbl_ad.png"];
        [cell.contentView addSubview:lblText];
        [cell.contentView addSubview:imgView];
	}
	else if (row == 1)
	{
        lblText.text       = @"My Dashboard";
        imgView.image      = [UIImage imageNamed:@"tbl_dash.png"];
        [cell.contentView addSubview:lblText];
        [cell.contentView addSubview:imgView];
	}
    else if (row == 2)
    {
        lblText.text       = @"Near Me Items";
        imgView.image      = [UIImage imageNamed:@"tbl_near.png"];
        [cell.contentView addSubview:lblText];
        [cell.contentView addSubview:imgView];
    }
	else if (row == 3)
	{
        lblText.text       = @"My Bought Items";
        imgView.image      = [UIImage imageNamed:@"tbl_bought.png"];
        [cell.contentView addSubview:lblText];
        [cell.contentView addSubview:imgView];
	}
	else if (row == 4)
	{
        lblText.text       = @"My Wanted Items";
        imgView.image      = [UIImage imageNamed:@"tbl_want.png"];
        [cell.contentView addSubview:lblText];
        [cell.contentView addSubview:imgView];
	}
    else if (row == 5)
	{
        lblText.text       = @"My Alerts";
        imgView.image      = [UIImage imageNamed:@"tbl_alert.png"];
        [cell.contentView addSubview:lblText];
        [cell.contentView addSubview:imgView];
	}
    else if (row == 6)
	{
        lblText.text       = @"My Messages";
        imgView.image      = [UIImage imageNamed:@"tbl_msg.png"];
        [cell.contentView addSubview:lblText];
        [cell.contentView addSubview:imgView];
	}
   
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealViewController *revealController = self.revealViewController;
    UINavigationController *frontNavigationController = (id)revealController.frontViewController;
    NSInteger row = indexPath.row;

	if (row == 0)
	{
        if ( ![frontNavigationController.topViewController isKindOfClass:[NewAdViewController class]] )
        {
			NewAdViewController    *vc                     = [[NewAdViewController alloc] init];
			UINavigationController *navigationController   = [[UINavigationController alloc] initWithRootViewController:vc];
			[self presentViewController:navigationController animated:YES completion:nil];
           
        }
		else
		{
			[revealController revealToggle:self];
		}
	}
    if (row == 1)
    {
        if (![frontNavigationController.topViewController isKindOfClass:[DashboardViewController class]])
        {
            DashboardViewController *vc                    = [[DashboardViewController alloc]init];
            UINavigationController  *navigationController  = [[UINavigationController alloc] initWithRootViewController:vc];
            [revealController pushFrontViewController:navigationController animated:YES];
        }
        else
        {
            [revealController revealToggle:self];
        }
    }
    if (row == 2)
    {
        if (![frontNavigationController.topViewController isKindOfClass:[MyLocationViewController class]])
        {
            MyLocationViewController  *vc                  = [[MyLocationViewController alloc]init];
            UINavigationController  *navigationController  = [[UINavigationController alloc] initWithRootViewController:vc];
            [revealController pushFrontViewController:navigationController animated:YES];
        }
        else
        {
            [revealController revealToggle:self];
        }
    }
    if (row == 3)
    {
        if (![frontNavigationController.topViewController isKindOfClass:[MyBoughtViewController class]])
        {
            MyBoughtViewController  *vc                    = [[MyBoughtViewController alloc]init];
            UINavigationController  *navigationController  = [[UINavigationController alloc] initWithRootViewController:vc];
            [revealController pushFrontViewController:navigationController animated:YES];
        }
        else
        {
            [revealController revealToggle:self];
        }
    }
    if (row == 4)
    {
        if (![frontNavigationController.topViewController isKindOfClass:[MyWantViewController class]])
        {
            MyWantViewController     *vc                   = [[MyWantViewController alloc]init];
            UINavigationController   *navigationController = [[UINavigationController alloc]initWithRootViewController:vc];
            [revealController pushFrontViewController:navigationController animated:YES];
        }
        else
        {
            [revealController revealToggle:self];
        }
    }
    if (row == 5)
    {
        if (![frontNavigationController.topViewController isKindOfClass:[MyAlertsViewController class]])
        {
            MyAlertsViewController   *vc                   = [[MyAlertsViewController alloc]init];
            UINavigationController   *navigationController = [[UINavigationController alloc]initWithRootViewController:vc];
            [revealController pushFrontViewController:navigationController animated:YES];
        }
        else
        {
            [revealController revealToggle:self];
        }
    }
    if (row == 6)
    {
        if (![frontNavigationController.topViewController isKindOfClass:[MyMessagesViewController class]])
        {
            MyMessagesViewController *vc                   = [[MyMessagesViewController alloc]init];
            UINavigationController   *navigationController = [[UINavigationController alloc]initWithRootViewController:vc];
            [revealController pushFrontViewController:navigationController animated:YES];
        }
        else
        {
            [revealController revealToggle:self];
        }
    }
    if (row == 7)
    {
        if (![frontNavigationController.topViewController isKindOfClass:[MyAccountViewController class]])
        {
            MyAccountViewController *vc                    = [[MyAccountViewController alloc]init];
            UINavigationController  *navigationController  = [[UINavigationController alloc]initWithRootViewController:vc];
            [revealController pushFrontViewController:navigationController animated:YES];
        }
        else
        {
            [revealController revealToggle:self];
        }
    }

}

- (IBAction)btnMenuClicked:(id)sender
{
    SWRevealViewController *revealController          = self.revealViewController;
    UINavigationController *frontNavigationController = (id)revealController.frontViewController;

    if ( ![frontNavigationController.topViewController isKindOfClass:[HomeViewController class]] )
    {
        HomeViewController *vc                         = [[HomeViewController alloc] init];
        UINavigationController *navigationController   = [[UINavigationController alloc] initWithRootViewController:vc];
        [revealController pushFrontViewController:navigationController animated:YES];
    }
    else
    {
        [revealController revealToggle:self];
    }

}

@end