

#ifndef _MM_TarProgress_H
#define _MM_TarProgress_H

#include "../ChilkatLib/Package/include/CkTarProgress.h"
		
// Progress callback C++ class w/ implementation source file as .mm
// to allow for relaying of callbacks back into Objective-C apps.

// DO NOT USE MULTIPLE INHERITANCE
class MmTarProgress : public CkTarProgress
{
	private:
		void *m_objc_callback;
	

    public:
    
    void setObjcCallback(void *cb);
    	
	MmTarProgress();
	 ~MmTarProgress();

	void ProgressInfo(const char *name, const char *value);

	// Called periodically to check to see if the method call should be aborted.
	void AbortCheck(bool *abort);

	// Called just before appending to TAR when writing a .tar, and just before
	// extracting during untar.
	void NextTarFile(const char *fileName, 
	    __int64 fileSize,
	    bool bIsDirectory, 
	    bool *skip);

};

#endif
