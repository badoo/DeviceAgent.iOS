// class-dump results processed by bin/class-dump/dump.rb
//
//     Generated by class-dump 3.5 (64 bit) (Debug version compiled Nov 26 2020 14:08:26).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//



@protocol XCTRunnerAutomationSession;

@protocol XCUIApplicationAutomationSessionProviding <NSObject>
- (void)requestAutomationSessionBlacklist:(void (^)(NSSet *, NSError *))arg1;
- (void)requestAutomationSessionForTestTargetWithPID:(NSInteger)arg1 preferredBackendPath:(NSString *)arg2 reply:(void (^)(id <XCTRunnerAutomationSession>, NSError *))arg3;
@end

