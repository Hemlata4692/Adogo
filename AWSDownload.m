//
//  AWSDownload.m
//  Sure_sp
//
//  Created by Ranosys on 13/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "AWSDownload.h"

@implementation AWSDownload

- (void)listObjects:(id)sender ImageName:(NSMutableArray*)imageName folderName:(NSString *)folderName {
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
  // NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"download"];
    AWSS3 *s3 = [AWSS3 defaultS3];
    
    AWSS3ListObjectsRequest *listObjectsRequest = [AWSS3ListObjectsRequest new];
    listObjectsRequest.bucket = [UserDefaultManager getValue:@"BucketName"];
    NSMutableArray *imagesArray=[NSMutableArray new];
    [[s3 listObjects:listObjectsRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            [myDelegate stopIndicator];
        } else {
            
            //            AWSS3ListObjectsOutput *listObjectsOutput = task.result;
            //            for (AWSS3Object *s3Object in listObjectsOutput.contents) {
            for (int i=0; i<imageName.count; i++) {
                NSString *downloadingFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"] stringByAppendingPathComponent:[imageName objectAtIndex:i]];
                NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
                
                //            if ([[NSFileManager defaultManager] fileExistsAtPath:downloadingFilePath]) {
                //                [self.collection addObject:downloadingFileURL];
                //            } else {
                AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
                if (folderName==nil)
                {
                    downloadRequest.bucket = [NSString stringWithFormat:@"%@",[UserDefaultManager getValue:@"BucketName"]];
                }
                else
                {
                downloadRequest.bucket = [NSString stringWithFormat:@"%@/%@",[UserDefaultManager getValue:@"BucketName"],folderName];
                }
                downloadRequest.key = [imageName objectAtIndex:i];
                downloadRequest.downloadingFileURL = downloadingFileURL;
                [imagesArray addObject:downloadRequest];
                
                [self download:downloadRequest index:i];
                //            }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_delegate ListObjectprocessCompleted:imagesArray];
            });
        }
        return nil;
    }];
}


- (void)download:(AWSS3TransferManagerDownloadRequest *)downloadRequest index : (NSUInteger)index {
    //    switch (downloadRequest.state) {
    //        case AWSS3TransferManagerRequestStateNotStarted:
    //        case AWSS3TransferManagerRequestStatePaused:
    //        {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager download:downloadRequest] continueWithBlock:^id(AWSTask *task) {
        if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]
            && task.error.code == AWSS3TransferManagerErrorPaused) {
        } else if (task.error) {
            [myDelegate stopIndicator];
        } else {
            //                    __weak AddServiceViewController *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{

                
                [_delegate DownloadprocessCompleted:downloadRequest index:index];
                //                        AddServiceViewController *strongSelf = weakSelf;
                //
                //                        NSUInteger index = [strongSelf.collection indexOfObject:downloadRequest];
//                [imagesArray replaceObjectAtIndex:index
//                                       withObject:downloadRequest.downloadingFileURL];
//                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            });
        }
        return nil;
    }];
    //        }
    //            break;
    //        default:
    //            break;
    //    }
}

@end