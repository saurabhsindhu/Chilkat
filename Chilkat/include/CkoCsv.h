// Chilkat Objective-C header.
// Generic/internal class name =  Csv
// Wrapped Chilkat C++ class name =  CkCsv



@interface CkoCsv : NSObject {

	@private
		void *m_obj;

}

- (id)init;
- (void)dealloc;
- (void)dispose;
- (NSString *)stringWithUtf8: (const char *)s;
- (void *)CppImplObj;
- (void)setCppImplObj: (void *)pObj;

// property getter: Crlf
- (BOOL)Crlf;

// property setter: Crlf
- (void)setCrlf: (BOOL)boolVal;

// property getter: DebugLogFilePath
- (NSString *)DebugLogFilePath;

// property setter: DebugLogFilePath
- (void)setDebugLogFilePath: (NSString *)input;

// property getter: Delimiter
- (NSString *)Delimiter;

// property setter: Delimiter
- (void)setDelimiter: (NSString *)input;

// property getter: HasColumnNames
- (BOOL)HasColumnNames;

// property setter: HasColumnNames
- (void)setHasColumnNames: (BOOL)boolVal;

// property getter: LastErrorHtml
- (NSString *)LastErrorHtml;

// property getter: LastErrorText
- (NSString *)LastErrorText;

// property getter: LastErrorXml
- (NSString *)LastErrorXml;

// property getter: NumColumns
- (NSNumber *)NumColumns;

// property getter: NumRows
- (NSNumber *)NumRows;

// property getter: VerboseLogging
- (BOOL)VerboseLogging;

// property setter: VerboseLogging
- (void)setVerboseLogging: (BOOL)boolVal;

// property getter: Version
- (NSString *)Version;

// method: GetCell
- (NSString *)GetCell: (NSNumber *)row 
	col: (NSNumber *)col;

// method: GetColumnName
- (NSString *)GetColumnName: (NSNumber *)index;

// method: GetIndex
- (NSNumber *)GetIndex: (NSString *)columnName;

// method: GetNumCols
- (NSNumber *)GetNumCols: (NSNumber *)row;

// method: LoadFile
- (BOOL)LoadFile: (NSString *)path;

// method: LoadFile2
- (BOOL)LoadFile2: (NSString *)path 
	charset: (NSString *)charset;

// method: LoadFromString
- (BOOL)LoadFromString: (NSString *)csvData;

// method: SaveFile
- (BOOL)SaveFile: (NSString *)path;

// method: SaveFile2
- (BOOL)SaveFile2: (NSString *)path 
	charset: (NSString *)charset;

// method: SaveLastError
- (BOOL)SaveLastError: (NSString *)path;

// method: SaveToString
- (NSString *)SaveToString;

// method: SetCell
- (BOOL)SetCell: (NSNumber *)row 
	col: (NSNumber *)col 
	content: (NSString *)content;

// method: SetColumnName
- (BOOL)SetColumnName: (NSNumber *)index 
	columnName: (NSString *)columnName;


@end
