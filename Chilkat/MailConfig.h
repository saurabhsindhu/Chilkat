//
//  MailConfig.h
//  DzMail
//
//  Created by JD YANG on 12. 1. 12..
//  Copyright (c) 2012년 DUZON C&T. All rights reserved.
//

#ifndef DzMail_MailConfig_h
#define DzMail_MailConfig_h

// Version check. I raise one whenever you need to initialize the DB-mail.
// Raise of 2.0, 9.18,
// Raise 9.19 to 2.1.
#define MailVersion @"2.3"

// Defined below, the mailbox is necessary to arrange
#define Mail__SentMessageBoxName__  @"Sent Items"
#define Mail__DraftMessageBoxName__ @"Draft"
#define Mail__SpamMessageBoxName__  @"spam"
#define Mail__InboxMessageBoxName__ @"inbox"
#define Mail__DeletedMessagesBoxName__    @"del mssg"

#define Mail__UseMailCount 1

// UI 
#define MailOneIndentWidth 23 //Mailbox name Deapth per pixel shift position
#define DISTANCE_MAIL_IMAGE 23 // Mailbox name and e-mail images

// Synchronization settings
#define Mail__CACHENUM__    50 // E-mail cache, the number of
#define Mail__SYNC_Interval 3  //X Seconds later, a new sink.

// Plain HTML conversion
//#define MAIL__PlainToHtmlPre @"<HTML><HEADER><meta name='viewport' content='initial-scale=2.0'/></HEADER><BODY>"
#define MAIL__PlainToHtmlPre @"<HTML><HEADER><meta name='viewport' content='user-scalable=no, initial-scale=1.0, maximum-scale=3.0, minimum-scale=1.0, width=device-width' /><style>body{margin:0;padding:5;width:645px;}</style><script language='javascript'>var uagent = navigator.userAgent.toLowerCase();var objHead = document.getElementsByTagName('head')[0];var xWidth = null;\
if (window.screen != null) xWidth = window.screen.availWidth;\
if (window.innerWidth != null) xWidth = window.innerWidth;\
if (document.body != null) xWidth = document.body.clientWidth;\
var scale = xWidth / 655;\
var metaSC = document.createElement('meta');metaSC.name = 'viewport';\
if (uagent.search('android') > -1) metaSC.content = 'user-scalable=yes, initial-scale=1.0, maximum-scale=3.0, minimum-scale=1.0, width=655';\
else metaSC.content = 'user-scalable=yes, initial-scale=' + scale + ', maximum-scale=3.0, minimum-scale=' + scale + ', width=655';\
objHead.appendChild(metaSC);\
function fn_EX_Aattch_File_View(id) { location.href = 'app:attach;' + id + ';'; }\
</script>\
</HEADER><BODY>"
#define MAIL__PlainToHtmlPost @"</BODY></HTML>"

//Mail whether Setting uiwebviewController ScaleToFit screen.
#define SnippetV_ScaleToFit   YES

//Set whether you want only mail write the name you want to include, e-mail
#define MAIL_WRITE_REMOVE_NAME 1

// Select a search method on the server.
// If you enter the wrong way below to continue your search from the server is not available.
#define MAIL__SearchCommand(str) [NSString stringWithFormat:@"OR (OR FROM %@ TO %@) SUBJECT %@",str, str,str]


// Determine the unicode server less. NULL when you do not need to can choose.
// * UTF-7 from iOS library.//#define MAIL__UNICODECHECK_MAILSERVER NULL
#define MAIL__UNICODECHECK_MAILSERVER @"mail.duzon.com"
// The name of the mailbox on the server, you must Hangul less
#define MAIL__UNICODECHECK_REQUIREDMAILBOX @"Inbox"

//Do not modify the information below.
#define MAIL__LASTRESPONSE_CHECK 0

// The server is NOOP anmeok in DUZON. Is instead of NOOP selectmailbox,.
#define NOOP_IS_SELECTED_MAILBOX 0

#endif
