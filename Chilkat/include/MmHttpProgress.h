

#ifndef _MMHTTPPROGRESS_H
#define _MMHTTPPROGRESS_H

#include "../ChilkatLib/Package/include/CkHttpProgress.h"
	
// Progress callback C++ class w/ implementation source file as .mm
// to allow for relaying of callbacks back into Objective-C apps.

// DO NOT USE MULTIPLE INHERITANCE
class MmHttpProgress : public CkHttpProgress
{
	private:
		void *m_objc_callback;
	
    public:
    
    void setObjcCallback(void *cb);
    	
	MmHttpProgress();
	 ~MmHttpProgress();

	// Called periodically to check to see if the method call should be aborted.
	 void AbortCheck(bool *abort);
	 void PercentDone(int pctDone, bool *abort);

	 void ProgressInfo(const char *name, const char *value);

	 void HttpRedirect(const char *originalUrl, const char *redirectUrl, bool *abort);

	// Called just before a chunked response is about to be received.
	// With chunked responses, it is not possible to get PercentDone callbacks because
	// the entire size of the HTTP response is not known as it is being received.
	 void HttpChunked(void);

	 void HttpBeginReceive(void);
	 void HttpEndReceive(bool success);
	 void HttpBeginSend(void);
	 void HttpEndSend(bool success);

	 void ReceiveRate(unsigned long byteCount, unsigned long bytesPerSec);

};

#endif
