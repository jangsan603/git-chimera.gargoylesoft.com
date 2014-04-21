//
//  ImageExplainViewController.h
//  TeamkNect
//
//  Created by Jangsan on 4/2/14.
//  Copyright (c) 2014 lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ImageExplainViewController : UIViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIButton                 *btnBack;           //------back               button event.
@property (strong, nonatomic) IBOutlet UIButton                 *btnSetting;        //------setting            button event.
@property (strong, nonatomic) IBOutlet UIButton                 *btnMessage;        //------message            button event.
@property (strong, nonatomic) IBOutlet UIButton                 *btnImgDisplay;     //------image display      button event.
@property (strong, nonatomic) IBOutlet UILabel                  *lblCommodityTitle; //------commodity title.
@property (strong, nonatomic) IBOutlet MKMapView                *mapView;
@property (strong, nonatomic) IBOutlet UIScrollView             *scrollView;
@property (strong, nonatomic) IBOutlet UITableView              *tblMoreInfo;
@property (strong, nonatomic) IBOutlet UIButton                 *btnBuyFor;         //------buy for button event.
@property (strong, nonatomic) IBOutlet UIButton                 *btnSendMsg;        //------send message button event.


- (IBAction)btnBackClicked:(id)sender;
- (IBAction)btnSettingClicked:(id)sender;
- (IBAction)btnMessageClicked:(id)sender;
- (IBAction)btnImgDisplayClicked:(id)sender;
- (IBAction)btnBuyForClicked:(id)sender;
- (IBAction)btnSendMsgClicked:(id)sender;
@end
