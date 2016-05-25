#require "FileOperations.pl";

use utf8;
use Encode;

package Composer;

my %RUS_SHORT_CITIES;

sub setRusShortCities(%)
{
	(%RUS_SHORT_CITIES) = @_;
}

my ($pagesCount, $pageDiapason, $year,
		$city, $name, $pulisher, @authors);
		
my ( $dash ) = "–";
my ( $page ) = "с";

sub Compose
{
	my $composedString;
	($pagesCount, $pageDiapason, $year,
		$city, $name, $publisher, $magazineName, 
			$magazineNumber, $magazineVolume, @authors) = @_;
	my $sourceType = findSourceType();
	FileOperations::save("Source_type:$sourceType");
	if (validateInputParameters($sourceType))
	{
		$composedString = composeAsBook() if  $sourceType eq "Book";
		$composedString = composeAsArticle() if  $sourceType eq "Article";
	}
	else
	{
		return "Cannot compose";
	}
	return $composedString;
}

sub validateInputParameters
{
	my ($sourceType) = @_;
	if ($sourceType eq "Book")
	{
		if ($pagesCount and $year and $city and $name 
			and $publisher and @authors)
		{
			return 1;
		}
		return 0;
	}
	if ($sourceType eq "Article")
	{
		if ($pageDiapason and $year and $name 
			and $magazineName and $magazineNumber)
		{
			return 1;
		}
		return 0;
	}
	return 0;
}

sub findSourceType()
{
	return "Book" if $pagesCount and not $pageDiapason;
	return "Article" if not $pagesCount and $pageDiapason;
	return "Unknown";
}

sub composeAsBook
{
	my $composedString;
	my $standardStringEnding = ": $publisher, $year. $dash $pagesCount $page.";
	if (@authors == 1)
	{
		$composedString = insertComa(directAuthorName($authors[0]))." $name [Текст] / ".reverseAuthorName($authors[0]).
			". $dash ".correctCity($city).$standardStringEnding;
	}
	if (@authors == 2)
	{
		$composedString = insertComa(directAuthorName($authors[0]))." $name [Текст] / ".reverseAuthorName($authors[0]).
		", ".reverseAuthorName($authors[1]).". $dash ".correctCity($city).$standardStringEnding;
	}
	if (@authors == 3)
	{
		$composedString = insertComa(directAuthorName($authors[0]))." $name [Текст] / ".reverseAuthorName($authors[0]).", ".
		reverseAuthorName($authors[1]).", ".reverseAuthorName($authors[2]).". $dash ".correctCity($city).
		$standardStringEnding;
	}
	if (@authors == 4)
	{
		$composedString = "$name [Текст] / ".reverseAuthorName($authors[0]).", ".reverseAuthorName($authors[1]).
		", ".reverseAuthorName($authors[2]).", ".reverseAuthorName($authors[3]).". $dash ".
		correctCity($city).$standardStringEnding;
	}
	if (@authors == 5)
	{
		$composedString = "$name [Текст] / ".reverseAuthorName($authors[0]).", ".reverseAuthorName($authors[1]).
		", ".reverseAuthorName($authors[2])." [и др.] ; $dash ".correctCity($city).$standardStringEnding;
	}
	return $composedString;
}

sub composeAsArticle
{
	my $composedString;
	my $standardStringEnding = " // ".$magazineName.". $dash $year. $dash № $magazineNumber. $dash C. $pageDiapason.";
	my $standardStringStarting = insertComa(directAuthorName($authors[0]))." $name [Текст] / ";
	if (@authors == 1)
	{
		$composedString = $standardStringStarting.reverseAuthorName($authors[0]).$standardStringEnding;
	}
	if (@authors == 2)
	{
		$composedString = $standardStringStarting.reverseAuthorName($authors[0]).", ".
			reverseAuthorName($authors[1]).$standardStringEnding;
	}
	if (@authors == 3)
	{
		$composedString = $standardStringStarting.reverseAuthorName($authors[0]).", ".
			reverseAuthorName($authors[1]).", ".reverseAuthorName($authors[2]).$standardStringEnding;
	}
	if (@authors == 4)
	{
		$composedString = "$name [Текст] / ".reverseAuthorName($authors[0]).", ".reverseAuthorName($authors[1]).
		", ".reverseAuthorName($authors[2]).", ".reverseAuthorName($authors[3]).$standardStringEnding;
	}
	if (@authors == 5)
	{
		$composedString = "$name [Текст] / ".reverseAuthorName($authors[0]).", ".reverseAuthorName($authors[1]).
		", ".reverseAuthorName($authors[2])." [и др.] ; $dash ".$standardStringEnding;
	}
	return $composedString;
}

sub directAuthorName($)
{	# direct means {Lastname A.B.}
	my ($author) = @_;
	@splited = split(" ", $author);
	if (isLastName(@splited[0]))
	{
		return $author;
	}
	else
	{
		return $splited[0]." ".$splited[1];
	}
}

sub reverseAuthorName($)
{	# reverse means {A.B. Lastname}
	my ($author) = @_;
	@splited = split(" ", $author);
	if (isLastName($splited[1]))
	{
		
		return $author;
	}
	else
	{
		return $splited[1]." ".$splited[0];
	}
}

sub isLastName($)
{
	my ( $string ) =  @_;
	return 1 if index($string, ".") == -1;
	return 0;
}

sub correctCity($)
{
	my ( $city ) = @_;
	keys %RUS_SHORT_CITIES;
	while (($shortName, $fullName) = each %RUS_SHORT_CITIES)
	{
		return $shortName if $city eq $fullName;
	}
	return $city;
}

sub insertComa($)
{
	my ( $authorName ) = @_;
	return join(", ", split(" ", $authorName));
}

1;