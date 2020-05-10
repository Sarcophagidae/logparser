#!/usr/bin/perl
use strict;
use warnings;
use 5.020;
use CGI qw(:all -utf8);
use DBI;
use Data::Dumper;
use utf8;

sub searchDiv{
	print "<div class='center'>";
	print "<fieldset><legend>Поиск по e-mail</legend>";
	print start_form(
		-action=>'./',
		-enctype => &CGI::URL_ENCODED);
	print textfield(-name=>'address',
		-size=>35,
		-maxlength=>50);
	print submit(-value=>'Найти');
	print end_form ;
	print "</fieldset>";
	print "</div>";
}

sub tableHeader{
	print '<table>
    <thead>
        <Th>Timestamp</th>
        <Th>Log</th>
    </thead>'
};

sub tableRow{
	my ($dte, $log) = @_;
	print 
		"<tr>
        <td width=150px>$dte</td>
        <td>$log</td>
		</tr>";
}

sub tableEnd{
	print "</table>"; 
}

my $style= ".container {
  display: flex;
  border:1px solid white;
  flex-direction: column;
  justify-content: center;
}

.center {
  width: 80%;
  border:1px solid white;
  align-self: center;
  margin-bottom: 20px;
}

table, td, th {
  border: 1px solid black;
}

table {
  border-collapse: collapse;
  width: 100%;
}

th {
  height: 50px;
}

tr:hover { background: #e1e1d0; }
thead:hover { background: white; }
";

$|  = 1;
binmode(STDOUT,':utf8');

my $dbh=DBI->connect("dbi:Pg:dbname=logs","","") or die 'Failed to connect to db';
my $q = new CGI; 
print $q->header(	-type => "text/html", 
									-charset => "UTF-8");
print $q->start_html(	-title=>'Logs',
											-encoding => "UTF-8",
										 	-style=>{-verbatim=>$style});

print "<div class='container'>";
if (!$q->param){
	searchDiv();
} else {
		my $adr = $q->param('address');
		searchDiv();
		if ($adr){
	 		print "<div class='center'>";
 			print "<fieldset><legend>Результаты поиска</legend>";

			my $sql =
"select created, str from (select created, str, int_id from message where (split_part(str,' ',3)) = ?
union
select created, str, int_id from log where address = ?) a
order by int_id, created" ;
			my $sth = $dbh->prepare($sql);
			$sth->execute($adr,$adr);
			if ($sth->rows == 0) {
				print "Ничего не найдено";
			} else {
				if ($sth->rows > 100){
					print "<h1><center>Результат поиска содержит более ста записей. Выведены первые сто.</center></h1>";
				}
				tableHeader();
    		my $res = $sth->fetchall_arrayref();
				my $i = 0;
				foreach my $r (@{$res}){
					tableRow($$r[0],$$r[1]);
					last if (++$i == 100);
    		}	 	  	
				tableEnd();
			}
			print "</div>";
		}
}
print "</div>";
print end_html;
