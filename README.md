# scripts4bgthai
Scripts and sources for creating html files for Bhagavad Gita As It Is in Thai language

### pdf2html

pdf2html.pl is a perl script used to output html files which are served via bgthai.github.io, these files are not included here.

What is included are source files - raw html, but without css and js so they are pretty useless on their own, and various other files like verse and chapter sequences etc.

This is not the actual directory I run my perl script from, rather it's a copy of what I use for this specific script only. For this reason the source files are put into directories with names that make little sense here. Their names make sense for me as I created them long time ago and I preserved them here so that paths in the perl script work without modifications. There are some paths that won't work on your machine without recreating them - the parts where perl copies files to this git directory, they are commented out so the script would still run. Otherwise, you'd just need a working perl with the same modules installed. I'm currently on 5.38, the script calls for 5.032, but that is not essential - any later version of Perl should work just fine.

Anyway, this part of the work is basically done, but if you need custom html for your site then that's what we can workd together and create new scripts that would work everywhere.

### gd2wp

These are bash scripts to automate converting twenty or so Google Docs files to text. Thai editors work in Google Docs, I need to get text files from that. The idea is that we need to preserve mark up for italics which are processed differently from the rest of the text, because they use Pali Sanskrit transliteration.

There are two steps involved - copy paste from Google Docs to Wordpress editor (called Gutenberg, afaik) and then switch Wordpress to code view and copy paste from there into a text file.

Saving Google Docs as html creates too much unnecessary mark up to deal with later, and it first comes as a zip file, too. When passed through Wordpress html mark up is minimal, like here:

```
<!-- wp:paragraph -->
<p><em>อรฺชุนห์ อุวาจ</em> - <em>อรฺชุน</em> ตรัส, <em>มตฺ-อนุคฺรหาย</em> — เพื่อแสดงความอนุเคราะห์ต่อข้า, <em>ปรมมฺ</em> — สูงสุด, <em>คุหฺยมฺ</em> — เรื่องลับ, <em>อธฺยาตฺม</em> — ทิพย์,+<em>สํชฺญิตมฺ</em> — ในเรื่องของ, <em>ยตฺ</em> — อะไร, <em>ตฺวยา</em> — โดยพระองค์, <em>อุกฺตมฺ</em> — ตรัส, <em>วจห์</em> — คำพูด, <em>เตน</em> — ด้วยนั้น, <em>โมหห์</em> — ความหลง, <em>อยมฺ</em> — นี้, <em>วิคตห์</em> — ขจัดออกไป, <em>มม</em> — ของข้า</p>
<!-- /wp:paragraph -->
```
Compare this to what comes from Google Docs:

```
<p class="c1"><span class="c0 c10">&#3618;&#3605;&#3642; &#3605;&#3642;&#3623;&#3650;&#3618;&#3585;&#3642;&#3605;&#3661; &#3623;&#3592;&#3626;&#3642; &#3648;&#3605;&#3609; &nbsp;&#3650;&#3617;&#3650;&#3627; &rsquo;&#3618;&#3661; &#3623;&#3636;&#3588;&#3650;&#3605; &#3617;&#3617;</span></p><p class="c15"><span class="c0">&#3629;&#3619;&#3642;&#3594;&#3640;&#3609;&#3627;&#3660; &#3629;&#3640;&#3623;&#3634;&#3592;</span><span class="c2">&nbsp;- </span><span class="c0">&#3629;&#3619;&#3642;&#3594;&#3640;&#3609;</span><span class="c2">&nbsp;&#3605;&#3619;&#3633;&#3626;</span><sup><a href="#cmnt1" id="cmnt_ref1">[a]</a></sup><span class="c2">, </span><span class="c0">&#3617;&#3605;&#3642;-&#3629;&#3609;&#3640;&#3588;&#3642;&#3619;&#3627;&#3634;&#3618;</span>...
```
And it's all in one super long line of text, too, so good luck figuring out where to split it into paragraphs.

Anyway, Google Docs to Wordpress conversion can be done manually and that's what I do it for incorporating edits for one chapter only, but to process the whole Bhagavad Gita there needs to be lots of clicks and copy pasting, which **gd2wp** scripts automate. There are two of them, the original was written for X and relies on **xdotool**, the current one is written for Wayland where xdtotools do not work and are replaced with **dotool**. How to set dotool daemon up and running on Wayland is beyond the scope of this readme. Automated mousemoves would need different coordinates on different displays and in different browsers, so adjust as needed.

Modify your Wordpress link  and location of output files as necessary, and included chapterUrls.txt won't work unless you have BBT permission to view these files - this is to avoid dealing with copyright issues. Without access to Google Docs this script would be useless.

Oh, and I have no idea how this automation could be done on Windows, sorry.

### wp2txt

This is the most troublesome script. It's meant to take text files produced by **gd2wp** and convert them into "mother" th-bg-masterPlusWP.txt file that is used as a basis for production of all other presentations like books and websites.

It's troublesome because lots of errors and typos made by editors have to be caught here. The master text file must follow English original very strictly - the same number of lines and the same content on each line. Something like "line 867 must be translation of verse X" and nothing else, and "line 1008 must be the third paragraph in the purport to verse Y". Sanskrit words are fixed in English, too, but Thai transliteratioin may potentially vary, so the master file contains Roman IAST transliteration only whereas editors work with Thai transliteration in Google Docs. If they make any changes to Pali Sanskrit there, the script should throw an error.

When an error is detected I first have to check with my source text files produced by **gd2wp**. If it's not there I have to go back to Google Docs, and in Google Docs I can fix some errors and for others I have to ask the editors. If there are lots of edits to process this back and forth might take days.

Generally, the process goes like this - the script backs up and then reads the existing masterfile, processes text files saved from Wordpress, dumps all the lines into one file for checking, converts text to "motherFile" format and overwrites the existing "motherFile" if there are no fatal errors. Otherwise errors are written in yet another file for checking and correcting.

In th-bg-masterPlusWP.txt "plus" means original English file with addition of "About Author" and "Glossary", and WP means it comes from Wordpress. At least that's how I remember naming it.

There are no comments in the perl script itself that would explain how it works. Maybe eventually I get around to doing it.

A few words on transliteration. This script uses two helper files with the fixed Roman IAST spelling and corresponding Thai Pali Sanskrit transliterations. These transliterations were originally made by using [Akshramakukha software](https://www.aksharamukha.com/python) but near the end of the files there is a significant number of manual additions and overwrites. The script reads these files line by line into hash so whatever is added at the end overwrites same lines in the beginning. This is because there are editorial decisions to use this or that spelling for certain words regardless of auto-transliterations by Aksharamukha, and also because sometimes Sanskrit quotations are split in different ways or news ones are needed,so I added them at the bottom instead of searching where they would fit alphabetically. There two text files are the main dictionary for this entire project, so they are super important.

Finally, the script takes line number from which to proceed so that it doesn't process from the begininng each time. This line number is shown in the error collecting file. Providing this line number is not necessary but it just makes it faster when errors go into dozens or even hundreds.



