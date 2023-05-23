SELECT DISTINCT
A.Ticket_JobDescription AS 'Job Name'
,CONCAT(P.Address1,',',P.City,',',P.State) AS 'Address'
,CASE
WHEN P.SAI_Lead = 'Joe Ouellette' THEN 'EVCI'
WHEN P.SAI_Lead IN ('Paul Kean','Shawn Hancock') THEN 'Telecom-Tower'
ELSE 'Telecom-DAS'
END AS 'Job_Type'
,A.Ticket_WorkDescription
,A.Ticket_Owner
,A.Ticket_SAGE_ID
FROM SAI_Scheduler.dbo.tScheduler_MainScheduleData A
INNER JOIN SAI_ProposalTable P
ON A.Ticket_SAGE_ID = P.SAGE_ID
WHERE A.Ticket_Start_Date = CAST(GETDATE() AS DATE)
OR A.Ticket_End_Date = CAST(GETDATE() AS DATE)

UNION ALL

SELECT DISTINCT
P.Project_Name
,CONCAT(P.Address1,',',P.City,',',P.State)
,'EVCI'
,S.SAGE_Project
,P.SAI_Lead
,P.SAGE_ID
FROM SAI_ProposalTable P
INNER JOIN SAGE_Type S
ON P.Project_Key = S.SAGE_Code
INNER JOIN EVCI_EA_Normalized_Data E
    ON RIGHT(P.Project_Name,6) = E.Project_Number 
    AND E.Name = 'Mobilize / Install Construction Fencing' 
    AND DATEPART(wk,E.Start) = DATEPART(wk,GETDATE())
WHERE P.SAI_Lead = 'Joe Ouellette'

UNION ALL

SELECT
'SALEM HQ'
,'12 Industrial Way,Salem,NH'
,'HQ'
,'HOME BASE'
,'Tony Miller'
,'NH-000-00000'

UNION ALL

SELECT
'NORRISTOWN OFFICE'
,'529 Foundry Rd,Norristown,PA'
,'HQ'
,'PA OFFICE'
,'Todd Higginbotton'
,'PA-000-00000'