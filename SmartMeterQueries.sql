/*
Smart Meter Data Source: Annual Electric Power Industry Report, Form EIA-861 detailed data files (2017)
https://www.eia.gov/electricity/data/eia861/
*/


# Residential smart meter penetration and proportion of AMR and AMI meters among total smart meters, by state. 
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

# Utility companies with minimum number of AMI smart meters to target for business development. 
SELECT
	Utility_Name,
	State,
    	AMI_Total
FROM advanced_meter_data
WHERE AMI_Total >= 25000 AND AMI_Total <= 75000 AND OrgType = "Cooperative"
ORDER BY Utility_Name ASC; 

# Email campaign contact list based on smart meter count, contact title and topics relevant to the contact. 
SELECT
	SmartTtl.Utility_Name, 
    	SmartTtl.State, 
    	u.First_Name, 
    	u.Last_Name, 
    	u.Salutation, 
    	u.Email,
    	u.Signature, 
    	u.RelationshipOwner_email
FROM utilities_contacts u
LEFT JOIN
(SELECT
	Utility_Name,
	State,
    	AMI_Total + AMR_Total AS Total_Smart
FROM advanced_meter_data
WHERE AMI_Total >= 25000 AND AMI_Total <= 75000 AND OrgType = "Cooperative") AS SmartTtl
ON u.Utility_Name = SmartTtl.Utility_Name AND u.State = SmartTtl.State
WHERE 
	interests IN ('smart meter','net metering','demand response') 
		AND 
	(Decision_Maker = TRUE OR Influencer = TRUE) 
		AND 
	OptIn = TRUE 
		AND 
	Active = TRUE; 
