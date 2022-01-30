DROP DATABASE IF EXISTS ClubHub;
CREATE DATABASE IF NOT EXISTS ClubHub;
USE ClubHub;

CREATE TABLE City (
CityID INT PRIMARY KEY AUTO_INCREMENT,
CityName VARCHAR(100) NOT NULL,
StateName VARCHAR(100) NOT NULL
);

CREATE TABLE Address (
AddressID INT PRIMARY KEY AUTO_INCREMENT,
LocationName VARCHAR(100),
Street VARCHAR(100) NOT NULL,
BuildingNo INT,
ZipCode VARCHAR(10) NOT NULL,
AddressCityID INT NOT NULL,
CONSTRAINT cityID_fk
FOREIGN KEY (AddressCityID)
REFERENCES City (CityID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Club (
ClubId INT PRIMARY KEY AUTO_INCREMENT,
ClubName VARCHAR(100) NOT NULL UNIQUE,
ClubDescription VARCHAR(500),
Website VARCHAR(100),
Email VARCHAR(100),
ClubAddressID INT,
NumMembers INT DEFAULT 0,
NumInterests INT DEFAULT 0,
CONSTRAINT addressID_fk
FOREIGN KEY (ClubAddressID)
REFERENCES Address (AddressID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Interest (
InterestName VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Announcement (
AnnouncementID INT PRIMARY KEY AUTO_INCREMENT,
AnnouncementText VARCHAR(100) NOT NULL,
AnnouncementTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
ClubAnnouncer INT NOT NULL,
CONSTRAINT clubAnnouncer_fk
FOREIGN KEY (ClubAnnouncer)
REFERENCES Club (ClubID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE AppUser (
UserID INT PRIMARY KEY AUTO_INCREMENT,
UserName VARCHAR(25) NOT NULL UNIQUE,
PasswordHash VARCHAR(100) NOT NULL UNIQUE,
NumInterests INT DEFAULT 0
);

CREATE TABLE ClubAdmin (
AdminID INT NOT NULL,
ClubAdministering INT NOT NULL,
PRIMARY KEY (AdminID, ClubAdministering),
CONSTRAINT adminId_fk
FOREIGN KEY (AdminID)
REFERENCES AppUser (UserID) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT clubadministering
FOREIGN KEY (ClubAdministering)
REFERENCES Club (ClubID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ClubEvent (
EventID INT PRIMARY KEY AUTO_INCREMENT,
EventName VARCHAR(100) NOT NULL,
EventDescription VARCHAR(500),
StartTime DATETIME NOT NULL,
EndTime DATETIME NOT NULL,
RegistrationRequired BOOLEAN NOT NULL DEFAULT FALSE,
Capacity INT DEFAULT NULL,
ClubHost INT NOT NULL,
CONSTRAINT club_fk
FOREIGN KEY (ClubHost)
REFERENCES Club (ClubID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ClubInterests (
InterestName VARCHAR(50) NOT NULL,
ClubIDInterest INT NOT NULL,
PRIMARY KEY(InterestName, ClubIDInterest),
CONSTRAINT interestName_fk
FOREIGN KEY (InterestName)
REFERENCES Interest (InterestName) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT ClubIDInterest_fk
FOREIGN KEY (ClubIDInterest)
REFERENCES Club (ClubID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE ClubMembers (
MemberID INT NOT NULL,
ClubIDMembers INT NOT NULL,
PRIMARY KEY(MemberID, ClubIDMembers),
CONSTRAINT MemberID_fk
FOREIGN KEY (MemberID)
REFERENCES AppUser (UserID) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT ClubIDMembers_fk
FOREIGN KEY (ClubIDMembers)
REFERENCES Club (ClubID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE UserInterests (
InterestNameUser VARCHAR(50) NOT NULL,
UserIDInterest INT NOT NULL,
PRIMARY KEY(InterestNameUser, UserIDInterest),
CONSTRAINT interestNameUser_fk
FOREIGN KEY (InterestNameUser)
REFERENCES Interest (InterestName) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT UserIDInterest_fk
FOREIGN KEY (UserIDInterest)
REFERENCES AppUser (UserID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE EventRegistrations (
EventID INT NOT NULL,
UserID INT NOT NULL,
PRIMARY KEY (EventID, UserID),
CONSTRAINT EventID_fk
FOREIGN KEY (EventID)
REFERENCES ClubEvent (EventID) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT UserID_fk
FOREIGN KEY (UserID)
REFERENCES AppUser (UserID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Triggers:

DROP TRIGGER IF EXISTS incrementNumMembers;
DELIMITER //
CREATE TRIGGER 
incrementNumMembers  
AFTER INSERT ON 
ClubMembers
FOR EACH ROW
BEGIN
    UPDATE Club
    SET NumMembers = NumMembers + 1 WHERE ClubId = NEW.ClubIdMembers;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS incrementNumClubInterests;
DELIMITER //
CREATE TRIGGER 
incrementNumClubInterests 
AFTER INSERT ON 
ClubInterests
FOR EACH ROW
BEGIN
    UPDATE Club
    SET NumInterests = NumInterests + 1 WHERE ClubId = NEW.ClubIDInterest;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS incrementNumMemberInterests;
DELIMITER //
CREATE TRIGGER 
incrementNumMemberInterests 
AFTER INSERT ON 
UserInterests
FOR EACH ROW
BEGIN
    UPDATE AppUser
    SET NumInterests = NumInterests + 1 WHERE UserId = NEW.UserIDInterest;
END//
DELIMITER ;

INSERT INTO City (CityName, StateName) VALUES ('Boston', 'Massachusetts');
INSERT INTO City (CityName, StateName) VALUES ('Portland', 'Maine');
INSERT INTO City (CityName, StateName) VALUES ('Charlotte', 'North Carolina');
INSERT INTO City (CityName, StateName) VALUES ('Seattle', 'Washington');
INSERT INTO City (CityName, StateName) VALUES ('San Francisco', 'California');

INSERT INTO Address (Street, LocationName, ZipCode, AddressCityID) VALUES ('440 Huntington Avenue', 'West Village H', '02115', 1);
INSERT INTO Address (Street, LocationName, ZipCode, AddressCityID) VALUES ('346 Huntington Avenue', 'Ell Hall', '02115', 1);
INSERT INTO Address (Street, ZipCode, AddressCityID) VALUES ('100 Fore Street', '04101', 2);
INSERT INTO Address (Street, LocationName, ZipCode, AddressCityID) VALUES ('1155 Tremont St', 'International Village', 02120, 3);
INSERT INTO Address (Street, LocationName, ZipCode, AddressCityID) VALUES ('360 Huntington Avenue', 'Richards Hall', 02115, 4);
INSERT INTO Address (Street, LocationName, ZipCode, AddressCityID) VALUES ('795 Columbus Avenue', 'SquashBusters', 02120, 5);


INSERT INTO Club (ClubName, ClubDescription, Website, Email, ClubAddressId) VALUES ('Database Club', 'A fun club where you spend all day writing SQL queries', 'https://www.mysql.com/', 'sql@northeastern.edu', 1);
INSERT INTO Club (ClubName, ClubDescription, Website, Email, ClubAddressId) VALUES ('AI Club', 'Come here to learn how to classify cats from dogs with 47% accuracy', 'https://www.tensorflow.org/', 'ai@northeastern.edu', 1);
INSERT INTO Club (ClubName, ClubDescription, Website, Email, ClubAddressId) VALUES ('Meditation Club', 'Join us in Ell Hall to learn how to sit still without looking at your phone every 2 seconds', 'https://www.northeastern.edu/spirituallife/', 'zen@northeastern.edu', 2);
INSERT INTO Club (ClubName, ClubDescription, Website, Email, ClubAddressId) VALUES ('Fishing Club', 'Meet at the listed address every Friday at 7 to before we go out to try and fail to catch fish in the beautiful Portland harbor', 'https://www.mysql.com/', 'mrfish@northeastern.edu', 3);
INSERT INTO Club (ClubName, ClubDescription, Website, Email, ClubAddressId) VALUES ('NFL Club', 'Join us in ell hall to weatch NFL games every Sunday! ', 'https://www.nunflclub.com/', 'ilovefootball@northeastern.edu', 1);
INSERT INTO Club (ClubName, ClubDescription, Website, Email, ClubAddressId) VALUES ('Cooking Club', 'All cooking experience levels welcome!', 'https://www.nucooks.com/', 'nuchef123@northeastern.edu', 3);
INSERT INTO Club (ClubName, ClubDescription, Website, Email, ClubAddressId) VALUES ('Painting club', 'Join us in Richards Hall to do some painting!', 'https://www.nupaintingclub.com/', 'mrpainter@northeastern.edu', 4);


INSERT INTO Interest VALUES ('Technology');
INSERT INTO Interest VALUES ('Wellness');
INSERT INTO Interest VALUES ('Outdoors');
INSERT INTO Interest VALUES ('Sports');
INSERT INTO Interest VALUES ('Cooking');
INSERT INTO Interest VALUES ('Art');
INSERT INTO Interest VALUES ('Video Games');


INSERT INTO Announcement (AnnouncementText, ClubAnnouncer) VALUES ('Today we will be making queries on a table of soccer games', 1);
INSERT INTO Announcement (AnnouncementText, ClubAnnouncer) VALUES ('Today we will be making queries on a table of Lord of the Rings data', 1);
INSERT INTO Announcement (AnnouncementText, ClubAnnouncer) VALUES ('Please have Tensorflow installed before the next meeting if you plan to come', 2);
INSERT INTO Announcement (AnnouncementText, ClubAnnouncer) VALUES ('We ask that everyone turn their phone on silent during the next session if you plan on joining', 3);
INSERT INTO Announcement (AnnouncementText, ClubAnnouncer) VALUES ('Bring lots of food!!', 5);
INSERT INTO Announcement (AnnouncementText, ClubAnnouncer) VALUES ('Bring a partner so we can do some pair cooking', 6);
INSERT INTO Announcement (AnnouncementText, ClubAnnouncer) VALUES ('Feel free to bring your own wine!', 7);


INSERT INTO AppUser (UserName, PasswordHash) VALUES ('test_username', '$2b$10$OB2UdXWHmCVvEcJHCqiWPuIkrxmnZIEt5/Lf.wcXautw4MgQnEt7G');
INSERT INTO AppUser (UserName, PasswordHash) VALUES ('test_username_2', '$2b$10$DNb9oFD63693fQGwPQermetKRE59Xc8IjDmkKgbc9oCtiuFg5seMy');
INSERT INTO AppUser (UserName, PasswordHash) VALUES ('test_username_3', '$2b$10$TKMckXE2sHnuRm7OMdnSmuhzegTf.QR5X1SK2oJPvmkaWEIwrzW7u');

INSERT INTO ClubAdmin VALUES (1, 1);
INSERT INTO ClubAdmin VALUES (1, 2);
INSERT INTO ClubAdmin VALUES (2, 3);
INSERT INTO ClubAdmin VALUES (3, 4);
INSERT INTO ClubAdmin VALUES (3, 5);
INSERT INTO ClubAdmin VALUES (3, 6);
INSERT INTO ClubAdmin VALUES (3, 7);


INSERT INTO ClubEvent (EventName, EventDescription, StartTime, EndTime, ClubHost) VALUES ('Introduction to MySQL', 'A starter event for new members to get acquainted with the workings of MySQL', '2021-12-01 20:00:00', '2021-12-01 22:00:00', 1);
INSERT INTO ClubEvent (EventName, EventDescription, StartTime, EndTime, RegistrationRequired, Capacity, ClubHost) VALUES ('Careers in ML with Andrew Ng', 'Industry leader Andrew Ng comes for an exclusive event to share career advice in the field of AI', '2021-12-01 20:00:00', '2021-12-01 21:00:00', true, 2, 2);
INSERT INTO ClubEvent (EventName, EventDescription, StartTime, EndTime, RegistrationRequired, Capacity, ClubHost) VALUES ('Introduction To TensorFlow', 'Master TensorFlow in 1 hour', '2021-12-02 20:00:00', '2021-12-02 21:00:00', true, 100, 2);
INSERT INTO ClubEvent (EventName, EventDescription, StartTime, EndTime, ClubHost) VALUES ('Weekly Meditation Session', 'Our clubs weekly meditation session', '2021-12-02 20:00:00', '2021-12-01 21:00:00', 3);
INSERT INTO ClubEvent (EventName, EventDescription, StartTime, EndTime, ClubHost) VALUES ('Fishing with Friends', 'Come join us to meet new people and have fun fishing!', '2021-12-03 19:00:00', '2021-12-03 21:00:00', 4);
INSERT INTO ClubEvent (EventName, EventDescription, StartTime, EndTime, ClubHost) VALUES ('NFL Sunday watch party', 'Come meet with us on Sunday to watch games and talk football!', '2021-12-05 13:00:00', '2021-12-05 23:00:00', 5);
INSERT INTO ClubEvent (EventName, EventDescription, StartTime, EndTime, ClubHost) VALUES ('Cooking with friends', 'Bring a friend and learn how to cook different dishes!', '2021-12-05 18:00:00', '2021-12-05 19:30:00', 6);
INSERT INTO ClubEvent (EventName, EventDescription, StartTime, EndTime, ClubHost) VALUES ('Paint n sip', 'Come join us for a fun night of painting and wine tasting!', '2021-12-04 20:00:00', '2021-12-03 23:00:00', 7);


INSERT INTO ClubInterests VALUES ('Technology', 1);
INSERT INTO ClubInterests VALUES ('Technology', 2);
INSERT INTO ClubInterests VALUES ('Wellness', 3);
INSERT INTO ClubInterests VALUES ('Outdoors', 4);
INSERT INTO ClubInterests VALUES ('Sports', 5); 
INSERT INTO ClubInterests VALUES ('Cooking', 6);
INSERT INTO ClubInterests VALUES ('Art', 7);


INSERT INTO ClubMembers VALUES (1, 1);
INSERT INTO ClubMembers VALUES (1, 2);
INSERT INTO ClubMembers VALUES (2, 3);
INSERT INTO ClubMembers VALUES (3, 4);
INSERT INTO ClubMembers VALUES (3, 5);
INSERT INTO ClubMembers VALUES (3, 6);
INSERT INTO ClubMembers VALUES (3, 7);


INSERT INTO UserInterests VALUES ('Technology', 1);
INSERT INTO UserInterests VALUES ('Wellness', 2);
INSERT INTO UserInterests VALUES ('Outdoors', 3);
INSERT INTO UserInterests VALUES ('Sports', 3); 
INSERT INTO UserInterests VALUES ('Cooking', 3); 
INSERT INTO UserInterests VALUES ('Art', 3); 
INSERT INTO UserInterests VALUES ('Video Games', 3); 


INSERT INTO EventRegistrations VALUES (2, 1);