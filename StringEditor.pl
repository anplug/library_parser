package StringEditor;

#require "FileOperations.pl";

my( @SYMBOLS_TO_BE_CUTED ) = (" ", ".", "-", "–", "/", "|", "\\", ",", "\"", ";", ":", " ", "–");

sub deleteSub($$)
{
	my ( $string, $substr ) = @_;
	return $string if $substr eq "";
	my $subPosition = index($string, $substr);
	return $string if $subPosition == -1;
	substr( $string, $subPosition, length($substr)) = "";
	return $string;
}

sub cutToLeft($$)
{
	my ( $string, $substr ) = @_;
	return $string if $substr eq "";	
	my $subPosition = index($string, $substr);
	if ($subPosition == -1 and $substr eq "//")
	{
		return cutToLeft($string, "\\");
	}
	return $string if $subPosition == -1;
	substr( $string, 0, $subPosition + length($substr)) = "";
	return $string;
}

sub cutToRight($$)
{
	my ( $string, $substr ) = @_;
	return $string if $substr eq "";
	my $subPosition = index($string, $substr);
	if ($subPosition == -1 and $substr eq "//")
	{
		return cutToRight($string, "\\");
	}
	return $string if $subPosition == -1;
	substr( $string, $subPosition, length($string)) = "";
	return $string;
}
sub trimEdges($)
{
	my ( $string ) = @_;
	my $cutFun = sub
	{		
		my $needToCut;
		do
		{
			$needToCut = 0;
			if (substr($string, 0, 1) eq $_)
			{
				substr($string, 0, 1) = "";
				$needToCut = 1;
			}
			my $lastCharNumber = length($string) - 1;
			if (substr($string, $lastCharNumber, 1) eq $_)
			{
				substr($string, $lastCharNumber , 1) = "";
				$needToCut = 1;
			}
		} while ($needToCut);
	};
	map(&$cutFun, @SYMBOLS_TO_BE_CUTED);
	map(&$cutFun, reverse @SYMBOLS_TO_BE_CUTED);
	return $string;
}
1;