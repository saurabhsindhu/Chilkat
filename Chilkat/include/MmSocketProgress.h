

#ifndef _MM_SocketProgress_H
#define _MM_SocketProgress_H

#include "../ChilkatLib/Package/include/CkSocketProgress.h"

// Progress callback C++ class w/ implementation source file as .mm
// to allow for relaying of callbacks back into Objective-C apps.

// DO NOT USE MULTIPLE INHERITANCE
class MmSocketProgress : public CkSocketProgress
{
	private:
		void *m_objc_callback;
	
    public:
    
    void setObjcCallback(void *cb);
    	
	MmSocketProgress();
	 ~MmSocketProgress();

	void AbortCheck(bool *abort);
	void PercentDone(int pctDone, bool *abort);
	 void ProgressInfo(const char *name, const char *value);


	// Asynch socket completion events.
	void DnsComplete(int objectId, const char *hostname, const char *ipAddress, bool success);
	void ConnectComplete(int objectId, const char *hostname, long port, bool success);
	void AcceptComplete(int objectId, const char *ipAddress, long port, bool success);
	void ReverseDnsComplete(int objectId, const char *ipAddress, const char *hostname, bool success);
	void SendComplete(int objectId, long numBytes, bool success);
	void ReceiveBytesComplete(int objectId, const unsigned char *bytesReceived, unsigned long numBytesReceived, bool success);
	void ReceiveStringComplete(int objectId, CkString &strReceived, bool success);

};

#endif
