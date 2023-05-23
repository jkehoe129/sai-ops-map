WITH SAGE_Address(SAGE_ID,Address1)
AS
(
    SELECT
    P.SAGE_ID
    ,CONCAT(P.Address1,',',P.City,',',P.State)
    FROM SAI_ProposalTable P
    INNER JOIN
    (
        SELECT SAGE_ID, MAX(Proposal_ID) MaxID
        FROM SAI_ProposalTable
        GROUP BY SAGE_ID
    ) MaxIDs
    ON P.SAGE_ID = MaxIDs.SAGE_ID AND P.Proposal_ID = MaxIDs.MaxID
)

SELECT DISTINCT
P.Project_Name AS 'Job Name'
,B.Address1
,CASE
WHEN P.SAI_Lead = 'Joe Ouellette' THEN 'EVCI'
WHEN P.SAI_Lead IN ('Paul Kean','Shawn Hancock') THEN 'Telecom-Tower'
ELSE 'Telecom-DAS'
END AS 'Job_Type'
,S.SAGE_Project
,A.Ticket_Owner
,A.Ticket_SAGE_ID
FROM SAI_Scheduler.dbo.tScheduler_MainScheduleData A
INNER JOIN SAI_ProposalTable P
ON A.Ticket_SAGE_ID = P.SAGE_ID
INNER JOIN SAGE_Address B
ON B.SAGE_ID = P.SAGE_ID
INNER JOIN SAGE_Type S
ON P.Project_Key = S.SAGE_Code
WHERE YEAR(A.Ticket_Start_Date) = YEAR(GETDATE())
AND
    (
        DATEPART(wk,A.Ticket_Start_Date) = DATEPART(wk,GETDATE())
        OR DATEPART(wk,A.Ticket_End_Date) = DATEPART(wk,GETDATE())
    )

UNION ALL

SELECT DISTINCT
P.Project_Name
,B.Address1
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
INNER JOIN SAGE_Address B
ON B.SAGE_ID = P.SAGE_ID
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