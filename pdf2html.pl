#!/usr/bin/perl
use strict;
use warnings;
no warnings 'uninitialized';
use Data::Dumper; #say Dumper \@array or print Dumper (\@array);
use 5.032;
use utf8;
binmode STDOUT, ":utf8";
binmode STDIN, ":utf8";
use File::Copy qw(copy);
use IO::Handle;
use File::Copy::Recursive qw(dircopy);
use URI::Escape;
use Archive::Zip;
use Unicode::Normalize 'normalize';
use HTML::Strip;
#use Mojo::DOM;
use File::Slurp;


my $eDir='vedabase/html4pdf';

my $findx = IO::Handle->new();
my $fchs = IO::Handle->new();
my $fchsA = IO::Handle->new();
my $fver = IO::Handle->new();

my $chit;
my $verit;

#my %css;


my %clash = (
"bg-content chapter" => "",
"chapter-num chpage-1" => "",
"chapter-num chpage-10" => "",
"chapter-num chpage-11" => "",
"chapter-num chpage-12" => "",
"chapter-num chpage-13" => "",
"chapter-num chpage-14" => "",
"chapter-num chpage-15" => "",
"chapter-num chpage-16" => "",
"chapter-num chpage-17" => "",
"chapter-num chpage-18" => "",
"chapter-num chpage-2" => "",
"chapter-num chpage-3" => "",
"chapter-num chpage-4" => "",
"chapter-num chpage-5" => "",
"chapter-num chpage-6" => "",
"chapter-num chpage-7" => "",
"chapter-num chpage-8" => "",
"chapter-num chpage-9" => "",
"chapter-sub" => "",
"chapter-title" => "r r-title r-chapter",
"chapterMargin" => "",
"devanagari" => "bb r-verse",
"devinside" => "",
"forHeaderLeft" => "",
"forHeaderRight" => "",
"hairsp" => "",
"image_ch" => "",
"p-centered" => "r-paragraph-centered",
"p-end" => "r r-lang-th r-paragraph-thus-ends",
"purport" => "r r-lang-th r-paragraph",
"purport paramparaGrid" => "",
"purport-title" => "section-title",
"purportQuote" => "wrapper-verse-text r r-lang-th r-verse-text",
"sans" => "wrapper-verse-text r r-lang-en r-verse-text",
"sans pali" => "wrapper-verse-text r r-lang-th r-verse-text",
"sans-ref" => "r r-lang-th r-reference",
"sign-off" => "r r-lang-th r-paragraph",
"synonym" => "",
"text-title" => "section-title",
"textNo" => "r-chapter-title",
"thickersp" => "",
"thinsp" => "",
"trans" => "r r-lang-th r-translation",
"vcenter" => "",
"verse-uvaca" => "",
"verseSpace" => "",
"vholder" => "",
"wbw" => "r r-lang-th r-synonyms",
);

my $parampara = '<p>1. <i>กฺฤษฺณ</i> <br />2. <i>พฺรหฺมา</i> (พระพรหม)<br />3. <i>นารท</i> <br />4. <i>วฺยาส</i> <br />5. <i>มธฺว</i><br />6. <i>ปทฺมนาภ</i> <br />7. <i>นฺฤหริ</i> <br />8. <i>มาธว</i> <br />9. <i>อกฺโษภฺย</i> <br />10. <i>ชย ตีรฺถ</i> <br />11. <i>ชฺญานสินฺธุ</i> <br />12. <i>ทยานิธิ</i> <br />13. <i>วิทฺยานิธิ</i> <br />14. <i>ราเชนฺทฺร</i> <br />15. <i>ชยธรฺม</i> <br />16. <i>ปุรุโษตฺตม</i> <br />17. <i>พฺรหฺมณฺย ตีรฺถ</i><br />18. <i>วฺยาส ตีรฺถ</i><br />19. <i>ลกฺษฺมีปติ</i><br />20. <i>มาธเวนฺทฺร ปุรี</i><br />21. <i>อีศฺวร ปุรี</i> (<i>นิตฺยานนฺท อไทฺวต</i>)<br />22. องค์ <i>ไจตนฺย</i><br />23. <i>รูป</i> (<i>สฺวรูป</i>, <i>สนาตน</i>)<br />24. <i>รฆุนาถ</i>, <i>ชีว</i><br />25. <i>กฺฤษฺณทาส</i><br />26. <i>นโรตฺตม</i><br />27. <i>วิศฺวนาถ</i><br />28. (<i>วิทฺยาภูษณ</i>), <i>ชคนฺนาถ</i><br />29. <i>ภกฺติวิโนท</i><br />30. <i>เคารกิโศร</i><br />31. <i>ภกฺติสิทฺธานฺต สรสฺวตี</i> <br />32. <i>อภัย จรณารวินฺท ภกฺติเวทนฺต สฺวามี ปฺรภุปาท</i></p>';

my @cssFix = (
   '   <link href="https://fonts.googleapis.com/css2?family=Trirong:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap" rel="stylesheet">',
   '<style>',
   '  #content  {font-family: "Trirong", "Noto Serif", serif;text-align: justify;text-justify: inter-character;word-spacing: 6pt;}',
   '  .r-lang-en {font-family: "Noto Serif vedabaseio", "Noto Serif", serif;}',
   '  .hairsp {word-spacing: 1px}',
   '  .thinsp {word-spacing: -0.4pt}',
   '  .thickersp {word-spacing: -0.3pt;}',
   '  /*@media {.container{ max-width: 40em;}}*/',
   '  .verseText {display:inline; text-align: justify; text-justify:inter-character;margin-left:6px;}',
   '  .verseText::before{content: "";display:inline-block;width:0.2em;}',

   '</style>',
   '<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">'
);

open ($findx, ">:encoding(UTF-8)", "vedabase/www/index.html") or die "can't open bg/index:$!";
my @findAr;
open (my $finx, "<:encoding(UTF-8)", "$eDir/indexOut.html") or die "$!";
while(my $row = <$finx>){
   chomp $row;
   push @findAr, $row;
}
close $finx;


my @chits;
open (my $fcseq, "<:encoding(UTF-8)", "modules/seqC.txt") or die "$!";
while(my $row = <$fcseq>){
   chomp $row;
   push @chits, $row;
}
#splice @chits,1,1;
#say Dumper \@chits;
splice @chits,23,1;
#push @chits, 'about-author';
push @chits, 'guide';
#say Dumper \@chits;
#say $chits[-1];

#for my $i (0 .. $#chits){
#   say "$i - $chits[$i]";
#}


my @verses;
open (my $fvseq, "<:encoding(UTF-8)", "modules/seqV.txt") or die "$!";
while(my $row = <$fvseq>){
   chomp $row;
   push @verses, $row;
}
#say $#verses;# 1/1, 1/2, 1/16-18


my $cc=0;
foreach(-3..19){
   my $ch = $_;
   my $chit = $_ + 4;
   my @fAr;
   #my $html = read_file("$eDir/indexOut$chit.html");
   #my $dom = Mojo::DOM->new("$html");
   #my $class = $dom->find('*')->map(attr => 'class')->compact->join("\n");
   #my @classes = split("\n",$class);
   #$css{"$_"} = '' foreach @classes;

   open (my $fin, "<:encoding(UTF-8)", "$eDir/indexOut$chit.html") or die "$!";
   while(my $row = <$fin>){
      chomp $row;
      push @fAr, $row;
      #my $dom = Mojo::DOM->new("$row");
      #say $dom->find('*')->map(attr => 'class')->compact->join("\n");
   }
   close $fin;


   $chit='setting-the-scene' if $ch == -3;
   $chit='dedication' if $ch == -2;
   $chit='preface' if $ch == -1;
   $chit='introduction' if $ch == 0;
   $chit='about-author' if $ch == 19;
   #$chit='guide' if $ch == 20;

   #say $fAr[4];
   if($chit =~ /\D/){
      my $title = $chit;
      $title =~ s/\-/ /g;
      $title =~ s/([\w']+)/\u\L$1/g;
      $fAr[4] = "<title>$title</title>";
   }else{
      $fAr[4] = "<title>Chapter $ch</title>";
   }
   #say $fAr[4];

   
   #for my $i (0 .. $#fAr){
   #   my $ln = $i+1;

   #}

   #say "ch $ch chit $ch";

   if($chit eq 'dedication'){
      splice @fAr,19,7;
      splice @fAr,28,2;
      splice @fAr,34,1,'<p>';
      splice @fAr,36,1,'</p>';
      splice @fAr,37,2;

   }
   if($chit eq 'introduction'){
      splice @fAr,26,1;
      splice @fAr,-8,1,$parampara;
   }
   #if($ch > 0){
   if($chit =~ /^\d+$/){
      #say "$ch. $fAr[38]";
      splice @fAr,25,0,'<!-- insert here -->';
      $fAr[29]='</h1>';
      $fAr[39]=' <h1 style="text-align:center" class="chapter-title">';
   }

   my @chitOut = vedify (@fAr);
   #say $chitOut[44] if $ch == 1;

   my @nav = navigate ('chapter',$cc);
   #say "cc=$cc" if $chit eq 'about';
   splice @chitOut,-5,0,@nav;
   #say Dumper \@nav;


   #if($ch > 0) {
   if($chit =~ /^\d+$/){
      if(! -d "vedabase/www/$ch/full/"){
         mkdir "vedabase/www/$ch/full/";
      }
      #
      #
      #
      #fix navigation for full chapters, keep the original for simple
      $chitOut[11+$#cssFix+25]='<div class="r-chapter-title" style="margin:-1em 0em 1em;"><a href="../">SIMPLE</a></div>';
      #say "chit=$chit, $chitOut[44]";
      #$chitOut[44] =~ s/FULL/SIMPLE/;
      #$chitOut[44] =~ s/full/..\//;


      simplify ($ch, @chitOut);

      if($chitOut[-18] =~ /\d/){

         $chitOut[-18] =~ s/\.\.\//..\/..\//;
         $chitOut[-18] =~ s/">/\/full\/">/;
      }else{
         $chitOut[-18] =~ s/\.\.\//..\/..\//;

      }
      if($chitOut[-12] =~ /\d/){

         $chitOut[-12] =~ s/\.\.\//..\/..\//;
         $chitOut[-12] =~ s/">/\/full\/">/;
      }else{
         $chitOut[-12] =~ s/\.\.\//..\/..\//;
      }
      #end of fix

      open ($fchsA, ">:encoding(UTF-8)", "vedabase/www/$ch/full/index.html") or die "can't open bg/%chit/index for writing:$!";



      foreach(@chitOut){
         say $fchsA $_;
         #say $_ if $_ =~ /สำรวจกองทัพที่สมรภูมิ/;
         #say $_ if $ch ==1 and $_ =~ /container/;
      }
      #say "Main: doing ch $ch";
      versify ($ch, @chitOut);

   }else{
      if(! -d "vedabase/www/$chit/"){
         mkdir "vedabase/www/$chit/";
      }
      open ($fchs, ">:encoding(UTF-8)", "vedabase/www/$chit/index.html") or die "can't open bg/%chit/index for writing:$!";
      foreach(@chitOut){
         say $fchs $_;
      }
   }
   $cc++;
}

############ Guide ##########

my @fGa;
open (my $fgin, "<:encoding(UTF-8)", "$eDir/title/guide.html") or die "$!";
while(my $row = <$fgin>){
   chomp $row;
   push @fGa, $row;
   #my $dom = Mojo::DOM->new("$row");
   #say $dom->find('*')->map(attr => 'class')->compact->join("\n");
}
close $fgin;

my @gOut = vedifyGuide (@fGa);
my @nav = navigate ('chapter',23);


splice @gOut,-5,0,@nav;

if(! -d "vedabase/www/guide/"){
   mkdir "vedabase/www/guide/";
}
open (my $fg, ">:encoding(UTF-8)", "vedabase/www/guide/index.html") or die "can't open bg/guide/index for writing:$!";
foreach(@gOut){
   say $fg $_;
}
close $fg;
############# End of Guide ########
   
############# Index ###############
   
my @ded=('<div id="con8ded" class="contentOuter">',
'   <div id="con9" class="contentLeft gloss">',
'      อุทิศแด่',
'   </div>',
'   <div id="con10ded" class="contentRight gloss">',
'      ',
'   </div>',
'   <div style="clear: both;"></div>',
'</div>');

#remove Glossary
splice @findAr,281,9;
#add dedication
splice @findAr,35,0,@ded;

my @indxOut = vedifyContent (@findAr);# if $#findAr > 10;
open (my $fchin, ">:encoding(UTF-8)", "vedabase/www/index.html") or die "can't open bg/index for writing:$!";
foreach(@indxOut){
   say $fchin $_;
}
close $findx;

############ End of Index ############




sub versify {
   #my @ar = @_;
   #say $#ar;
   #my $c = $ar[0];
   my $c = shift @_;
   #say "Chapter $c";
   #my @html = @{$ar[1]};
   #say $#html;
   
   #say $#cssFix if $c==1;

   #change BG link
   #splice @_,24,1,'<h1 style="text-align:center;"><a href="../../">ภควัท-คีตา ฉบับเดิม</a></h1>';
   splice @_,(11+$#cssFix+5),1,'<h1 style="text-align:center;"><a href="../../">ภควัท-คีตา ฉบับเดิม</a></h1>';

   #add Chapter link
   #$_[29]= '<a href="../">'.$_[29].'</a>';
   $_[11+$#cssFix+10]= '<a href="../">'.$_[11+$#cssFix+10].'</a>';

   #remove SIMPLE link
   $_[11+$#cssFix+25] = '';

   #my @head = splice @_,0,46; 
   my @head = splice @_,0,(11+$#cssFix+27); 
   #foreach (@head){
   #   say $_;
   #}
   splice @_, -7,7;
   my @vbody = shift @_;#have bb r-verse in array already so it's skipped later
   

   my @end = ('','','','</div>','</body>','</html>');
   #if($c == 1){
   #   #say $_[0];
   #   #say $_[-2];
   #   say "vbody before iterating:\n$vbody[0]";
   #}
   my $v = '';
   my $counter = 0;
   foreach(@_){
      #if($_ =~ /ch5\-div5/){
      #   say "Got this: $_";
      #}
      if( $_ =~ /bb r-verse/){

         #say $_[$counter+3];
         #say $vbody[3];
         $vbody[3] =~ s/^.+   //;
         $vbody[3] = substr($vbody[3],0,-4);

         #if($c == 1){
         #   say $_ foreach @vbody;
         #}
         #if($_ =~ /ch5\-div5/){
         #   say "Got this: $_";
         #}
         my $next;
         my $prev = "../../$v";

         $prev = '../../introduction' if $v eq '';

         if( !exists $verses[1] ){
            $next = '../../setting-the-scene';
         }else{
            $next = "../../$verses[1]";
         }

         #my @nav = ('<!-- Navigation -->','<a href="'.$prev.'">Prev</a>','<a href="'.$next.'">Next</a>','<!-- End of Navigation -->','','');

         my @nav=('<div class="col-12">',
                  '  <ul class="mini-pager mt-2 pb-4">',
                  '     <li class="pager-prev">');
         push @nav, '         <a class="btn" href="'.$prev.'">';
         push @nav, '             <i class="fa fa-chevron-left"></i>';
         push @nav, '               Previous';
         push @nav, '         </a>';
         push @nav, '      </li>';
         push @nav, '      <li class="pager-next">';
         push @nav, '         <a class="btn" href="'.$next.'">';
         push @nav, '            Next';
         push @nav, '            <i class="fa fa-chevron-right"></i>';
         push @nav, '         </a>';
         push @nav, '      </li>';
         push @nav, '   </ul>';
         push @nav, '</div>';
         $v = shift @verses;
         #say $v;
         #if($v eq '1/1'){
         #   say "current line: $_";
         #   say 'Going to write 1/1';
         #   say "vbody now starts from:\n$vbody[0]";
         #   say "vbody now has $#vbody lines";
         #   #say "vbody now line 2:\n$vbody[95]";
         #   #say $_ foreach @vbody;
         #}
         my @vhtml = (@head,@vbody,@nav,@end);
         #say "Vbody starts with: $vbody[0],$vbody[1],$vbody[2]" if $next eq '../../1/2';
         writeV ($v,@vhtml);
         if($v =~ /-/){
            #say $v;
            my @points = $v =~ /(\d+)\/(\d+)-(\d+)/;
            #say "    ch $points[0] verses $points[1] to $points[2]";
            for ($points[1] .. $points[2]){
               #say "write $points[0]/$_";
               writeV ("$points[0]/$_",@vhtml);
            }
         }
         @vbody = ();
      }
      push @vbody, $_;
      if($c == 1 and $v eq ''){
         #say "Pushed on vbody:\n$_";
         #say "Vbody now has $#vbody lines";
      }
      $counter++;
   }
   $v = shift @verses;
   #say $v;
   my @vhtml = (@head,@vbody,@end);
   writeV ($v,@vhtml);
   #say $v;
   #if($c == 1){
   #   say $_ foreach @vbody;
   #}
   #if($v =~ /-/){ #luckily no chapter ends on double verses
   #   say $v;
   #}
}

sub writeV {
   my $v = shift @_;
   #say $v;
   my @vhtml = @_;
   #if($v eq '1/1'){
   #   say $_ foreach @vhtml;
   #}
   if(! -d "vedabase/www/$v/"){
      mkdir "vedabase/www/$v/";
   }
   open (my $fv, ">:encoding(UTF-8)", "vedabase/www/$v/index.html") or die "can't open www/$v/index for writing:$!";
   foreach(@vhtml){
      say $fv $_;
   }
   #say "Written $v";

   #if($v =~ /-/){
   #   say $v;
   #}
}

sub navigate {
   my @out=('<div class="col-12">',
            '  <ul class="mini-pager mt-2 pb-4">',
            '     <li class="pager-prev">');
         #    <a class="btn" href="/en/library/bg/introduction/">
         #                <i class="fa fa-chevron-left"></i>
         #                    Previous
         #            </a></li>
         #            <li class="pager-next"><a class="btn" href="/en/library/bg/2/">
         #                    Next
         #                <i class="fa fa-chevron-right"></i>
         #            </a></li>
         #    </ul>
         #< /div>
   my @ar = @_;
   my $c = $ar[1];
   my $prev = $c-1;
   my $next = $c+1;
   #say "c=$c, prev=$chits[$prev], this=$chits[$c], next=$chits[$next]";
   #$next = 0 if $c == 18;
   $chits[$next] = $chits[0] if $c == 24;
   push @out, '         <a class="btn" href="../'.$chits[$prev].'">';
   push @out, '                     <i class="fa fa-chevron-left"></i>';
   push @out, '             Previous';
   push @out, '         </a>';
   push @out, '      </li>';
   push @out, '      <li class="pager-next">';
   push @out, '         <a class="btn" href="../'.$chits[$next].'">';
   push @out, '            Next';
   push @out, '            <i class="fa fa-chevron-right"></i>';
   push @out, '         </a>';
   push @out, '      </li>';
   push @out, '   </ul>';
   push @out, '</div>';
   return @out;
}

sub vedifyContent {

   $_[4]='<title>Content</title>';

   my @inAr = @_;
   my @outAr;

   my $css='   <link rel="stylesheet" type="text/css" href="/vedabase.css">';
   #my $css='   <link rel="stylesheet" type="text/css" href="/vedabase.css">'."\n".'   <link rel="stylesheet" type="text/css" href="/styles.css">';

   splice @inAr,7,1,'   <meta name="viewport" content="width=device-width, initial-scale=1.0">';
   splice @inAr,10,7,$css;
   splice @inAr,13,1,'<div id="content" class="container first-container">';
   #splice @inAr,15,1,'<h1 style="text-align:center;"><a href="/bg">ภควัท-คีตา ฉบับเดิม</a></h1>';
   splice @inAr,15,1,'<h1 style="text-align:center;">ภควัท-คีตา ฉบับเดิม</h1>';

   #my $titleLine = 19;
   #$titleLine=20 if $inAr[26] =~ /forHeader/;
   #say $inAr[20];

   #splice @inAr,$titleLine,1,'<h1 style="text-align:center;" id="dedication" class="r r-title r-chapter">';
   #
   splice @inAr,19,1;



   my $counter = 0;
   for my $i ( 0..$#inAr){
      my $ln = $i+1;
      my $line = $inAr[$i];

      #say $line if $i> 20 and $i <50;

      #last if $line =~ /con122/;
      last if $line =~ /con132/;

      #substr $line, 5, 0, 'style="text-align:center" ' if $ln == 20;
      #say $line if $ln == 19;

      $line = '' if $line =~ /^\s*<!-/;
      $line = '' if $line =~ /class="forHeader/;
      $line = '' if $line =~ /clear/;

      $line =~ s/<span style="hardHyphen">-<wbr><\/span>/<wbr>/g;


      if($line =~ /contentRight/){
         $line = '';
         $inAr[$i+1] = '';
         $inAr[$i+2] = '';
      }
      if($line =~ /อภิธานศัพท์สันสกฤต/){
         $line = '';
         $outAr[$i-2] = '';
         $outAr[$i-1] = '';
         $inAr[$i+1] = '';
         $inAr[$i+2] = '';
         $inAr[$i+3] = '';
         $inAr[$i+4] = '';
         $inAr[$i+5] = '';
         $inAr[$i+6] = '';
      }


      if($line =~ /class/){
         my @classes = ($line =~ /class="(.*?)"/g);
         foreach(@classes){
            if($clash{$_} ne ''){
               $line =~ s/\Q$_\E/$clash{$_}/g;
            }
         }
      }
      $line =~ s/\Q<wbr><span class="verseSpace"> <\/span>\E/<br \/>/g;

      my $link = $chits[$counter];
      if($line =~ /contentLeft gloss/){
         #say $counter;
         #if($inAr[$i+1] =~ /span/){
         #   #$inAr[$i+1] = '<a href="">'.$inAr[$i+1].'</a>';
         #   my @parts = split /<\/span>/,$inAr[$i+1];
         #   #say Dumper \@parts;
         #   $parts[0]= '<a href="'.$link.'">'.$parts[0].'</a>';
         #   $inAr[$i+1] = join '',@parts;

         #}else{
         #   $inAr[$i+1] = '<a href="'.$link.'">'.$inAr[$i+1].'</a>';
         #}
         $inAr[$i+1] = '<a href="'.$link.'">'.$inAr[$i+1].'</a>';
         #say "counter=$counter, chits=$chits[$counter]";
         #say 'added link: '.'<a href="'.$link.'">'.$inAr[$i+1].'</a>';
         $counter++;
      }



      push @outAr,$line;
   }
   push @cssFix, '<style>';
   push @cssFix,'p {margin-left:3em;}';
   push @cssFix,'.contentOuter {font-size:1.2rem;line-height:2em;}';
   #'  .r-lang-en {font-family: "Noto Serif vedabaseio", "Noto Serif", serif;}',
   #'  .hairsp {word-spacing: 1px}',
   #'  .thinsp {word-spacing: -0.5pt}',
   #'  .thickersp: {word-spacing -0.2pt}',
   push @cssFix,'</style>';

   splice(@outAr,11,0,@cssFix);
   push @outAr,'</div>';
   push @outAr,'</body>';
   push @outAr,'</html>';

   return @outAr;
}

sub vedifyGuide{

   $_[4]='<title>Sanskrit Guide</title>';
   my @inAr = @_;

   my @outAr;

   my $css='    <link rel="stylesheet" type="text/css" href="/vedabase.css">';
   #my $css='   <link rel="stylesheet" type="text/css" href="/vedabase.css">'."\n".'   <link rel="stylesheet" type="text/css" href="/styles.css">';

   splice @inAr,7,1,'   <meta name="viewport" content="width=device-width, initial-scale=1.0">';
   splice @inAr,10,12,$css;
   splice @inAr,13,1,'<div id="content" class="container first-container">';
   splice @inAr,14,1,'<h1 style="text-align:center;"><a href="../">ภควัท-คีตา ฉบับเดิม</a></h1>';
   splice @inAr,15,0,'<h1 style="text-align:center;">';
   splice @inAr,16,0,'<div class="r r-lang-th r-paragraph">';

   #my $titleLine = 19;
   #$titleLine=20 if $inAr[26] =~ /forHeader/;
   #say $inAr[20];

   #splice @inAr,$titleLine,1,'<h1 style="text-align:center;" id="dedication" class="r r-title r-chapter">';
   #
   splice @inAr,19,1;



   for my $i ( 0..$#inAr){
      my $ln = $i+1;
      my $line = $inAr[$i];

      last if $line =~ /con122/;

      #substr $line, 5, 0, 'style="text-align:center" ' if $ln == 20;
      #say $line if $ln == 19;

      $line = '' if $line eq '<article>';
      $line = '' if $line eq '</article>';
      $line = '' if $line eq '<header>';
      $line = '' if $line eq '</header>';
      $inAr[$i+2] = '</h1>' if $line eq '<h1 class="chapter-title">';
      #$line = '' if $line =~ /class="forHeader/;
      #$line = '' if $line =~ /clear/;

      $line =~ s/<span style="hardHyphen">-<wbr><\/span>/<wbr>/g;
      $line =~ s/ class="tightLine"//;
      $line =~ s/page-break-before: always;//;


      if($line =~ /class/){
         my @classes = ($line =~ /class="(.*?)"/g);
         foreach(@classes){
            if($clash{$_} ne ''){
               $line =~ s/\Q$_\E/$clash{$_}/g;
            }
         }
      }
      $line =~ s/\Q<wbr><span class="verseSpace"> <\/span>\E/<br \/>/g;



      push @outAr,$line;
   }
   push @cssFix, '<style>';
   #push @cssFix,'p {margin-left:3em;}';
   push @cssFix,'.table {';
   push @cssFix,' display: table;';
   push @cssFix,' margin-left: 3em;';
   push @cssFix,' border-collapse: separate;';
   push @cssFix,' border-spacing: 10px 0px;';
   push @cssFix,' word-spacing:normal;';
   push @cssFix,'}';
   push @cssFix,'.table-row {';
   push @cssFix,' display: table-row;';
   push @cssFix,'}';


   push @cssFix,'.table-cell {';
   push @cssFix,' display: table-cell;';
   push @cssFix,'}';

   push @cssFix,'.pali-col {';
   push @cssFix,' font-weight:500;';
   push @cssFix,' font-style: italic;';
   push @cssFix,'}';

   push @cssFix,'.iast-col {';
   push @cssFix,' font-family: "Noto Serif Vedabase", serif;';
   push @cssFix,' font-style: italic;';
   push @cssFix,'}';

   push @cssFix,'.sample {';
   push @cssFix,' padding-left:2em;';
   push @cssFix,'}';

   push @cssFix,'.thankyou {';
   push @cssFix,' list-style-type: "\1F44D";';
   push @cssFix,' list-style-type: " - ";';
   push @cssFix,'}';

   push @cssFix,'.trans {';
   push @cssFix,' margin: 1em 0;';
   push @cssFix,'}';
   push @cssFix,'.r {';
   push @cssFix,' margin-bottom: 1em;';
   push @cssFix,'}';
   push @cssFix,'.r-title {';
   push @cssFix,' font-size: 2em;';
   push @cssFix,'}';
   push @cssFix,'.r-translation{';
   push @cssFix,' margin-top: 0.5em;';
   push @cssFix,'}';
 
   push @cssFix,'</style>';

   splice(@outAr,12,0,@cssFix);
   #push @outAr,'</div>';
   #push @outAr,'</body>';
   #push @outAr,'</html>';

   return @outAr;
}




sub vedify {

   my @inAr = @_;
   my @outAr;

   my $css='   <link rel="stylesheet" type="text/css" href="/vedabase.css">';
   #my $css='   <link rel="stylesheet" type="text/css" href="/vedabase.css">'."\n".'   <link rel="stylesheet" type="text/css" href="/styles.css">';

   splice @inAr,7,1,'   <meta name="viewport" content="width=device-width, initial-scale=1.0">';
   splice @inAr,10,9,$css;
   splice @inAr,13,1,'<div id="content" class="container first-container">';
   splice @inAr,15,1,'<h1 style="text-align:center;"><a href="../">ภควัท-คีตา ฉบับเดิม</a></h1>';

   my $titleLine = 19;
   #$titleLine=20 if $inAr[26] =~ /forHeader/;
   #say $inAr[20];

   splice @inAr,$titleLine,1,'<h1 style="text-align:center;"  class="r r-title r-chapter">';



   for my $i ( 0..$#inAr){

      #$inAr[35]='<div class="r-chapter-title" style="margin:-1em 0em 1em;"><a href="full">FULL</a></div>';



      my $ln = $i+1;
      my $line = $inAr[$i];



      #substr $line, 5, 0, 'style="text-align:center" ' if $ln == 20;
      #say $line if $ln == 19;

      $line = '' if $line =~ /^\s*<!-/;
      #$line = '' if $line =~ /^<p class="forHeader/;
      $line = '' if $line =~ /class="forHeader/;
      $line = '' if $line =~ /img\/1.png/;
      $line = '' if $line =~ /devinside/;
      $line = '' if $line =~ /chapterMargin/;
      $line = '' if $line eq '<article>';
      $line = '' if $line eq '</article>';
      $line = '' if $line eq '<header>';
      $line = '' if $line eq '</header>';

      $line =~ s/<span style="hardHyphen">-<wbr><\/span>/<wbr>/g;

      if($line =~ /purportQuote/){
         $inAr[$i+1] = '<em>';
         $inAr[$i+4] = '</em>';
      }
      if($line =~ /sans-ref/){
         $inAr[$i+1] = '<p><em>';
         $inAr[$i+4] = '</em></p>';
      }
      if($line =~ /textNo/){
         $line =~ s/div/h1/;
         my @links = split ' ',$inAr[$i+1];
         $inAr[$i+1] = '<a href="../'.$links[-1].'">'.$inAr[$i+1].'</a>';
         $inAr[$i+2] = '  </h1>';
      }
      if($line =~ /"sans"|"sans pali"/){
         $line .= '<em>';
         $inAr[$i+4] = '</em></div>';
      }
      if($line =~ /text-title/){
         $line =~ s/div/h2/;
         $inAr[$i+2] =~ s/div/h2/;
      }
      if($line =~ /"trans"/){
         $line .= '<p><strong>';
         $inAr[$i+3] =~ s/^\s+//;
         $inAr[$i+3] =~ s/\s+$//;
         $inAr[$i+3] = '<span style="white-space:pre-wrap">'.$inAr[$i+3].'</span>';
         $inAr[$i+4] = '</strong></p>';
      }
      if($line =~ /purport-title/){
         $line =~ s/div/h2/;
         $inAr[$i+2] =~ s/div/h2/;
      }
      if($line =~ /"purport"/){
         $inAr[$i+3] =~ s/^\s+//;
         $inAr[$i+3] =~ s/\s+$//;
         $inAr[$i+3] = '<span style="white-space:pre-wrap">'.$inAr[$i+3].'</span>';
         $inAr[$i+4] = '</strong></p>';
      }
      if($line =~ /p-end/){
         $inAr[$i+1] = '<p><em>';
         $inAr[$i+4] = '</em></p>';
      }

      #if($line =~ /textNo/){
      #   my @links = split ' ',$inAr[$i+1];
      #   $inAr[$i+1] = '<a href="../'.$links[-1].'">'.$inAr[$i+1].'</a>';
      #}
      if($line =~ /image_ch/){
         #say $line;
         $line = '';
         $inAr[$i+3] = '';
      }


      $line =~ s/thickersp"> /thickersp">   /g;



      #say "$line\n$inAr[$i+1]" if $line =~ /chapter\-title/;





      if($line =~ /class/){
         my @classes = ($line =~ /class="(.*?)"/g);
         foreach(@classes){
            if($clash{$_} ne ''){
               $line =~ s/\Q$_\E/$clash{$_}/g;
            }
         }
      }
      $line =~ s/\Q<wbr><span class="verseSpace"> <\/span>\E/<br \/>/g;


      #say "$inAr[$i-1]\n$line\n$inAr[$i+1]" if $line =~ /  สำรวจกองทัพที่สมรภูมิ/;

      push @outAr,$line;
   }
   splice(@outAr,11,0,@cssFix);

   return @outAr;
}

sub simplify {

   my $ch = shift @_;
   my @full = @_;

   $full[11+$#cssFix+25] =~ s/SIMPLE/FULL/;
   $full[11+$#cssFix+25] =~ s/\.\.\//full/;
   #say "First element in @ is $_[0]" if $ch ==1;


   #my @full;
   #open ( my $fcin, "<:encoding(UTF-8)", "vedabase/www/$ch/full/index.html") or die "can't open bg/$ch/full/index for writing:$!";
   #while(my $row = <$fcin>){
   #   chomp $row;
   #   push @full, $row;
   #   #say $row if $ch == 1;
   #}
   #close $fcin;
   my @simple;
   my @verse;
   for my $i (0 .. $#full){
      if($i < 11+$#cssFix+27){
         push @simple, $full[$i];
         next;
      }
      if($i > ($#full - 22) ){
         push @simple, $full[$i];
         next;
      }
      if($full[$i] =~ /bb r-verse/){
         push @verse,'<div style="position:relative;">';
         #push @verse,'<span style="display:inline;white-space:nowrap;">';
         ( my $text = $full[$i+3] ) =~ s/>    />/;
         $text =~ s/<\/a>/:<\/a>/;
         $text =~ s/ก /&ensp;/;
         #say "$text - ch=$ch";
         $text =~ s/\//\/$ch\//;
         push @verse, '<span style="display:inline;white-space:nowrap;text-align:left;">'.$text.'</span>';
         #push @verse, '</span>';
         #push @verse, '<span style="display:inline;">';
         $verse[-1] .= '<span style="display:inline;">';
         #push @verse,'</dt><dd>';

         #say $full[$i+3] if $ch == 1;
      }
      if($full[$i] =~ /translation/){
         #push @verse,'<dd>';
         #push @verse, $full[$i+3];
         #push @verse,'</dd>';
         #push @verse,'</dl>';
         #push @verse, '<span class="verseText">'.$full[$i+3].'</span>';
         $verse[-1] .= '<span class="verseText">'.$full[$i+3].'</span>';
         #push @verse, $full[$i+3];
         push @verse, '</span>';
         push @verse, '</span>';
         push @verse, '</div>';
         #$verse[-1] .= $full[$i+3].'</span></span></div>';
      }
      if($full[$i] =~ /paragraph/){
         push @simple, @verse;
         @verse = ();
      }
      #say $full[$i] if $ch ==1;

      #push @simple, $full[$i];
   }
   open ( my $fcout, ">:encoding(UTF-8)", "vedabase/www/$ch/index.html") or die "can't open bg/$ch/s/index for writing:$!";
   foreach(@simple){
      say $fcout $_;
   }
   close $fcout;

}






#dircopy("vedabase/www/","/home/stan/public_html/th-bg/www/") or die "Can't copy dir to local site:$!";
#system("rsync","vedabase/www/","/home/stan/public_html/th-bg/www") or die "Can't copy dir to local site:$!";
`rsync -r --delete vedabase/www/ /home/stan/public_html/th-bg/www`;
`rsync -r --delete vedabase/www/ /home/stan/GitHub/ThaiBhagavadGita/www`;
`rsync -r --delete vedabase/www/ /home/stan/GitHub/sitalatma.github.io/bg/`;

#dircopy("vedabase/www/","/home/stan/GitHub/ThaiBhagavadGita/www/") or die "Can't copy dir to local github site:$!";

#say 'my %clash = (';
#
#foreach my $cl (sort keys %css){
#   say '"'."$cl".'" => "",';
#}
#say ');';

exit;
