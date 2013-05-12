

#ifndef _MM_SshProgress_H
#define _MM_SshProgress_H

#include "../ChilkatLib/Package/include/CkSshProgress.h"
	
// Progress callback C++ class w/ implementation source file as .mm
// to allow for relaying of callbacks back into Objective-C apps.

// DO NOT USE MULTIPLE INHERITANCE
class MmSshProgress : public CkSshProgress
{
	private:
		void *m_objc_callback;
	
    public:
    
    void setObjcCallback(void *cb);
    	
	MmSshProgress();
	 ~MmSshProgress();

	 void AbortCheck(bool *abort);
	 void PercentDone(int pctDone, bool *abort);
	 void ProgressInfo(const char *name, const char *value);


};

#endif
