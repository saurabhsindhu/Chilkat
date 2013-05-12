

#ifndef _MM_ZipProgress_H
#define _MM_ZipProgress_H

#include "../ChilkatLib/Package/include/CkZipProgress.h"

// Progress callback C++ class w/ implementation source file as .mm
// to allow for relaying of callbacks back into Objective-C apps.

// DO NOT USE MULTIPLE INHERITANCE
class MmZipProgress : public CkZipProgress
{
	private:
		void *m_objc_callback;
	
    public:
    
    void setObjcCallback(void *cb);
    	
	MmZipProgress();
	 ~MmZipProgress();

	void WriteZipPercentDone(long pctDone, bool *abort);
	void UnzipPercentDone(long pctDone, bool *abort);

	// Called periodically to check to see if the Zip / Unzip should be aborted.
	void AbortCheck(bool *abort);

	void ToBeAdded(const char *fileName, 
	    unsigned long fileSize, 
	    bool *excludeFlag);

	void DirToBeAdded(const char *fileName, 
	    bool *excludeFlag);

	void FileAdded(const char *fileName, 
	    unsigned long fileSize, 
	    bool *abort);

	void ToBeZipped(const char *fileName, 
	    unsigned long fileSize, 
	    bool *abort);

	void FileZipped(const char *fileName, 
	    unsigned long fileSize, 
	    unsigned long compressedSize, 
	    bool *abort);

	void ToBeUnzipped(const char *fileName, 
	    unsigned long compressedSize,
	    unsigned long fileSize, 
	    bool *abort);

	void FileUnzipped(const char *fileName, 
	    unsigned long compressedSize,
	    unsigned long fileSize, 
	    bool *abort);

	void AddFilesBegin(void);
	void AddFilesEnd(void);
	void WriteZipBegin(void);
	void WriteZipEnd(void);
	void UnzipBegin(void);
	void UnzipEnd(void);

};

#endif
