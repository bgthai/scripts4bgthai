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

Modify your Wordpress link  as necessary, and included chapterUrls.txt won't work unless you have BBT permission to view these files - this is to avoid dealing with copyright issues. Without access to Google Docs this script would be useless.

Oh, and I have no idea how this automation could be done on Windows, sorry.



