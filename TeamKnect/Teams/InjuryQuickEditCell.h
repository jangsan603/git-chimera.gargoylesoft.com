//
//  InjuryQuickEditCell.h
//  TeamKnect
//
//  Created by Scott Grosch on 3/4/14.
//  Copyright (c) 2014 Gargoyle Software, LLC. All rights reserved.
//

#import "InjuryStatus.h"

typedef void (^InjuryQuickEditBlock)(InjuryStatusType statusType);

@interface InjuryQuickEditCell : UITableViewCell

@property (nonatomic, copy) InjuryQuickEditBlock onQuickEditSelected;

@end
