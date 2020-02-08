USE AdventureWorks2012;
GO

--a)
CREATE VIEW Person.CountryRegion_SalesTerritory_View
WITH SCHEMABINDING
AS
SELECT 
Region.CountryRegionCode,	
Region.Name AS CountryRegionName,
Region.ModifiedDate AS CountryRegionModifiedDate,
Terr.TerritoryID,
Terr.Name AS SalesTerrName,
Terr.[Group],
Terr.SalesYTD,
Terr.SalesLastYear,
Terr.CostYTD,
Terr.CostLastYear,
Terr.rowguid,
Terr.ModifiedDate AS SalesTerrModifiedDate
FROM Person.CountryRegion AS Region
INNER JOIN Sales.SalesTerritory AS Terr
ON Region.CountryRegionCode = Terr.CountryRegionCode
GO

CREATE UNIQUE CLUSTERED INDEX Index_TerritoryID
ON Person.CountryRegion_SalesTerritory_View (TerritoryID)
GO

--b)
CREATE TRIGGER Person.TR_InsteadOf_CountryRegion_SalesTerritory_View
ON Person.CountryRegion_SalesTerritory_View
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
	IF EXISTS (SELECT * FROM INSERTED)
	BEGIN
		IF NOT EXISTS (
			SELECT * FROM INSERTED AS I 
			INNER JOIN Person.CountryRegion_SalesTerritory_View AS CS_View
			ON 
				I.TerritoryID = CS_View.TerritoryID)
		BEGIN	
			INSERT INTO Person.CountryRegion
				(CountryRegionCode,
				Name,
				ModifiedDate)
			SELECT 
				I.CountryRegionCode,
				I.CountryRegionName,
				I.CountryRegionModifiedDate
			FROM 
				INSERTED AS I	
						
			INSERT INTO Sales.SalesTerritory
				(Name,
				CountryRegionCode,
				[Group],
				SalesYTD,
				CostLastYear,
				CostYTD,
				SalesLastYear,
				rowguid,			
				ModifiedDate				
				)
			SELECT 
			    I.SalesTerrName,
				I.CountryRegionCode,
				I.[Group],
				I.SalesYTD,
				I.SalesLastYear,
				I.CostYTD,
				I.CostLastYear,
				I.rowguid,
			    I.SalesTerrModifiedDate				
			FROM 
				INSERTED AS I 
				INNER JOIN Person.CountryRegion AS Region 
			ON
				I.CountryRegionCode = Region.CountryRegionCode;			
		END
		ELSE
		BEGIN
			UPDATE Person.CountryRegion
			SET
				CountryRegionCode = INSERTED.CountryRegionCode,
				Name = INSERTED.CountryRegionName,
				ModifiedDate = INSERTED.CountryRegionModifiedDate
			FROM INSERTED
			WHERE INSERTED.CountryRegionCode = Person.CountryRegion.CountryRegionCode;

			UPDATE Sales.SalesTerritory
			SET
			    Name = INSERTED.SalesTerrName,
				CountryRegionCode = INSERTED.CountryRegionCode,
				[Group] = INSERTED.[Group],
				SalesYTD = INSERTED.SalesYTD,
				SalesLastYear = INSERTED.SalesLastYear,
				CostYTD = INSERTED.CostYTD,
				CostLastYear = INSERTED.CostLastYear,
				rowguid = INSERTED.rowguid,				
				ModifiedDate = INSERTED.SalesTerrModifiedDate				
			FROM INSERTED
			WHERE INSERTED.TerritoryID = Sales.SalesTerritory.TerritoryID;
		END
	END
	IF EXISTS (SELECT * FROM DELETED) 
	AND NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN
		DELETE Sales.SalesTerritory
		WHERE TerritoryID IN (SELECT TerritoryID FROM DELETED)
		
		DELETE Person.CountryRegion
		WHERE CountryRegionCode IN (SELECT CountryRegionCode FROM DELETED) 
		AND CountryRegionCode NOT IN (SELECT CountryRegionCode FROM Sales.SalesTerritory)
	END
END;
GO

--ñ)
INSERT INTO Person.CountryRegion_SalesTerritory_View (
CountryRegionCode,
CountryRegionName,
CountryRegionModifiedDate,
SalesTerrName,
[Group],
SalesYTD,
SalesLastYear,
CostYTD,
CostLastYear,
rowguid,
SalesTerrModifiedDate)
VALUES 
('ZZ',
'Zzzzzz',
GETDATE(),
'Zzzz',
'ZZZ',
1,
2,
3,
4,
NEWID(),
GETDATE());
GO

UPDATE Person.CountryRegion_SalesTerritory_View
SET
CountryRegionName = 'ZZZzzz',
[Group] ='zzz',
CostLastYear = 20
WHERE
CountryRegionCode = 'ZZ'
GO

DELETE Person.CountryRegion_SalesTerritory_View
WHERE 
CountryRegionCode = 'ZZ'
GO