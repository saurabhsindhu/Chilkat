

#ifndef _MMFTP2PROGRESS_H
#define _MMFTP2PROGRESS_H

#include "../ChilkatLib/Package/include/CkFtpProgress.h"

// Progress callback C++ class w/ implementation source file as .mm
// to allow for relaying of callbacks back into Objective-C apps.

// DO NOT USE MULTIPLE INHERITANCE
class MmFtp2Progress : public CkFtpProgress
{
	private:
		void *m_objc_callback;
	
    public:
    
     	void setObjcCallback(void *cb);
    	
	 MmFtp2Progress();
	 ~MmFtp2Progress();
	 
	 void FtpPercentDone(long pctDone, bool *abort);
	 void AbortCheck(bool *abort);


	// Called to notify the application of the port number of the data connection
	// being used for Active connections (as opposed to Passive connections).
	// For Active data transfers, the client creates a data socket and chooses
	// a random port number between 1024 and 5000.
	void DataPort(int portNumber);

	void BeginDownloadFile(const char *pathUtf8, bool *skip);
	void EndDownloadFile(const char *pathUtf8, unsigned long numBytes);
	void VerifyDownloadDir(const char *pathUtf8, bool *skip);

	void BeginUploadFile(const char *pathUtf8, bool *skip);
	void EndUploadFile(const char *pathUtf8, unsigned long numBytes);
	void VerifyUploadDir(const char *pathUtf8, bool *skip);

	void VerifyDeleteDir(const char *pathUtf8, bool *skip);
	void VerifyDeleteFile(const char *pathUtf8, bool *skip);

	void UploadRate(unsigned long byteCount, unsigned long bytesPerSec);
	void DownloadRate(unsigned long byteCount, unsigned long bytesPerSec);

	void ProgressInfo(const char *name, const char *value);


};

#endif
