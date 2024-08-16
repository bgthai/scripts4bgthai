#!/usr/bin/perl
use strict;
use warnings;
no warnings 'uninitialized';
use Data::Dumper; #say Dumper \@array or print Dumper (\@array);
use 5.032;
use utf8;
binmode STDOUT, ":utf8";
binmode STDIN, ":utf8";
use HTML::Strip;
use Text::Diff;#uninstall this thing when you have time
use Text::Levenshtein::XS qw/distance/;
use File::Copy;
#use POSIX qw(strftime);
use Time::Piece;

my $last =  $ARGV[0];
$last = 1 if $last !~ /^\d+$/;

#my $date = localtime->strftime('%d.%m.%y');
my $date = localtime->dmy('.');
say $date;

my %en2PaliDict;
my %pali2EnDict;
my @enArr;
my @paliArr;


open (my $fhenD, '<:encoding(UTF-8)', 'vedabase/aksaraIsArrayEn.txt') or die "$!";
while (my $row = <$fhenD>){
   chomp $row;
   push @enArr, $row;
}
close $fhenD;


open (my $fhpaliD, '<:encoding(UTF-8)', 'vedabase/aksaraIsArrayPali.txt') or die "$!";
while (my $row = <$fhpaliD>){
   chomp $row;
   push @paliArr, $row;
}
close $fhpaliD;





for my $iarr (0 ..$#enArr){
   $en2PaliDict{$enArr[$iarr]} = $paliArr[$iarr];
   $pali2EnDict{$paliArr[$iarr]} = $enArr[$iarr];
}

$en2PaliDict{'Kṛṣṇa'} = 'กฺฤษฺณ';


open (my $fhhardhy, '<:encoding(UTF-8)', 'vedabase/hardHyphens.txt') or die "$!";
while (my $row = <$fhhardhy>){
   chomp $row;
   my($pali,$eng) = split '::',$row;
   #say $pali. ' - '.$eng;
   $en2PaliDict{$eng} = $pali;
   $pali2EnDict{$pali} = $eng;
}
close $fhhardhy;

open (my $fhsofthy, '<:encoding(UTF-8)', 'vedabase/softHyphens.txt') or die "$!";
while (my $row = <$fhsofthy>){
   chomp $row;
   my($pali,$eng) = split $row,'::';
   #say $pali. ' - '.$eng;
   #$en2PaliDict{$eng} = $pali;
   #$pali2EnDict{$pali} = $eng;
}
close $fhhardhy;
open (my $fhhhy, ">>:encoding(UTF-8)", "vedabase/hardHyphens.txt") or die "$!";
open (my $fhshy, ">>:encoding(UTF-8)", "vedabase/softHyphens.txt") or die "$!";

my %codes;
open (my $fh, '<', 'modules/code2style.txt') or die "$!";
while (my $row = <$fh>){
   chomp $row;
   my ($code) = $row =~ /^(\@.*= )/;
   #say Dumper \@keys;
   $codes{$code} = 'process';
}
$codes{'@para-no-indent = '} = 'process';
close $fh;


copy("yourExistingMaster.txt", "yourExistingMaster.$date.txt") or die "Copy master text failed: $!";

my @inPlus;

open (my $fin, "<:encoding(UTF-8)", "yourExistingMaster.txt") or die "$!";
while (my $row = <$fin>){
   chomp  $row;
   #say $row if $ln==39;
   #next if $row eq '';
   #next if $row =~ /\@language/;
   #next if $row =~ /\@book/;
   $row =~ s/<i><\/i>//g;
   push @inPlus, $row;
}
close $fin;

my @wp;
my @wploc;

for (0 .. 20){
   my $wpl=$_;
   #say $wp;
   open (my $fwp, "<:encoding(UTF-8)", "whereYourGd2wpFilesAre/wp.$wpl.txt") or die "$!";
   while (my $row = <$fwp>){
      chomp  $row;


      #if($row =~ s/\s+\x{201d}/\x{201d}/g){
      #   my $noTag = stripTags ("$row");
      #   say 'Ch '.$wpl.' : '.$noTag;
      #}





      next if substr($row,0,2) eq '<!';
      next if $row eq '';
      next if $row eq '<h1 class="wp-block-heading"></h1>';
      $row =~ s/\s/ /g;
      if($wpl == 0 and substr($row,0,10) eq '<p>1. <em>'){
         #say "\n\n\n\n\n\n\n$row";
         push @wp,$row;
         push @wploc,$wpl;
         last;
      }
      #say $row;
      push @wp,$row;
      push @wploc,$wpl;
   }
}

open (my $for, ">:encoding(UTF-8)", "whereYouWant2seeAllyourLines.txt") or die "$!";
#foreach (@wp){
for my $n (0 .. $#wp){
   #say $for "$wploc[$n]. $wp[$n]";
   say $for $wp[$n];
}
close $for;

my @out;


my $verseflag = 'off';

my $ln=0;
my $versenum;
my $badPali = 1;

my @shifts;


my $hyphencount=1;

foreach(@inPlus){
   
   $ln++;
   #@shifts = ();
   #say $fout "$ln. $_";
   #say "$ln. $_";
   #say "At 5116 in wp it's: $wp[0]" if $ln == 5116;
   #say "At 5117 in wp it's: $wp[0]" if $ln == 5117;
   #say "At 5119 in wp it's: $wp[0]" if $ln == 5119;
   #say "At 5120 in wp it's: $wp[0]" if $ln == 5120;
   #say "At 5121 in wp it's: $wp[0]" if $ln == 5121;
   #say "At 5122 in wp it's: $wp[0]" if $ln == 5122;
   

   #say $fout $_;
   #say $_;#.' - in master txt';
   my $line = $_;
   my ($code, $txt) = $_ =~ /(.* = )(.*)/;
   $versenum = $txt if $code eq '@code = ';
   #if($txt eq 'glossary'){
   #   say 'Code = glossary, shifts empty, wp[0]:';
   #   #foreach(@shifts){
   #   #   say $_;
   #   #}
   #   #say '^end of shifts';
   #   say substr($wp[0],0,20);
   #}
   #if($versenum eq 'about-author'){
   #   say 'Code = about-author, shifts:';
   #   foreach(@shifts){
   #      say $_;
   #   }
   #   say '^end of shifts';
   #   say 'wp[0]:';
   #   say substr($wp[0],0,30);
   #   say '^end of wp[0]';
   #   say '';
   #}

   if($code eq '@para-title = '){
      #say 'Working on para-title now, wpt is:';
      #say $wp[0];
      push @shifts, shift @wp;
      #shift @wp;
      shift @wploc;
   }
   #say $ln if $code eq '@stop = ';
   if(! exists($codes{$code})){
      #say $fout $line;
      push @out, $line;
      next;
   }
   #say "process: $_";

   my $wpt; my $wpch; my $owpt;
   
   #if( $code eq '@sans = ' and $wp[0] =~ /—/){
   if( substr($code,0,5) eq '@sans' and $wp[0] =~ /—/){
      
      #say $fout $line;
      push @out, $line;
      #say "Skipping on verseflag : $verseflag and wp[0]:\n$wp[0]\ncontinued";
      next;
   }else{
      if($code eq '@ch-title = ' and ($versenum eq 'about-author' or $versenum eq 'glossary')){
         #say $fout $line;
         #say $line;
         push @out, $line;
         next;
      }


      #if($versenum eq 'about-author'){
      #   say 'Shifting each new line, on code '.$code.' got wp[0]: '.substr($wp[0],0,40);
      #}
      $wpt = shift(@wp);
      push @shifts, "$ln  here:$line\n\n$wpt";
      $wpch = shift(@wploc);
      $owpt = $wpt;
      #if($versenum eq 'about-author'){
      #   say 'Shifted new line, on code '.$code.' got wp[0]: '.substr($wp[0],0,40);
      #}
   }
   #if($ln == 37){
   #   say "line $ln, wpt: $wpt";
   #}
   #if($ln == 38){
   #   say "line $ln, wpt: $wpt";
   #}
   #if($ln == 39){
   #   say "line $ln, wpt: $wpt";
   #}
   #if(substr($wpt,0,2) eq '<f'){ #for figure class="...
   #   say "before shift: $wpt";
   #   $wpt = shift(@wp);
   #   push @shifts, $wpt;
   #   say "pushed into array: $wpt";
   #   $wpch = shift(@wploc);
   #   $owpt = $wpt;
   #}
   
   if($code eq '@chapter = '){
      if(substr($wpt,0,2) ne '<h' and $txt ne 'คำนำ' ){
         say 'No chapter start in wpt '.$wploc[0].':';
         say "In wplines: $wpt";
         say "Txt: $txt";

         say $ln;
         last;
      }
      #my $hs = HTML::Strip->new();
      #my $noTag = $hs->parse( $wpt );
      #$hs->eof;
      ##say $noTag;
      my $noTag = stripTags ("$wpt");
      $wpt = $code.$noTag;
   }
   if($code eq '@para-centered = '){# dedication
      #$wpt = $line;
      #@wp = @wp[ 4 ..$#wp];
      #@wploc = @wploc[ 4 ..$#wploc];
      # ^ that was old dedication copied from old file

      #say 'processing dedication para-centered';
      #say "wpt: $wpt";
      #say "wp[0]: $wp[0]";
      #say "wploc: $wploc[0]";
      #say "wp[1]: $wp[1]";
      #say "wploc: $wploc[1]";

      $wpt .= '<br />';
      $wpt .= shift @wp;
      $wpt .= '<br />';
      $wpt .= shift @wp;
      #$wpt .= '<br>';
      #$wpt =~ s/\s*$//;

      $wpt =~ s/<p>//g;
      $wpt =~ s/<\/p>//g;
      $wpt =~ s/\s*$//;
      $wpt = $code.$wpt;
      #say "'$wpt'";

      shift @wploc;
      shift @wploc;
      

   }
   if($code eq '@para = '){
      if(substr($wpt,0,3) ne '<p>'){
         say 'No para start in wpt '.$wploc[0].':';
         say $wpt;
         say $ln;
         last;
      }
      $wpt = substr($wpt,3);
      $wpt = substr($wpt,0,-4);
      $wpt = $code.$wpt;
      #if($versenum eq 'about-author'){
      #   say 'Para in about-author';
      #   #foreach(@shifts){
      #   #   say $_;
      #   #}
      #   #say '^end of shifts';
      #   say 'Wpt starts with: '.substr($wpt,0,40);
      #   #say 'wp[0]:';
      #   #say substr($wp[0],0,30);
      #   #say '^end of wp[0]';
      #   say '';
      #}
   }
   if($code eq '@para-no-indent = '){
      #$wpt = $line;
      #@wp = @wp[ 2 ..$#wp];
      #@wploc = @wploc[ 2 ..$#wploc];
      #say "\n\n para-no-indent, next line in wp:";
      #say $wp[0];
      # ^ that was before sign-off was edited, same as in dedication

      #say 'processing signoff in preface';
      #say "wpt: $wpt";
      #shift @wp;
      #say "after shift:$wpt";
      #shift @wploc;
      $wpt = shift @wp; shift @wploc;
      #say "after shift:$wpt";
      #say "wpt: $wpt";
      #say "wp[0]: $wp[0]";
      #say "wploc: $wploc[0]";
      #say "wp[1]: $wp[1]";
      #say "wploc: $wploc[1]";
      $wpt .= '<br />';
      $wpt .= shift @wp;
      $wpt .= '<br />';
      $wpt .= shift @wp;
      $wpt .= '<br>';
      $wpt =~ s/<p>//g;
      $wpt =~ s/<\/p>//g;
      $wpt = $code.$wpt;
      shift @wploc;
      shift @wploc;
   }
   if($code eq '@sans = '){
      
      if($verseflag ne 'off'){
         #say "Verseflag is on for $verseflag";
         #say "wp[0] is\n$wp[0]\n\ncontinued\n";
         until($wp[0] =~ /—/){
            #shift @wp;
            push @shifts, shift @wp;
            shift @wploc;
         }
         #$verseflag = 'off';
         $wpt = $line;
         #say "For line $ln shift wp ended with wp[0]:\n$wp[0]\ncontinued";
         #say $fout $wpt;
         push @out, $wpt;
         next;
      }else{

         my ($lastChunk) = $txt =~ /.*<br \/>(.*)$/g;
         #say "\n\nLooking for $lastChunk";
         my $thaiChunk = $en2PaliDict{$lastChunk};
         #say "In Thai it's : $thaiChunk";
         my $chunks = () = $txt =~ /<br \/>/g;
         for ( 1 .. $chunks ){
            shift(@wploc);
            $wpt = shift(@wp);
            push @shifts, "$ln $wpt";
            last if $wpt =~ /$thaiChunk/;
         }
      }
      #say "Last we got from wp is : $wpt";
      $wpt = $line;
   }
   if($code eq '@wbw = '){
      $verseflag = 'off';
      $wpt =~ s/<p>//;
      $wpt =~ s/<\/p>//;
      $wpt = $code.$wpt;
   }
   if($code eq '@trans = '){
      $wpt =~ s/<p>//;
      $wpt =~ s/<\/p>//;



      if($wpt =~ /\x{201c}/){
         #say " Ch. $wploc[0].$versenum: $wpt"; 
      #   if($wpt !~ /โอํ/){
      #      say "$wploc[0]: $wpt"; 
      #      #my $noQ = substr($wpt,0,1,'');
      #      #say $noQ;
      #      $wpt =~ s/&nbsp;/ /g;
      #      $wpt =~ s/\x{201c}//;
      #      $wpt =~ s/\x{201d}\s*$//;
      #      say $wpt;
      #      say '';
      #      #$wpt =~ s/“//;
      #      #$wpt =~ s/”//;
      #      #$wpt =~ s/[+ ]*“/+:+/;
      #   }
      }

      $wpt = $code.$wpt;
   }
   if($code eq '@verse-uvaca = '){
      $wpt = $line;
   }
   if($code eq '@verse-ref = '){
      $wpt = $line;
   }
   if($code eq '@sub-chapter = '){
      $wpt = $line;
   }
   if($ln == 189){
      $wpt = $line;
      @shifts = ();
      #say $fout $wpt;
      push @out,$wpt;
      next;
   }
   if($code eq '@ch-title = '){
      #say $inPlus[$ln-2];
      #say $wpt;
      #$wpt =~ s/<h1 class="wp-block-heading">//;
      #$wpt =~ s/<\/h1>//;
      #$wpt =~ s/<strong>//g;
      #$wpt =~ s/<\/strong>//g;
      #$wpt =~ s/<em>/<i>/g;
      #$wpt =~ s/<\/em>/<\/i>/g;
      #say '@ch-title = '.$wpt;
      $wpt = $line;
      #say $line;
      #say '';
      #say $ln;
      @shifts = ();
      #if($versenum eq 'about-author'){
      #   say 'In ch-title wp[0]: '.substr($wp[0],0,40);
      #}
      #say $fout $wpt;
      push @out,$wpt;
      next;
   }
   if($code eq '@text = '){
      $wpt = $line;
      $verseflag = $txt;
      #say 'On @text current lines is '.$wp[0];
      @shifts = ();
      #say $fout $wpt;
      push @out,$wpt;
      next;
   }
   if($code eq '@sans-uvaca = '){
      $wpt = $line;
      @shifts = ();
      #say $fout $wpt;
      push @out,$wpt;
      next;
   }
   if($code eq '@trans-title = '){
      $wpt = $line;
      @shifts = ();
      #say $fout $wpt;
      push @out,$wpt;
      next;
   }
   if($code eq '@para-title = '){
      #say 'Working on para-title now, wpt is:';
      #say $wpt;
      $wpt = $line;
      #say $fout $wpt;
      push @out,$wpt;
      next;
   }
   if($code eq '@ch-end = '){
      my $noTag = stripTags ("$wpt");
      $wpt = $code.$noTag;
   }
   if($code eq '@gloss = '){
      $wpt =~ s/<p>//;
      $wpt =~ s/<\/p>//;
      $wpt =~ s/<strong>/<i>/;
      $wpt =~ s/<\/strong>/<\/i>/;


      next if $wpt eq '';

      
      $wpt = $code.$wpt;
      #say 'Processing master line: '.substr($line,0,30);
      #say 'Wpt right now is      : '.substr($wpt,0,30);
   }

   $wpt =~ s/&nbsp;/ /g;
   $wpt =~ s/<em>/<i>/g;
   $wpt =~ s/<\/em>/<\/i>/g;
   $wpt =~ s/<i>\s*\+\s*/ <i>/g;
   $wpt =~ s/\+\s*<\/i>/<\/i> /g;
   $wpt =~ s/<\/i>\s*\+\s*<i>/<\/i> <i>/g;
   $wpt =~ s/\s*\*\s*<i>/* <i>/g;
   $wpt =~ s/\s*\*\s*<\/i>/<\/i> */g;
   $wpt =~ s/\s*<i>/ <i>/g;
   $wpt =~ s/i>\s*/i> /g;
   $wpt =~ s/<i>\s*/<i>/g;
   $wpt =~ s/\s*<\/i>/<\/i>/g;
   $wpt =~ s/<i><\/i>//g;


   $wpt =~ s/\x{201c}\s+<i>/\x{201c}<i>/g;
   $wpt =~ s/i>\s+\x{201d}/i>\x{201d}/g;
   $wpt =~ s/\x{2018}\s+<i>/\x{2018}<i>/g;
   $wpt =~ s/i>\s+\x{2019}/i>\x{2019}/g;

   #if($wpt =~ s/\s+\x{201d}/\x{201d}/g){
   #   my $noTag = stripTags ("$row");
   #   say 'Ch '.$wpl.' : '.$noTag;
   #}

   $wpt =~ s/\*/ \* /g;

   $wpt =~ s/\s+/ /g;

   $wpt =~ s/<\/i>\s*=\s*<i>/=/g;

   #$wpt =~ s/=//g;




   my $hyphen = '';
   my @italics = ( $wpt =~ /<i>(.*?)<\/i>/g );
   #say $txt if $ln == 7035;
   foreach (@italics){
      #say 'Looking for paliIt: '.$_;
      my $paliIt = $_;

      $paliIt =~ s/^\s+|\s+$//g;
      
     
      my $lookUp = $paliIt;
      $lookUp =~ s/\+/ /g;
      $lookUp =~ s/\s+/ /g;

      if($lookUp =~ /=/g and ! exists $pali2EnDict{$lookUp}){

         #$pali2EnDict{$lookUp}
         #$hyphen.'::'.$enIt.$hyphencount.'=';
         say "Line $ln - adding hyphenated: $lookUp";
         $hyphen = $lookUp;

         $lookUp =~ s/=//g;
         $pali2EnDict{$lookUp.$hyphencount.'='} = $hyphen;

      }

      #say $paliIt;
      if( ! exists $pali2EnDict{$lookUp}){
         say "\n\n\nNo Sanskrit for '$paliIt' - '$lookUp' in ch $wploc[0], verse $versenum:\n$owpt\n\nLast line:";
         say $wpt;
         say "In masterPlus it's:\n$line";
         say "Bad Pali $badPali";
         say $ln;
         $badPali++;
         next;
         exit;

      }
      my $enIt = $pali2EnDict{$lookUp};

      #add hyphenated pali to dictionary
      if($hyphen ne ''){
         say $fhhhy $hyphen.'::'.$enIt.$hyphencount.'=';
         $hyphencount++;
         $hyphen = '';
      }



      if($wpt =~ s/\Q<i>$paliIt<\/i>\E/<i>$enIt<\/i>/){
         #if (index($wpt, '@para = เนื้อหาสาระของ') != -1) {
         #   say "$paliIt - $enIt";
         #} 
      }else{
         say "\n\n\nSubstitution  failed for :\n$paliIt\n$enIt";
         say "Perl command: wpt =~ s/\Q<i>$paliIt<\/i>\E/<i>$enIt<\/i>/";
         say "In: $wpt";
         say '';
         say '';
         say 'Examining the issue';

         $wpt =~ s/\Q<i>$paliIt<\/i>\E/<i>$enIt<\/i>/;
         say $1;
         




         say "\nLast Line \n\n$ln";
         exit;
      }
   }
   #
   #if( scalar @hyphens != 0 ){
   #   #say $wpt;
   #   #say Dumper \@hyphens;
   #   say "hyphens in line $ln at $hyphens[0]";
   #}
   #
   #
   #
   #say $fout $wpt;
   push @out,$wpt;
   #say '';
   #say $wpt;
   next if $ln < $last;
   if($wpt ne $line and $versenum ne 'glossary'){

      my $bad = distance ($line, $wpt);
      my $len = length($line);
      #say "Distance is $bad, length is $len";
      next if $bad/$len < 0.9;
      say "\n\n\n";
      say 'Something is wrong in chapter '.$wploc[0].' verse '.$versenum;
      say 'Original wpt:';
      say $owpt;
      say '';
      say 'Current wpt:';
      say $wpt;
      say '';
      say 'Master line:';
      say $line;
      say '';
      say 'In shifts:';
      foreach(@shifts){
         say $_;
      }
      say '';
      #say 'Diff:';
      ##my $diff = diff \$line, \$wpt;
      ##say $diff;
      #my @l = split //,$line;
      #my @w = split //,$wpt;
      #my $good = '';
      #my $bad;
      #for my $i (0 .. $#l){
      #   if($l[$i] eq $w[$i]){
      #      $good .= $l[$i];
      #   }else{
      #      $bad="'$l[$i]'".' '.ord($l[$i]).' '."'$w[$i]'".' '.ord($w[$i]);
      #      last;
      #   }
      #}
      #say $good;
      #say "bad: $bad";
      #say "In shifts there are $#shifts elements";
      #say $_ foreach @shifts;
      say ($ln-10);
      last;
   }
   @shifts = ();
}

open (my $fout, ">:encoding(UTF-8)", "yourExistingMaster.txt") or die "$!";

#say $fout $_ foreach @out;
#my $lc=1;
#my $qcl=0;
#my $qcr=0;
#my $count = 0;
#my $thiscount = 0;

#my %transIgnore;
#$transIgnore{'โอํ'} = '17.24-6296';
#$transIgnore{'จงดูบรรดาสมาชิกของ'} = '1.25-396';
#$transIgnore{'หลังจากตรัสเช่นนี้แล้ว'} = '2.9-672';
#$transIgnore{'ในตอนเริ่มต้นของการสร้างพระผู้เป็นเจ้าแห่งสร'} = '3.10-1425';
#$transIgnore{'กองทัพเทวดาทั้งหลายศิโรราบต่อหน้าพร'} = '11.21-4595';
#$transIgnore{'ด้วยความคิดว่าพระองค์ทรงเป็นพระสหาย'} = '11.41-42-4761';
#$transIgnore{'เช่นนี้บุคคเหล่านี้ลุ่มหลงอยู่ในอวิชชา'} = '16.15-5993';

my @transIgnore;
$transIgnore['6296'] = '17.24-โอํ';
$transIgnore['396'] = '1.25-จงดูบรรดาสมาชิกของ';
#$transIgnore['672'] = '2.9-หลังจากตรัสเช่นนี้แล้ว';
$transIgnore['1425'] = '3.10-ในตอนเริ่มต้นของการสร้างพระผู้เป็นเจ้าแห่งสร';
$transIgnore['4595'] = '11.21-กองทัพเทวดาทั้งหลายศิโรราบต่อหน้าพร';
$transIgnore['4761'] = '11.41-42-ด้วยความคิดว่าพระองค์ทรงเป็นพระสหาย';
$transIgnore['5993'] = '16.15-เช่นนี้บุคคเหล่านี้ลุ่มหลงอยู่ในอวิชชา';

my $io=1;
foreach(@out){
   my $out = $_;
   #$out =~ s/i> ”/i>”/g;
   $out =~ s/\x{201c}\s*/\x{201c}/;
   $out =~ s/\s*\x{201d}/\x{201d}/;
   #if($out =~ /\@trans = / and $transIgnore[$io] eq ''){
   #  $out =~ s/\x{201c}\s*/\x{201c}/;
   #  $out =~ s/\s*\x{201d}/\x{201c}/;
   ##   #say $io.' '.$out;
   #}
   $out =~ s/\s+$//;
   say $fout $out;
   #say $out if $io == 28;
   $io++;
}
#say "qcl:$qcl";
#say "count: $count";
#say "qcr:$qcr";

close $fout;
close $fhhhy;
close $fhshy;



sub stripTags {

   my $hs = HTML::Strip->new();
   my $noTag = $hs->parse( $_[0] );
   $hs->eof;
   return $noTag;
}


