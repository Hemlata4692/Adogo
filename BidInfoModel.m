//
//  BidInfoModel.m
//  Adogo
//
//  Created by Ranosys on 21/10/16.
//  Copyright © 2016 Sumit. All rights reserved.
//

#import "BidInfoModel.h"

@implementation BidInfoModel

- (id)copyWithZone:(NSZone *)zone {
    
    BidInfoModel *bidModel = [[[self class] allocWithZone:zone] init];
    bidModel.advertiserName = [self.advertiserName copyWithZone:zone];
    bidModel.carId = [self.carId copyWithZone:zone];
    bidModel.campaignId = [self.campaignId copyWithZone:zone];
    bidModel.bidId = [self.bidId copyWithZone:zone];
    bidModel.campaignName = [self.campaignName copyWithZone:zone];
    bidModel.duration = [self.duration copyWithZone:zone];
    bidModel.brand = [self.brand copyWithZone:zone];
    bidModel.companyName = [self.companyName copyWithZone:zone];
    bidModel.campaignStartDate = [self.campaignStartDate copyWithZone:zone];
    bidModel.carOwnerName = [self.carOwnerName copyWithZone:zone];
    bidModel.myBid = [self.myBid copyWithZone:zone];
    bidModel.signaturePath = [self.signaturePath copyWithZone:zone];
    bidModel.carPlateNumber = [self.carPlateNumber copyWithZone:zone];
    bidModel.ICNumber = [self.ICNumber copyWithZone:zone];
    bidModel.dateTime = [self.dateTime copyWithZone:zone];
    bidModel.totalPoints = [self.totalPoints copyWithZone:zone];
    bidModel.distanceCovered = [self.distanceCovered copyWithZone:zone];
    bidModel.daysTravelled = [self.daysTravelled copyWithZone:zone];
    bidModel.totalEarning = [self.totalEarning copyWithZone:zone];
    bidModel.avgBidAmount = [self.avgBidAmount copyWithZone:zone];
    bidModel.maxBid = [self.maxBid copyWithZone:zone];
    return bidModel;
}

@end