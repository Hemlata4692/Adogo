//
//  BidInfoModel.h
//  Adogo
//
//  Created by Ranosys on 21/10/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BidInfoModel : NSObject <NSCopying>

@property(nonatomic, retain)NSString *campaignId;
@property(nonatomic, retain)NSString *carId;
@property(nonatomic, retain)NSString *bidId;
@property(nonatomic, retain)NSString *advertiserName;
@property(nonatomic, retain)NSString *campaignName;
@property(nonatomic, retain)NSString *duration;
@property(nonatomic, retain)NSString *brand;
@property(nonatomic, retain)NSString *companyName;
@property(nonatomic, retain)NSString *campaignStartDate;
@property(nonatomic, retain)NSString *carOwnerName;
@property(nonatomic, retain)NSString *carPlateNumber;
@property(nonatomic, retain)NSString *ICNumber;
@property(nonatomic, retain)NSString *myBid;
@property(nonatomic, retain)NSString *signaturePath;
@property(nonatomic, retain)NSString *dateTime;
@property(nonatomic, retain)NSString *totalPoints;
@property(nonatomic, retain)NSString *distanceCovered;
@property(nonatomic, retain)NSString *daysTravelled;
@property(nonatomic, retain)NSString *totalEarning;
@property(nonatomic, retain)NSString *avgBidAmount;
@property(nonatomic, retain)NSString *maxBid;
@end
