

#ifndef _MM_SFtpProgress_H
#define _MM_SFtpProgress_H

#include "../ChilkatLib/Package/include/CkSFtpProgress.h"

// Progress callback C++ class w/ implementation source file as .mm
// to allow for relaying of callbacks back into Objective-C apps.

// DO NOT USE MULTIPLE INHERITANCE
class MmSFtpProgress : public CkSFtpProgress
{
	private:
		void *m_objc_callback;
	
    public:
    
    void setObjcCallback(void *cb);
    	
	MmSFtpProgress();
	 ~MmSFtpProgress();

	 void AbortCheck(bool *abort);
	 void PercentDone(int pctDone, bool *abort);
 	 void ProgressInfo(const char *name, const char *value);


	void UploadRate(unsigned long byteCount, unsigned long bytesPerSec);
	void DownloadRate(unsigned long byteCount, unsigned long bytesPerSec);

};

#endif
