  #Sub-cohort: EVUSHELD as Pre-exposure Prophylaxis (PrEP)

select distinct masterpatientid from (
select y.masterpatientid, y.mindiff from (
select x.masterpatientid, x.patientid, MIN(x.diff) as mindiff from (
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
                                '94533-7','94534-5','94547-7','94558-4','94559-2')) cov_pat
                           on inclusion_both.patientid = cov_pat.patientid ) x
                           group by x.masterpatientid, x.patientid ) y
                           where (mindiff <-90 OR mindiff >6 OR mindiff is NULL) )
                           
                           
                           
                           
###Sub-cohort: EVUSHELD as TREATMENT -  7 DAYS

select distinct masterpatientid from (
select y.masterpatientid, y.mindiff from (
select x.masterpatientid, x.patientid, MIN(x.diff) as mindiff from (
select inclusion_both.masterpatientid, inclusion_both.patientid, inclusion_both.indexdate, cov_pat.dxdate,
DATEDIFF(days, indexdate, dxdate) as diff from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () 
 over (partition by masterpatientid order by indexdate ASC) as row1 from
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
   ) evu_age where row1=1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
inner join  (select patientid, dxdate
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
                                '94533-7','94534-5','94547-7','94558-4','94559-2')) cov_pat
                           on inclusion_both.patientid = cov_pat.patientid ) x
                           group by x.masterpatientid, x.patientid ) y
                           where (mindiff >=-7 AND mindiff <=0) )
                           
                           
                           
###Sub-cohort: EVUSHELD as TREATMENT -  14 DAYS

select distinct masterpatientid from (
select y.masterpatientid, y.mindiff from (
select x.masterpatientid, x.patientid, MIN(x.diff) as mindiff from (
select inclusion_both.masterpatientid, inclusion_both.patientid, inclusion_both.indexdate, cov_pat.dxdate,
DATEDIFF(days, indexdate, dxdate) as diff from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () 
 over (partition by masterpatientid order by indexdate ASC) as row1 from
(SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId
--LEFT JOIN "DEID_PLATFORM"."GRATICULESOW3"."VW_DEID_PATIENTS" p2 ON p2.PatientId = e.PatientId AND p2.DataOwnerId = e.DataOwnerId
WHERE (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))
--AND (e.PatientId IS NULL OR p2.masterpatientid = p.masterpatientid)
 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId, orderdate as indexdate, p.patientid, p.BIRTHDATE
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
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
WHERE (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
 ) evu_exp
   ) evu_age where row1=1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
inner join  (select patientid, dxdate
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
                                '94533-7','94534-5','94547-7','94558-4','94559-2')) cov_pat
                           on inclusion_both.patientid = cov_pat.patientid ) x
                           group by x.masterpatientid, x.patientid ) y
                           where (mindiff >=-14 AND mindiff <=0) )
                           
                           
                           
###Sub-cohort: EVUSHELD as Post-exposure Prophylaxis (PEP)

select distinct masterpatientid from (
select y.masterpatientid, y.mindiff from (
select x.masterpatientid, x.patientid, MIN(x.diff) as mindiff from (
select inclusion_both.masterpatientid, inclusion_both.patientid, inclusion_both.indexdate, cov_pat.dxdate,
DATEDIFF(days, indexdate, dxdate) as diff from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () 
 over (partition by masterpatientid order by indexdate ASC) as row1 from
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
   ) evu_age where row1=1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
inner join  (select patientid, dxdate
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
                                '94533-7','94534-5','94547-7','94558-4','94559-2')) cov_pat
                           on inclusion_both.patientid = cov_pat.patientid ) x
                           group by x.masterpatientid, x.patientid ) y
                           where (mindiff >=1 AND mindiff <=6) )
                           
                           
                           
## Sub-cohort: EVUSHELD exposure unclassified


select distinct masterpatientid from (
select y.masterpatientid, y.mindiff from (
select x.masterpatientid, x.patientid, MIN(x.diff) as mindiff from (
select inclusion_both.masterpatientid, inclusion_both.patientid, inclusion_both.indexdate, cov_pat.dxdate,
DATEDIFF(days, indexdate, dxdate) as diff from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate from (
select aa.masterpatientid, aa.patientid,aa.age, aa.indexdate from (
select evu_age.masterpatientid, evu_age.patientid,evu_age.indexdate, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () 
 over (partition by masterpatientid order by indexdate ASC) as row1 from
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
   ) evu_age where row1=1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
inner join  (select patientid, dxdate
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
                                '94533-7','94534-5','94547-7','94558-4','94559-2')) cov_pat
                           on inclusion_both.patientid = cov_pat.patientid ) x
                           group by x.masterpatientid, x.patientid ) y
                           where (mindiff >=-90 AND mindiff <=-15) )