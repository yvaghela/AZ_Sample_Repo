--- 1. Line 9 to 70 contains code to find Total Number of Patients exposed to EVUSHELD
--- 2. Line 70 to 142 contains code to find Total Number of EVUSHELD Doses
--- 3. Line 151 to 224 contains code for Patients with age >= 12 years as of index Date
--- 4. Line 225 to 298 contains code for Patients with actively receiving care >= 12 months prior the index date (Both inclusion criteria)


------------------------------------------------------Evusheld Exposed patients ----------------------------------

select distinct masterpatientid from 
(select evu_exp.masterpatientid,dataownerid, evu_exp.patientid, evu_exp.BIRTHDATE,evu_exp.indexdate, row_number () over 
(partition by masterpatientid order by indexdate ASC) as row1,row_number () over 
(partition by masterpatientid order by datarefreshid DESC) as refreshrank, datarefreshid from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221')) and (p.ISACTIVE = 1 and pr.ISACTIVE = 1) and (p.ISDELETED = 0 and pr.ISDELETED = 0)

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId
WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221')) and (p.ISACTIVE = 1 and b.ISACTIVE = 1) and (p.ISDELETED = 0 and b.ISDELETED = 0)

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))
        and (p.ISACTIVE = 1 and mo.ISACTIVE = 1) and (p.ISDELETED = 0 and mo.ISDELETED = 0)

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  )) and  (p.ISACTIVE = 1 and mf.ISACTIVE = 1) and (p.ISDELETED = 0 and mf.ISDELETED = 0)
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102')) and (p.ISACTIVE = 1 and ma.ISACTIVE = 1) and (p.ISDELETED = 0 and ma.ISDELETED = 0)
 ) evu_exp
   ) evu_refresh  where row1=1 and indexdate < '2022-12-01'and dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
--and indexdate is not null

 


------------------------------------------------- TOTAL EVUSHELD EXPOSURSES-----------------------------------------


select  distinct masterpatientid, indexdate from 
(select evu_exp.masterpatientid,dataownerid, evu_exp.patientid, evu_exp.BIRTHDATE,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1,row_number () over 
 (partition by masterpatientid order by datarefreshid DESC) as refreshrank, datarefreshid from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221')) and (p.ISACTIVE = 1 and pr.ISACTIVE = 1) and (p.ISDELETED = 0 and pr.ISDELETED = 0)

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId
WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221')) and (p.ISACTIVE = 1 and b.ISACTIVE = 1) and (p.ISDELETED = 0 and b.ISDELETED = 0)

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))
        and (p.ISACTIVE = 1 and mo.ISACTIVE = 1) and (p.ISDELETED = 0 and mo.ISDELETED = 0)

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  )) and  (p.ISACTIVE = 1 and mf.ISACTIVE = 1) and (p.ISDELETED = 0 and mf.ISDELETED = 0)
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102')) and (p.ISACTIVE = 1 and ma.ISACTIVE = 1) and (p.ISDELETED = 0 and ma.ISDELETED = 0)
 ) evu_exp
   ) evu_refresh  where dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72') and indexdate < '2022-12-01'
and indexdate is not null
order by masterpatientid 




-------------------------------------Patients with age >=12----------------------------------------------



select distinct masterpatientid from (
select evu_age.masterpatientid,dataownerid,evu_age.datarefreshid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid,dataownerid, evu_exp.patientid, evu_exp.BIRTHDATE,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1,row_number () over 
 (partition by masterpatientid order by datarefreshid DESC) as refreshrank, datarefreshid from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221')) and (p.ISACTIVE = 1 and pr.ISACTIVE = 1) and (p.ISDELETED = 0 and pr.ISDELETED = 0)

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId
WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221')) and (p.ISACTIVE = 1 and b.ISACTIVE = 1) and (p.ISDELETED = 0 and b.ISDELETED = 0)

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))
        and (p.ISACTIVE = 1 and mo.ISACTIVE = 1) and (p.ISDELETED = 0 and mo.ISDELETED = 0)

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  )) and  (p.ISACTIVE = 1 and mf.ISACTIVE = 1) and (p.ISDELETED = 0 and mf.ISDELETED = 0)
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102')) and (p.ISACTIVE = 1 and ma.ISACTIVE = 1) and (p.ISDELETED = 0 and ma.ISDELETED = 0)
 ) evu_exp
   ) evu_age  where row1=1  and age is not null) 
   where age >=12 and indexdate < '2022-12-01'and indexdate is not null and dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72') 
  
  




--------------------------------- Patients after apply both the inclusion criterias-------------------------------------------



select distinct masterpatientid from (
select age_pat.masterpatientid,dataownerid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid,dataownerid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid,dataownerid,evu_age.datarefreshid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid,dataownerid, evu_exp.patientid, evu_exp.BIRTHDATE,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1,row_number () over 
 (partition by masterpatientid order by datarefreshid DESC) as refreshrank, datarefreshid from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221')) and (p.ISACTIVE = 1 and pr.ISACTIVE = 1) and (p.ISDELETED = 0 and pr.ISDELETED = 0)

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId
WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221')) and (p.ISACTIVE = 1 and b.ISACTIVE = 1) and (p.ISDELETED = 0 and b.ISDELETED = 0)

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))
        and (p.ISACTIVE = 1 and mo.ISACTIVE = 1) and (p.ISDELETED = 0 and mo.ISDELETED = 0)

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  )) and  (p.ISACTIVE = 1 and mf.ISACTIVE = 1) and (p.ISDELETED = 0 and mf.ISDELETED = 0)
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE,gender, p.datarefreshid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102')) and (p.ISACTIVE = 1 and ma.ISACTIVE = 1) and (p.ISDELETED = 0 and ma.ISDELETED = 0)
 ) evu_exp
   ) evu_age  where row1=1  and age is not null) aa
   where age >=12 and indexdate < '2022-12-01'and indexdate is not null and dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72') 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
             where  ISACTIVE = 1 and ISDELETED = 0 ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
