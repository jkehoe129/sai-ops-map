SELECT DISTINCT
CONCAT(P.Address1,',',P.City,',',P.State) AS 'Address'
,CASE
WHEN P.SAI_Lead = 'Joe Ouellette' THEN 'EVCI'
WHEN P.SAI_Lead IN ('Paul Kean','Shawn Hancock') THEN 'Telecom-Tower'
ELSE 'Telecom-DAS'
END AS 'Job_Type'
FROM SAI_Scheduler.dbo.tScheduler_MainScheduleData A
INNER JOIN SAI_ProposalTable P
ON A.Ticket_SAGE_ID = P.SAGE_ID
WHERE A.Ticket_Start_Date = CAST(GETDATE() AS DATE) OR
A.Ticket_End_Date = CAST(GETDATE() AS DATE)