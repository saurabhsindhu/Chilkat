

#ifndef _MM_MailManProgress_H
#define _MM_MailManProgress_H

#include "../ChilkatLib/Package/include/CkMailProgress.h"

// Progress callback C++ class w/ implementation source file as .mm
// to allow for relaying of callbacks back into Objective-C apps.

// DO NOT USE MULTIPLE INHERITANCE
class MmMailManProgress : public CkMailProgress
{
	private:
		void *m_objc_callback;
	
    public:
    
    void setObjcCallback(void *cb);
    	
	MmMailManProgress();
	 ~MmMailManProgress();

	void SendPercentDone(long pctDone, bool *abort);
	void ReadPercentDone(long pctDone, bool *abort);
	 void ProgressInfo(const char *name, const char *value);


	// Called periodically to check to see if the email sending/receiving should be aborted.
	void AbortCheck(bool *abort);

	void EmailReceived(const char *subject, 
			    const char *fromAddr, const char *fromName, 
			    const char *returnPath, 
			    const char *dateTime, 
			    const char *uidl, 
			    int sizeInBytes);

};

#endif
