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







ISNULL(
    CASE
    WHEN SUBSTRING(E.Job,4,1) = '3' THEN 'Eric Campbell'
    WHEN SUBSTRING(E.Job,4,3) IN ('130') THEN 'Eric Campbell'
    WHEN E.[Customer] = 'ATT001' THEN 'Warren Kelleher'
    WHEN SUBSTRING(E.Job,4,3) IN ('122','123') AND E.[PO Line Description] LIKE '%construction project management%' THEN 'Paul Kean'
    WHEN SUBSTRING(E.Job,4,3) IN ('122','123') AND E.[PO Line Description] NOT LIKE '%construction project management%' THEN 'Warren Kelleher'
    ELSE NULL
    END,ISNULL((SELECT TOP 1 P.SAI_Lead FROM SAI_ProposalTable P WHERE P.SAGE_ID = E.Job ORDER BY Proposal_ID DESC),'NOT IN BIDLOGGER')
 ) AS 'PM'








 -----------------------
 SELECT
    E.[PO&Line Number]
    ,E.[SITE]
    ,E.[Site Name]
    ,E.[Project_Type]
    ,E.[Contract]
    ,E.[Job]
    ,E.[PACE Task]
    ,E.[Milestone]
    ,E.[FA]
    ,E.[PO Number]
    ,E.[Line Number]
    ,E.[PO Line Description]
    ,E.[Revised_Contract]
    ,E.[Adjustment]
    ,E.[Total_Billed]
    ,E.[Cash_Receipt]
    ,E.[Tax]
    ,E.[Vendor_PO_Tax]
    ,E.[Invoice]
    ,E.[Invoice_Date]
    ,E.[Revised_Invoice]
    ,E.[Customer]
    ,E.[Orig PO Date Rec]
    ,E.[Line Revision Date]
    ,E.[Notes]
    ,E.[Address_2]
    ,E.[City]
    ,E.[State]
    ,ISNULL(
        CASE
        WHEN SUBSTRING(E.Job,4,1) = '3' THEN 'Eric Campbell'
        WHEN SUBSTRING(E.Job,4,3) IN ('130') THEN 'Eric Campbell'
        WHEN E.[Customer] = 'ATT001' THEN 'Warren Kelleher'
        WHEN SUBSTRING(E.Job,4,3) IN ('122','123') AND E.[PO Line Description] LIKE '%construction project management%' THEN 'Paul Kean'
        WHEN SUBSTRING(E.Job,4,3) IN ('122','123') AND E.[PO Line Description] NOT LIKE '%construction project management%' THEN 'Warren Kelleher'
        ELSE NULL
        END
        ,ISNULL((SELECT TOP 1 P.SAI_Lead FROM SAI_ProposalTable P WHERE P.SAGE_ID = E.Job ORDER BY Proposal_ID DESC),'NOT IN BIDLOGGER')
 ) AS 'PM'
    ,E.PM AS 'sagePM'
    ,B.Line_Action
    ,B.Line_Notes
    ,B.Modified
    ,B.ModifiedBy
    ,CASE
    WHEN E.[PO Number] IS NULL AND E.[Line Number] <> 1111 THEN ISNULL(E.[Revised_Contract],0) - ISNULL(E.[Total_Billed],0)
    WHEN E.[PO Number] NOT LIKE '%NO PO%' AND RIGHT(E.[PO Number],1) <> '.' AND E.[Line Number] <> 1111 THEN ISNULL(E.[Revised_Contract],0) - ISNULL(E.[Total_Billed],0)
    ELSE 0
    END AS 'OPEN-PO'
    ,CASE
    WHEN E.[PO Number] LIKE '%NO PO%' OR RIGHT(E.[PO Number],1) = '.' OR E.[Line Number] = 1111 THEN ISNULL(E.[Revised_Contract],0) - ISNULL(E.[Total_Billed],0)
    ELSE 0
    END AS 'OPEN-PO-PH'
FROM sai_tracker.dbo.Erica_Contracts_with_PACE_and_ProjectType E
INNER JOIN SAGE_Type S
    ON SUBSTRING(E.Job,4,3) = S.SAGE_Code
LEFT JOIN sai_tracker.dbo.OPS_Billable_Tracker B
ON B.Line_Item_ID = E.Job + '|' + E.[PO&Line Number]
WHERE E.[Revised_Contract] - ISNULL(E.[Total_Billed],0) <> 0
    AND SUBSTRING(E.Job,4,3) <> '999'
    AND E.[Credit_Memo] IS NULL    
ORDER BY 
    (SELECT TOP 1 P.SAI_Lead 
    FROM SAI_ProposalTable P 
    WHERE P.SAGE_ID = E.Job 
    ORDER BY Proposal_ID DESC)
    , E.[Project_Type],E.[Job]

