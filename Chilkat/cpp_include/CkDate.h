// CkDate.h: interface for the CkDate class.
//
//////////////////////////////////////////////////////////////////////

#ifndef _CKDATE_H
#define _CKDATE_H



#include "CkString.h"
#include "SystemTime.h"

#include "CkObject.h"

#ifndef __sun__
#pragma pack (push, 8)
#endif
 

// Have all methods return a CkDateTime object instead of SYSTEMTIME...

/*
ticks
    Type: System.Int64
    A date and time expressed in the number of 100-nanosecond intervals that have elapsed since January 1, 0001 at 00:00:00.000 in the Gregorian calendar. 
    */

// time() returns the time as the number of seconds since the Epoch, 1970-01-01 00:00:00 +0000 (UTC). 

// Windows: SYSTEMTIME and FILETIME

// struct tm

// DOS date/time

// RFC formatted strings.


// CLASS: CkDate
class CkDate  : public CkObject
{
    private:

	void *m_impl;
	
	// Don't allow assignment or copying these objects.
	CkDate(const CkDate &) { } 
	CkDate &operator=(const CkDate &) { return *this; }
	CkDate(void *impl) : m_impl(impl) { }

    public:
    	
	void *getImpl(void) const { return m_impl; } 

	CkDate();
	virtual ~CkDate();

	// BEGIN PUBLIC INTERFACE
	
	bool fromSystemTime(SYSTEMTIME &sysTime);
	void toSystemTime(SYSTEMTIME &sysTime);

	// Number of seconds since January 1, 1970
	double toSecondsSince1970(void);
	void fromSecondsSince1970(double numSec);


	// DATE_INSERT_POINT

	// END PUBLIC INTERFACE

	


};
#ifndef __sun__
#pragma pack (pop)
#endif



#endif


