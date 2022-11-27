# HiJinx
Chromium browsers (such as *Chrome* and *Edge*) store their saved user logins & passwords in an encrypted SQLite database located at:

`%LocalAppData%\<Chromium Version Directory>\User Data\<Chromium Profile>\Login Data`

HiJinx converts this login data into something human-readable. It even has a decent go at decrypting some of the passwords by employing the .NET System.Security class.

This code is (like most of my scripts) incredibly verbose and extensivley commented. Efficient and elegant? No. But modular and easy to follow? I like to think so.

## Main Menu
- ### Chrome
HiJinx all User's Chrome profiles.
- ### Edge
HiJinx all User's Edge profiles.
- ### All
HiJiinx runs on ALL User's Chrome profiles AND all User's Edge profiles.
- ### Custom
Input your own filepath to a `Login Data` file to be HiJinxed.
- ### Log to file
Everything you HiJinx session gets added to a log. Selecting this option will that log will get written to a file in the same directoy that the HiJinx script is in.
- ### q
Quit

## System.Data.SQLite.dll

**This .dll file must be kept in the same directory as the HiJinx script for it to function.** It is the SQLite database engine that powers the requests made to the *Login Data* file. The System.Data.SQLite library is public domain and can be found here: https://system.data.sqlite.org/

Included in this package is version `1.0.117.0`
