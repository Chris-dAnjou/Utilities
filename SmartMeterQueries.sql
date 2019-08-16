
/*
Smart Meter Data Source: Annual Electric Power Industry Report, Form EIA-861 detailed data files (2017)
https://www.eia.gov/electricity/data/eia861/
*/


# Advanced Meter Reading smart meter (AMR), Advanced Metering Infrastructure smart meter (AMI) and conventional electric meter statistics for residential customers by state. 
SELECT 
	State,
	SUM(AMR_Residential) AS Total_AMR, 
    SUM(AMI_Residential) AS Total_AMI, 
    SUM(NonSmart_Total) AS Total_NonSmartMeters, 
	SUM(AMR_Residential) + SUM(AMI_Residential) + SUM(NonSmart_Total) AS Total_Meters, 
	SUM(AMR_Residential)/(SUM(AMR_Residential) + SUM(AMI_Residential)) AS AMR_PctOfSmart, 
	(1 - SUM(AMR_Residential)/(SUM(AMR_Residential) + SUM(AMI_Residential))) AS AMI_PctOfSmart,
	(SUM(AMR_Residential) + SUM(AMI_Residential))/(SUM(AMR_Residential) + SUM(AMI_Residential) + SUM(NonSmart_Total)) AS Smart_PctOfMeters
FROM advanced_meter_data
GROUP BY State
ORDER BY Smart_PctOfMeters; 

# Utility companies with threshhold number of AMI smart meters. 
SELECT
	Utility_Name,
	State,
    AMI_Total + AMR_Total AS Total_Smart
FROM advanced_meter_data
WHERE AMI_Total + AMR_Total > 250000
ORDER BY Utility_Name ASC; 

# Email campaign contact list based on smart meter count, contact title and topics relevant to the contact. 
SELECT
	SmartTtl.Utility_Name, 
    SmartTtl.State, 
    u.First_Name, 
    u.Last_Name, 
    u.Salutation, 
    u.email,
    u.signature, 
    u.Relationship_Owner
FROM utilities_contacts u
LEFT JOIN
(SELECT
	Utility_Name,
	State,
    AMI_Total + AMR_Total AS Total_Smart
FROM advanced_meter_data
WHERE AMI_Total + AMR_Total > 250000) AS SmartTtl
ON u.Utility_Name = SmartTtl.Utility_Name AND u.State = SmartTtl.State
WHERE 
	interests IN ('smart meter','net metering','demand response') 
		AND 
	(decision_maker = TRUE OR influencer = TRUE) 
		AND 
	OptIn = TRUE 
		AND 
	Active = TRUE; 