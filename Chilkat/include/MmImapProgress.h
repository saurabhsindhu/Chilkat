

#ifndef _MM_ImapProgress_H
#define _MM_ImapProgress_H

#include "../ChilkatLib/Package/include/CkImapProgress.h"

// Progress callback C++ class w/ implementation source file as .mm
// to allow for relaying of callbacks back into Objective-C apps.

// DO NOT USE MULTIPLE INHERITANCE
class MmImapProgress : public CkImapProgress
{
	private:
		void *m_objc_callback;
	
    public:
    
    void setObjcCallback(void *cb);
    	
	MmImapProgress();
	 ~MmImapProgress();

	 void AbortCheck(bool *abort);
	 void PercentDone(int pctDone, bool *abort);
	 void ProgressInfo(const char *name, const char *value);


};

#endif
