#!"C:\xampp\perl\bin\perl.exe"
# Author: <Suhail Munshi>
# [perl03B] Project : Not fail scripting languages. Go!
use CGI qw(-utf-8 :all *table);
use LWP::Simple qw(get);
use IO::String;
use warnings;
binmode( STDOUT, ":encoding(utf-8)" );

#Declare header and start html
print header( -charset => 'utf-8' ), "\n",
  start_html(
    { -title => 'Assignment 1', -author => 'sgmmunsh@student.liv.ac.uk' } ),
  "\n";

#Declare variables to hold values of output
$commentNo;
$instruct;
$elements;
$commentsWords;
$nonTrivial =0;


#If statement checking for input values
if ( param('Code') xor param('URL') ) {
	#statements retrieve text for each method of input and store it in a string
    if ( param('Code') ) {
        $Code = param('Code');
    }
    elsif ( param('URL') ) {
        $Code = get( param('URL') );
    }
	
	#This while loop will process the and reassign the variables we declared earlier.
	#The while loop uses the code stored in the string
	#first the loop will remove non empty single line commments
	#secondly the loop will remove multi-line comments
	#lastly, the remaining text will be used to workout the instruction based information.
    $input = $Code;
    while ( defined($input) ) {
		
		#checks for single-line comments with atleast one charachter  using regular expressions.
        $_ = $input;
        if (/((#|\/\/)(.+\n))/) {
			
			#words will measure number of words a single comment has
			$words = scalar(() = $3 =~ /\w+/g );
			#add words to total comment words
			$commentWords += $words;
			#Increment non trivial words variable if conditions met.
			if($words >= 5){$nonTrivial++}
			
			#Line below removes the comment we just retrieved.
            $input =~ s/((#|\/\/).+)//;	
	
			#comment number is incremented
            $commentNo++;
        }
		#checks for multiple line comments using regular expressions.
        elsif (/(\/\*([^\/]*)\*\/)/) {
			#declare variables to hold parts of comment
			$insert = $1;
            $comment = $2;
			#Determine if variable trivial and add words to comment words
			$words = scalar(() = $comment =~ /\w+/g );
			if( $words >= 5){
					$nonTrivial++;
				}
			$commentWords += $words;
			
			#goes through each line of the comment and checks for a charachter
			#If a charachter is present in the line, comment number is incremented
            my $handle = IO::String->new($insert);
            while ( defined( my $line = <$handle> ) ) {
                $_ = $line;
                if (/(\w+)/) {
                    $commentNo++;
                }
            }
			$input =~ s/(\/\*[^\/]*\*\/)//;
        }
        else {
			#The while loop below works out number of the lines of instruction
            my $handle = IO::String->new( $input);
            while ( defined( my $line = <$handle> ) ) {
                $_ = $line;
				#if statement below attempts to check if value contains an instruction.
                if (/([^=><+%!&][A-Za-z]+\w*|[=><+%!&])/) {
                    $instruct++;
                }
            }
			$input =~ s/(?<!%)(\(|\)|\{|\})/ /g;
            
            my @matches = ( $input =~ /([^=><+%!&{}][_A-Za-z]+[_A-Za-z0-9]*|[=><+%!&])/g );
            @matches = grep( /(^[^0-9])\w*/, @matches );
            $elements = scalar @matches;
            last;
        }
        $count++;
    }
	
	print table({-name=> "Code Analysis" ,-border => "1",-cellpadding => 3},
		Tr(td(['Number of lines of instruction:',  $instruct])),
		Tr(td(['Number of elements of instruction:',  $elements])),
		Tr(td(['Number of non-empty comments:',  $commentNo])),
		Tr(td(['Number of non-trivial comments:',  $nonTrivial])),
		Tr(td(['Number of words of comments:',  $commentWords])),
		Tr(td(['Ratio of non-empty lines of comment to lines of instruction:',  sprintf("%.1f",$commentNo/$instruct)	])),
		Tr(td(['Ratio of non-trivial comments to lines of instruction',  sprintf("%.1f",$nonTrivial/$instruct)	])),
		Tr(td(['Ratio of words of comment to elements of instruction',  sprintf("%.1f",$commentWords/$elements)	]))
	);

	
	

}
elsif ( param('URL') and param('Code') ) {
	#Error message for Text area and field both filled.
    print "Error. Enter text in only one of the two fields provided.";    
}
else{
	print "Enter text in one of the two fields below and hit submit."
}

#DECLARE TEXT FIELDS ETC
print h1("Enter a URL or Code below :"), br(), "\n";
print start_form( { -align => 'left' } );
print "<BLOCKQUOTE>\n";
	print textfield( { -name => 'URL', -size => 75, -placeholder => 'Enter URL' } );
print "</BLOCKQUOTE>\n","<BLOCKQUOTE>\n";
	print textarea(
		-name        => 'Code',
		-placeholder => '[Enter Code For Analysis]',
		-value       => undef,
		-rows        => 20,
		-columns     => 75
	);
print "</BLOCKQUOTE>\n";
print "<BLOCKQUOTE>\n";
	print submit( { -name => 'Submit', -value => 'Submit', -align => 'center' } );
print "</BLOCKQUOTE>\n";

print end_form,end_html;