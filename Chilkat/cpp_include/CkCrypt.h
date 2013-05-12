// CkCrypt.h: interface for the CkCrypt class.
//
//////////////////////////////////////////////////////////////////////

#ifndef _CKCRYPT_H
#define _CKCRYPT_H



#ifdef WIN32
class CkCsp;
#endif

class CkCert;
class CkCertStore;
#include "CkString.h"
class CkByteData;
#include "CkMultiByteBase.h"

#ifndef __sun__
#pragma pack (push, 8)
#endif
 

// CLASS: CkCrypt
class CkCrypt  : public CkMultiByteBase
{
    private:
	// Don't allow assignment or copying these objects.
	CkCrypt(const CkCrypt &) { } 
	CkCrypt &operator=(const CkCrypt &) { return *this; }
	CkCrypt(void *impl);

    public:

	CkCrypt();
	virtual ~CkCrypt();

#if defined(WIN32) && !defined(__MINGW32__)
	bool SetCSP(const CkCsp *csp);
#endif

	// BEGIN PUBLIC INTERFACE


#if defined(WIN32) && !defined(__MINGW32__)
	bool SetCSP(const CkCsp &csp) { return SetCSP(&csp); }
#endif
	void SetAlgorithmRSA();
	void SetAlgorithmTwofish();
	void SetAlgorithmBlowfish();
	void SetAlgorithmRijndael();

#if defined(WIN32) && !defined(__MINGW32__)
	bool AddSearchCertStore(const CkCertStore *certStore);
#endif

	bool SetEncryptCertificate(const CkCert *cert);
	bool SetSigningCertificate(const CkCert *cert);

	bool UnlockComponent(const char *unlockCode);
	bool IsUnlocked(void) const;

	void get_LastCertSubject(CkString &str);
	void get_LastAlgorithm(CkString &str);

	void get_SigningCertSubject(CkString &str);
	void put_SigningCertSubject(const char *str);

	void get_EncryptCertSubject(CkString &str);
	void put_EncryptCertSubject(const char *str);

	//bool get_UseStandardSearchCertStores(void);
	//void put_UseStandardSearchCertStores(bool newVal);

	// Key length is implied by the length of the secret key.
	void get_SecretKey(CkByteData &data);
	void put_SecretKey(const unsigned char *pByteData, unsigned long szByteData);

	// Generate a secret key according to a particular method.
	void PassPhraseToSecretKey(const char *newVal);

	long get_KeyLength(void);
	void put_KeyLength(long newVal);

	bool CreateSignature(const unsigned char *pByteData, unsigned long szByteData, CkByteData &outSigData);
	bool VerifySignature(const unsigned char *pByteData, unsigned long szByteData, 
	    const unsigned char *sig, unsigned long sigLen);

	bool Encrypt(const unsigned char *pByteData, unsigned long szByteData, CkByteData &outData);
	bool Decrypt(const unsigned char *pByteData, unsigned long szByteData, CkByteData &outData);

	void Base64Encode(const unsigned char *pByteData, unsigned long szByteData, CkString &outStr);
	bool Base64Decode(const char *str, CkByteData &outData);

	void QuotedPrintableEncode(const unsigned char *pByteData, unsigned long szByteData, CkString &outStr);
	bool QuotedPrintableDecode(const char *str, CkByteData &outData);
	
	void HexEncode(const unsigned char *pByteData, unsigned long szByteData, CkString &outStr);
	void HexDecode(const char *str, CkByteData &outData);

	void CalcDigestMD5(const unsigned char *pByteData, unsigned long szByteData, CkByteData &outData);
	bool CalcSha1Hash(const unsigned char *pByteData, unsigned long szByteData, CkByteData &outData);
	bool CalcMd2Hash(const unsigned char *pByteData, unsigned long szByteData, CkByteData &outData);

	bool get_HasIV(void);
	void put_HasIV(bool b);

	void get_IV(CkByteData &db);
	void put_IV(const unsigned char *ivData);

	void GenerateRandomIV(void);

	bool ZipAndEncrypt(const unsigned char *pByteData, unsigned long szByteData, CkByteData &outData);
	bool DecryptAndUnzip(const unsigned char *pByteData, unsigned long szByteData, CkByteData &outData);


	// CRYPT_INSERT_POINT

	// END PUBLIC INTERFACE

};
#ifndef __sun__
#pragma pack (pop)
#endif



#endif


