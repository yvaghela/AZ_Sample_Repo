##ALL casue hospitalization

WITH EVU_PAT as (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
  )
  
  select distinct masterpatientid, encounterdate from EVU_PAT
  inner join "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
  on EVU_PAT.patientid = "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS".patientid
  where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
            AND ENCOUNTERTYPE IN ('EI', 'IP')) 
            
            
            



_____________________________________________________________________________________________________________________

##ALL Unique patient's hospitalization

WITH EVU_PAT as (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
  )
  
  select distinct masterpatientid from EVU_PAT
  inner join "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
  on EVU_PAT.patientid = "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS".patientid
  where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
            AND ENCOUNTERTYPE IN ('EI', 'IP')) 
            
            
            
  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx          
            
## COVID hospitalizations + 14days covid **(NOT IN USE)


---WITH FINAL1 as (
WITH EVU_PAT as (
select inclusion_both.masterpatientid, inclusion_both.patientid, inclusion_both.indexdate, inclusion_both.encounterid from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate, encounterid from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
  INNER JOIN (
                select patientid, dxdate,ENCOUNTERID
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000')
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') ) covid
                     on inclusion_both.encounterid = covid.encounterid
  )
  
    
  select distinct masterpatientid, encounterdate from EVU_PAT
  inner join "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
  on EVU_PAT.patientid = "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS".patientid
  where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
            AND ENCOUNTERTYPE IN ('EI', 'IP'))
  ),
  
FINAL2 as (
WITH EVU_PAT as (
select inclusion_both.masterpatientid, inclusion_both.patientid, inclusion_both.indexdate, inclusion_both.encounterid, dxdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate, encounterid from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
  INNER JOIN (
                select patientid, dxdate,ENCOUNTERID
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000')
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') ) covid
                     on inclusion_both.encounterid = covid.encounterid
                     
  )
  
    
  select distinct masterpatientid, encounterdate from EVU_PAT
  inner join "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
  on EVU_PAT.patientid = "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS".patientid
  where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
            AND ENCOUNTERTYPE IN ('EI', 'IP')) AND dxdate >= (admitdate - 14) AND dxdate <= dischargedate
  )
  
  select distinct masterpatientid from FINAL1
  UNION ALL
  select distinct masterpatientid from FINAL2
            
            
## Record of COVID during hospitalizations**

----WITH EVU_PAT as (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
  ),
  
  EVU_EN as (
  select distinct masterpatientid, encounterdate, encounterid from EVU_PAT
  inner join "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
  on EVU_PAT.patientid = "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS".patientid
  where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
            AND ENCOUNTERTYPE IN ('EI', 'IP')) 
    )
    
    select distinct masterpatientid, encounterdate--, covid.dxdate,encounterdate, evu_en.encounterid, covid.encounterid as covid_encounterid
    from EVU_EN
    inner join (
       select patientid, dxdate,ENCOUNTERID
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000')
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') ) covid
                      
                      on EVU_EN.encounterid = covid.encounterid
 __________________________________________________________________________________________________________________________________________________________                     
                      ),
                      
                      
  ---    query2 as   (
---WITH EVU_PAT as (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
  ),
  
  EVU_EN as (
  select distinct masterpatientid, encounterdate, encounterid from EVU_PAT
  inner join "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
  on EVU_PAT.patientid = "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS".patientid
  where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
            AND ENCOUNTERTYPE IN ('EI', 'IP')) 
    )
    
    select distinct masterpatientid, covid.dxdate,encounterdate, evu_en.encounterid, covid.encounterid as covid_encounterid
    from EVU_EN
    inner join (
       select patientid, dxdate,ENCOUNTERID
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000')
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') ) covid
                      
                      on EVU_EN.encounterid = covid.encounterid
        where (dxdate >=((encounterdate)-14) and dxdate <=encounterdate)
                      
                      )
        
        select distinct masterpatientid, encounterdate
        from query1
        
        UNION ALL
        
        select distinct masterpatientid, encounterdate
        from query2
        
                    
             select distinct patientid, encounterdate from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"       --- 5,522,905   2,446,189
         -- where ADMITDATE is not null                ----723,260 
    where DISCHARGEDATE is not null      --- 367101 
	
	
	
	
___________________________________________________________________________________________________________________________________________________

##COVID  casue hospitalization + 14 days before hospitalization until discharge (Any diagnosis - not first one)

select distinct masterpatientid from (
select masterpatientid,encounterdate from (
select EVU_EN_JOIN.* from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  encounterid, encounterdate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000')
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL') ) COVID
                     
                     on EVU_EN_JOIN.encounterid = COVID.encounterid
                     
                     )COVID_HOSP
                     
                     
    UNION ALL
    

select masterpatientid,encounterdate from (
select EVU_EN_JOIN.masterpatientid, EVU_EN_JOIN.patientid, EVU_EN_JOIN.encounterid,EVU_EN_JOIN.indexdate, EVU_EN_JOIN.encounterdate,
case
  when dischargedate is not null then dischargedate
  when dischargedate is null then encounterdate
  END as enddate
from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  encounterid, encounterdate, admitdate, dischargedate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid, admitdate, dischargedate
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000')
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL' ) ) COVID
                     
                     on EVU_EN_JOIN.patientid = COVID.patientid
                     where dxdate >= (encounterdate - 14) AND dxdate <= enddate
                     
                     )COVID_HOSP1
                     
                     ) FINAL_COHORT
                     
                     
                     
 ______________________________________________________________________________________________________________________________________________________________
 
 
 ##  PRIMARY COVID IP patients + 14 days
 
 
select distinct masterpatientid from (
select masterpatientid,encounterdate from (
select EVU_EN_JOIN.* from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  encounterid, encounterdate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL') where PDX = 'P') COVID
                     
                     on EVU_EN_JOIN.encounterid = COVID.encounterid
                     
                     )COVID_HOSP
                     
                     
    UNION ALL
    

select masterpatientid,encounterdate from (
select EVU_EN_JOIN.masterpatientid, EVU_EN_JOIN.patientid, EVU_EN_JOIN.encounterid,EVU_EN_JOIN.indexdate, EVU_EN_JOIN.encounterdate,
case
  when dischargedate is not null then dischargedate
  when dischargedate is null then encounterdate
  END as enddate
from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  encounterid, encounterdate, admitdate, dischargedate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid, admitdate, dischargedate
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL' ) WHERE PDX = 'P') COVID
                     
                     on EVU_EN_JOIN.patientid = COVID.patientid
                     where dxdate >= (encounterdate - 14) AND dxdate <= enddate
                     
                     )COVID_HOSP1
                     
                     ) FINAL_COHORT
                     
                     
                     
 _______________________________________________________________________________________________________________________________________________
 
 
 ## For patients with all cause admissions, 
 --Pneumonia OR ARDS OR Respiratory failure diagnosis anytime between visit start date and visit end date.
 ---AND 14 days before hospitalization until discharge
 
select distinct masterpatientid from (
select masterpatientid,encounterdate from (
select EVU_EN_JOIN.* from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  encounterid, encounterdate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('J96.0','J96.01','J96.10','J96.11','J96.20','J96.21','J96.90','J96.91','R05','R06.00','R06.02',
                                           'R06.03','R06.09','R06.9','R09.02','R79.81','R11.0','R11.10','R11.2','R19.7','R41.89','R43.2',
                                           'R43.8','R43.9','R50.81','R50.9','R52','R53.1','R53.81','R53.83','R68.89','U07.1','Z20.828',
                                           'Z78.9','Z99.81') ) ) COVID
                     
                     on EVU_EN_JOIN.encounterid = COVID.encounterid
                     
                     )COVID_HOSP
                     
                     
    UNION ALL
    

select masterpatientid,encounterdate from (
select EVU_EN_JOIN.masterpatientid, EVU_EN_JOIN.patientid, EVU_EN_JOIN.encounterid,EVU_EN_JOIN.indexdate, EVU_EN_JOIN.encounterdate,
case
  when dischargedate is not null then dischargedate
  when dischargedate is null then encounterdate
  END as enddate
from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  encounterid, encounterdate, admitdate, dischargedate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid, admitdate, dischargedate
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('J96.0','J96.01','J96.10','J96.11','J96.20','J96.21','J96.90','J96.91','R05','R06.00','R06.02',
                                           'R06.03','R06.09','R06.9','R09.02','R79.81','R11.0','R11.10','R11.2','R19.7','R41.89','R43.2',
                                           'R43.8','R43.9','R50.81','R50.9','R52','R53.1','R53.81','R53.83','R68.89','U07.1','Z20.828',
                                           'Z78.9','Z99.81') ) ) COVID
                     
                     on EVU_EN_JOIN.patientid = COVID.patientid
                     where dxdate >= (encounterdate - 14) AND dxdate <= enddate
                     
                     )COVID_HOSP1
                     
                     ) FINAL_COHORT 

                     
                     


                     
_______________________________________________________________________________________________________________________________________________

## Any diagnosis code of COVID-19 AND any diagnosis of any related complication

WITH secondary_covid as (
select distinct masterpatientid,evu_encounterid,covid_encounterid from (
  
select masterpatientid,evu_encounterid,covid_encounterid from (
select EVU_EN_JOIN.*, covid_encounterid from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  evu_encounterid, encounterdate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid as evu_encounterid
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID as covid_encounterid, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID as covid_encounterid, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL')   ) COVID
                     
                     on EVU_EN_JOIN.evu_encounterid = COVID.covid_encounterid
                     
                     )COVID_HOSP
                     
                     
    UNION ALL
    

select masterpatientid,evu_encounterid, covid_encounterid from (
select EVU_EN_JOIN.masterpatientid, EVU_EN_JOIN.patientid, EVU_EN_JOIN.evu_encounterid,covid_encounterid,EVU_EN_JOIN.indexdate, EVU_EN_JOIN.encounterdate,
case
  when dischargedate is not null then dischargedate
  when dischargedate is null then encounterdate
  END as enddate
from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  evu_encounterid, encounterdate, admitdate, dischargedate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid as evu_encounterid, admitdate, dischargedate
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID as covid_encounterid, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID as covid_encounterid, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL' )   ) COVID
                     
                     on EVU_EN_JOIN.patientid = COVID.patientid
                     where dxdate >= (encounterdate - 14) AND dxdate <= enddate
                     
                     )COVID_HOSP1
                     
                     ) FINAL_COHORT ),
                     
                     
                     
   PRIMARY_OTHER as (
     select distinct masterpatientid,other_encounterid,evu_encounterid from (
       
select masterpatientid,other_encounterid,evu_encounterid from (
select EVU_EN_JOIN.*, other_encounterid from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  evu_encounterid, encounterdate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid as evu_encounterid
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID as other_encounterid, PDX
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('J96.0','J96.01','J96.10','J96.11','J96.20','J96.21','J96.90','J96.91','R05','R06.00','R06.02',
                                           'R06.03','R06.09','R06.9','R09.02','R79.81','R11.0','R11.10','R11.2','R19.7','R41.89','R43.2',
                                           'R43.8','R43.9','R50.81','R50.9','R52','R53.1','R53.81','R53.83','R68.89','U07.1','Z20.828',
                                           'Z78.9','Z99.81') )  ) COVID
                     
                     on EVU_EN_JOIN.evu_encounterid = COVID.other_encounterid
                     
                     )OTHER_HOSP
                     
                     
    UNION ALL
    

select masterpatientid,evu_encounterid, other_encounterid from (
select EVU_EN_JOIN.masterpatientid, EVU_EN_JOIN.patientid, EVU_EN_JOIN.evu_encounterid,other_encounterid,EVU_EN_JOIN.indexdate, EVU_EN_JOIN.encounterdate,
case
  when dischargedate is not null then dischargedate
  when dischargedate is null then encounterdate
  END as enddate
from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  evu_encounterid, encounterdate, admitdate, dischargedate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid as evu_encounterid, admitdate, dischargedate
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID as other_encounterid, PDX
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('J96.0','J96.01','J96.10','J96.11','J96.20','J96.21','J96.90','J96.91','R05','R06.00','R06.02',
                                           'R06.03','R06.09','R06.9','R09.02','R79.81','R11.0','R11.10','R11.2','R19.7','R41.89','R43.2',
                                           'R43.8','R43.9','R50.81','R50.9','R52','R53.1','R53.81','R53.83','R68.89','U07.1','Z20.828',
                                           'Z78.9','Z99.81') ) ) COVID
                     
                     on EVU_EN_JOIN.patientid = COVID.patientid
                     where dxdate >= (encounterdate - 14) AND dxdate <= enddate
                     
                     )OTHER_HOSP1
                     
                     ) FINAL_COHORT 
   )

         select distinct PRIMARY_OTHER.masterpatientid from secondary_covid
         inner join PRIMARY_OTHER
         on secondary_covid.covid_encounterid = PRIMARY_OTHER.other_encounterid
                     
______________________________________________________________________________________________________________________________________________



_____________________________________________________________________________________________________________________________________________-

##Total number of patients qualifying for the outcomes (Step 2a or 2b)


WITH secondary_covid as (
select distinct masterpatientid,evu_encounterid,covid_encounterid from (
  
select masterpatientid,evu_encounterid,covid_encounterid from (
select EVU_EN_JOIN.*, covid_encounterid from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  evu_encounterid, encounterdate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid as evu_encounterid
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID as covid_encounterid, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID as covid_encounterid, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL')   ) COVID
                     
                     on EVU_EN_JOIN.evu_encounterid = COVID.covid_encounterid
                     
                     )COVID_HOSP
                     
                     
    UNION ALL
    

select masterpatientid,evu_encounterid, covid_encounterid from (
select EVU_EN_JOIN.masterpatientid, EVU_EN_JOIN.patientid, EVU_EN_JOIN.evu_encounterid,covid_encounterid,EVU_EN_JOIN.indexdate, EVU_EN_JOIN.encounterdate,
case
  when dischargedate is not null then dischargedate
  when dischargedate is null then encounterdate
  END as enddate
from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  evu_encounterid, encounterdate, admitdate, dischargedate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid as evu_encounterid, admitdate, dischargedate
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID as covid_encounterid, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID as covid_encounterid, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL' )   ) COVID
                     
                     on EVU_EN_JOIN.patientid = COVID.patientid
                     where dxdate >= (encounterdate - 14) AND dxdate <= enddate
                     
                     )COVID_HOSP1
                     
                     ) FINAL_COHORT ),
                     
                     
                     
   PRIMARY_OTHER as (
     select distinct masterpatientid,other_encounterid,evu_encounterid from (
       
select masterpatientid,other_encounterid,evu_encounterid from (
select EVU_EN_JOIN.*, other_encounterid from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  evu_encounterid, encounterdate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid as evu_encounterid
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID as other_encounterid, PDX
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('J96.0','J96.01','J96.10','J96.11','J96.20','J96.21','J96.90','J96.91','R05','R06.00','R06.02',
                                           'R06.03','R06.09','R06.9','R09.02','R79.81','R11.0','R11.10','R11.2','R19.7','R41.89','R43.2',
                                           'R43.8','R43.9','R50.81','R50.9','R52','R53.1','R53.81','R53.83','R68.89','U07.1','Z20.828',
                                           'Z78.9','Z99.81') )  ) COVID
                     
                     on EVU_EN_JOIN.evu_encounterid = COVID.other_encounterid
                     
                     )OTHER_HOSP
                     
                     
    UNION ALL
    

select masterpatientid,evu_encounterid, other_encounterid from (
select EVU_EN_JOIN.masterpatientid, EVU_EN_JOIN.patientid, EVU_EN_JOIN.evu_encounterid,other_encounterid,EVU_EN_JOIN.indexdate, EVU_EN_JOIN.encounterdate,
case
  when dischargedate is not null then dischargedate
  when dischargedate is null then encounterdate
  END as enddate
from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  evu_encounterid, encounterdate, admitdate, dischargedate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid as evu_encounterid, admitdate, dischargedate
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID as other_encounterid, PDX
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('J96.0','J96.01','J96.10','J96.11','J96.20','J96.21','J96.90','J96.91','R05','R06.00','R06.02',
                                           'R06.03','R06.09','R06.9','R09.02','R79.81','R11.0','R11.10','R11.2','R19.7','R41.89','R43.2',
                                           'R43.8','R43.9','R50.81','R50.9','R52','R53.1','R53.81','R53.83','R68.89','U07.1','Z20.828',
                                           'Z78.9','Z99.81') ) ) COVID
                     
                     on EVU_EN_JOIN.patientid = COVID.patientid
                     where dxdate >= (encounterdate - 14) AND dxdate <= enddate
                     
                     )OTHER_HOSP1
                     
                     ) FINAL_COHORT 
   )

---------------------------------------------------------------------------------
         select distinct masterpatientid from (
         select PRIMARY_OTHER.masterpatientid from secondary_covid
         inner join PRIMARY_OTHER
         on secondary_covid.covid_encounterid = PRIMARY_OTHER.other_encounterid
         UNION ALL
         
        select distinct masterpatientid from (
select masterpatientid,encounterdate from (
select EVU_EN_JOIN.* from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  encounterid, encounterdate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL') where PDX = 'P') COVID
                     
                     on EVU_EN_JOIN.encounterid = COVID.encounterid
                     
                     )COVID_HOSP
                     
                     
    UNION ALL
    

select masterpatientid,encounterdate from (
select EVU_EN_JOIN.masterpatientid, EVU_EN_JOIN.patientid, EVU_EN_JOIN.encounterid,EVU_EN_JOIN.indexdate, EVU_EN_JOIN.encounterdate,
case
  when dischargedate is not null then dischargedate
  when dischargedate is null then encounterdate
  END as enddate
from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  encounterid, encounterdate, admitdate, dischargedate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid, admitdate, dischargedate
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'IP')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL' ) WHERE PDX = 'P') COVID
                     
                     on EVU_EN_JOIN.patientid = COVID.patientid
                     where dxdate >= (encounterdate - 14) AND dxdate <= enddate
                     
                     )COVID_HOSP1
                     
                     ) FINAL_COHORT
           )
		   
		   
		   
		   
## Medically attended COVID-19 (Prep Only)

WITH prep as (
select distinct masterpatientid, patientid, indexdate from (
select y.masterpatientid, y.mindiff,y.patientid, y.indexdate from (
select x.masterpatientid, x.patientid,x.indexdate, MIN(x.diff) as mindiff from (
select inclusion_both.masterpatientid, inclusion_both.patientid, inclusion_both.indexdate, cov_pat.dxdate,
DATEDIFF(days, indexdate, dxdate) as diff from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE COALESCE(pr.PxDate, e.EncounterDate, e.AdmitDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId
--LEFT JOIN "DEID_PLATFORM"."GRATICULESOW3"."VW_DEID_PATIENTS" p2 ON p2.PatientId = e.PatientId AND p2.DataOwnerId = e.DataOwnerId
WHERE COALESCE(b.ServiceDate, e.EncounterDate, e.AdmitDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))
--AND (e.PatientId IS NULL OR p2.masterpatientid = p.masterpatientid)
 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE COALESCE(mo.OrderDate, e.AdmitDate, e.EncounterDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE COALESCE(ma.MedAdminStartDate, e.AdmitDate, e.EncounterDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age where row1=1 and age is not null ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
LEFT join  (select patientid, dxdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82')
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL') cov_pat
                           on inclusion_both.patientid = cov_pat.patientid ) x
                           group by x.masterpatientid, x.patientid, x.indexdate ) y
                           where (mindiff <-90 OR mindiff >6 OR mindiff is NULL) )
     ),
     
 encounter as (select patientid, encounterdate, encountertype, encounterid
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
             
              
              ),
      
 covid as (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000')
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID, NULL as PDX
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL' ) 
                             where PDX = 'P'), 
                             
                             
   combined_1  as(                         
            select distinct masterpatientid from prep
            inner join encounter
            on prep.patientid = encounter.patientid
            inner join covid
            on covid.encounterid = encounter.encounterid
             where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encountertype is NOT NULL AND encounterdate is not null))),
             
 combined_2 as (select distinct masterpatientid from prep
            inner join encounter
            on prep.patientid = encounter.patientid
            inner join covid
            on covid.encounterid = encounter.encounterid
             where ((encounterdate > ((indexdate)+6) AND encounterdate <= ((indexdate)+180) AND encountertype is not null AND encounterdate is not null
                    AND dxdate >= (encounterdate - 14) AND dxdate <= encounterdate)))
                    
          select * from combined_1
          UNION ALL
          select * from combined_2




______________________________________________________________________________________________________________________________________________________________



## Medically attended acute care COVID 19


select distinct masterpatientid from (
select masterpatientid,encounterdate from (
select EVU_EN_JOIN.* from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  encounterid, encounterdate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'ED')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL') where PDX = 'P') COVID
                     
                     on EVU_EN_JOIN.encounterid = COVID.encounterid
                     
                     )COVID_HOSP
                     
                     
    UNION ALL
    

select masterpatientid,encounterdate from (
select EVU_EN_JOIN.masterpatientid, EVU_EN_JOIN.patientid, EVU_EN_JOIN.encounterid,EVU_EN_JOIN.indexdate, EVU_EN_JOIN.encounterdate,
case
  when dischargedate is not null then dischargedate
  when dischargedate is null then encounterdate
  END as enddate
from (
select EVU_PAT.masterpatientid,EVU_PAT.patientid, EVU_PAT.indexdate,  encounterid, encounterdate, admitdate, dischargedate from (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate, encounterid
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
   ) EVU_PAT
   
   inner join (select * from(
              select patientid, encounterdate, encountertype, encounterid, admitdate, dischargedate
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
               ) ) EN_PAT
              on EVU_PAT.patientid = EN_PAT.patientid
              where ((encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
              AND ENCOUNTERTYPE IN ('EI', 'ED')) 
              ) EVU_EN_JOIN
    inner join (select * from(
       select patientid, dxdate,ENCOUNTERID, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL' ) WHERE PDX = 'P') COVID
                     
                     on EVU_EN_JOIN.patientid = COVID.patientid
                     where dxdate >= (encounterdate - 14) AND dxdate <= enddate
                     
                     )COVID_HOSP1
                     
                     ) FINAL_COHORT
                     
                     
                     
______________________________________________________________________________________________________________________________________________________________

## Post-COVID 19 Condition

WITH EVU_PAT as (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
  ),
  
  encounter as (select patientid, encounterdate as dx_encounterdate, encountertype, encounterid
  from"HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"),
  
  long_covid as (select patientid, dxdate, pdx
                from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                where dxcode IN ('U09','U09.9') )
  
    select distinct masterpatientid from EVU_PAT
    inner join encounter
    on EVU_PAT.patientid = encounter.patientid
    inner join long_covid
    on long_covid.patientid = EVU_PAT.patientid
    where (dx_encounterdate > (indexdate) AND dx_encounterdate <= ((indexdate)+180) AND dx_encounterdate is not null)
    
    
    
    
    
 ## All cause mortality 
 
 
WITH EVU_PAT as (
select masterpatientid, patientid, indexdate from (
select age_pat.masterpatientid, age_pat.patientid,age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE  (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE  (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age  where row1=1 and age is not null) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             ) inclusion_both
  )
  
  
  select distinct EVU_PAT.masterpatientid from EVU_PAT
  inner join "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" encounter
  on encounter.patientid = EVU_PAT.patientid
  inner join "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" patients
  on patients.patientid = EVU_PAT.patientid
  where (encounterdate > (indexdate) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null)
  AND DECEASEDDATE is not NULL
  
  
  
  
## SARS-CoV-2 infection (PrEP only)


WITH prep as (
select distinct masterpatientid, patientid, indexdate from (
select y.masterpatientid, y.mindiff,y.patientid, y.indexdate from (
select x.masterpatientid, x.patientid,x.indexdate, MIN(x.diff) as mindiff from (
select inclusion_both.masterpatientid, inclusion_both.patientid, inclusion_both.indexdate, cov_pat.dxdate,
DATEDIFF(days, indexdate, dxdate) as diff from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE COALESCE(pr.PxDate, e.EncounterDate, e.AdmitDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId
--LEFT JOIN "DEID_PLATFORM"."GRATICULESOW3"."VW_DEID_PATIENTS" p2 ON p2.PatientId = e.PatientId AND p2.DataOwnerId = e.DataOwnerId
WHERE COALESCE(b.ServiceDate, e.EncounterDate, e.AdmitDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))
--AND (e.PatientId IS NULL OR p2.masterpatientid = p.masterpatientid)
 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE COALESCE(mo.OrderDate, e.AdmitDate, e.EncounterDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE COALESCE(ma.MedAdminStartDate, e.AdmitDate, e.EncounterDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age where row1=1 and age is not null ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
LEFT join  (select patientid, dxdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82')
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL') cov_pat
                           on inclusion_both.patientid = cov_pat.patientid ) x
                           group by x.masterpatientid, x.patientid, x.indexdate ) y
                           where (mindiff <-90 OR mindiff >6 OR mindiff is NULL) )
     ), 
     
     
     encounter as (select patientid, encounterdate, encounterid, encountertype
                  from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"),
                  
     covid_diagnosis as (
       select patientid, dxdate,ENCOUNTERID, PDX, NULL as resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode IN ('U07.1','J12.82','441590008','674814021000119000') 
---- Didn't use Z86.16 & U09.9 as mentioned in valueset file
  UNION ALL 
  select patientid , RESULTDATE AS dxdate,ENCOUNTERID, NULL as PDX, resultqual
             from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                        where LABLOINC IN ('94562-6','94563-4','94564-2','94565-9','94639-2','94640-0','94641-8','94660-8','94756-4','94757-2',
                                '94759-8','94760-6','94761-4','94763-0','94766-3','94767-1','94768-9','94822-4','94845-5','95125-1',
                                '95209-3','95406-5','95409-9','95411-5','95416-4','95424-8','95425-5','95542-7','95608-6','95609-4',
                                '95823-1','95824-9','95825-6','95970-0','95971-8','96091-4','96119-3','96120-1','96121-9','96122-7',
                                '96123-5','96448-6','96603-6','96752-1','96763-8','96765-3','96797-6','96829-7','96957-6','96958-4',
                                '96986-5','97097-0','97098-8','98069-8','98131-6','98132-4','98493-0','98494-8','99596-9','99597-7',
                                '99772-6','94762-2','94307-6','94308-4','94309-2','94314-2','94316-7','94500-6','94507-1','94508-9',
                                '94533-7','94534-5','94547-7','94558-4','94559-2') AND resultqual = 'ABNORMAL' )
                                
                                
      select distinct masterpatientid from prep
      inner join encounter
      on encounter.patientid = prep.patientid
      inner join covid_diagnosis
      on covid_diagnosis.patientid = prep.patientid
      where encounterdate > ((indexdate)+6) AND encounterdate <= ((indexdate)+180) AND encounterdate is not null