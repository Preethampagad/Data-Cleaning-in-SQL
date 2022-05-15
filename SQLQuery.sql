SELECT *
FROM sqlprojects.dbo.nashvillehousing

--separating data and time
SELECT CAST(SaleDate AS date) 
FROM sqlprojects.dbo.nashvillehousing

ALTER TABLE nashvillehousing
ADD sale_date_converted Date;

UPDATE nashvillehousing
SET sale_date_converted = CAST(SaleDate AS date)


--Populating property address data 
SELECT x.ParcelID, x.PropertyAddress,y.ParcelID,y.PropertyAddress,ISNULL(x.PropertyAddress,y.PropertyAddress)
FROM sqlprojects.dbo.nashvillehousing AS x
JOIN  sqlprojects.dbo.nashvillehousing AS y
ON x.ParcelID=y.ParcelID AND x.[UniqueID ]!=y.[UniqueID ]
WHERE x.PropertyAddress is null

UPDATE x
SET PropertyAddress= ISNULL(x.PropertyAddress,y.PropertyAddress)
FROM sqlprojects.dbo.nashvillehousing AS x
JOIN  sqlprojects.dbo.nashvillehousing AS y
ON x.ParcelID=y.ParcelID AND x.[UniqueID ]!=y.[UniqueID ]
WHERE x.PropertyAddress is null

--separating PropertyAddress into Address,city
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) )as address
FROM sqlprojects.dbo.nashvillehousing 

ALTER TABLE nashvillehousing 
ADD PropertySplitAddress nvarchar(300);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE nashvillehousing
ADD PropertySplitCity nvarchar(300);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) )

--Checking whether the new column formed and values are entered
SELECT *
FROM sqlprojects.dbo.nashvillehousing

--separating OwnerAddress into Address,city and state using PARSENAME METHOD
--PARSENAME METHOD access the column in periods so replaced , by . and PARSENAME METHOD access from backward 

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),   
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM sqlprojects.dbo.nashvillehousing

ALTER TABLE sqlprojects.dbo.nashvillehousing 
ADD OwnerSplitAddress nvarchar(300);

UPDATE sqlprojects.dbo.nashvillehousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE sqlprojects.dbo.nashvillehousing 
ADD OwnerSplitCity nvarchar(300);

UPDATE sqlprojects.dbo.nashvillehousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE sqlprojects.dbo.nashvillehousing 
ADD OwnerSplitState nvarchar(300);

UPDATE sqlprojects.dbo.nashvillehousing 
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress,',','.'),1

--Checking whether the new column formed and values are entered
SELECT *
FROM sqlprojects.dbo.nashvillehousing

--Changing Y and N to yes and no in SoldAsVacant Column

--Checking for number of Y, N, Yes, No
SELECT DISTINCT SoldAsVacant,COUNT(SoldAsVacant)
FROM sqlprojects.dbo.nashvillehousing
GROUP BY SoldAsVacant

----Changing Y and N to yes and no in SoldAsVacant Column using CASE 

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM sqlprojects.dbo.nashvillehousing

--Updating the SoldAsVacant column (we are not adding a separate column so we dont use ALTER TABLE

UPDATE sqlprojects.dbo.nashvillehousing 
SET SoldAsVacant=
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Removing Duplicates in Common table expression table(CTE) using ROW_NUM

WITH RowNumCTE AS (        
SELECT *,
        ROW_NUMBER()OVER(
        PARTITION BY ParcelID,
			         PropertyAddress,
				     SalePrice,
				     SaleDate,
					 LegalReference
				     ORDER BY UniqueID) AS row_num
FROM sqlprojects.dbo.nashvillehousing 
)
DELETE
FROM RowNumCTE 
WHERE row_num>1  --checking whether there are any repeated rows if the row_num is greater than1 then that particular column is repeated and deleting it

--Now check for duplicates by replacing  DELETE by SELECT* and run the query by selecting the CTE table

SELECT *
FROM sqlprojects.dbo.nashvillehousing

---Removing unused column

ALTER TABLE sqlprojects.dbo.nashvillehousing
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict

SELECT	*
FROM sqlprojects.dbo.nashvillehousing

--Populating OwnerName 
--If Owner name is missing then it is populated by 'No Owner Name'
SELECT a.PropertySplitAddress,a.OwnerName,b.PropertySplitAddress,b.OwnerName,ISNULL(a.OwnerName,b.OwnerName),ISNULL(a.OwnerName,'No Owner Name')
FROM sqlprojects.dbo.nashvillehousing as a
JOIN sqlprojects.dbo.nashvillehousing as b
ON a.PropertySplitAddress=b.PropertySplitAddress 
AND a.[UniqueID ]!=b.[UniqueID ]
WHERE a.OwnerName is Null


UPDATE a
SET OwnerName=ISNULL(a.OwnerName,b.OwnerName)
FROM sqlprojects.dbo.nashvillehousing as a
JOIN sqlprojects.dbo.nashvillehousing as b
ON a.PropertySplitAddress=b.PropertySplitAddress 
AND a.[UniqueID ]!=b.[UniqueID ]

UPDATE a
SET OwnerName=ISNULL(a.OwnerName,'No Owner Name')
FROM sqlprojects.dbo.nashvillehousing as a
JOIN sqlprojects.dbo.nashvillehousing as b
ON a.PropertySplitAddress=b.PropertySplitAddress 
AND a.[UniqueID ]!=b.[UniqueID ]

SELECT PropertySplitAddress,OwnerName
FROM  sqlprojects.dbo.nashvillehousing
WHERE OwnerName ='No Owner Name' OR OwnerName is NULL

UPDATE sqlprojects.dbo.nashvillehousing
SET OwnerName=ISNULL(OwnerName,'No Owner Name')
FROM sqlprojects.dbo.nashvillehousing 

--Checking OwnerName Column  
SELECT OwnerName
FROM  sqlprojects.dbo.nashvillehousing

--Splitting OwnerName into Owner1,OtherOwners
SELECT 
SUBSTRING(OwnerName,1,CHARINDEX(',',OwnerName)) AS Owner1,
SUBSTRING(OwnerName,CHARINDEX(',',OwnerName)+1,LEN(OwnerName)) AS Owner2
FROM sqlprojects.dbo.nashvillehousing 
WHERE OwnerName!='No Owner Name'

ALTER TABLE sqlprojects.dbo.nashvillehousing 
ADD Owner1 nvarchar(300);

UPDATE sqlprojects.dbo.nashvillehousing 
SET Owner1 = SUBSTRING(OwnerName,1,CHARINDEX(',',OwnerName)) 

ALTER TABLE sqlprojects.dbo.nashvillehousing 
ADD OtherOwners nvarchar(300);

UPDATE sqlprojects.dbo.nashvillehousing 
SET OtherOwners = SUBSTRING(OwnerName,CHARINDEX(',',OwnerName)+1,LEN(OwnerName)) 

--Updating Blank cells in Owner1 Column to 'No Owner Name'
UPDATE sqlprojects.dbo.nashvillehousing
SET Owner1='No Owner Name'
WHERE Owner1=' '

--Checking the Owner1 Column
SELECT Owner1
FROM sqlprojects.dbo.nashvillehousing 
WHERE Owner1=' '

SELECT *
FROM  sqlprojects.dbo.nashvillehousing

--Removing OwnerName Column

ALTER TABLE sqlprojects.dbo.nashvillehousing
DROP COLUMN OwnerName

SELECT *
FROM sqlprojects.dbo.nashvillehousing
