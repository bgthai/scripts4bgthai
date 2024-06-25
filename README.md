# scripts4bgthai
Scripts and sources for creating html files for Bhagavad Gita As It Is in Thai language

This is a perl script used to output html files which are served via bgthai.github.io, these files are not included here.

What is included are source files - raw html, but without css and js so they are pretty useless on their own, and various other files like verse and chapter sequences etc.

This is not the actual directory I run my perl script from, rather it's a copy of what I use for this specific script only. For this reason the source files are put into directories with names that make little sense here. Their names make sense for me as I created them long time ago and I preserved them here so that paths in the perl script work without modifications. There are some paths that won't work on your machine without recreating them - the parts where perl copies files to this git directory, they are commented out so the script would still run. Otherwise, you'd just need a working perl with the same modules installed. I'm currently on 5.38, the script calls for 5.032, but that is not essential - any later version of Perl should work just fine.

Anyway, this part of the work is basically done, but if you need custom html for your site then that's what we can workd together and create new scripts that would work everywhere.
