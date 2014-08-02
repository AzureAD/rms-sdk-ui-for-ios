/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     PolicyTemplateCell.h
 *
 */

#import <UIKit/UIKit.h>

#define CELL_CONTENT_MARGIN 25.0f
#define POLICY_TITLE_PADDING 20.0f
#define POLICY_DESCRIPTION_PADDING 30.0f

@interface PolicyTemplateCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *policyTitle;
@property (weak, nonatomic) IBOutlet UILabel *policyDescription;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerLabelConstraint;

@end
