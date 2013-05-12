// CkFileList.h: interface for the CkFileList class.
//
//////////////////////////////////////////////////////////////////////

#ifndef _CKFILELIST_H
#define _CKFILELIST_H




class CkByteData;
#include "CkString.h"
#include "CkMultiByteBase.h"

#ifdef WIN32
#pragma warning( disable : 4068 )
#pragma unmanaged
#endif


/*
    IMPORTANT: Objects returned by methods as non-const pointers must be deleted
    by the calling application. 

  */

#ifndef __sun__
#pragma pack (push, 8)
#endif
 

// CLASS: CkFileList
class CkFileList  : public CkMultiByteBase
{
    public:
	CkFileList();
	virtual ~CkFileList();

	// May be called when finished with the object to free/dispose of any
	// internal resources held by the object. 
	void dispose(void);

	// BEGIN PUBLIC INTERFACE


	void get_AppendFromDir(CkString &str) const;
	void put_AppendFromDir(const char *dir);

	int AppendFilesEx(const char *filenamePattern, 
	    bool recurse, bool saveExtraPath, bool archiveOnly, 
	    bool includeHidden, bool includeSystem);

	int AppendFiles(const char *filenamePattern, bool recurse);

	// Append a single file (relative to AppendFromDir)
	bool AppendFile(const char *filePath);

	// Add an arbitrary directory entry that may not necessarily be on disk.
	bool AppendDirEntry(const char *dirPath);

	int get_Count(void) const;

	bool GetArchivePath(int idx, CkString &outStr);
	bool SetArchivePath(int idx, const char *filePath);

	bool GetDiskPath(int idx, CkString &outStr);
	bool IsOnDisk(int idx);
	bool IsDirectory(int idx);

	bool GetData(int idx, CkByteData &byteData);

	// Replace findStr with replaceStr in all the ArchivePaths.
	void StringReplace(const char *findStr, const char *replaceStr);


	const char *getArchivePath(int index);
	const char *getDiskPath(int index);
	const char *appendFromDir(int index);

	// FILELIST_INSERT_POINT

	// END PUBLIC INTERFACE



    // For internal use only.
    private:
	// Don't allow assignment or copying these objects.
	CkFileList(const CkFileList &) { } 
	CkFileList &operator=(const CkFileList &) { return *this; }
	CkFileList(void *impl);



};

#ifndef __sun__
#pragma pack (pop)
#endif


#endif


