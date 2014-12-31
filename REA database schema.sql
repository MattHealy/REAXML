drop database if exists reaxml;
create database reaxml;
use reaxml;

create table STATE (
 stateid INT NOT NULL AUTO_INCREMENT,
 state VARCHAR(30),
 abbrev VARCHAR(8),
 PRIMARY KEY(stateid)
) Engine=InnoDB;

insert into STATE (stateid,state,abbrev) values (1,'Australian Capital Territory','ACT');
insert into STATE (stateid,state,abbrev) values (2,'New South Wales','NSW');
insert into STATE (stateid,state,abbrev) values (3,'Northern Territory','NT');
insert into STATE (stateid,state,abbrev) values (4,'South Australia','SA');
insert into STATE (stateid,state,abbrev) values (5,'Queensland','QLD');
insert into STATE (stateid,state,abbrev) values (6,'Tasmania','TAS');
insert into STATE (stateid,state,abbrev) values (7,'Victoria','VIC');
insert into STATE (stateid,state,abbrev) values (8,'Western Australia','WA');

create table SUBURB (
 suburbid INT NOT NULL AUTO_INCREMENT,
 suburb VARCHAR(250),
 postcode varchar(8),
 pobox TINYINT,
 stateid INT,
 PRIMARY KEY(suburbid),
 INDEX(suburb),
 INDEX(postcode),
 INDEX(stateid),
 FOREIGN KEY(stateid) REFERENCES STATE (stateid)
) Engine=InnoDB;

create table DOCUMENT (
 documentid INT NOT NULL AUTO_INCREMENT,
 documenturl VARCHAR(500),
 PRIMARY KEY(documentid)
) Engine=InnoDB;

create table ESTATE (
 estateid INT NOT NULL AUTO_INCREMENT,
 estatename VARCHAR(500),
 PRIMARY KEY(estateid)
) Engine=InnoDB;

create table OFFICE (
 officeid INT NOT NULL AUTO_INCREMENT,
 officename VARCHAR(500),
 reaxmlid VARCHAR(20),
 PRIMARY KEY(officeid),
 INDEX(reaxmlid)
) Engine=InnoDB;

create table AGENT (
 agentid INT NOT NULL AUTO_INCREMENT,
 officeid INT NOT NULL,
 firstname VARCHAR(75),
 lastname VARCHAR(75),
 email VARCHAR(255),
 telephone VARCHAR(20),
 mobile VARCHAR(20),
 PRIMARY KEY(agentid),
 INDEX(officeid),
 FOREIGN KEY(officeid) REFERENCES OFFICE (officeid)
) Engine=InnoDB;

create table IMAGE (
 imageid INT NOT NULL AUTO_INCREMENT,
 officeid INT NOT NULL,
 imageurl VARCHAR(500),
 PRIMARY KEY(imageid),
 INDEX(officeid),
 FOREIGN KEY(officeid) REFERENCES OFFICE (officeid)
) Engine=InnoDB;

create table AUTHORITY (
 authorityid INT NOT NULL AUTO_INCREMENT,
 authorityname VARCHAR(50),
 PRIMARY KEY(authorityid)
) Engine=InnoDB;

insert into AUTHORITY (authorityid,authorityname) values (1,'auction');
insert into AUTHORITY (authorityid,authorityname) values (2,'exclusive');
insert into AUTHORITY (authorityid,authorityname) values (3,'multilist');
insert into AUTHORITY (authorityid,authorityname) values (4,'conjunctional');
insert into AUTHORITY (authorityid,authorityname) values (5,'open');
insert into AUTHORITY (authorityid,authorityname) values (6,'sale');
insert into AUTHORITY (authorityid,authorityname) values (7,'setsale');

create table COMMERCIAL_AUTHORITY (
 authorityid INT NOT NULL AUTO_INCREMENT,
 authorityname VARCHAR(50),
 PRIMARY KEY(authorityid)
) Engine=InnoDB;

insert into COMMERCIAL_AUTHORITY (authorityid,authorityname) values (1,'auction');
insert into COMMERCIAL_AUTHORITY (authorityid,authorityname) values (2,'eoi');
insert into COMMERCIAL_AUTHORITY (authorityid,authorityname) values (3,'forsale');
insert into COMMERCIAL_AUTHORITY (authorityid,authorityname) values (4,'offers');
insert into COMMERCIAL_AUTHORITY (authorityid,authorityname) values (5,'sale');
insert into COMMERCIAL_AUTHORITY (authorityid,authorityname) values (6,'tender');

create table PROPERTY_TYPE (
 typeid INT NOT NULL AUTO_INCREMENT,
 typename VARCHAR(50),
 PRIMARY KEY(typeid)
) Engine=InnoDB;

insert into PROPERTY_TYPE (typeid,typename) values (1,'Business');
insert into PROPERTY_TYPE (typeid,typename) values (2,'Commercial');
insert into PROPERTY_TYPE (typeid,typename) values (3,'Commercial Land');
insert into PROPERTY_TYPE (typeid,typename) values (4,'Land');
insert into PROPERTY_TYPE (typeid,typename) values (5,'Rental');
insert into PROPERTY_TYPE (typeid,typename) values (6,'Holiday Rental');
insert into PROPERTY_TYPE (typeid,typename) values (7,'Residential');
insert into PROPERTY_TYPE (typeid,typename) values (8,'Rural');

create table PROPERTY_STATUS (
 statusid INT NOT NULL AUTO_INCREMENT,
 statusname VARCHAR(50),
 PRIMARY KEY(statusid)
) Engine=InnoDB;

insert into PROPERTY_STATUS (statusid,statusname) values (1,'current');
insert into PROPERTY_STATUS (statusid,statusname) values (2,'withdrawn');
insert into PROPERTY_STATUS (statusid,statusname) values (3,'offmarket');
insert into PROPERTY_STATUS (statusid,statusname) values (4,'leased');
insert into PROPERTY_STATUS (statusid,statusname) values (5,'sold');

create table LANDAREATYPE (
 typeid INT NOT NULL AUTO_INCREMENT,
 typename VARCHAR(50),
 PRIMARY KEY(typeid)
) Engine=InnoDB;

insert into LANDAREATYPE (typeid,typename) values (1,'sqm');
insert into LANDAREATYPE (typeid,typename) values (2,'acre');
insert into LANDAREATYPE (typeid,typename) values (3,'hectare');

create table HOLIDAY_CATEGORY (
 typeid INT NOT NULL AUTO_INCREMENT,
 typename VARCHAR(50),
 PRIMARY KEY(typeid)
) Engine=InnoDB;

insert into HOLIDAY_CATEGORY (typeid,typename) values (1,'House');
insert into HOLIDAY_CATEGORY (typeid,typename) values (2,'Alpine');
insert into HOLIDAY_CATEGORY (typeid,typename) values (3,'Apartment');
insert into HOLIDAY_CATEGORY (typeid,typename) values (4,'Backpacker-Hostel');
insert into HOLIDAY_CATEGORY (typeid,typename) values (5,'BedAndBreakfast');
insert into HOLIDAY_CATEGORY (typeid,typename) values (6,'Campground');
insert into HOLIDAY_CATEGORY (typeid,typename) values (7,'Caravan-HolidayPark');
insert into HOLIDAY_CATEGORY (typeid,typename) values (8,'DuplexSemi-detached');
insert into HOLIDAY_CATEGORY (typeid,typename) values (9,'ExecutiveRental');
insert into HOLIDAY_CATEGORY (typeid,typename) values (10,'FarmStay');
insert into HOLIDAY_CATEGORY (typeid,typename) values (11,'Flat');
insert into HOLIDAY_CATEGORY (typeid,typename) values (12,'Hotel');
insert into HOLIDAY_CATEGORY (typeid,typename) values (13,'HouseBoat');
insert into HOLIDAY_CATEGORY (typeid,typename) values (14,'Lodge');
insert into HOLIDAY_CATEGORY (typeid,typename) values (15,'Motel');
insert into HOLIDAY_CATEGORY (typeid,typename) values (16,'Resort');
insert into HOLIDAY_CATEGORY (typeid,typename) values (17,'Retreat');
insert into HOLIDAY_CATEGORY (typeid,typename) values (18,'SelfContainedCottage');
insert into HOLIDAY_CATEGORY (typeid,typename) values (19,'ServicedApartment');
insert into HOLIDAY_CATEGORY (typeid,typename) values (20,'Studio');
insert into HOLIDAY_CATEGORY (typeid,typename) values (21,'Terrace');
insert into HOLIDAY_CATEGORY (typeid,typename) values (22,'Townhouse');
insert into HOLIDAY_CATEGORY (typeid,typename) values (23,'Unit');
insert into HOLIDAY_CATEGORY (typeid,typename) values (24,'Villa');
insert into HOLIDAY_CATEGORY (typeid,typename) values (25,'Other');

create table RESIDENTIAL_CATEGORY (
 typeid INT NOT NULL AUTO_INCREMENT,
 typename VARCHAR(50),
 PRIMARY KEY(typeid)
) Engine=InnoDB;

insert into RESIDENTIAL_CATEGORY (typeid,typename) values (1,'House');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (2,'Unit');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (3,'Townhouse');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (4,'Villa');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (5,'Apartment');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (6,'Flat');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (7,'Studio');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (8,'Warehouse');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (9,'DuplexSemi-detached');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (10,'Alpine');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (11,'AcreageSemi-rural');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (12,'BlockOfUnits');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (13,'Terrace');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (14,'Retirement');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (15,'ServicedApartment');
insert into RESIDENTIAL_CATEGORY (typeid,typename) values (16,'Other');

create table COMMERCIAL_CATEGORY (
 typeid INT NOT NULL AUTO_INCREMENT,
 typename VARCHAR(50),
 PRIMARY KEY(typeid)
) Engine=InnoDB;

insert into COMMERCIAL_CATEGORY (typeid,typename) values (1,'Commercial Farming');
insert into COMMERCIAL_CATEGORY (typeid,typename) values (2,'Land/Development');
insert into COMMERCIAL_CATEGORY (typeid,typename) values (3,'Hotel/Leisure');
insert into COMMERCIAL_CATEGORY (typeid,typename) values (4,'Industrial/Warehouse');
insert into COMMERCIAL_CATEGORY (typeid,typename) values (5,'Medical/Consulting');
insert into COMMERCIAL_CATEGORY (typeid,typename) values (6,'Offices');
insert into COMMERCIAL_CATEGORY (typeid,typename) values (7,'Retail');
insert into COMMERCIAL_CATEGORY (typeid,typename) values (8,'Showrooms/Bulky Goods');

create table RURAL_CATEGORY (
 typeid INT NOT NULL AUTO_INCREMENT,
 typename VARCHAR(50),
 PRIMARY KEY(typeid)
) Engine=InnoDB;

insert into RURAL_CATEGORY (typeid,typename) values (1,'Cropping');
insert into RURAL_CATEGORY (typeid,typename) values (2,'Dairy');
insert into RURAL_CATEGORY (typeid,typename) values (3,'Farmlet');
insert into RURAL_CATEGORY (typeid,typename) values (4,'Horticulture');
insert into RURAL_CATEGORY (typeid,typename) values (5,'Lifestyle');
insert into RURAL_CATEGORY (typeid,typename) values (6,'Livestock');
insert into RURAL_CATEGORY (typeid,typename) values (7,'Viticulture');
insert into RURAL_CATEGORY (typeid,typename) values (8,'MixedFarming');
insert into RURAL_CATEGORY (typeid,typename) values (9,'Other');

create table PROPERTY (
 propertyid INT NOT NULL AUTO_INCREMENT,
 addressdisplay TINYINT,
 agentid INT NOT NULL,
 agentid2 INT,
 airconditioning TINYINT,
 alarmsystem TINYINT,
 annualreturn DOUBLE,
 auctiondate DATETIME,
 auctionvenue VARCHAR(255),
 authority INT,
 balcony TINYINT,
 bathrooms INT,
 bedrooms INT,
 bond DOUBLE,
 broadband TINYINT,
 buildingarea DOUBLE,
 builtinrobes TINYINT,
 businesssubcategory INT,
 businesssubcategory2 INT,
 businesssubcategory3 INT,
 businesslease DOUBLE,
 carspaces INT,
 carports INT,
 carryingcapacity TEXT,
 category INT,
 commercialauthority INT,
 commercialcategory INT,
 commercialcategory2 INT,
 commercialcategory3 INT,
 commerciallistingtype ENUM('sale','lease','both'),
 commercialrent DOUBLE,
 commercialrentpersqmmin DOUBLE,
 commercialrentpersqmmax DOUBLE,
 councilrates VARCHAR(255),
 courtyard TINYINT,
 createdate DATETIME,
 crossover ENUM('left','right','center'),
 currentleaseenddate DATETIME,
 dateavailable DATETIME,
 deck TINYINT,
 deleted TINYINT,
 depthside ENUM('left','right','rear'),
 depth DOUBLE,
 description TEXT,
 dishwasher TINYINT,
 ductedcooling TINYINT,
 ductedheating TINYINT,
 energyrating DOUBLE,
 ensuite INT,
 estate INT,
 evaporativecooling TINYINT,
 exclusivity ENUM('exclusive','open'),
 externallink VARCHAR(500),
 externallink2 VARCHAR(500),
 externallink3 VARCHAR(500),
 fencing TEXT,
 floorboards TINYINT,
 floorplanimageid INT,
 floorplanimageid2 INT,
 franchise TINYINT,
 frontage DOUBLE,
 fullyfenced TINYINT,
 furnished TINYINT,
 furtheroptions TEXT,
 garages INT,
 greywatersystem TINYINT,
 gasheating TINYINT,
 gym TINYINT,
 headline VARCHAR(150),
 heating ENUM('gas','electric','GDH','solid','other'),
 holidaycategory INT,
 hotwaterservice ENUM('gas','electric','solar'),
 hydronicheating TINYINT,
 imagemodtime DATETIME,
 improvements TEXT,
 insidespa TINYINT,
 intercom TINYINT,
 irrigation TEXT,
 ishomelandpackage TINYINT,
 ismultiple TINYINT,
 landarea DOUBLE,
 landareatype INT NOT NULL DEFAULT 1 ,
 landcategory ENUM('commercial','residential'),
 livingareas INT,
 lotnumber VARCHAR(20),
 mainimageid INT,
 miniweb VARCHAR(500),
 miniweb2 VARCHAR(500),
 miniweb3 VARCHAR(500),
 modtime DATETIME,
 municipality VARCHAR(255), 
 officeid INT NOT NULL,
 openfireplace TINYINT,
 openspaces INT,
 outdoorent TINYINT,
 otherfeatures VARCHAR(100),
 outgoings DOUBLE,
 outsidespa TINYINT,
 parkingcomments VARCHAR(255),
 paytv TINYINT,
 poolinground TINYINT,
 poolaboveground TINYINT,
 petfriendly TINYINT,
 price DOUBLE,
 pricedisplay TINYINT,
 priceview VARCHAR(50),
 propertyextent ENUM('whole','part'),
 propertytype INT NOT NULL,
 purchaseorder VARCHAR(20),
 remotegarage TINYINT,
 rentprice DOUBLE,
 rentperiod ENUM('week','month'),
 reversecycleaircon TINYINT,
 rumpusroom TINYINT,
 ruralcategory INT,
 secureparking TINYINT,
 services TEXT,
 shed TINYINT,
 site VARCHAR(50),
 smokers TINYINT,
 soiltypes TEXT,
 solarhotwater TINYINT,
 solarpanels TINYINT,
 splitsystemaircon TINYINT,
 splitsystemheating TINYINT,
 stage VARCHAR(100),
 status INT NOT NULL,
 street VARCHAR(500),
 streetnum VARCHAR(20),
 study TINYINT,
 subnumber VARCHAR(20),
 suburbid INT,
 takings VARCHAR(255),
 tax ENUM('unknown','exempt','inclusive','exclusive'),
 tenancy ENUM('unknown','vacant','tenanted'),
 tenniscourt TINYINT,
 terms VARCHAR(300),
 toilets INT,
 underoffer TINYINT,
 uniqueid VARCHAR(50),
 vacuumsystem TINYINT,
 videolink VARCHAR(500),
 watertank TINYINT,
 workshop TINYINT,
 zone VARCHAR(150),
 PRIMARY KEY(propertyid),
 INDEX(officeid),
 FOREIGN KEY(officeid) REFERENCES OFFICE (officeid),
 INDEX(landareatype),
 FOREIGN KEY(landareatype) REFERENCES LANDAREATYPE (typeid),
 INDEX(authority),
 FOREIGN KEY(authority) REFERENCES AUTHORITY (authorityid),
 INDEX(propertytype),
 FOREIGN KEY(propertytype) REFERENCES PROPERTY_TYPE (typeid),
 INDEX(agentid),
 FOREIGN KEY(agentid) REFERENCES AGENT (agentid),
 INDEX(agentid2),
 FOREIGN KEY(agentid2) REFERENCES AGENT (agentid),
 INDEX(category),
 FOREIGN KEY(category) REFERENCES RESIDENTIAL_CATEGORY (typeid),
 INDEX(commercialauthority),
 FOREIGN KEY(commercialauthority) REFERENCES COMMERCIAL_AUTHORITY (authorityid),
 INDEX(commercialcategory),
 FOREIGN KEY(commercialcategory) REFERENCES COMMERCIAL_CATEGORY (typeid),
 INDEX(commercialcategory2),
 FOREIGN KEY(commercialcategory2) REFERENCES COMMERCIAL_CATEGORY (typeid),
 INDEX(commercialcategory3),
 FOREIGN KEY(commercialcategory3) REFERENCES COMMERCIAL_CATEGORY (typeid),
 INDEX(estate),
 FOREIGN KEY(estate) REFERENCES ESTATE (estateid),
 INDEX(floorplanimageid),
 FOREIGN KEY(floorplanimageid) REFERENCES IMAGE (imageid),
 INDEX(floorplanimageid2),
 FOREIGN KEY(floorplanimageid2) REFERENCES IMAGE (imageid),
 INDEX(holidaycategory),
 FOREIGN KEY(holidaycategory) REFERENCES HOLIDAY_CATEGORY (typeid),
 INDEX(mainimageid),
 FOREIGN KEY(mainimageid) REFERENCES IMAGE (imageid),
 INDEX(ruralcategory),
 FOREIGN KEY(ruralcategory) REFERENCES RURAL_CATEGORY (typeid),
 INDEX(suburbid),
 FOREIGN KEY(suburbid) REFERENCES SUBURB (suburbid),
 INDEX(status),
 FOREIGN KEY(status) REFERENCES PROPERTY_STATUS (statusid),
 INDEX(uniqueid)
) Engine=InnoDB;

create table PROPERTY_DOCUMENT (
 propertyid INT NOT NULL,
 documentid INT NOT NULL,
 INDEX(propertyid),
 FOREIGN KEY(propertyid) REFERENCES PROPERTY(propertyid),
 INDEX(documentid),
 FOREIGN KEY(documentid) REFERENCES DOCUMENT (documentid)
) Engine=InnoDB;

create table PROPERTY_SALE (
 saleid INT NOT NULL AUTO_INCREMENT,
 propertyid INT NOT NULL,
 solddate DATETIME,
 soldprice DOUBLE,
 soldpricedisplay TINYINT,
 PRIMARY KEY(saleid),
 INDEX(propertyid),
 FOREIGN KEY(propertyid) REFERENCES PROPERTY(propertyid)
) Engine=InnoDB;

create table PROPERTY_IMAGE (
 propertyid INT NOT NULL,
 imageid INT NOT NULL,
 INDEX(propertyid),
 FOREIGN KEY(propertyid) REFERENCES PROPERTY(propertyid),
 INDEX(imageid),
 FOREIGN KEY(imageid) REFERENCES IMAGE (imageid)
) Engine=InnoDB;

create table INSPECTION (
 inspectionid INT NOT NULL AUTO_INCREMENT,
 propertyid INT NOT NULL,
 start DATETIME,
 end DATETIME,
 appointment TINYINT,
 PRIMARY KEY(inspectionid),
 INDEX(propertyid),
 FOREIGN KEY(propertyid) REFERENCES PROPERTY(propertyid)
) Engine=InnoDB;

