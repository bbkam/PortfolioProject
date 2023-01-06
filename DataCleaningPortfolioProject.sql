/*

cleaning data with SQL queries

*/

select * from PortfolioProject..NashvilleHousing

---------------------------------------------------------
--Standardize date format

Select SaleDate, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date, SaleDate)

Select SaleDate
from NashvilleHousing

Alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

Select * from NashvilleHousing

---------------------------------------------------------------------------------------------

--Populate Property Address

Select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b. ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

Update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

---------------------------------------------------------------------------------------------------------

--Breaking out address into individual columns (address, city, state)

Select *
from NashvilleHousing


select
SUBSTRING(PropertyAddress, 1,charIndex(',',PropertyAddress)-1) as address,
Substring(PropertyAddress, charIndex(',', PropertyAddress)+1, len(PropertyAddress)) as City
from NashvilleHousing

Alter table NashvilleHousing
add PropertySplitAddress NVarChar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,charIndex(',',PropertyAddress)-1)



Alter table NashvilleHousing
add PropertySplitCity NVarChar(255);

update NashvilleHousing
set PropertySplitCity = Substring(PropertyAddress, charIndex(',', PropertyAddress)+1, len(PropertyAddress))

Select * from NashvilleHousing

Select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3) 
,PARSENAME(replace(OwnerAddress, ',', '.'), 2) 
,PARSENAME(replace(OwnerAddress, ',', '.'), 1) 
from NashvilleHousing
where OwnerAddress is not null

Alter table NashvilleHousing
add OwnerSplitAddress NVarChar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3) 



Alter table NashvilleHousing
add OwnerSplitCity NVarChar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2) 


Alter table NashvilleHousing
add OwnerSplitState NVarChar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1) 


--------------------------------------------------------------------------------------------------------

---Change Y and N to Yes and No in 'SoleAsVacant' field

select distinct(SoldAsVacant), Count(soldAsVacant) 
from NashvilleHousing
group by SoldAsVacant
order by 2

with temp as
(
Select SoldAsVacant,
		case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant end as new
from NashvilleHousing
)

Select * from temp 
where SoldAsVacant in ('y','n')


update NashvilleHousing
set SoldAsVacant =  case when SoldAsVacant = 'Y' then 'Yes'
					when SoldAsVacant = 'N' then 'No'
					else SoldAsVacant end

----------------------------------------------------------------------------------

--Remove Duplicate (usually not done, need to confirm before deleting anything from raw data)


with RowNumCTE as(
select *,
		ROW_NUMBER() over (
		partition by ParcelID, 
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
		order by UniqueID) as row_num
from PortfolioProject.dbo.NashvilleHousing
)

--Delete 
Select * 
from RowNumCTE
where row_num >1

-------------------------------------------------------------------------------------------------

--Delete unused column (usually not done, need to confirm before deleting anything from raw data)


Select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add temp nvarchar (255)

update PortfolioProject.dbo.NashvilleHousing
set temp = OwnerSplitCity

alter table PortfolioProject.dbo.NashvilleHousing
drop column temp

---------------------------------------------------------------------------------------------------
