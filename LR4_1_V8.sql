USE AdventureWorks2012;
GO

--a)
CREATE TABLE Person.CountryRegionHst (
ID INT IDENTITY(1, 1) PRIMARY KEY,
Action NVARCHAR(6) CHECK(Action IN ('INSERT', 'UPDATE', 'DELETE')),
ModifiedDate DATETIME NOT NULL,
SourceID NVARCHAR(3) NOT NULL,
UserName NVARCHAR(200)
);
GO

--b)
CREATE TRIGGER Person.TR_CountryRegion_AfterInsert 
ON Person.CountryRegion
AFTER INSERT  
AS 
INSERT INTO Person.CountryRegionHst (
Action, 
ModifiedDate, 
SourceID, 
UserName
)  
SELECT 
'INSERT', 
GETDATE(), 
inser.CountryRegionCode, 
CURRENT_USER 
FROM inserted AS inser;
GO

CREATE TRIGGER Person.TR_CountryRegion_AfterUpdate 
ON Person.CountryRegion
AFTER UPDATE  
AS 
INSERT INTO Person.CountryRegionHst (
Action, 
ModifiedDate, 
SourceID, 
UserName
) 
SELECT 
'UPDATE', 
GETDATE(), 
inser.CountryRegionCode, 
CURRENT_USER 
FROM inserted AS inser;
GO

CREATE TRIGGER Person.TR_CountryRegion_AfterDelete 
ON Person.CountryRegion
AFTER DELETE  
AS 
INSERT INTO Person.CountryRegionHst (
Action, 
ModifiedDate, 
SourceID, 
UserName
)
SELECT 
'DELETE', 
GETDATE(), 
del.CountryRegionCode, 
CURRENT_USER 
FROM deleted AS del;
GO

--c)
CREATE VIEW Person.CountryRegion_View
WITH ENCRYPTION
AS
SELECT * FROM Person.CountryRegion;
GO

--d)
INSERT INTO Person.CountryRegion_View (
CountryRegionCode, 
Name, 
ModifiedDate
) 
VALUES 
(
'AA', 
'Aaaaa', 
GETDATE()
)
GO

SELECT * FROM Person.CountryRegionHst;

UPDATE [Person].[CountryRegion_View]
SET
ModifiedDate = GETDATE(), Name = 'AAAAA'
WHERE CountryRegionCode = 'AA';
GO

SELECT * FROM Person.CountryRegionHst;

DELETE FROM Person.CountryRegion_View
WHERE [CountryRegionCode] = 'AA';
GO

SELECT * FROM Person.CountryRegionHst;