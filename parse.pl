use strict;
use warnings;
no warnings 'experimental';
use 5.020;

#$variable =~ /(?<count>\d+)/;
#print "Count is $+{count}";
sub insertToLog{
	my ($dte,$int_id,$str,$adr) =  @_;
	print "Inserted to log \n";
	print "DATE => $dte\n";
	print "INTID => $int_id\n";
	print "mail => $adr\n";
	print "str => $str\n\n";
}

sub insertToMessages{
	my ($dte,$int_id,$str,$adr, $id) =  @_;
	print "Inserted to MSG \n";
	print "DATE => $dte\n";
	print "INTID => $int_id\n";
	print "mail => $adr\n";
	print "id => $id\n";
	print "str => $str\n\n";
}

while (<>){
	my ($int_id, $dte, $str, $other) = undef;	
	my $currentLogString = $_;
	chomp;
	#try to get data for created, int_id and str
	if (!/^(?<dte>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s(?<str>(?<intid>[\w-]{16})\s(?<other>.*))$/){
		#try to get timestamp 
		#(for string lile "2012-02-13 15:10:35 SMTP connection from nms.somehost.ru [194.226.65.146] closed by QUIT")
		if ( !/^(?<dte>\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})\s(?<other>.*)$/){
			#nothing can help here - we dont know format of that row. F.
			print "ERROR: Broken string $_\n";
		} else {
			insertToLog($+{dte},"",$+{other},"");
		}
	} else {
		$int_id = $+{intid};
		$dte = $+{dte};
		$str = $+{str};
#		print "$str\n";
		if ($+{other} !~ /^(?<flag>(?:<=)|(?:=>)|(?:->)|(?:\*\*)|(?:==))\s(?<other>.*)/){
			#If flag doesnt exisrt then insert in general log
			insertToLog($dte,$int_id,$str,"");
		} else {
			given ($+{flag}){
				when (['->','==']){
						if( $+{other} !~ /^(?<adr>[\w\d\-\@\.]+?)\s/){
							print "ERROR: unknown format in $str";
						} else{
							insertToLog($dte,$int_id,$str,$+{adr});
						}
				}

				when ('**'){
						if( $+{other} !~ /^(?<adr>[\w\d\-\@\.]+?)(?:\s|:)/){
							print "ERROR: unknown format in $str";
						} else{
							insertToLog($dte,$int_id,$str,$+{adr});
						}
				}

				when ('=>'){
						if( $+{other} !~ /^(?:\:blackhole\: <)?(?<adr>[\w\d\-\@\.]+?)(?:\>)?\s/){
							print "ERROR: unknown format in $str";
						} else{
							insertToLog($dte,$int_id,$str,$+{adr});
						}
				}

				when ('<='){
            if( $+{other} =~ /^(?<adr>[\w\d\-\@\.]+?)\s.*id=(?<id>.+?)$/){
							insertToMessages($dte,$int_id,$str,$+{adr},$+{id});
            } else{
							# all strings with flag="<=" and email="<>"
              insertToLog($dte,$int_id,$str,"");
            }
				}

				default {
					print "ERROR: Invalid <flag> in $str\n";
				}
			}	
		}
	}
}
