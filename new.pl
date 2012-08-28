#!/usr/bin/perl

####################

$mirrorpath = "http://www.thetvdb.com";
$key = "768A3A72ACDABC4A";
$language = "en";

####################

$match = 0;
@shows = ();
open(SHOWS, "$ARGV[0]");
while(chomp($line = <SHOWS>)){
	push(@shows,$line);
}
close(SHOWS);

@ava = ();
open(AVAILABLE, "available.txt");
while(chomp($line = <AVAILABLE>)){
	push(@ava, $line);
}
close(AVAILABLE);

system("wget -q http://www.tvguide.com/new-tonight/80001");
open(INPUT, "80001");
open(OUT, ">new.txt");
system("rm -rf $ARGV[0]-search.txt");
while(chomp($line = <INPUT>)){
	if($line =~ /<h6 id="(.*)">.*<\/h6>/){
		print OUT "$1\n";
	}
	if($line =~ /<!-- SHOW LINK, SHOW TITLE -->/){
		chomp($line = <INPUT>);
		if($line =~/<h3>/){
			chomp($line = <INPUT>);
			if($line =~ /<a .*>(.*)<\/a>/){
				foreach $x (@shows){
					if($x =~ /^\s*($1)\s*$/){
						print OUT "\t$1";
						$search = $1;
						$download="$1\%20s";
						$search =~ s/\s+/ /;
						$search =~ s/&/%26/;
						$search =~ s/Doctor Who/Doctor Who (2005)/;
						$search =~ s/Prime Suspect/Prime Suspect (US)/;
						$search =~ s/Last Man Standing/Last Man Standing (2011)/;
						$search =~ s/Being Human/Being Human (US)/;
						$search =~ s/Once Upon a Time/Once Upon a Time (2011)/;
						$search =~ s/Castle/Castle (2009)/;
						$search =~ s/Touch/Touch (2012)/;
						$search =~ s/Smash/Smash (2012)/;
						$search =~ s/CSI:\s*Crime Scene Investigation/CSI/;
						$search =~ s/Wiflred/Wilfred (US)/;

						system("wget -q \"$mirrorpath/api/GetSeries.php?seriesname=$search&language=$language\";");
						$search =~ s/%26/&/;
						system("mv \"GetSeries.php?seriesname=$search&language=$language\" GetSeries.php");
						open(GETID, "GetSeries.php");
						while(chomp($line2 = <GETID>)){
							if($line2 =~ /<seriesid>(\d+)<\/seriesid>/){
								$seriesid = $1;
								$match = "1";
								last;
							}
						}
						close(GETID);
						system("rm -f GetSeries.php");

						($_,$_,$_,$dom,$mon,$year,$_,$_,$_)=localtime(time);
						$mon+=1;
						$year+=1900;

						system("wget -q \"$mirrorpath/api/GetEpisodeByAirDate.php?apikey=$key&seriesid=$seriesid&airdate=$year-$mon-$dom&language=$language\";mv \"GetEpisodeByAirDate.php?apikey=$key&seriesid=$seriesid&airdate=$year-$mon-$dom&language=$language\" GetEpisodeByAirDate.php");
						open(GETEPNUM, "GetEpisodeByAirDate.php");
						while(chomp($line2 = <GETEPNUM>)){
							if($line2 =~ /<EpisodeNumber>(.*)<\/EpisodeNumber>/){
								$e = $1;
							}
							if($line2 =~ /<SeasonNumber>(.*)<\/SeasonNumber>/){
								$s = $1;
							}
						}
						close(GETEPNUM);
						system("rm -f GetEpisodeByAirDate.php");

						system("wget -q \"$mirrorpath/api/$key/series/$seriesid/$language.xml\"");
						open(GETNETWORK, "$language.xml");
						while(chomp($line2 = <GETNETWORK>)){
							if($line2 =~ /<Network>(.*)<\/Network>/){
								$network = $1;
							}
						}
						close(GETNETWORK);
						system("rm -f $language.xml");

						if($s == 0 and $e == 0){
							printf OUT "\tRerun";
						}
						else{
							printf OUT "\ts%02d",$s;
							printf OUT "e%02d",$e;
						}
						open(SEARCH, ">>$ARGV[0]-search.txt");
						if(not($s == 0 and $e == 0)){
							printf SEARCH "$search s%02de%02d\n",$s,$e;
						}
						close(SEARCH);
						print OUT "\n\t\t$network\n";
					}
				}
			}
		}
	}
}
close(INPUT);
close(OUT);
if($match == 0){
	open(OUT, ">new.txt");
	print OUT "There is nothing new tonight.\n";
	close(OUT);
}
system("rm -rf 80001");
exit;
