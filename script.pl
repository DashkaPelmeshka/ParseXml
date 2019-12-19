#!/usr/bin/perl -w

use strict;
use warnings;
use open ':std', ':encoding(cp866)';

use Unicode::Normalize;
use List::Util 'sum';
use XML::LibXML;
use Data::Dumper qw(Dumper);


my $letters_in_tags = 0;
my $symbols_in_tags_normalized = 0;
my $inner_links_count = 0;
my $broken_inner_links_count = 0;

my %ids_in_links = ();
my %ids = ();


sub process_xml_nodes {
	my $filename = $_[0];

	my $dom = XML::LibXML->load_xml(location => $filename);

	for my $node ($dom->findnodes('//text()')) {
		my $text = $node->nodeValue();

		$text =~ s/(^\s+|\s+$)//g;
		$text =~ s/\s+/ /g;

		next unless $text;

		my @letters_only = $text =~ /\p{L}/g;
		$letters_in_tags += @letters_only;

		my $normalized_text = NFC($text);
		my @letters_and_spaces_normalized = $normalized_text =~ /[\p{L}\s]/g;
		$symbols_in_tags_normalized += @letters_and_spaces_normalized;
	}

	foreach my $node ($dom->findnodes('//*[@id]')) {
		$ids{$node->{id}} += 1;
	}

	foreach my $node ($dom->findnodes('//a[@href]')) {
		my $href = ($node->{href} =~ /^#(.*)/) ? $1 : "";
		$ids_in_links{$href} += 1 if $href;
	}
}

sub find_inner_links_count {
	$inner_links_count = sum values %ids_in_links || 0;
}

sub find_broken_inner_links_count {
	foreach my $id_in_link (keys %ids_in_links) {
		if (! exists $ids{$id_in_link}) {
			$broken_inner_links_count += $ids_in_links{$id_in_link};
		}
	}
}


# ------------------------- Main script --------------------------------------- #

my $filename = $ARGV[0];
if (@ARGV > 1) {
	print STDERR "Warning: too many arguments. Ignored all except the first\n";
}

if (! -e $filename) {
	print STDERR "Error! File does not exist";
	exit 1;
}

process_xml_nodes $filename;
find_inner_links_count;
find_broken_inner_links_count;

# bonus check: are all the ids unique?
my @non_unique_ids = grep { $ids{$_} > 1 } keys %ids;
if (@non_unique_ids) {
	print STDERR "Warning! The following ids are not unique in the XML-document: "
				 .join(", ", @non_unique_ids)."\n";
}

print join "\n", ($letters_in_tags, $symbols_in_tags_normalized,
	$inner_links_count, $broken_inner_links_count , "");
