use strict;
use warnings;
use diagnostics;

use utf8;
use Encode;

require "D:\\Dropbox\\To Do\\Dip\\dip_project\\StringEditor.pl";
require "D:\\Dropbox\\To Do\\Dip\\dip_project\\FileOperations.pl";
require "D:\\Dropbox\\To Do\\Dip\\dip_project\\Composer.pl";

#Заменить титульный лист в этом шаблоне
#Заменить тире на нормальные
#Заменить использование перечисления в записке
#Не нумеровать формулы

# 1 par - i_file
# 2 par - [o_file]

### Global variables

my( $BL ) = '[А-ЯA-ZІЇЄ]';
my( $SL ) = '[а-яa-zіїє]';

my( $defaultOutputFileName ) = FileOperations::getDefaultOutputFileName();
my( $citiesFileName ) = "D:\\Dropbox\\To Do\\Dip\\dip_project\\cities";

my( %RUS_SHORT_CITIES ) = (
						'М.' => 'Москва', 
						'Спб.' => 'Санкт-Петербург',
						'СПб' => 'Санкт-Петербург',
						'Л.' => 'Ленинград',
						'К.' => 'Киев');
						
my ( $shortCityForm ) = 0;

### Found variables

my ( $pagesCount );
my ( $pageDiapason );
my ( $year );
my ( @authors );
my ( $city );
my ( $publisher );
my ( $name );
my ( $magazineName );
my ( $magazineNumber );
my ( $magazineVolume );

my ( $composedString );

### ---

my ( $magazineNumberStruct );
my ( $magazineVolumeStruct );

### Entry point

my $numOfParameters = $#ARGV + 1;
my $outputFileName = $defaultOutputFileName;
my $inputFileName = $ARGV[0];

$outputFileName = $ARGV[1] if $numOfParameters == 2;

&main($inputFileName, $outputFileName);

sub main($)
{
	my( $inputFileName, $outputFileName ) = @_;
	FileOperations::setOutputFileName($outputFileName);
	Composer::setRusShortCities(%RUS_SHORT_CITIES);
	FileOperations::clearOutput();
	my @lines = FileOperations::readFile($inputFileName);
	map( parseSource($_), @lines);
}

sub save
{
	FileOperations::save(@_);
}


# Main function that parse 1 source

sub parseSource($)
{
	my ( $source )  = @_;
	
	$pagesCount = findPages($source);
	$pageDiapason = findPageDiapason($source);
	$year = findYear($source);
	
	my $magazineNumberArrayRef = findMagazineNumber($source);
	$magazineNumberStruct = $magazineNumberArrayRef->[0];
	$magazineNumber = $magazineNumberArrayRef->[1];
	
	my $magazineVolumeArrayRef = findMagazineVolume($source);
	$magazineVolumeStruct = $magazineVolumeArrayRef->[0];
	$magazineVolume = $magazineVolumeArrayRef->[1];
	
	@authors = findAuthors($source);
	
	my $cutedSource = prepareToPositionBasedCutting($source);
	my @cities = loadCities();
	
	$city = findCity(\@cities, $cutedSource);
	$name = findName($cutedSource);
	$magazineName = findMagazineName($cutedSource);
	$publisher = findPublisher($cutedSource);
	$composedString = Composer::Compose(
		$pagesCount, $pageDiapason, $year,
		$city, $name, $publisher, $magazineName, 
		$magazineNumber, $magazineVolume, @authors);
	
	saveResult($source);
}

sub saveResult
{
	my ( $source ) = @_;
	
	save("Pages:$pagesCount");
	save("Page_diapason:$pageDiapason");
	save("Year:$year");
	save("Magazine_name:$magazineName");
	save("Magazine_number:$magazineNumber");
	save("Magazine_volume:$magazineVolume");
	save("Authors:", @authors, ";");
	save("City:$city");
	save("Name:$name");
	save("Publisher:$publisher");
	save("Composed_string:$composedString");
	
	#save($source, "--------------------------");
}

# --- Find functions

sub findPages($)
{
	my( $source ) = @_;
	$source =~ /(\d+?)\s?[сСcCpP]\.?/;
	return $1;
}

sub findPageDiapason($)
{
	my ( $source ) = @_;
	$source =~ /[cCсСpP]{1,2}\.?\s?(\d+[-–]\d+)/;
	return $1;
}

sub findYear($)
{
	my ( $source ) = @_;
	$source =~ /(\d{4})[гГ\.,\s]/;
	return $1;
}

sub findAuthors($)
{
	my ( $source ) = @_;
	my ( @authors);
	while ($source =~ /(${BL}${SL}+-?(${BL}${SL}+)?\s${BL}${SL}?\.\s?(${BL}${SL}?\.)?)/g)
	{
		push(@authors, $1);
	}
	return "Unknown author" if 0 == @authors;
	return @authors;
}

sub findMagazineNumber($)
{
	my ( $source ) = @_;
	$source =~ /((?:(?:(?:Вып|Nо)\.)|[№N]\.?)\s?(\d{1,3})\.?)/;
	#my @a = ($1, $2);
	return [$1, $2];
}

sub findMagazineVolume($)
{
	my ( $source ) = @_;
	$source =~ /(Т\.\s?(\d{1,3})(,|\.)?)/;
	return [$1, $2];
}


sub prepareToPositionBasedCutting($)
{
	my ( $source ) = @_;
	$source = StringEditor::deleteSub($source, $magazineNumberStruct);
	$source = StringEditor::deleteSub($source, $magazineVolumeStruct);
	$source = StringEditor::cutToLeft($source, $authors[$#authors]);
	$source = StringEditor::cutToRight($source, $year);
	$source = cutCity($source) if isArticle();
	$source = StringEditor::trimEdges($source);
	#save("Cuted: $source");
	return $source;
}

sub getCityToken($)
{
	my ( $source ) = @_;
	
	return $city if (index($source, $city) != -1 or $city eq "");
	
	keys %RUS_SHORT_CITIES;
	while (my ($shortName, $fullName) = each %RUS_SHORT_CITIES)
	{
		return $shortName if $city eq $fullName;
	}
	return "Strange problem";
}

sub cutCity($)
{
	my ( $source ) = @_;	
	return StringEditor::deleteSub($source, getCityToken($source));
}

sub isArticle()
{
	return 1 if not $pagesCount and $pageDiapason;
	return 0;
}

sub loadCities()
{
	FileOperations::readFile( $citiesFileName );
}

sub findCity($$)
{
	my ( $cities_ptr, $string ) = @_;
	my ( @cities ) = @$cities_ptr;
	foreach (@cities)
	{
		chomp;
		$shortCityForm = 0, return $_ if index($string, $_) != -1;
	}
	my ($shortName, $fullName);
	keys %RUS_SHORT_CITIES;
	while (($shortName, $fullName) = each %RUS_SHORT_CITIES)
	{
		$shortCityForm = 1, return $fullName if index($string, $shortName) != -1;
	}
	$shortCityForm = 0;
	return "";
}

sub findName($)
{
	my ( $source ) = @_;
	my $name;
	unless (isArticle())
	{
		unless ($city eq "")
		{
			unless ($shortCityForm)
			{
				my $cutedString = StringEditor::cutToRight($source, $city);
				$name = StringEditor::trimEdges($cutedString);
			}
			else
			{
				for my $shortCityName (keys %RUS_SHORT_CITIES)
				{
					if (index($source, $shortCityName) != -1)
					{
						my $cutedString = StringEditor::cutToRight($source, $shortCityName);
						$name = StringEditor::trimEdges($cutedString);
						last;
					}
				}
			}
		}
	}
	else
	{
		$name = StringEditor::cutToRight($source, "//");
		$name = StringEditor::trimEdges($name);
	}
	return $name;
}

sub findPublisher($)
{
	my ( $source ) = @_;
	return "" if (isArticle());	
	my $publisher;
	unless ($city eq "")
	{
		
		unless (index($source, $city) == -1)
		{
			my $cutedString = StringEditor::cutToLeft($source, $city);
			$publisher = StringEditor::trimEdges($cutedString);
		}
		else
		{
			for my $shortCityName (keys %RUS_SHORT_CITIES)
			{
				if (index($source, $shortCityName) != -1)
				{
					my $cutedString = StringEditor::cutToLeft($source, $shortCityName);
					$publisher = StringEditor::trimEdges($cutedString);
					last;
				}
			}
		}
	}
	return $publisher;
}

sub findMagazineName($)
{
	my ( $source ) = @_;
	my $name;
	if (isArticle())
	{
		$name = StringEditor::cutToLeft($source, "//");
		$name = StringEditor::cutToRight($name, getCityToken($name));
		$name = StringEditor::trimEdges($name);
	}
	return $name;
}