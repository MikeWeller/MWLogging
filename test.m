#import "MWLogging.h"

/* clang sanity_check_main.m MWLogging.m -framework Foundation && ./a.out */
int main(int argc, char **argv) {
  @autoreleasepool {

    /* This will cause a system-wide broadcast on OSX so we enable
       this only when we need it for our tests */
#if EMERGENCY_ENABLED
    MWLogEmergency(@"Emergency test message");
#endif

    MWLogAlert(@"Alert");
    MWLogCritical(@"Critical");
    MWLogError(@"Error");
    MWLogWarning(@"Warning");
    MWLogNotice(@"Notice");
    MWLogInfo(@"Info");
    MWLogDebug(@"Debug");

    return 0;
  }
}
