#! /usr/local/bin/perl

use lib '~/cpan';
use Data::Dumper;
use Getopt::Std;
use Tie::IxHash;
use strict;
use warnings;
use Getopt::Long 'GetOptions';

#use vars qw ($opt_a $opt_b $opt_l $opt_v);
#&getopts('a:b:v');

my $B1_file = "";
my $CAZ1_file = "";
my $PIPC1_file = "";
my $FOM1_file = "";
my $AMK1_file = "";

my $B2_file = "";
my $CAZ2_file = "";
my $PIPC2_file = "";
my $FOM2_file = "";
my $AMK2_file = "";

my $verbose = "";

GetOptions(
  'B1=s'       => \$B1_file,
  'B2=s'       => \$B2_file,
  'CAZ1=s'     => \$CAZ1_file,
  'CAZ2=s'      => \$CAZ2_file,
  'PIPC1=s'    => \$PIPC1_file,
  'PIPC2=s'    => \$PIPC2_file,
  'FOM1=s'      => \$FOM1_file,
  'FOM2=s'      => \$FOM2_file,
  'AMK1=s'      => \$AMK1_file,
  'AMK2=s'      => \$AMK2_file,
  'verbose'     => \$verbose
);

my $usage = <<_EOH_;

# --B1     kensa_snapshot_2016.default_inpatient_withDedup_DrugDiff_20191120171314.Eng.txt
# --B2     kensa_snapshot_2015.default_inpatient_withDedup_DrugDiff_20191120170121.Eng.txt
# --CAZ1   kensa_snapshot_2015.default_inpatient_withDedup_DrugDiff_20200305153225_CAZ.Eng.txt
# --CAZ2   kensa_snapshot_2016.default_inpatient_withDedup_DrugDiff_20200305154447_CAZ.Eng.txt
# --PIPC1  kensa_snapshot_2015.default_inpatient_withDedup_DrugDiff_20200310110531.PIPC.Eng.txt
# --PIPC2  kensa_snapshot_2016.default_inpatient_withDedup_DrugDiff_20200310111747.PIPC.Eng.txt
# --FOM1   kensa_snapshot_2015.default_inpatient_withDedup_DrugDiff_20200605163644_FOM.Eng.txt
# --FOM2   kensa_snapshot_2016.default_inpatient_withDedup_DrugDiff_20200605093840_FOM.Eng.txt
# --AMK1   kensa_snapshot_2015.default_inpatient_withDedup_DrugDiff_20200605163613_AMK.Eng.txt
# --AMK2   kensa_snapshot_2016.default_inpatient_withDedup_DrugDiff_20200605093804_AMK.Eng.txt


# [-v]

_EOH_
;

#
# IN
#


if ($B1_file eq "") {
  die $usage;
} elsif ($B2_file eq "") {
  die $usage;
} 

if ($CAZ1_file eq "") {
  die $usage;
} elsif ($CAZ2_file eq "") {
  die $usage;
} elsif ($PIPC1_file eq "") {
  die $usage;
} elsif ($PIPC2_file eq "") {
  die $usage;
} elsif ($FOM1_file eq "") {
  die $usage;
} elsif ($FOM2_file eq "") {
  die $usage;
} elsif ($AMK1_file eq "") {
  die $usage;
} elsif ($AMK2_file eq "") {
  die $usage;
} 


my %hash_year_pref_species_info = ();
my %hash_3drugs_year_pref_species_info = ();

#tie my %hash, 'Tie::IxHash';

my @arr_drug_3rds = ();
push(@arr_drug_3rds, "CAZ");
push(@arr_drug_3rds, "PIPC");
push(@arr_drug_3rds, "FOM");
push(@arr_drug_3rds, "AMK");

my @arr_BFiles = ();
push(@arr_BFiles, $B1_file);
push(@arr_BFiles, $B2_file);

my @arr_3drugFiles = ();
push(@arr_3drugFiles, $CAZ1_file);
push(@arr_3drugFiles, $CAZ2_file);
push(@arr_3drugFiles, $PIPC1_file);
push(@arr_3drugFiles, $PIPC2_file);
push(@arr_3drugFiles, $FOM1_file);
push(@arr_3drugFiles, $FOM2_file);
push(@arr_3drugFiles, $AMK1_file);
push(@arr_3drugFiles, $AMK2_file);

foreach my $inFile (@arr_BFiles) {

  my $year = $inFile;
     $year =~ s/kensa_snapshot_([0-9]+).*$/$1/g;

  #
  # first, store all target hot loci into a hash
  #
  my %hash_header_name2colIndex =();
  my $header=`head -1 $inFile`;
  chomp($header);
  my @arr_header = split(/\t/, $header, -1);
  my $num_arr_header = @arr_header;
  for (my $i=0; $i<$num_arr_header; $i++) {
    $hash_header_name2colIndex{ $arr_header[$i] } = $i;
  }

  open(IN, "tail -n +2 $inFile |");
  while (my $line = <IN>) {
    chomp $line;
    my @arr_line = split(/\t/, $line, -1);
    
    if (scalar(@arr_line) == 0) {
      next;
    }

    my $species    = $arr_line[ $hash_header_name2colIndex{"species"} ];
    my $prefNo = $arr_line[ $hash_header_name2colIndex{"prefecture"} ];

    #
    # count num_IMP6 and total across speciments
    #
    my $i_starting_iteration = $hash_header_name2colIndex{"SS"};

    my $num_SS = $arr_line[ $hash_header_name2colIndex{"SS"} ];
    my $num_RR = $arr_line[ $hash_header_name2colIndex{"RR"} ];
    my $num_RS = $arr_line[ $hash_header_name2colIndex{"RS"} ];
    
    my $num_IMP6 = $arr_line[ $hash_header_name2colIndex{"SR"} ];

    my $total = 0;
    for (my $i=$i_starting_iteration; $i<scalar(@arr_line); $i++) {
      $total += $arr_line[ $i ];
    }
    
    my @arr_species = ();
    push(@arr_species, $species);
    push(@arr_species, "all");
    
    foreach my $each_species (@arr_species) {
      if (!defined($hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"total"})) {
        $hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"total"} = $total;
      } else {
        $hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"total"} += $total;
      }

      if (!defined($hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_IMP6"})) {
        $hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_IMP6"} = $num_IMP6;
      } else {
        $hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_IMP6"} += $num_IMP6;
      }

      if (!defined($hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_SS"})) {
        $hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_SS"} = $num_SS;
      } else {
        $hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_SS"} += $num_SS;
      }

      if (!defined($hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_RR"})) {
        $hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_RR"} = $num_RR;
      } else {
        $hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_RR"} += $num_RR;
      }

      if (!defined($hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_RS"})) {
        $hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_RS"} = $num_RS;
      } else {
        $hash_year_pref_species_info{$year}{$prefNo}{$each_species}{"num_RS"} += $num_RS;
      }
    }

  }
  close(IN);
}


foreach my $inFile (@arr_3drugFiles) {

  my $year = $inFile;
     $year =~ s/kensa_snapshot_([0-9]+).*$/$1/g;

  my $drug = $inFile;
     $drug =~ s/\.Eng\.txt//g;
     $drug =~ s/^.*DrugDiff_[0-9]+_([A-Z]+)/$1/g;

  #
  # first, store all target hot loci into a hash
  #
  my %hash_header_name2colIndex =();
  my $header=`head -1 $inFile`;
  chomp($header);
  my @arr_header = split(/\t/, $header, -1);
  my $num_arr_header = @arr_header;
  for (my $i=0; $i<$num_arr_header; $i++) {
    $hash_header_name2colIndex{ $arr_header[$i] } = $i;
  }

  open(IN, "tail -n +2 $inFile |");
  while (my $line = <IN>) {
    chomp $line;
    my @arr_line = split(/\t/, $line, -1);
    
    if (scalar(@arr_line) == 0) {
      next;
    }

    my $species    = $arr_line[ $hash_header_name2colIndex{"species"} ];
    my $prefNo = $arr_line[ $hash_header_name2colIndex{"prefecture"} ];

    my $num_SRS = $arr_line[ $hash_header_name2colIndex{"SRS"} ];
    my $num_SRR = $arr_line[ $hash_header_name2colIndex{"SRR"} ];
    
    my @arr_species = ();
    push(@arr_species, $species);
    push(@arr_species, "all");
    
    foreach my $each_species (@arr_species) {

      if (!defined($hash_3drugs_year_pref_species_info{$drug}{$year}{$prefNo}{$each_species}{"num_SRS"})) {
        $hash_3drugs_year_pref_species_info{$drug}{$year}{$prefNo}{$each_species}{"num_SRS"} = $num_SRS;
      } else {
        $hash_3drugs_year_pref_species_info{$drug}{$year}{$prefNo}{$each_species}{"num_SRS"} += $num_SRS;
      }

      if (!defined($hash_3drugs_year_pref_species_info{$drug}{$year}{$prefNo}{$each_species}{"num_SRR"})) {
        $hash_3drugs_year_pref_species_info{$drug}{$year}{$prefNo}{$each_species}{"num_SRR"} = $num_SRR;
      } else {
        $hash_3drugs_year_pref_species_info{$drug}{$year}{$prefNo}{$each_species}{"num_SRR"} += $num_SRR;
      }

    }

  }
  close(IN);
}

if ($verbose ne "") {
  print Dumper(\%hash_3drugs_year_pref_species_info);
  exit(0);
}





#
# out
#

my $out_header  = "prefNo";
   $out_header .= "\t" . "year";

   $out_header .= "\t" . "species";
   $out_header .= "\t" . "de-duplication_num_SR_EcoKpn";
   $out_header .= "\t" . "de-duplication_total_EcoKpn";
   $out_header .= "\t" . "de-duplication_%IMP6_EcoKpn";
   
   $out_header .= "\t" . "species";
   $out_header .= "\t" . "de-duplication_percent_imipenemRmeropenemR";
   $out_header .= "\t" . "de-duplication_percent_IMP6";
   $out_header .= "\t" . "num_imipenemSmeropenemS";
   $out_header .= "\t" . "num_imipenemRmeropenemR";
   $out_header .= "\t" . "num_imipenemSmeropenemR";
   $out_header .= "\t" . "num_imipenemRmeropenemS";
   $out_header .= "\t" . "ceftazidime_num_ISMR_ceftazidimeS";
   $out_header .= "\t" . "ceftazidime_num_ISMR_ceftazidimeR";
   $out_header .= "\t" . "piperacillin_num_ISMR_piperacillinS";
   $out_header .= "\t" . "piperacillin_num_ISMR_piperacillinR";
   $out_header .= "\t" . "fosfomycin_num_ISMR_fosfomycinS";
   $out_header .= "\t" . "fosfomycin_num_ISMR_fosfomycinR";
   $out_header .= "\t" . "amikacin_num_ISMR_amikacinS";
   $out_header .= "\t" . "amikacin_num_ISMR_amikacinR";
   $out_header .= "\t" . "total";

   $out_header .= "\t" . "species";
   $out_header .= "\t" . "de-duplication_percent_imipenemRmeropenemR";
   $out_header .= "\t" . "de-duplication_percent_IMP6";
   $out_header .= "\t" . "num_imipenemSmeropenemS";
   $out_header .= "\t" . "num_imipenemRmeropenemR";
   $out_header .= "\t" . "num_imipenemSmeropenemR";
   $out_header .= "\t" . "num_imipenemRmeropenemS";
   $out_header .= "\t" . "ceftazidime_num_ISMR_ceftazidimeS";
   $out_header .= "\t" . "ceftazidime_num_ISMR_ceftazidimeR";
   $out_header .= "\t" . "piperacillin_num_ISMR_piperacillinS";
   $out_header .= "\t" . "piperacillin_num_ISMR_piperacillinR";
   $out_header .= "\t" . "fosfomycin_num_ISMR_fosfomycinS";
   $out_header .= "\t" . "fosfomycin_num_ISMR_fosfomycinR";
   $out_header .= "\t" . "amikacin_num_ISMR_amikacinS";
   $out_header .= "\t" . "amikacin_num_ISMR_amikacinR";
   $out_header .= "\t" . "total";

print $out_header . "\n";

foreach my $year (sort {$b <=> $a} keys %hash_year_pref_species_info) {
  foreach my $prefNo (sort {$a <=> $b} keys %{$hash_year_pref_species_info{$year}}) {
    
    my $species = "all";
    
    my $out_line  = "$prefNo\t$year";
    
       $out_line .= "\t" . $species;
       $out_line .= "\t" . $hash_year_pref_species_info{$year}{$prefNo}{$species}{"num_IMP6"};
       $out_line .= "\t" . $hash_year_pref_species_info{$year}{$prefNo}{$species}{"total"};
       $out_line .= "\t" . sprintf("%.5f", $hash_year_pref_species_info{$year}{$prefNo}{$species}{"num_IMP6"} / $hash_year_pref_species_info{$year}{$prefNo}{$species}{"total"} * 100);

    my @arr_species = ();
    push(@arr_species, "E. coli");
    push(@arr_species, "K. pneumoniae");
    foreach my $species (@arr_species) {

       $out_line .= "\t" . $species;
       $out_line .= "\t" . sprintf("%.5f", $hash_year_pref_species_info{$year}{$prefNo}{$species}{"num_RR"} / $hash_year_pref_species_info{$year}{$prefNo}{$species}{"total"} * 100);
       $out_line .= "\t" . sprintf("%.5f", $hash_year_pref_species_info{$year}{$prefNo}{$species}{"num_IMP6"} / $hash_year_pref_species_info{$year}{$prefNo}{$species}{"total"} * 100);

       $out_line .= "\t" . $hash_year_pref_species_info{$year}{$prefNo}{$species}{"num_SS"};
       $out_line .= "\t" . $hash_year_pref_species_info{$year}{$prefNo}{$species}{"num_RR"};
       $out_line .= "\t" . $hash_year_pref_species_info{$year}{$prefNo}{$species}{"num_IMP6"};
       $out_line .= "\t" . $hash_year_pref_species_info{$year}{$prefNo}{$species}{"num_RS"};

       foreach my $drug (@arr_drug_3rds) {
         $out_line .= "\t" . $hash_3drugs_year_pref_species_info{$drug}{$year}{$prefNo}{$species}{"num_SRS"};
         $out_line .= "\t" . $hash_3drugs_year_pref_species_info{$drug}{$year}{$prefNo}{$species}{"num_SRR"};
       }

       $out_line .= "\t" . $hash_year_pref_species_info{$year}{$prefNo}{$species}{"total"};

    }

    print $out_line . "\n";

  }
}


#$species = "K. pneumoniae";