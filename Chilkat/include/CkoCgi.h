// Chilkat Objective-C header.
// Generic/internal class name =  Cgi
// Wrapped Chilkat C++ class name =  CkCgi



@interface CkoCgi : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: AsyncBytesRead
- (NSNumber *)AsyncBytesRead;

// property getter: AsyncInProgress
- (BOOL)AsyncInProgress;

// property getter: AsyncPostSize
- (NSNumber *)AsyncPostSize;

// property getter: AsyncSuccess
- (BOOL)AsyncSuccess;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: HeartbeatMs
- (NSNumber *)HeartbeatMs;

// property setter: HeartbeatMs
- (void)setHeartbeatMs: (NSNumber *)intVal;

// property getter: IdleTimeoutMs
- (NSNumber *)IdleTimeoutMs;

// property setter: IdleTimeoutMs
- (void)setIdleTimeoutMs: (NSNumber *)intVal;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: NumParams
- (NSNumber *)NumParams;

// property getter: NumUploadFiles
- (NSNumber *)NumUploadFiles;

// property getter: ReadChunkSize
- (NSNumber *)ReadChunkSize;

// property setter: ReadChunkSize
- (void)setReadChunkSize: (NSNumber *)intVal;

// property getter: SizeLimitKB
- (NSNumber *)SizeLimitKB;

// property setter: SizeLimitKB
- (void)setSizeLimitKB: (NSNumber *)ulongVal;

// property getter: StreamToUploadDir
- (BOOL)StreamToUploadDir;

// property setter: StreamToUploadDir
- (void)setStreamToUploadDir: (BOOL)boolVal;

// property getter: UploadDir
- (NSString *)UploadDir;

// property setter: UploadDir
- (void)setUploadDir: (NSString *)input;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: AbortAsync
- (void)AbortAsync;

// method: GetEnv
- (NSString *)GetEnv: (NSString *)varName;

// method: GetParam
- (NSString *)GetParam: (NSString *)paramName;

// method: GetParamName
- (NSString *)GetParamName: (NSNumber *)idx;

// method: GetParamValue
- (NSString *)GetParamValue: (NSNumber *)idx;

// method: GetRawPostData
- (NSData *)GetRawPostData;

// method: GetUploadData
- (NSData *)GetUploadData: (NSNumber *)idx;

// method: GetUploadFilename
- (NSString *)GetUploadFilename: (NSNumber *)idx;

// method: GetUploadSize
- (NSNumber *)GetUploadSize: (NSNumber *)idx;

// method: IsGet
- (BOOL)IsGet;

// method: IsHead
- (BOOL)IsHead;

// method: IsPost
- (BOOL)IsPost;

// method: IsUpload
- (BOOL)IsUpload;

// method: ReadRequest
- (BOOL)ReadRequest;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SleepMs
- (void)SleepMs: (NSNumber *)millisec;


@end
