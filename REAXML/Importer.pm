#--------------------------------------------------------------
# REAXML::Importer Module
# Reads an XML packet and commits it to the database
#--------------------------------------------------------------
package REAXML::Importer;
require Exporter;

use strict;

our @ISA     = qw(Exporter);
our @EXPORT  = qw(ProcessResidential SetupHashArray);   # symbols to be exported by default (space-separated)
our $VERSION = 1.00;                  # version number

use Switch;

#----------------
# ConvertDateTimeToMySQL
#----------------

sub ConvertDateTimeToMySQL () {

  my ($returnval) = @_;

  # Target - YYYY-MM-DD hh:mm:ss

  if ($returnval =~ /\d{4}-\d{2}-\d{2}/) { # YYYY-MM-DD
      $returnval = "$returnval 00:00:00";
  } elsif ($returnval =~ /\d{4}-\d{2}-\d{2}-\d{2}:\d{2}/) { # YYYY-MM-DD-hh:mm
      $returnval=~s/(\d{4})-(\d{2})-(\d{2})-(\d{2}):(\d{2})/$1-$2-$3 $4:$5:00/;
  } elsif ($returnval =~ /\d{4}-\d{2}-\d{2}-\d{2}:\d{2}:\d{2}/) { # YYYY-MM-DD-hh:mm:ss
      $returnval=~s/(\d{4})-(\d{2})-(\d{2})-(\d{2}):(\d{2}):(\d{2})/$1-$2-$3 $4:$5:$6/;
  } elsif ($returnval =~ /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/) { # YYYY-MM-DDThh:mm
      $returnval=~s/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/$1-$2-$3 $4:$5:00/;
  } elsif ($returnval =~ /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/) { # YYYY-MM-DDThh:mm:ss
      $returnval=~s/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})/$1-$2-$3 $4:$5:$6/;
  } elsif ($returnval =~ /\d{4}\d{2}\d{2}/) { # YYYYMMDD
      $returnval=~s/(\d{4})(\d{2})(\d{2})/$1-$2-$3 00:00:00/;
  } elsif ($returnval =~ /\d{4}\d{2}\d{2}-\d{2}\d{2}/) { # YYYYMMDD-hhmm
      $returnval=~s/(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})/$1-$2-$3 $4:$5:00/;
  } elsif ($returnval =~ /\d{4}\d{2}\d{2}-\d{2}\d{2}\d{2}/) { # YYYYMMDD-hhmmss
      $returnval=~s/(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/;
  } elsif ($returnval =~ /\d{4}\d{2}\d{2}T\d{2}\d{2}/) { # YYYYMMDDThhmm
      $returnval=~s/(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})/$1-$2-$3 $4:$5:00/;
  } elsif ($returnval =~ /\d{4}\d{2}\d{2}T\d{2}\d{2}\d{2}/) { # YYYYMMDDThhmmss
      $returnval=~s/(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/;
  } else { # Invalid date supplied
      $returnval = undef;
  }

  return($returnval);

}

#----------------
# FindEstate
#----------------

sub FindEstate() {

  my ($dbhwrite,$estatename) = @_;
  my $sql; my $sth; my $estateid;

  eval {
  $sql = "select estateid from ESTATE where estatename=? limit 1";
  $sth=$dbhwrite->prepare($sql);
  $sth->execute($estatename);
  ($estateid)=$sth->fetchrow_array();
  $sth->finish();
  };
  if ($@) { &MySQLterminate($@,"Error searching for existing estate"); }

  # If we don't find this estate, let's add it
  if (!$estateid) {
    eval {
    $sql = "insert into ESTATE (estatename) values (?)";
    $sth=$dbhwrite->prepare($sql);
    $sth->execute($estatename);
    $sth->finish();
    };
    if ($@) { &MySQLterminate($@,"Error inserting estate"); }

    eval {
    $sql = "select last_insert_id()";
    $sth=$dbhwrite->prepare($sql);
    $sth->execute();
    ($estateid)=$sth->fetchrow_array();
    $sth->finish();
    };
    if ($@ || !$estateid) { &MySQLterminate($@,"Error getting estateid"); }
  }

  if ($estateid) {
     return($estateid);
  } else {
     return(undef);
  }

}

#----------------
# FindAuthority
#----------------

sub FindAuthority() {

  my ($authority,$authorityhash) = @_;

  return($authorityhash->{$authority});

}

#----------------
# FindPropertyStatus
#----------------

sub FindPropertyStatus() {

  my ($propertystatus,$propertystatushash) = @_;

  return($propertystatushash->{$propertystatus});

}


#----------------
# FindResidentialCategory
#----------------

sub FindResidentialCategory() {

  my ($category,$categoryhash) = @_;

  return($categoryhash->{$category});

}

#----------------
# ProcessProperty
#----------------

sub ProcessProperty() {

  my ($dbhread,$dbhwrite,$p) = @_;
  my $returnval = "";
  my $sql; my $sth; my $propertyid;

  my @fields = qw (propertyid addressdisplay agentid agentid2 airconditioning alarmsystem buildingarea auctiondate auctionvenue authority balcony bathrooms bedrooms bond broadband builtinrobes businesssubcategory businesssubcategory2 businesssubcategory3 businesslease carspaces carports carryingcapacity category commercialauthority commercialcategory commercialcategory2 commercialcategory3 commerciallistingtype commercialrent commercialrentpersqmmin commercialrentpersqmmax councilrates courtyard createdate crossover currentleaseenddate dateavailable deck deleted depthside depth description dishwasher ductedcooling ductedheating energyrating ensuite estate evaporativecooling exclusivity externallink externallink2 externallink3 fencing floorboards floorplanimageid floorplanimageid2 franchise frontage fullyfenced furnished furtheroptions garages greywatersystem gasheating gym headline heating holidaycategory hotwaterservice hydronicheating imagemodtime improvements insidespa intercom irrigation ishomelandpackage ismultiple landarea landareatype landcategory livingareas lotnumber mainimageid miniweb miniweb2 miniweb3 modtime municipality officeid openfireplace openspaces outdoorent otherfeatures outgoings outsidespa parkingcomments paytv poolinground poolaboveground petfriendly price pricedisplay priceview propertyextent propertytype purchaseorder remotegarage rentprice rentperiod annualreturn reversecycleaircon rumpusroom ruralcategory secureparking services shed site smokers soiltypes solarhotwater solarpanels splitsystemaircon splitsystemheating stage status street streetnum study subnumber suburbid takings tax tenancy tenniscourt terms toilets underoffer uniqueid vacuumsystem videolink watertank workshop zone);

  my @values = ($p->{propertyid},$p->{addressdisplay},$p->{agentid},$p->{agentid2},$p->{airconditioning},$p->{alarmsystem},$p->{buildingarea},$p->{auctiondate},$p->{auctionvenue},$p->{authority},$p->{balcony},$p->{bathrooms},$p->{bedrooms},$p->{bond},$p->{broadband},$p->{builtinrobes},$p->{businesssubcategory},$p->{businesssubcategory2},$p->{businesssubcategory3},$p->{businesslease},$p->{carspaces},$p->{carports},$p->{carryingcapacity},$p->{category},$p->{commercialauthority},$p->{commercialcategory},$p->{commercialcategory2},$p->{commercialcategory3},$p->{commerciallistingtype},$p->{commercialrent},$p->{commercialrentpersqmmin},$p->{commercialrentpersqmmax},$p->{councilrates},$p->{courtyard},$p->{createdate},$p->{crossover},$p->{currentleaseenddate},$p->{dateavailable},$p->{deck},$p->{deleted},$p->{depthside},$p->{depth},$p->{description},$p->{dishwasher},$p->{ductedcooling},$p->{ductedheating},$p->{energyrating},$p->{ensuite},$p->{estate},$p->{evaporativecooling},$p->{exclusivity},$p->{externallink},$p->{externallink2},$p->{externallink3},$p->{fencing},$p->{floorboards},$p->{floorplanimageid},$p->{floorplanimageid2},$p->{franchise},$p->{frontage},$p->{fullyfenced},$p->{furnished},$p->{furtheroptions},$p->{garages},$p->{greywatersystem},$p->{gasheating},$p->{gym},$p->{headline},$p->{heating},$p->{holidaycategory},$p->{hotwaterservice},$p->{hydronicheating},$p->{imagemodtime},$p->{improvements},$p->{insidespa},$p->{intercom},$p->{irrigation},$p->{ishomelandpackage},$p->{ismultiple},$p->{landarea},$p->{landareatype},$p->{landcategory},$p->{livingareas},$p->{lotnumber},$p->{mainimageid},$p->{miniweb},$p->{miniweb2},$p->{miniweb3},$p->{modtime},$p->{municipality},$p->{officeid},$p->{openfireplace},$p->{openspaces},$p->{outdoorent},$p->{otherfeatures},$p->{outgoings},$p->{outsidespa},$p->{parkingcomments},$p->{paytv},$p->{poolinground},$p->{poolaboveground},$p->{petfriendly},$p->{price},$p->{pricedisplay},$p->{priceview},$p->{propertyextent},$p->{propertytype},$p->{purchaseorder},$p->{remotegarage},$p->{rentprice},$p->{rentperiod},$p->{annualreturn},$p->{reversecycleaircon},$p->{rumpusroom},$p->{ruralcategory},$p->{secureparking},$p->{services},$p->{shed},$p->{site},$p->{smokers},$p->{soiltypes},$p->{solarhotwater},$p->{solarpanels},$p->{splitsystemaircon},$p->{splitsystemheating},$p->{stage},$p->{status},$p->{street},$p->{streetnum},$p->{study},$p->{subnumber},$p->{suburbid},$p->{takings},$p->{tax},$p->{tenancy},$p->{tenniscourt},$p->{terms},$p->{toilets},$p->{underoffer},$p->{uniqueid},$p->{vacuumsystem},$p->{videolink},$p->{watertank},$p->{workshop},$p->{zone});

  # First check if property exists for given OfficeID
  eval {
  $sql = "select propertyid from PROPERTY where uniqueid = ? and officeid = ? limit 1";
  $sth = $dbhread->prepare($sql);
  $sth->execute($p->{uniqueid},$p->{officeid});
  $propertyid = $sth->fetchrow_array();
  $sth->finish();
  };
  if ($@) { &MySQLterminate($@,"Error searching for existing property"); }
  
  if ($propertyid) { # We are updating
      print "Matched on propertyid $propertyid\n";
  } else { # We are adding

      $sql = "insert into PROPERTY (";

      foreach my $field (@fields) {
            next if ($field eq "propertyid");
            $sql.="$field,";
      }

      chop($sql);
      $sql.=") values (";

      for(my $i=0; $i<@fields-1; $i++) {  # Minus one for propertyid
            $sql.="?,";
      }
      chop($sql);

      $sql.=")";

      eval {
      $sth = $dbhwrite->prepare($sql);
      $sth->execute(@values[1..@values-1]);
      $sth->finish();
      };
      if ($@) { &MySQLterminate($@,"Error inserting property"); }
     
      $dbhwrite->commit();

  }

  

}

#----------------
# ProcessResidential
#----------------

sub ProcessResidential() {

  my ($dbhread,$dbhwrite,$propertyList,$p,$authorityhash,$commercialauthorityhash,$commercialcategoryhash,$holidaycategoryhash,$landareatypehash,$propertystatushash,$residentialcategoryhash,$ruralcategoryhash,$statehash) = @_;

  $p->{propertytype}=7; # Residential

  foreach my $residential ($propertyList->getElementsByTagName('residential')) {

     $p->{modtime} = $residential->getAttributeNode('modTime')->getValue;
     $p->{modtime} = &ConvertDateTimeToMySQL($p->{modtime});
     $p->{status} = $residential->getAttributeNode('status')->getValue;
     $p->{status} = &FindPropertyStatus($p->{status},$propertystatushash);

     # Handle Address
     if ($residential->getElementsByTagName('address')->item(0)) {
        my $address = $residential->getElementsByTagName('address')->item(0);
        $p->{subnumber} = &ProcessLeafNode($dbhwrite,$address,'subNumber','string');
        $p->{lotnumber} = &ProcessLeafNode($dbhwrite,$address,'lotNumber','string');
        $p->{streetnum} = &ProcessLeafNode($dbhwrite,$address,'streetNumber','string');
        $p->{street} = &ProcessLeafNode($dbhwrite,$address,'street','string');
        $p->{suburb} = &ProcessLeafNode($dbhwrite,$address,'suburb','string');
        $p->{state} = &ProcessLeafNode($dbhwrite,$address,'state','string');
        $p->{postcode} = &ProcessLeafNode($dbhwrite,$address,'postcode','string');
        $p->{country} = &ProcessLeafNode($dbhwrite,$address,'country','string');
     } else {
        my $address = "";
        $p->{subnumber} = undef;
        $p->{lotnumber} = undef;
        $p->{streetnum} = undef;
        $p->{street} = undef;
        $p->{suburb} = undef;
        $p->{state} = undef;
        $p->{postcode} = undef;
        $p->{country} = undef;
     }

     $p->{suburbid} = &FindSuburb($dbhread,$p->{suburb},$p->{state},$p->{postcode});

     $p->{officeid} = &ProcessLeafNode($dbhwrite,$residential,'agentID','string');

     # Convert REA agentID to our primary key
     $p->{officeid} = &FindOffice($dbhread,$p->{officeid});

     if ($p->{officeid} eq "") {
         print "Fatal error: office not found\n";
         next;
     }

     $p->{agentid} = 1;

     $p->{auctiondate} = &GetAttributeFromNode($dbhwrite,$residential,'auction','date','date');
     $p->{authority} = &GetAttributeFromNode($dbhwrite,$residential,'authority','value','string');
     $p->{authority} = &FindAuthority($p->{authority},$authorityhash);
     
     if ($residential->getElementsByTagName('buildingDetails')->item(0)) {
         my $buildingdetails = $residential->getElementsByTagName('buildingDetails')->item(0);
         if ($buildingdetails->getElementsByTagName('energyRating')) {
             $p->{energyrating} = $buildingdetails->getElementsByTagName('energyRating');
         }
         if ($buildingdetails->getElementsByTagName('area')) {
             $p->{buildingarea} = &ProcessLeafNode($dbhwrite,$buildingdetails,'area','double');
             # We hard code unit as SQM
         }
     }

     if ($residential->getElementsByTagName('landDetails')->item(0)) {
         my $landdetails= $residential->getElementsByTagName('landDetails')->item(0);
         $p->{crossover} = &GetAttributeFromNode($dbhwrite,$landdetails,'councilrates','value','string');
         $p->{depth} = &ProcessLeafNode($dbhwrite,$landdetails,'depth','double');
         $p->{depthside} = &GetAttributeFromNode($dbhwrite,$landdetails,'depth','side','string');
         $p->{frontage} = &ProcessLeafNode($dbhwrite,$landdetails,'frontage','double');
         $p->{landarea} = &ProcessLeafNode($dbhwrite,$landdetails,'area','double');
         $p->{landareatype} = &GetAttributeFromNode($dbhwrite,$landdetails,'area','unit','double');
         $p->{landareatype} = &FindLandAreaType($p->{landareatype});
     }

     if ($residential->getElementsByTagName('features')->item(0)) {
         my $features = $residential->getElementsByTagName('features')->item(0);
         $p->{airconditioning} = &ProcessLeafNode($dbhwrite,$features,'airConditioning','boolean');
         $p->{alarmsystem} = &ProcessLeafNode($dbhwrite,$features,'alarmSystem','boolean');
         $p->{balcony} = &ProcessLeafNode($dbhwrite,$features,'balcony','boolean');
         $p->{bathrooms} = &ProcessLeafNode($dbhwrite,$features,'bathrooms','integer');
         $p->{bedrooms} = &ProcessLeafNode($dbhwrite,$features,'bedrooms','integer');
         $p->{broadband} = &ProcessLeafNode($dbhwrite,$features,'broadband','boolean');
         $p->{builtinrobes} = &ProcessLeafNode($dbhwrite,$features,'builtInRobes','boolean');
         $p->{carports} = &ProcessLeafNode($dbhwrite,$features,'carports','integer');
         $p->{courtyard} = &ProcessLeafNode($dbhwrite,$features,'courtyard','boolean');
         $p->{deck} = &ProcessLeafNode($dbhwrite,$features,'deck','boolean');
         $p->{dishwasher} = &ProcessLeafNode($dbhwrite,$features,'dishwasher','boolean');
         $p->{ductedcooling} = &ProcessLeafNode($dbhwrite,$features,'ductedcooling','boolean');
         $p->{ensuite} = &ProcessLeafNode($dbhwrite,$features,'ensuite','integer');
         $p->{evaporativecooling} = &ProcessLeafNode($dbhwrite,$features,'evaporativecooling','boolean');
         $p->{floorboards} = &ProcessLeafNode($dbhwrite,$features,'floorboards','boolean');
         $p->{fullyfenced} = &ProcessLeafNode($dbhwrite,$features,'fullyfenced','boolean');
         $p->{garages} = &ProcessLeafNode($dbhwrite,$features,'garages','integer');
         $p->{gasheating} = &ProcessLeafNode($dbhwrite,$features,'gasheating','boolean');
         $p->{gym} = &ProcessLeafNode($dbhwrite,$features,'gym','boolean');
         $p->{heating} = &GetAttributeFromNode($dbhwrite,$residential,'heating','type','string');
         $p->{hotwaterservice} = &GetAttributeFromNode($dbhwrite,$features,'hotWaterService','type','string');
         $p->{hydronicheating} = &ProcessLeafNode($dbhwrite,$features,'hydronicHeating','boolean');
         $p->{insidespa} = &ProcessLeafNode($dbhwrite,$features,'insideSpa','boolean');
         $p->{intercom} = &ProcessLeafNode($dbhwrite,$features,'intercom','boolean');
         $p->{livingareas} = &ProcessLeafNode($dbhwrite,$features,'livingAreas','boolean');
         $p->{openfireplace} = &ProcessLeafNode($dbhwrite,$features,'openFirePlace','boolean');
         $p->{openspaces} = &ProcessLeafNode($dbhwrite,$features,'openSpaces','integer');
         $p->{outdoorent} = &ProcessLeafNode($dbhwrite,$features,'outdoorEnt','boolean');
         $p->{otherfeatures} = &ProcessLeafNode($dbhwrite,$features,'otherFeatures','string');
         $p->{outsidespa} = &ProcessLeafNode($dbhwrite,$features,'outsideSpa','boolean');
         $p->{paytv} = &ProcessLeafNode($dbhwrite,$features,'payTV','boolean');
         $p->{poolinground} = &ProcessLeafNode($dbhwrite,$features,'poolInGround','boolean');
         $p->{poolaboveground} = &ProcessLeafNode($dbhwrite,$features,'poolAboveGround','boolean');
         $p->{remotegarage} = &ProcessLeafNode($dbhwrite,$features,'remoteGarage','boolean');
         $p->{reversecycleaircon} = &ProcessLeafNode($dbhwrite,$features,'reverseCycleAirCon','boolean');
         $p->{rumpusroom} = &ProcessLeafNode($dbhwrite,$features,'rumpusRoom','boolean');
         $p->{secureParking} = &ProcessLeafNode($dbhwrite,$features,'secureParking','boolean');
         $p->{shed} = &ProcessLeafNode($dbhwrite,$features,'shed','boolean');
         $p->{splitsystemaircon} = &ProcessLeafNode($dbhwrite,$features,'splitSystemAirCon','boolean');
         $p->{splitsystemheating} = &ProcessLeafNode($dbhwrite,$features,'splitSystemHeating','boolean');
         $p->{study} = &ProcessLeafNode($dbhwrite,$features,'study','boolean');
         $p->{tenniscourt} = &ProcessLeafNode($dbhwrite,$features,'tennisCourt','boolean');
         $p->{toilets} = &ProcessLeafNode($dbhwrite,$features,'toilets','integer');
         $p->{vacuumsystem} = &ProcessLeafNode($dbhwrite,$features,'vacuumSystem','boolean');
         $p->{watertank} = &ProcessLeafNode($dbhwrite,$features,'waterTank','boolean');
         $p->{workshop} = &ProcessLeafNode($dbhwrite,$features,'workshop','boolean');
     }
     
     $p->{category} = &GetAttributeFromNode($dbhwrite,$residential,'category','name','string');
     $p->{category} = &FindResidentialCategory($p->{category},$residentialcategoryhash);
     $p->{councilrates} = &ProcessLeafNode($dbhwrite,$residential,'councilrates','string');
     $p->{description} = &ProcessLeafNode($dbhwrite,$residential,'description','string');
     
     if ($residential->getElementsByTagName('ecoFriendly')->item(0)) {
         my $ecofriendly = $residential->getElementsByTagName('ecoFriendly')->item(0);
         $p->{solarpanels} = &ProcessLeafNode($dbhwrite,$ecofriendly,'solarPanels','boolean');
         $p->{solarhotwater} = &ProcessLeafNode($dbhwrite,$ecofriendly,'solarHotWater','boolean');
         $p->{watertank} = &ProcessLeafNode($dbhwrite,$ecofriendly,'waterTank','boolean');
         $p->{greywatersystem} = &ProcessLeafNode($dbhwrite,$ecofriendly,'greyWaterSystem','boolean');
     }

     $p->{estate} = &ProcessLeafNode($dbhwrite,$residential,'estate','string');
     $p->{estate} = &FindEstate($dbhwrite,$p->{estate}) if ($p->{estate});

     $p->{exclusivity} = &GetAttributeFromNode($dbhwrite,$residential,'exclusivity','value','string');

     my $counter=0;
     if ($residential->getElementsByTagName('externalLink')->item(0)) {
       foreach my $externallink ($residential->getElementsByTagName('externalLink')) {
         if ($counter==0) {
            $p->{externallink} = &GetAttributeFromNode($dbhwrite,$residential,'externalLink','href','string');
         } elsif ($counter==1) {
            $p->{externallink2} = &GetAttributeFromNode($dbhwrite,$residential,'externalLink','href','string');
         } elsif ($counter==2) {
            $p->{externallink3} = &GetAttributeFromNode($dbhwrite,$residential,'externalLink','href','string');
         }
       }
     }

     $p->{headline} = &ProcessLeafNode($dbhwrite,$residential,'headline','string');

     if ($residential->getElementsByTagName('inspectionTimes')->item(0)) {
         my $inspectionTimes = $residential->getElementsByTagName('inspectionTimes')->item(0);
         foreach my $inspection ($inspectionTimes->getElementsByTagName('inspection')) {
             #$p->{} = &ProcessLeafNode($dbhwrite,$residential,'estate','string');
         }
     }

     $p->{ishomelandpackage} = &GetAttributeFromNode($dbhwrite,$residential,'isHomeLandPackage','value','boolean');
     $p->{municipality} = &ProcessLeafNode($dbhwrite,$residential,'municipality','string');
     
     $p->{price} = &ProcessLeafNode($dbhwrite,$residential,'price','double');
     $p->{pricedisplay} = &GetAttributeFromNode($dbhwrite,$residential,'price','display','boolean');
     $p->{priceview} = &ProcessLeafNode($dbhwrite,$residential,'priceView','string');

     if ($p->{status} eq "sold") {
         if ($residential->getElementsByTagName('soldDetails')->item(0)) {
            my $solddetails = $residential->getElementsByTagName('soldDetails')->item(0);
            $p->{solddate} = &ProcessLeafNode($dbhwrite,$solddetails,'soldDate','date');
            $p->{soldprice} = &ProcessLeafNode($dbhwrite,$solddetails,'soldPrice','double');
            $p->{soldpricedisplay} = &GetAttributeFromNode($dbhwrite,$solddetails,'soldPrice','display','boolean');
         }
     }

     $p->{stage} = &ProcessLeafNode($dbhwrite,$residential,'stage','string');
     $p->{underoffer} = &GetAttributeFromNode($dbhwrite,$residential,'underOffer','value','boolean');
     $p->{uniqueid} = &ProcessLeafNode($dbhwrite,$residential,'uniqueID','string');
     $p->{videolink} = &ProcessLeafNode($dbhwrite,$residential,'videoLink','string');

     print "Processing $p->{uniqueid} ($p->{streetnum} $p->{street}, $p->{suburb})\n";

     my ($success) = &ProcessProperty($dbhread,$dbhwrite,$p);

  }

}

#----------------
# ProcessLeafNode
#----------------

sub ProcessLeafNode() {

  my ($dbhwrite,$parent,$nodename,$datatype) = @_;
  my $returnval;

  if ($parent->getElementsByTagName("$nodename")->item(0)) {
     if ($parent->getElementsByTagName("$nodename")->item(0)->getFirstChild) {
        $returnval = $parent->getElementsByTagName("$nodename")->item(0)->getFirstChild->getData;
     } 
     if ($datatype eq "string") {
     } elsif ($datatype eq "double") {
        $returnval = sprintf("%.2f",$returnval);
     } elsif ($datatype eq "boolean") { # All booleans are stored as 1 or 0 in our database table
        if ($returnval =~ /true/i || $returnval =~ /yes/i || $returnval >= 1) { 
             $returnval = 1;
        } else {
             $returnval = 0;
        }
     } elsif ($datatype eq "date") {
        $returnval = &ConvertDateTimeToMySQL($returnval);
     } elsif ($datatype eq "integer") {
        $returnval = sprintf("%d",$returnval);
     } 
  } else {
     $returnval = undef;
  }

  return ($returnval);

}

#----------------
# GetAttributeFromNode
#----------------

sub GetAttributeFromNode() {

  my ($dbhwrite,$parent,$nodename,$attributename,$datatype) = @_;
  my $returnval = "";

  if ($parent->getElementsByTagName("$nodename")->item(0)) {
     $returnval = $parent->getElementsByTagName("$nodename")->item(0)->getAttributeNode("$attributename")->getValue;
     if ($datatype eq "string") {
        #$returnval = $dbhwrite->quote($returnval);
     } elsif ($datatype eq "double") {
        $returnval = sprintf("%.2f",$returnval);
     } elsif ($datatype eq "boolean") { # All booleans are stored as 1 or 0 in our database table
        if ($returnval =~ /true/i || $returnval =~ /yes/i || $returnval >= 1) {
             $returnval = 1;
        } else {
             $returnval = 0;
        }
     } elsif ($datatype eq "integer") {
        $returnval = sprintf("%d",$returnval);
     } elsif ($datatype eq "date") {
        $returnval = &ConvertDateTimeToMySQL($returnval);
     }
  } else {
     $returnval = undef;
  }

  return ($returnval);

}


#----------------
# FindOffice
#----------------

sub FindOffice() {

  my ($dbhread,$officeid) = @_;
  my $sql; my $sth; 
  my $returnval = "";

  eval {
  $sql = "select officeid from OFFICE where reaxmlid=? limit 1";
  $sth=$dbhread->prepare($sql);
  $sth->execute($officeid);
  ($returnval) = $sth->fetchrow_array();
  $sth->finish();
  };
  if ($@) {
     &MySQLterminate($@,"Error searching for office");
  }

  return($returnval);

}

#----------------
# FindSuburb
#----------------

sub FindSuburb() {

  my ($dbhread,$suburb,$state,$postcode) = @_;
  my $sql; my $sth; 
  my $returnval = "";

  eval {
  $sql = "select suburbid from SUBURB a, STATE b where a.stateid=b.stateid and a.suburb=? and a.postcode=? and a.pobox is null and b.abbrev=? limit 1";
  $sth=$dbhread->prepare($sql);
  $sth->execute($suburb,$postcode,$state);
  ($returnval) = $sth->fetchrow_array();
  $sth->finish();
  };
  if ($@) {
     &MySQLterminate($@,"Error searching for suburb");
  }

  # Fall back on "UNKNOWN" suburb if we can't locate.
  $returnval = 1 unless $returnval;

  return($returnval);

}

#----------------
# FindLandAreaType
#----------------

sub FindLandAreaType() {

  my ($landareatype) = @_;

  if ($landareatype eq "hectare") {
    return(3);
  } elsif ($landareatype eq "acre") {
    return(2);
  } else { # sqm
    return(1);
  }

}

#----------------
# SetupHashArray
#----------------

sub SetupHashArray() {

  my ($dbhread,$hashvalue) = @_;
  my $sth; my $sql; my $a; my $b;

  switch($hashvalue) {
      case('authority') { $sql = "select authorityid,authorityname from AUTHORITY"; }
      case('commercialauthority') { $sql = "select authorityid,authorityname from COMMERCIAL_AUTHORITY"; }
      case('commercialcategory') { $sql = "select typeid,typename from COMMERCIAL_CATEGORY"; }
      case('holidaycategory') { $sql = "select typeid,typename from HOLIDAY_CATEGORY"; }
      case('landareatype') { $sql = "select typeid,typename from LANDAREATYPE"; }
      case('propertystatus') { $sql = "select statusid,statusname from PROPERTY_STATUS"; }
      case('residentialcategory') { $sql = "select typeid,typename from RESIDENTIAL_CATEGORY"; }
      case('ruralcategory') { $sql = "select typeid,typename from RURAL_CATEGORY"; }
      case('state') { $sql = "select stateid,abbrev from STATE"; }
  }

  my %hash = ();

  eval {
  $sth = $dbhread->prepare($sql);  
  $sth->execute();
  while (($a,$b)=$sth->fetchrow_array) {
     $hash{$b}=$a;
  }
  $sth->finish();
  };
  if ($@) { &MySQLterminate($@,"Error writing hash values"); }

  return(%hash);

}

1;

