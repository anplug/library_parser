package FileOperations;

my( $defaultOutputFileName, $outputFileName ) = "D:\\Dropbox\\To Do\\Dip\\dip_project\\output";


sub getDefaultOutputFileName
{
	return $defaultOutputFileName;
}

sub setOutputFileName($)
{
	($outputFileName) = @_;
}

sub readFile($)
{
	my( $filePath ) = @_;
	-e $filePath or die "Can't find this file";	
	my @readLines;
	open(my $file, "<".$filePath) or die "Can't open this file";	
	binmode($file, ':utf8' );	
	push @readLines, $_ while <$file>;	
	return @readLines;
}

sub _save($@)
{
	my( $fileName, @lines) = @_;
	open(my $file, ">>".$fileName);
	binmode($file, ':utf8');
	map( print($file $_."\n"), @lines);
	close($file);
}

sub save(@)
{
	_save($outputFileName, @_);
}

sub saveToFile($@)
{
	_save(@_);
}

sub clearOutput
{
	return 1 unless -e $outputFileName;
	unlink $outputFileName or die 
		"Error while deleting output file ".$outputFileName."\n";
}

1;