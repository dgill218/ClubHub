-- adminRouter.js procedures
-- get list of clubs this user administers
DROP PROCEDURE IF EXISTS clubsAdministering;
DELIMITER //
CREATE PROCEDURE clubsAdministering(userIdParam INT)
BEGIN
	SELECT c.ClubId, c.ClubName FROM ClubAdmin ad INNER JOIN Club c ON ad.ClubAdministering = c.ClubId WHERE ad.AdminID = userIdParam;
END //
DELIMITER ;

-- get all information about a club this user administers
-- getting club information accessed by admin
DROP PROCEDURE IF EXISTS adminClubInfo;
DELIMITER //
CREATE PROCEDURE adminClubInfo(userIdParam INT, clubIdParam INT)
BEGIN
	SELECT c.*, a.*, ci.* FROM ClubAdmin ad 
    INNER JOIN Club c ON ad.ClubAdministering = c.ClubId INNER JOIN Address a ON c.ClubAddressID = a.AddressID INNER JOIN City ci ON a.AddressCityID = ci.CityID 
    WHERE ad.AdminID = userIdParam AND ad.ClubAdministering = clubIdParam;
END //
DELIMITER ;

-- get announcements of the club
DROP PROCEDURE IF EXISTS adminClubAnnouncements;
DELIMITER //
CREATE PROCEDURE adminClubAnnouncements(clubIdParam INT)
BEGIN
	SELECT AnnouncementID, AnnouncementText FROM Announcement WHERE ClubAnnouncer = clubIdParam;
END //
DELIMITER ;

-- get events of the club
DROP PROCEDURE IF EXISTS adminClubEvents;
DELIMITER //
CREATE PROCEDURE adminClubEvents(clubIdParam INT)
BEGIN
	SELECT EventID, EventName FROM ClubEvent WHERE ClubHost = clubIdParam;
END //
DELIMITER ;

-- get interests of the club
DROP PROCEDURE IF EXISTS adminClubInterests;
DELIMITER //
CREATE PROCEDURE adminClubInterests(clubIdParam INT)
BEGIN
	SELECT InterestName FROM ClubInterests WHERE ClubIDInterest = clubIdParam;
END //
DELIMITER ;

-- get members of the club
DROP PROCEDURE IF EXISTS adminClubMembers;
DELIMITER //
CREATE PROCEDURE adminClubMembers(clubIdParam INT)
BEGIN
	SELECT u.UserName FROM ClubMembers m INNER JOIN AppUser u ON m.MemberID = u.UserID WHERE m.ClubIDMembers = clubIdParam;
END //
DELIMITER ;

-- get all info about this event this user administers
-- get all adminevent info
DROP PROCEDURE IF EXISTS adminEventInfo;
DELIMITER //
CREATE PROCEDURE adminEventInfo(userIdParam INT, eventIdParam INT)
BEGIN
	SELECT e.*, c.* FROM ClubAdmin ad 
    INNER JOIN Club c ON ad.ClubAdministering = c.ClubId INNER JOIN ClubEvent e ON e.ClubHost = c.ClubId WHERE ad.AdminID = userIdParam AND e.EventID = eventIdParam;
END //
DELIMITER ;

-- get all registered attendents of this event
DROP PROCEDURE IF EXISTS eventRegistered;
DELIMITER //
CREATE PROCEDURE eventRegistered(eventIdParam INT)
BEGIN
	SELECT u.Username FROM EventRegistrations r INNER JOIN AppUser u ON r.UserID = u.UserID WHERE r.EventID = eventIdParam;
END //
DELIMITER ;
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- clubRouter.js procedures
-- Search club
DROP PROCEDURE IF EXISTS searchClub;
DELIMITER //
CREATE PROCEDURE searchClub(searchArg VARCHAR(100))
BEGIN
	SELECT ClubId, ClubName FROM Club WHERE ClubName LIKE searchArg ORDER BY ClubId;
END //
DELIMITER ;

-- Create club
DROP PROCEDURE IF EXISTS createClub;
DELIMITER //
CREATE PROCEDURE createClub(cityNameParam VARCHAR(100), stateNameParam VARCHAR(100), locationNameParam VARCHAR(100), streetNameParam VARCHAR(100), buildingNoParam INT, zipCodeParam VARCHAR(10), 
clubNameParam VARCHAR(100), clubDescriptionParam VARCHAR(500), websiteParam VARCHAR(100), emailParam VARCHAR(100), userIdParam INT)
cc: BEGIN
  DECLARE cityIdParam INT;
  DECLARE addressIdParam INT;
  DECLARE clubIdParam INT;

  IF EXISTS(SELECT CityID FROM City WHERE CityName = cityNameParam AND StateName = stateNameParam) THEN
    SELECT CityID FROM City WHERE CityName = cityNameParam AND StateName = stateNameParam INTO cityIdParam;
  ELSE
    INSERT INTO City (CityName, StateName) VALUES (cityNameParam, stateNameParam);
	SELECT LAST_INSERT_ID() INTO cityIdParam;
  END IF;

  IF EXISTS(SELECT AddressID FROM Address WHERE LocationName = locationNameParam AND Street = streetNameParam AND ZipCode = zipCodeParam) THEN
    SELECT AddressID FROM Address WHERE LocationName = locationNameParam AND Street = streetNameParam AND ZipCode = zipCodeParam INTO addressIdParam;
  ELSE 
    INSERT INTO Address (LocationName, Street, BuildingNo, ZipCode, AddressCityID) VALUES (locationNameParam, streetNameParam, buildingNoParam, zipCodeParam, cityIdParam);
	SELECT LAST_INSERT_ID() INTO addressIdParam;
  END IF;

  IF EXISTS(SELECT ClubId FROM Club WHERE ClubName = clubNameParam) THEN
    SELECT true AS error, 'club with that name already as exists' AS message;
	LEAVE cc;
  ELSE
    INSERT INTO Club (ClubName, ClubDescription, Website, Email, ClubAddressID) VALUES (clubNameParam, clubDescriptionParam, websiteParam, emailParam, addressIdParam);
	SELECT LAST_INSERT_ID() INTO clubIdParam;
  END IF;

  INSERT INTO ClubAdmin VALUES (userIdParam, clubIdParam);
  INSERT INTO ClubMembers VALUES (userIdParam, clubIdParam);
  SELECT false AS error, 'club created successfully' AS message;
END //
DELIMITER ;

-- Delete club
DROP PROCEDURE IF EXISTS deleteClub;
DELIMITER //
CREATE PROCEDURE deleteClub(clubIdParam INT)
BEGIN
	DELETE FROM Club WHERE ClubId = clubIdParam;
	SELECT false AS error, 'club deleted successfully' AS message;
END //
DELIMITER ;

-- Search club
DROP PROCEDURE IF EXISTS modifyClub;
DELIMITER //
CREATE PROCEDURE modifyClub(clubNameParam VARCHAR(100), clubDescriptionParam VARCHAR(500), websiteParam VARCHAR(100), emailParam VARCHAR(100), clubIdParam INT)
BEGIN
  IF NOT EXISTS (SELECT ClubId FROM Club WHERE clubName = clubNameParam AND ClubId != clubIdParam) THEN
    UPDATE Club SET ClubName = clubNameParam, Website = websiteParam, ClubDescription = clubDescriptionParam, Email = emailParam WHERE ClubId = clubIdParam;
    SELECT false AS error, 'club updated successfully' AS message;
  ELSE
    SELECT true AS error, 'club could not be updated: name already taken' AS message;
  END IF;
END //
DELIMITER ;

-- Add interest for club
DROP PROCEDURE IF EXISTS addClubInterest;
DELIMITER //
CREATE PROCEDURE addClubInterest(interestNameParam VARCHAR(100), clubIdParam INT)
BEGIN
    IF NOT EXISTS (SELECT InterestName FROM Interest WHERE InterestName = interestNameParam) THEN
	  INSERT INTO Interest VALUES (interestNameParam);
	END IF;
	INSERT INTO ClubInterests VALUES (interestNameParam, clubIdParam);
	SELECT false AS error, 'interest added successfully!' AS message;
END //
DELIMITER ;

-- Delete interest for club
DROP PROCEDURE IF EXISTS deleteClubInterest;
DELIMITER //
CREATE PROCEDURE deleteClubInterest(interestNameParam VARCHAR(100), clubIdParam INT)
BEGIN
	DELETE FROM ClubInterests WHERE InterestName = interestNameParam AND ClubIdInterest = clubIdParam;
	SELECT false AS error, 'interest removed successfully!' AS message;
END //
DELIMITER ;

-- Get all relevant info for a club
DROP PROCEDURE IF EXISTS getAllClubInfo;
DELIMITER //
CREATE PROCEDURE getAllClubInfo(userIdParam INT, clubIdParam INT)
BEGIN
	SELECT c.*, a.*, ci.*, 
    EXISTS(SELECT m.MemberID FROM ClubMembers m WHERE m.ClubIDMembers = c.ClubId AND m.MemberID = userIdParam) IsFollowing, 
    EXISTS(SELECT ad.AdminID FROM ClubAdmin ad WHERE ad.AdminID = userIdParam AND ad.ClubAdministering = c.ClubId) IsAdmin 
    FROM Club c INNER JOIN Address a ON c.ClubAddressID = a.AddressID INNER JOIN City ci ON a.AddressCityID = ci.CityID WHERE c.ClubId = clubIdParam;
END //
DELIMITER ;

-- Get all events for a club
DROP PROCEDURE IF EXISTS getEventsForClub;
DELIMITER //
CREATE PROCEDURE getEventsForClub(clubIdParam INT)
BEGIN
	SELECT e.EventId, e.EventName, e.RegistrationRequired FROM ClubEvent e WHERE e.ClubHost = clubIdParam;
END //
DELIMITER ;

-- Add given user as follower to club
DROP PROCEDURE IF EXISTS followClub;
DELIMITER //
CREATE PROCEDURE followClub(userIdParam INT, clubIdParam INT)
BEGIN
	INSERT INTO ClubMembers VALUES (userIdParam, clubIdParam);
	SELECT false AS error, 'club followed successfully!' AS message;
END //
DELIMITER ;

-- Remove given user as follower to club
DROP PROCEDURE IF EXISTS unfollowClub;
DELIMITER //
CREATE PROCEDURE unfollowClub(userIdParam INT, clubIdParam INT)
BEGIN
	DELETE FROM ClubMembers WHERE MemberID = userIdParam AND ClubIDMembers = clubIdParam;
	SELECT false AS error, 'club unfollowed successfully!' AS message;
END //
DELIMITER ;

-- Create announcement for a club
DROP PROCEDURE IF EXISTS addAnnouncement;
DELIMITER //
CREATE PROCEDURE addAnnouncement(announcementTextParam VARCHAR(100), clubIdParam INT)
BEGIN
	INSERT INTO Announcement (AnnouncementText, ClubAnnouncer) VALUES (announcementTextParam, clubIdParam);
	SELECT false AS error, 'announcement added successfully!' AS message;
END //
DELIMITER ;

-- Modify announcement for a club
DROP PROCEDURE IF EXISTS editAnnouncement;
DELIMITER //
CREATE PROCEDURE editAnnouncement(announcementTextParam VARCHAR(100), announcementIdParam INT)
BEGIN
	UPDATE Announcement SET AnnouncementText = announcementTextParam WHERE AnnouncementID = announcementIdParam;
	SELECT false AS error, 'announcement edited successfully!' AS message;
END //
DELIMITER ;

-- Delete announcement for a club
DROP PROCEDURE IF EXISTS deleteAnnouncement;
DELIMITER //
CREATE PROCEDURE deleteAnnouncement(announcementIdParam INT)
BEGIN
	DELETE FROM Announcement WHERE AnnouncementID = announcementIdParam;
	SELECT false AS error, 'announcement deleted successfully!' AS message;
END //
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- eventRouter.js procedures
-- create a new event
DROP PROCEDURE IF EXISTS createEvent;
DELIMITER //
CREATE PROCEDURE createEvent(eventNameParam VARCHAR(100), eventDescriptionParam VARCHAR(500), StartTimeParam DATETIME, EndTimeParam DATETIME, RegistrationRequiredParam BOOLEAN, CapacityParam INT, ClubHostParam INT)
BEGIN
	INSERT INTO ClubEvent (EventName, EventDescription, StartTime, EndTime, RegistrationRequired, Capacity, ClubHost) VALUES (eventNameParam, eventDescriptionParam, StartTimeParam, EndTimeParam, RegistrationRequiredParam, CapacityParam, ClubHostParam);
	SELECT false AS error, 'event created successfully' AS message;
END //
DELIMITER ;

-- get all info about an event
DROP PROCEDURE IF EXISTS getEventInfo;
DELIMITER //
CREATE PROCEDURE getEventInfo(userIdParam INT, eventIdParam INT)
BEGIN
	SELECT e.*, c.ClubName, EXISTS(SELECT r.UserID FROM EventRegistrations r WHERE r.EventID = e.EventID AND r.UserID = userIdParam) IsRegistered 
    FROM ClubEvent e INNER JOIN Club c ON e.ClubHost = c.ClubId WHERE e.EventID = eventIdParam;
END //
DELIMITER ;
SELECT * FROM appuser;

-- set event data
DROP PROCEDURE IF EXISTS setEventInfo;
DELIMITER //
CREATE PROCEDURE setEventInfo(eventNameParam VARCHAR(100), eventDescriptionParam VARCHAR(100), regReqParam BOOLEAN, capacityParam INT, eventIdParam INT)
BEGIN
	UPDATE ClubEvent SET EventName = eventNameParam, EventDescription = eventDescriptionParam, RegistrationRequired = regReqParam, Capacity = capacityParam WHERE EventId = eventIdParam;
	SELECT false AS error, 'event modified successfully' AS message;
END //
DELIMITER ;

-- delete an event
DROP PROCEDURE IF EXISTS deleteEvent;
DELIMITER //
CREATE PROCEDURE deleteEvent(eventIdParam INT)
BEGIN
	DELETE FROM ClubEvent WHERE EventID = eventIdParam;
	SELECT false AS error, 'event deleted successfully' AS message;
END //
DELIMITER ;

-- attempt to register to an event
DROP PROCEDURE IF EXISTS registerToEvent;
DELIMITER //
CREATE PROCEDURE registerToEvent(eventIdParam INT, userIdParam INT)
BEGIN
-- possibly add capacity limit
    IF (SELECT COUNT(UserID) FROM EventRegistrations WHERE EventID = eventIdParam) < (SELECT Capacity FROM ClubEvent WHERE EventID = eventIdParam) THEN
	   INSERT INTO EventRegistrations VALUES (eventIdParam, userIdParam);
	   SELECT false AS error, 'user registered successfully' AS message;
	ELSE 
	   SELECT true AS error, 'user could not be registered: event full' AS message;
	END IF;
END //
DELIMITER ;

-- attempt to unregister from an event
DROP PROCEDURE IF EXISTS unregisterFromEvent;
DELIMITER //
CREATE PROCEDURE unregisterFromEvent(eventIdParam INT, userIdParam INT)
BEGIN
	DELETE FROM EventRegistrations WHERE EventId = eventIdParam AND UserId = userIdParam;
	SELECT false AS error, 'user unregistered successfully' AS message;
END //
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------------
-- loginRouter.js prcedures
-- Select login info via username
DROP PROCEDURE IF EXISTS getLoginInfo;
DELIMITER //
CREATE PROCEDURE getLoginInfo(usernameParam VARCHAR(25))
BEGIN
	SELECT * FROM AppUser WHERE UserName = usernameParam;
END //
DELIMITER ;

-- -----------------------------------------------------------------------------------------------------------
-- userRouter.js procedures
-- creating a user
DROP PROCEDURE IF EXISTS createUser;
DELIMITER //
CREATE PROCEDURE createUser(usernameParam VARCHAR(25), passwordHashParam VARCHAR(100))
BEGIN
	IF NOT EXISTS (SELECT UserName FROM AppUser WHERE UserName = usernameParam) THEN 
		INSERT INTO AppUser (UserName, PasswordHash) VALUES (usernameParam, passwordHashParam);
        SELECT false AS error, 'successfully created user' AS message;
	ELSE 
		SELECT true as error, 'username already exists' AS message;
	END IF;
END //
DELIMITER ;

-- gets basic info about user (login info, interests)
-- gets username
DROP PROCEDURE IF EXISTS getUsername;
DELIMITER //
CREATE PROCEDURE getUsername(userIdParam INT)
BEGIN
	SELECT UserName FROM AppUser WHERE UserID = userIdParam;
END //
DELIMITER ;
-- gets interests
DROP PROCEDURE IF EXISTS getInterest;
DELIMITER //
CREATE PROCEDURE getInterest(userIdParam INT)
BEGIN
	SELECT InterestNameUser interest FROM UserInterests WHERE UserIDInterest = userIdParam;
END //
DELIMITER ;

-- updates a user's username
DROP PROCEDURE IF EXISTS updateUsername;
DELIMITER //
CREATE PROCEDURE updateUsername(newUsernameParam VARCHAR(25), userIdParam INT)
BEGIN
    IF NOT EXISTS (SELECT UserName FROM AppUser WHERE UserName = newUsernameParam AND UserID != userIdParam) THEN 
	  UPDATE AppUser SET UserName = newUsernameParam WHERE UserID = userIdParam;
	  SELECT false AS error, 'username updated successfully' AS message;
	ELSE
	  SELECT true as error, 'username already exists' AS message;
	END IF;
END //
DELIMITER ;

-- deletes a user from a database
DROP PROCEDURE IF EXISTS deleteUser;
DELIMITER //
CREATE PROCEDURE deleteUser(userIdParam INT)
BEGIN
	DELETE FROM AppUser WHERE UserId = userIdParam;
	SELECT false AS error, 'user deleted successfully' AS message;
END //
DELIMITER ;

-- modifies user interests
-- add user interests
DROP PROCEDURE IF EXISTS addUserInterests;
DELIMITER //
CREATE PROCEDURE addUserInterests(interestNameParam VARCHAR(50), userIdParam INT)
BEGIN
    IF NOT EXISTS (SELECT InterestName FROM Interest WHERE InterestName = interestNameParam) THEN
	  INSERT INTO Interest VALUES (interestNameParam);
	END IF;
	INSERT INTO UserInterests VALUES (interestNameParam, userIdParam);
	SELECT false AS error, 'interest added successfully' AS message;
END //
DELIMITER ;

-- delete user interests
DROP PROCEDURE IF EXISTS deleteUserInterests;
DELIMITER //
CREATE PROCEDURE deleteUserInterests(interestNameParam VARCHAR(50), userIdParam INT)
BEGIN
	DELETE FROM UserInterests WHERE InterestNameUser = interestNameParam AND UserIdInterest = userIdParam;
	SELECT false AS error, 'interest removed successfully' AS message;
END //
DELIMITER ;

-- gets announcements sent to a user
DROP PROCEDURE IF EXISTS userAnnouncements;
DELIMITER //
CREATE PROCEDURE userAnnouncements(userIdParam INT)
BEGIN
	SELECT a.*, c.* FROM Announcement a INNER JOIN Club c ON a.ClubAnnouncer = c.ClubId 
    WHERE c.ClubId IN (SELECT ClubIDMembers FROM ClubMembers WHERE MemberID = userIdParam) ORDER BY a.AnnouncementTime DESC;
END //
DELIMITER ;

-- gets the list of clubs that a user follows
DROP PROCEDURE IF EXISTS userClubsFollowing;
DELIMITER //
CREATE PROCEDURE userClubsFollowing(userIdParam INT)
BEGIN
	WITH club_ids AS (SELECT ClubIDMembers ClubId FROM ClubMembers WHERE MemberId = userIdParam)
    SELECT c.*, EXISTS(SELECT ad.AdminID FROM ClubAdmin ad WHERE ad.AdminID = userIdParam AND ad.ClubAdministering = c.ClubId) IsAdmin 
    FROM club_ids INNER JOIN Club c ON club_ids.ClubId = c.ClubId;
END //
DELIMITER ;

-- gets the list of upcoming events for a user
DROP PROCEDURE IF EXISTS userUpcomingEvents;
DELIMITER //
CREATE PROCEDURE userUpcomingEvents(userIdParam INT)
BEGIN
	WITH club_ids AS (SELECT ClubIDMembers ClubId FROM ClubMembers WHERE MemberId = userIdParam)
    SELECT e.*, c.*, EXISTS(SELECT UserID FROM EventRegistrations WHERE EventID = e.EventID AND UserID = userIdParam) IsRegistered FROM club_ids 
    INNER JOIN Club c ON club_ids.ClubId = c.ClubId INNER JOIN ClubEvent e ON c.ClubId = e.ClubHost ORDER BY e.StartTime ASC;
END //
DELIMITER ;