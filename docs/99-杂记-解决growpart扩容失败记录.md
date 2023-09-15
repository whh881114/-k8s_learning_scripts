# 解决growpart扩容失败记录

## 参考资料
- https://blog.51cto.com/u_16070335/6189155

## growpath扩容失败报错信息
```shell
[root@fake_hostname home]# growpart /dev/vdb 1
unexpected output in sfdisk --version [sfdisk，来自 util-linux 2.23.2]
[root@fake_hostname home]# 
```

## 解决方法
```shell
[root@fake_hostname ~]# LC_ALL=en_US.UTF-8 growpart /dev/vdb 1
CHANGED: partition=1 start=2048 old: size=419428352 end=419430400 new: size=629143519 end=629145567
[root@fake_hostname ~]# 
```

## 扩展：LANG、LC_ALL、LANGUAGE环境变量的区别
locale的设定： 
LC_ALL和LANG优先级的关系：LC_ALL > LC_* >LANG 
1、如果需要一个纯中文的系统的话，设定LC_ALL= zh_CN.XXXX，或者LANG=zh_CN.XXXX都可以。 
2、如果只想要一个可以输入中文的环境，而保持菜单、标题，系统信息等等为英文界面，那么只需要设定 LC_CTYPE＝zh_CN.XXXX，LANG=en_US.XXXX就可以了。 
3、假如什么也不做的话，也就是LC_ALL，LANG和LC_*均不指定特定值的话，系统将采用POSIX作为lcoale，也就是C locale。 

LANG和LANGUAGE的区别： 
LANG - Specifies the default locale for all unset locale variables 
LANGUAGE - Most programs use this for the language of its interface 
LANGUAGE是设置应用程序的界面语言。而LANG是优先级很低的一个变量，它指定所有与locale有关的变量的默认值  

```shell
[root@foreman.freedom.org ~ 14:32]# 6> locale
LANG=en_US.UTF-8
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL=
[root@foreman.freedom.org ~ 14:32]# 7> 
```
```shell
LC_ADDRESS (GNU extension, since glibc 2.2)
       Change  settings that describe the formats (e.g., postal addresses) used to describe locations and geography-related items.  Applications that need this information can use nl_langinfo(3)
       to retrieve nonstandard elements, such as _NL_ADDRESS_COUNTRY_NAME (country name, in the language of the locale) and _NL_ADDRESS_LANG_NAME (language name, in the language of the  locale),
       which return strings such as "Deutschland" and "Deutsch" (for German-language locales).  (Other element names are listed in <langinfo.h>.)

LC_COLLATE
       This  category  governs  the collation rules used for sorting and regular expressions, including character equivalence classes and multicharacter collating elements.  This locale category
       changes the behavior of the functions strcoll(3) and strxfrm(3), which are used to compare strings in the local alphabet.  For example, the German sharp s is sorted as "ss".

LC_CTYPE
       This category determines the interpretation of byte sequences as characters (e.g., single versus multibyte characters), character classifications (e.g.,  alphabetic  or  digit),  and  the
       behavior  of  character  classes.  On glibc systems, this category also determines the character transliteration rules for iconv(1) and iconv(3).  It changes the behavior of the character
       handling and classification functions, such as isupper(3) and toupper(3), and the multibyte character functions such as mblen(3) or wctomb(3).

LC_IDENTIFICATION (GNU extension, since glibc 2.2)
       Change settings that relate to the metadata for the locale.  Applications that need this information can use nl_langinfo(3) to  retrieve  nonstandard  elements,  such  as  _NL_IDENTIFICA‐
       TION_TITLE  (title  of  this  locale document) and _NL_IDENTIFICATION_TERRITORY (geographical territory to which this locale document applies), which might return strings such as "English
       locale for the USA" and "USA".  (Other element names are listed in <langinfo.h>.)

LC_MONETARY
       This category determines the formatting used for monetary-related numeric values.  This changes the information returned by localeconv(3), which describes  the  way  numbers  are  usually
       printed, with details such as decimal point versus decimal comma.  This information is internally used by the function strfmon(3).
LC_MESSAGES
       This  category  affects  the  language  in which messages are displayed and what an affirmative or negative answer looks like.  The GNU C library contains the gettext(3), ngettext(3), and
       rpmatch(3) functions to ease the use of this information.  The GNU gettext family of functions also obey the environment variable LANGUAGE (containing a colon-separated list  of  locales)
       if the category is set to a valid locale other than "C".  This category also affects the behavior of catopen(3).

LC_MEASUREMENT (GNU extension, since glibc 2.2)
       Change  the  settings  relating to the measurement system in the locale (i.e., metric versus US customary units).  Applications can use nl_langinfo(3) to retrieve the nonstandard _NL_MEA‐
       SUREMENT_MEASUREMENT element, which returns a pointer to a character that has the value 1 (metric) or 2 (US customary units).

LC_NAME (GNU extension, since glibc 2.2)
       Change settings that describe the formats used to address  persons.   Applications  that  need  this  information  can  use  nl_langinfo(3)  to  retrieve  nonstandard  elements,  such  as
       _NL_NAME_NAME_MR  (general  salutation for men) and _NL_NAME_NAME_MS (general salutation for women) elements, which return strings such as "Herr" and "Frau" (for German-language locales).
       (Other element names are listed in <langinfo.h>.)

LC_NUMERIC
       This category determines the formatting rules used for nonmonetary numeric values—for example, the thousands separator and the radix character (a period  in  most  English-speaking  coun‐
       tries, but a comma in many other regions).  It affects functions such as printf(3), scanf(3), and strtod(3).  This information can also be read with the localeconv(3) function.

LC_PAPER (GNU extension, since glibc 2.2)
       Change  the  settings  relating to the dimensions of the standard paper size (e.g., US letter versus A4).  Applications that need the dimensions can obtain them by using nl_langinfo(3) to
       retrieve the nonstandard _NL_PAPER_WIDTH and _NL_PAPER_HEIGHT elements, which return int values specifying the dimensions in millimeters.

LC_TELEPHONE (GNU extension, since glibc 2.2)
       Change settings that describe the formats to be used with telephone services.  Applications that need this information can use nl_langinfo(3) to retrieve  nonstandard  elements,  such  as
       _NL_TELEPHONE_INT_PREFIX (international prefix used to call numbers in this locale), which returns a string such as "49" (for Germany).  (Other element names are listed in <langinfo.h>.)

LC_TIME
       This  category  governs the formatting used for date and time values.  For example, most of Europe uses a 24-hour clock versus the 12-hour clock used in the United States.  The setting of
       this category affects the behavior of functions such as strftime(3) and strptime(3).

LC_ALL All of the above.              
```