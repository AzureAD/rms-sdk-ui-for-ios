/*
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *
 * FileName:     MSProtector.h
 *
 * MSProtector enables the developer to encrypt or decrypt any chunk of data and manage the stream by himself
 *
 */

#import <Foundation/Foundation.h>

@class MSUserPolicy;

@interface MSProtector : NSObject

- (id)initWithUserPolicy:(MSUserPolicy *)userPolicy;

- (NSData *)encryptAlignedBlocksWithStartingBlockNumber:(NSUInteger)startingBlockNumber unEncryptedData:(NSData *)unEncryptedData isFinal:(BOOL)isFinal error:(NSError **)errorPtr;

- (NSData *)decryptAlignedBlocksWithStartingBlockNumber:(NSUInteger)startingBlockNumber encryptedData:(NSData *)encryptedData isFinal:(BOOL)isFinal error:(NSError **)errorPtr;

// Get the minimum block size decryption/encryption calls should occur except the last block
@property (readonly) uint32_t blockSize;

@end