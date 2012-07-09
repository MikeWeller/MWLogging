
// We need all the log functions visible so we set this to DEBUG
#ifdef MW_COMPILE_TIME_LOG_LEVEL
#undef MW_COMPILE_TIME_LOG_LEVEL
#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG
#endif

#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG

#import "MWLogging.h"

static void AddStderrOnce()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		asl_add_log_file(NULL, STDERR_FILENO);
	});
}

#define __MW_MAKE_LOG_FUNCTION(LEVEL, NAME) \
void NAME (NSString *format, ...) \
{ \
	AddStderrOnce(); \
	va_list args; \
	va_start(args, format); \
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
	asl_log(NULL, NULL, (LEVEL), "%s", [message UTF8String]); \
	va_end(args); \
}

__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_EMERG, MWLogEmergency)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_ALERT, MWLogAlert)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_CRIT, MWLogCritical)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_ERR, MWLogError)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_WARNING, MWLogWarning)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_NOTICE, MWLogNotice)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_INFO, MWLogInfo)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_DEBUG, MWLogDebug)

#undef __MW_MAKE_LOG_FUNCTION
