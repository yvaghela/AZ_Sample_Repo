##CREATE OR REPLACE TEMPORARY TABLE Evusheld_Patients(DataOwnerId TEXT, MasterPatientId TEXT);

SELECT MASTERPATIENTID FROM (
SELECT pr.DataOwnerId, 
p.MasterPatientId
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE  (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId
--LEFT JOIN "DEID_PLATFORM"."GRATICULESOW3"."VW_DEID_PATIENTS" p2 ON p2.PatientId = e.PatientId AND p2.DataOwnerId = e.DataOwnerId
WHERE (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))
--AND (e.PatientId IS NULL OR p2.masterpatientid = p.masterpatientid)
 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE  (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))

---unique MASTERAPTIENTID


select distinct masterpatientid from (
SELECT  
p.MasterPatientId, pxdate as indexdate, p.dataownerid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON  pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON  pr.EncounterId = e.EncounterId
WHERE COALESCE(pr.PxDate, e.EncounterDate, e.AdmitDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT 
p.MasterPatientId, SERVICEDATE as indexdate, p.dataownerid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON  b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON  b.EncounterId = e.EncounterId
--LEFT JOIN "DEID_PLATFORM"."GRATICULESOW3"."VW_DEID_PATIENTS" p2 ON p2.PatientId = e.PatientId AND p2.DataOwnerId = e.DataOwnerId
WHERE COALESCE(b.ServiceDate, e.EncounterDate, e.AdmitDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))
--AND (e.PatientId IS NULL OR p2.masterpatientid = p.masterpatientid)
 
UNION

SELECT 
p.MasterPatientId, orderdate as indexdate, p.dataownerid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON  mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON  mo.EncounterId = e.EncounterId
WHERE COALESCE(mo.OrderDate, e.AdmitDate, e.EncounterDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT 
p.MasterPatientId, FILLEDDATE as indexdate, p.dataownerid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT 
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate,p.dataownerid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON  ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON  ma.EncounterId = e.EncounterId
WHERE COALESCE(ma.MedAdminStartDate, e.AdmitDate, e.EncounterDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
                                  ) where indexdate is NOT null
and  dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11','5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b','6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3','86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901','c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
                                 
                                  
                                  
                                  
                                  
                                  
_________________________________________________________________________________________________________________________________________________________--


## Total number of EVUSHELD exposures as defined in the protocol

select distinct masterpatientid,indexdate from (
SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE COALESCE(pr.PxDate, e.EncounterDate, e.AdmitDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate
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
p.MasterPatientId, orderdate as indexdate
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE COALESCE(mo.OrderDate, e.AdmitDate, e.EncounterDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE COALESCE(ma.MedAdminStartDate, e.AdmitDate, e.EncounterDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
  )
 where indexdate is not null
 
 
 ## Total number of EVUSHELD exposures after revised EUA authorization (600 mg initial dose)
 
 select distinct masterpatientid from (
SELECT pr.DataOwnerId, 
p.MasterPatientId, pxdate as indexdate
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE COALESCE(pr.PxDate, e.EncounterDate, e.AdmitDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId, SERVICEDATE as indexdate
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
p.MasterPatientId, orderdate as indexdate
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE COALESCE(mo.OrderDate, e.AdmitDate, e.EncounterDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId, FILLEDDATE as indexdate
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId, medadminstartdate as indexdate
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE COALESCE(ma.MedAdminStartDate, e.AdmitDate, e.EncounterDate, e.DischargeDate) BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
  )
  where indexdate > '2022-02-24'
  
  
  
  
#Find age of patients

select distinct masterpatientid from (
select evu_age.masterpatientid, evu_age.patientid, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age, row1 from
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
 ) evu_exp where indexdate is not null
   ) evu_age where row1 = 1 AND age is not NULL
    ) 




#Distinct person aged >=12

select distinct masterpatientid from (
select evu_age.masterpatientid, evu_age.patientid, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
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
 ) evu_exp where indexdate is not null
   ) evu_age where row1 =1 AND age is NOT NULL)
   where age >=12 
   
   
   
## Inclusion 3: Actively receiving care for ≥ 12 months* prior to index date


select distinct masterpatientid,indexdate from (
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
      
             
 _____________________________________________________________________________________________________________________
 
## age <12 
 
select distinct masterpatientid from (
select evu_age.masterpatientid, evu_age.patientid, DATEDIFF(year, evu_age.birthdate,evu_age.indexdate) as Age from
(select evu_exp.masterpatientid, evu_exp.patientid, evu_exp.BIRTHDATE ,evu_exp.indexdate, row_number () over 
 (partition by masterpatientid order by indexdate ASC) as row1 from
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

WHERE (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
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
 ) evu_exp where indexdate is not null
   ) evu_age where row1 =1 AND age is NOT NULL)
   where age <12 
   
   
   
 ____________________________________________________________________________________
 
 ## inclusion criteria excluding
 
 select distinct masterpatientid from (
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
WHERE (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
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
             where (encounterdate <= ((indexdate)-365) OR encounterdate > indexdate AND encounterdate is not null)
             
             
             
___________________________________________________________________________________________________________________________________________________________


## Total number of EVUSHELD exposed patients with immunocompromised conditions

select distinct a.masterpatientid from (
  select masterpatientid, patientid from
  (SELECT pr.DataOwnerId, 
p.MasterPatientId, p.patientid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES" pr
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON pr.DataOwnerId = p.DataOwnerId AND pr.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON pr.DataOwnerId = e.DataOwnerId AND pr.EncounterId = e.EncounterId
WHERE (pr.SourcePxCodeDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR pr.PxCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

UNION
 
SELECT b.DataOwnerId,
p.MasterPatientId,p.patientid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_BILLINGS" b ON p.DataOwnerId = b.DataOwnerId AND b.PatientId = p.PatientId 
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON b.DataOwnerId = e.DataOwnerId AND b.EncounterId = e.EncounterId

WHERE (b.BillingProcedureDescription ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%') OR b.MedicationName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR b.BillingProcedureCode ILIKE ANY ('Q0220','Q0221','M0220','M0221'))

 
UNION

SELECT mo.DataOwnerId AS DataOwnerId,
p.MasterPatientId,p.patientid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS" mo
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mo.DataOwnerId = p.DataOwnerId AND mo.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON mo.DataOwnerId = e.DataOwnerId AND mo.EncounterId = e.EncounterId
WHERE (mo.SourceRxMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR (mo.SourceRxCodeType = 'NDC' AND REPLACE(mo.SourceRxCode, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                                                            , '00310744202','00310889501','00310106101','00310886102')))

UNION

SELECT mf.DataOwnerId AS DataOwnerId,
p.MasterPatientId,p.patientid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS" mf
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON mf.DataOwnerId = p.DataOwnerId AND mf.PatientId = p.PatientId
WHERE mf.FilledDate BETWEEN TO_DATE('01/01/2020') AND TO_DATE('12/31/2022')
AND (mf.SourceDrugName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(mf.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'
                                  ))
UNION

SELECT ma.DataOwnerId AS DataOwnerId,
p.MasterPatientId AS MasterPatientId,p.patientid
FROM "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS" ma
INNER JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS" p ON ma.DataOwnerId = p.DataOwnerId AND ma.PatientId = p.PatientId
LEFT JOIN "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" e ON ma.DataOwnerId = e.DataOwnerId AND ma.EncounterId = e.EncounterId
WHERE (ma.SourceMedAdminMedName ILIKE ANY ('%Evusheld%', '%Tixagevimab%', '%Cilgavimab%', '%tixagev%', '%cilgav%')
OR REPLACE(ma.NDC, '-') ILIKE ANY ('0310744202','0310889501','0310106101','0310886102'
                                  , '00310744202','00310889501','00310106101','00310886102'))
) ) a
inner join (
           (Select patientid from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
 
  ---solid organ or islet transplant
           where dxcode IN ('C80.2','I25.750','I25.751','I25.758','I25.759','I25.760','I25.761','I25.768','I25.769','I25.811',
                            'I25.812','M31.11','T86.10','T86.11','T86.12','T86.13','T86.19','T86.20','T86.21','T86.22','T86.23',
                            'T86.290','T86.298','T86.30','T86.31','T86.32','T86.33','T86.39','T86.40','T86.41','T86.42','T86.43',
                            'T86.49','T86.810','T86.811','T86.812','T86.818','T86.819','T86.8401','T86.8402','T86.8403','T86.8409',
                            'T86.8411','T86.8412','T86.8413','T86.8419','T86.8421','T86.8422','T86.8423','T86.8429','T86.8481',
                            'T86.8482','T86.8483','T86.8489','T86.8491','T86.8492','T86.8493','T86.8499','T86.850','T86.851',
                            'T86.852','T86.858','T86.859','T86.890','T86.891','T86.892','T86.898','T86.899','T86.90','T86.91',
                            'T86.92','T86.93','T86.99','Y83.0','Z48.21','Z48.22','Z48.23','Z48.24','Z48.280','Z48.288','Z48.298',
                            'Z94.0','Z94.1','Z94.2','Z94.3','Z94.4','Z94.5','Z94.6','Z94.7','Z94.82','Z94.83','Z94.89','Z94.9','Z98.85')
   -----Receipt of chimeric antigen receptor T-cell (CAR-T) or hematopoietic stem cell transplant (HSCT)
              OR dxcode IN ('Z52.001','Z52.011','Z52.091','Z94.84')
   -----Moderate or severe primary immunodeficiency
              OR dxcode IN ('D80.0','D80.1','D80.2','D80.3','D80.4','D80.5','D80.6','D80.7','D80.8','D80.9','D81.0','D81.1',
                            'D81.2','D81.30','D81.31','D81.32','D81.39','D81.4','D81.5','D81.6','D81.7','D81.810','D81.818','D81.819',
                            'D81.89','D81.9','D82.0','D82.1','D82.2','D82.3','D82.4','D82.8','D82.9','D83.0','D83.1','D83.2','D83.8','D83.9',
                            'D84.0','D84.1','D84.81','D84.821','D84.822','D84.89','D84.9')
  ------Advanced or untreated human immunodeficiency virus (HIV) infection
              OR dxcode IN ('B20','B97.35','O98.7','O98.71','O98.711','O98.712','O98.713','O98.719','O98.72','O98.73','Z21','65758-5')
  ----ESRD or dialysis treatment
             OR dxcode IN ('I12.0','I13.11','I13.2','N18.6','Z49.01','Z49.02','Z49.31','Z49.32','Z99.2')
  -----Solid tumors or hematological malignancies on treatment
             OR dxcode IN ('C00.0','C00.1','C70','C70.1','C70.9','C71.0','C71','C71.1','C71.2','C71.3','C71.4','C71.5','C71.6','C71.7','C71.8',
                           'C71.9','C72.0','C72.1','C72.20','C72.2','C72.21','C72.22','C72.30','C72.3','C72.31','C72.32','C72.40','C72.4','C72.41',
                           'C72.42','C72.50','C72.5','C72.59','C72.9','C00','C00.2','C00.3','C00.4','C00.5','C00.6','C00.8','C00.9','C02.0',
                           'C02.1','C01','C02','C02.2','C02.4','C02.8','C70.0','C03.0','C03.1','C03.9','C04.8','C04.9','C04','C05.0','C05.1','C05.2',
                           'C05','C05.8','C05.9','C06.0','C06.1','C06.2','C06','C06.80','C06.89','C06.9','C08.0','C08.1','C08.9','C07','C08',
                           'C09.0','C09.1','C09.8','C09','C09.9','C10.0','C10.1','C10.2','C10','C10.3','C10.4','C10.8','C10.9','C11.0','C11.1',
                           'C11.2','C11','C11.3','C11.8','C11.9','C13.0','C13.1','C13.2','C12','C13','C13.8','C13.9','C14.0','C14.2','C14.8','C15.3',
                           'C15.4','C15.5','C15','C15.8','C15.9','C16.0','C16.1','C16.2','C16','C16.3','C16.4','C16.5','C16.8','C16.9','C17.0','C17.1',
                           'C17.2','C17','C03','C18.0','C18.1','C18.2','C18','C18.3','C18.4','C18.5','C18.6','C18.7','C18.8','C18.9','C21.0','C21.1',
                           'C21.2','C19','C20','C21','C22.0','C22.1','C22.2','C22.3','C22','C22.4','C22.7','C22.9','C24.0','C24.1','C24.8','C24.9',
                           'C23','C24','C25.0','C25.1','C25.2','C25.3','C25','C25.4','C25.7','C25.8','C25.9','C26.0','C26.1','C26.9','C30.0','C26',
                           'C30.1','C31.0','C31.1','C30','C31.2','C31.3','C31','C31.9','C32.0','C32.1','C32.2','C32.3','C32','C32.8','C32.9','C34.00',
                           'C34.01','C34.02','C34.10','C33','C34','C34.0','C34.11','C34.12','C34.2','C34.1','C34.30','C34.31','C34.32','C34.3',
                           'C34.8','C34.91','C34.9','C34.92','C38.0','C37','C38','C38.1','C38.2','C38.3','C38.4','C38.8','C39.0','C39','C39.9',
                           'C40.00','C40','C40.0','C40.01','C40.02','C40.10','C40.1','C40.11','C40.12','C40.20','C40.2','C40.21','C40.22','C40.30',
                           'C40.3','C40.31','C40.32','C40.80','C40.81','C40.82','C40.90','C40.9','C40.91','C40.92','C41.0','C41','C41.1','C41.2',
                           'C41.3','C41.4','C41.9','C43.0','C43','C43.10','C43.1','C43.11','C43.111','C43.112','C43.12','C43.121','C43.122','C43.20',
                           'C43.2','C43.21','C43.22','C43.30','C43.3','C43.31','C43.39','C43.4','C43.51','C43.5','C43.52','C43.62','C43.70','C43.71',
                           'C43.72','C43.7','C43.8','C43.9','C45.0','C45.1','C45.2','C45','C45.7','C45.9','C46.0','C46.1','C46.2','C46','C46.3','C46.4',
                           'C46.50','C46.51','C46.52','C46.5','C46.7','C46.9','C47.10','C47.11','C47.12','C47','C47.20','C47.21','C47.22','C47.3','C47.2',
                           'C47.4','C47.5','C47.6','C47.8','C47.9','C48.0','C48.1','C48.2','C48.8','C48','C49.0','C49.10','C49.11','C49.12','C49',
                           'C49.20','C49.1','C49.21','C49.22','C49.3','C49.2','C49.4','C49.5','C49.6','C49.8','C49.9','C49.A0','C49.A1','C49.A2',
                           'C49.A4','C49.A','C49.A5','C43.6','C4A.10','C4A.11','C4A.111','C4A.112','C4A.12','C4A.121','C4A.122','C4A.20','C4A.21',
                           'C4A.22','C4A.30','C4A.2','C4A.31','C4A.39','C4A.4','C4A.3','C4A.51','C4A.52','C4A.59','C4A.60','C4A.5','C4A.61','C4A.62',
                           'C4A.71','C4A.72','C4A.8','C4A.9','C4A.7','C50.011','C50.012','C50.019','C50.021','C50.022','C50','C50.0','C50.01','C50.029',
                           'C50.111','C50.112','C50.02','C50.119','C50.121','C50.122','C50.1','C50.11','C50.211','C50.212','C50.219','C50.12',
                           'C50.221','C50.222','C50.2','C50.21','C50.229','C50.311','C50.312','C50.22','C50.319','C50.321','C50.322','C50.3','C50.31',
                           'C50.329','C57.02','C50.32','C4A','C50.412','C50.419','C50.421','C50.422','C50.42','C50.429','C50.511','C50.512','C50.5',
                           'C50.51','C50.519','C50.521','C50.522','C50.52','C50.529','C50.611','C50.612','C50.6','C50.61','C50.621','C50.622','C50.62',
                           'C50.629','C50.811','C50.812','C50.8','C50.81','C50.819','C50.821','C50.822','C50.82','C50.829','C50.911','C50.912','C50.9',
                           'C50.91','C50.919','C50.921','C50.922','C50.92','C50.929','C51.0','C51.1','C51','C51.2','C51.8','C51.9','C53.0','C53.1',
                           'C52','C53','C53.9','C54.0','C54.1','C54','C54.2','C54.3','C54.8','C54.9','C56.1','C56.2','C55','C56','C56.9','C57.00',
                           'C57.01','C57','C57.0','C50.41','C57.12','C57.21','C57.2','C57.22','C57.3','C57.4','C57.7','C57.8','C57.9','C60.0','C58',
                           'C60','C60.1','C60.2','C60.8','C60.9','C62.00','C57.10','C62','C62.0','C62.01','C62.02','C62.10','C62.1','C62.11','C62.12',
                           'C62.92','C63.00','C63.01','C63','C63.0','C63.02','C63.10','C63.11','C63.1','C63.12','C63.2','C63.7','C63.8','C63.9',
                           'C64.1','C64.2','C64','C64.9','C65.1','C65.2','C65','C65.9','C66.1','C66.2','C66','C66.9','C67.0','C67.1','C67','C67.2',
                           'C67.3','C67.5','C67.6','C67.7','C67.8','C67.9','C68.0','C68.1','C68','C68.8','C68.9','C69.00','C69.01','C69','C69.0',
                           'C69.02','C57.11','C69.12','C69.20','C69.21','C69.22','C69.30','C69.2','C69.31','C69.32','C69.40','C69.3','C69.41','C69.42',
                           'C69.50','C69.4','C69.51','C69.52','C69.60','C69.5','C69.61','C69.62','C69.81','C69.6','C69.82','C69.90','C69.91','C69.92',
                           'C74.00','C74.01','C69.9','C74.02','C74.10','C74.11','C73','C74','C74.0','C74.12','C74.90','C74.91','C74.1','C74.92',
                           'C75.0','C75.1','C74.9','C75.2','C75.3','C75.4','C75','C75.8','C75.9','C76.0','C76.1','C76.2','C76.3','C76.40','C76',
                           'C76.41','C76.42','C76.50','C76.51','C76.4','C76.52','C76.8','C7A.00','C76.5','C7A.010','C7A.011','C7A.012','C7A.020','C7A',
                           'C7A.0','C7A.01','C7A.02','C69.1','C7A.025','C7A.026','C7A.090','C7A.091','C7A.09','C7A.092','C7A.093','C7A.094','C7A.095',
                           'C7A.096','C7A.098','C7A.1','C7A.8','C80.0','C80.1','C80','C80.2','C7A.023','C7A.024','C81.01','C81.02','C81.03','C81',
                           'C81.04','C81.05','C81.06','C81.07','C81.08','C81.09','C81.10','C81.11','C81.12','C81.13','C81.1','C81.14','C81.16','C81.17',
                           'C81.18','C81.19','C81.20','C81.21','C81.22','C81.23','C81.2','C81.24','C81.25','C81.26','C81.27','C81.28','C81.29','C81.30',
                           'C81.31','C81.32','C81.33','C81.3','C81.34','C81.35','C81.36','C81.37','C81.38','C81.39','C81.40','C81.41','C81.42','C81.43',
                           'C81.4','C81.44','C81.45','C81.46','C81.70','C81.71','C81.72','C81.7','C81.73','C81.74','C81.75','C81.76','C81.77','C81.78',
                           'C81.79','C81.90','C81.91','C81.92','C81.9','C81.93','C81.94','C81.95','C81.96','C81.97','C81.98','C81.99','C82.00','C82.02',
                           'C82.03','C82','C82.0','C82.04','C82.05','C82.06','C82.07','C82.08','C82.09','C82.10','C82.11','C82.12','C82.1','C82.13',
                           'C82.14','C82.15','C82.16','C82.17','C82.18','C82.19','C82.20','C82.22','C82.23','C82.2','C82.25','C82.26','C82.27','C82.28',
                           'C82.29','C82.30','C82.31','C82.32','C82.33','C82.3','C82.34','C82.35','C82.36','C82.37','C82.38','C82.39','C82.40','C82.4',
                           'C82.43','C82.45','C82.46','C82.47','C82.48','C82.49','C82.50','C82.51','C82.52','C82.53','C82.5','C82.54','C82.55','C82.56',
                           'C82.57','C82.58','C82.59','C82.60','C82.61','C82.62','C82.63','C82.6','C82.65','C82.66','C82.67','C82.68','C82.69','C82.80',
                           'C82.81','C82.82','C82.83','C82.8','C82.84','C82.85','C82.86','C82.87','C82.88','C82.89','C82.90','C82.91','C82.92','C82.93',
                           'C82.9','C82.94','C82.95','C82.96','C82.97','C82.98','C82.99','C83.00','C83.01','C83.02','C83.03','C83','C83.0','C83.05',
                           'C83.06','C83.07','C83.08','C83.09','C83.10','C83.11','C83.12','C83.13','C83.1','C83.15','C83.16','C83.17','C83.18',
                           'C83.19','C83.30','C83.3','C83.31','C83.32','C83.33','C83.34','C83.36','C83.37','C83.38','C83.50','C83.51','C83.5','C83.52',
                           'C83.54','C83.57','C83.58','C83.59','C83.70','C83.71','C83.7','C83.72','C83.73','C83.74','C83.75','C83.76','C83.77','C83.78',
                           'C83.79','C83.80','C83.81','C83.8','C83.82','C83.83','C83.84','C83.85','C83.86','C83.87','C83.88','C83.89','C83.90','C83.91',
                           'C83.9','C83.92','C83.93','C83.94','C83.95','C83.96','C83.97','C83.98','C83.99','C84.00','C84.01','C84','C84.0','C84.02',
                           'C84.03','C84.04','C84.05','C84.06','C84.07','C84.08','C84.10','C84.11','C84.1','C84.12','C84.13','C84.16','C84.17',
                           'C84.18','C84.19','C84.40','C84.41','C84.42','C84.4','C84.43','C84.44','C84.45','C84.46','C84.47','C84.48','C84.49',
                           'C84.60','C84.62','C84.63','C84.6','C84.64','C84.65','C84.66','C84.67','C84.68','C84.69','C84.70','C84.71','C84.72',
                           'C84.7','C84.73','C84.74','C84.75','C84.76','C84.77','C84.78','C84.79','C84.90','C84.91','C84.92','C84.9','C84.93',
                           'C84.94','C84.95','C84.96','C84.97','C84.98','C84.99','C84.A0','C84.A1','C84.A2','C84.A','C84.A3','C84.A4','C84.A6',
                           'C84.A7','C84.A8','C84.A9','C84.Z2','C84.Z3','C84.Z4','C84.Z','C84.Z5','C84.Z6','C84.Z7','C84.Z8','C84.Z9','C85.10','C85.11',
                           'C85.12','C85.13','C85','C85.1','C85.14','C85.16','C85.17','C85.18','C85.19','C85.20','C85.21','C85.22','C85.23','C85.2',
                           'C85.24','C85.25','C85.26','C85.27','C85.28','C85.29','C85.80','C85.81','C85.82','C85.83','C85.8','C85.84','C85.85','C85.86',
                           'C85.87','C85.88','C85.89','C85.90','C85.91','C85.92','C85.93','C85.9','C85.94','C85.96','C85.97','C85.98','C85.99','C86.0',
                           'C86.1','C86.2','C86.3','C86','C86.4','C86.5','C86.6','C88.2','C88.3','C88','C88.0','C90.01','C90.02','C90.11','C90','C90.0',
                           'C90.12','C90.20','C90.21','C90.1','C90.22','C90.30','C90.31','C90.2','C90.32','C91.00','C91.01','C90.3','C91.02','C91.11',
                           'C91.12','C91','C91.0','C91.30','C91.31','C91.32','C91.1','C91.40','C91.41','C91.3','C91.42','C91.50','C91.51','C91.4',
                           'C91.52','C91.60','C91.61','C91.5','C91.62','C91.90','C91.91','C91.6','C91.92','C91.A0','C91.A1','C91.9','C91.A2','C91.Z0',
                           'C91.Z1','C91.A','C91.Z2','C92.01','C92.02','C91.Z','C92.10','C92.11','C92.12','C92','C92.0','C92.20','C92.21','C92.1',
                           'C92.22','C92.30','C92.31','C92.2','C92.32','C92.40','C92.41','C92.3','C92.42','C92.50','C92.51','C92.4','C92.5','C92.62',
                           'C92.6','C92.90','C92.91','C92.9','C92.92','C92.A1','C92.A2','C92.A','C92.Z0','C92.Z1','C92.Z2','C92.Z','C93.00','C93.01',
                           'C93.02','C93','C93.0','C93.10','C93.11','C93.12','C93.1','C93.30','C93.31','C93.32','C93.3','C93.90','C93.91','C93.92',
                           'C93.9','C93.Z0','C93.Z1','C93.Z2','C93.Z','C94.01','C94.02','C94.20','C94','C94.0','C94.21','C94.22','C94.2','C94.30',
                           'C94.31','C94.32','C94.3','C94.40','C94.41','C94.42','C94.4','C94.6','C94.80','C94.81','C94.82','C94.8','C95.00','C95.01',
                           'C95.02','C95','C95.0','C95.11','C95.12','C95.90','C95.1','C95.91','C95.92','C95.9','C96.0','C96.20','C96.21','C96','C96.22',
                           'C96.2','C02.9','C81.0','C96.5','C96.6','C96.A','C96.Z','C72','C04.0','C17.3','C06.8','C14','C22.8','C31.8','C34.80',
                           'C34.90','C43.59','C43.60','C40.8','C49.A3','C49.A9','C47.1','C50.129','C50.619','C4A.1','C4A.6','C53.8','C50.4','C57.20',
                           'C67.4','C57.1','C69.10','C75.5','C69.8','C7A.021','C7A.022','C81.15','C7A.019','C81.47','C81.48','C82.01','C82.24',
                           'C82.41','C82.64','C83.04','C83.14','C83.39','C83.53','C83.55','C83.56','C84.09','C84.14','C84.61','C96.4','C62.9','C62.90',
                           'C84.Z0','C85.15','C85.95','C88.8','C88.9','C91.10','C92.00','C92.52','C92.60','C94.00','C95.10','C96.29','C96.9','C61',
                           'C56.3','C84.7A','D45','C02.3','C04.1','C16.6','C17.8','C17.9','C21.8','C34.81','C34.82','C43.61','C47.0','C4A.0','C4A.70',
                           'C50.411','C62.91','C69.11','C69.80','C7A.029','C81.00','C81.49','C82.21','C82.42','C82.44','C83.35','C84.15','C84.A5',
                           'C84.Z1','C88.4','C90.00','C90.10','C92.61','C92.A0',
                          'C79.63','C77','C77.0','C77.1','C77.2','C77.3','C77.4','C77.5','C77.8','C77.9','C78','C78.0','C78.00','C78.01','C78.02',
                           'C78.1','C78.2','C78.3','C78.30','C78.39','C78.4','C78.5','C78.6','C78.7','C78.8','C78.80','C78.89','C79','C79.0','C79.00',
                           'C79.01','C79.02','C79.1','C79.10','C79.11','C79.19','C79.2','C79.3','C79.31','C79.32','C79.4','C79.40','C79.49','C79.5',
                           'C79.51','C79.52','C79.6','C79.60','C79.61','C79.62','C79.7','C79.70','C79.71','C79.72','C79.8','C79.81','C79.82','C79.89',
                           'C79.9','C7B','C7B.0','C7B.00','C7B.01','C7B.02','C7B.03','C7B.04','C7B.09','C7B.1','C7B.8')
)
  UNION ALL
  
           (select patientid from "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES"
  
     ---solid organ or islet transplant
          where pxcode IN ('0055U','0087U','0088U','0141T','0142T','0143T','0584T','0585T','0586T','23440',
                           '29868','32851','32852','32853','32854','33927','33929','33935','33945','38240',
                           '38241','38242','38243','43625','44135','44136','44137','47135','47136','48160','48554','48556','50340',
                           '50360','50365','50366','50370','50380','60510','60512','65710','65720','65725','65730','65740','65745',
                           '65750','65755','65756','65767','65780','65781','65782','76776','76778','81595','G0341','G0342','G0343',
                           'G8727','S2052','S2053','S2054','S2060','S2065','S2102','S2103','S2109','S2142','S2150','S2152','02Y','02YA',
                           '02YA0Z0','02YA0Z1','02YA0Z2','07Y','07YM','07YM0Z0','07YM0Z1','07YM0Z2','07YP','07YP0Z0','07YP0Z1','07YP0Z2',
                           '0BY','0BYC','0BYC0Z0','0BYC0Z1','0BYC0Z2','0BYD','0BYD0Z0','0BYD0Z1','0BYD0Z2','0BYF','0BYF0Z0','0BYF0Z1','0BYF0Z2',
                           '0BYG','0BYG0Z0','0BYG0Z1','0BYG0Z2','0BYH','0BYH0Z0','0BYH0Z1','0BYH0Z2','0BYJ','0BYJ0Z0','0BYJ0Z1','0BYJ0Z2','0BYK',
                           '0BYK0Z0','0BYK0Z1','0BYK0Z2','0BYL','0BYL0Z0','0BYL0Z1','0BYL0Z2','0BYM','0BYM0Z0','0BYM0Z1','0BYM0Z2','0DY','0DY5',
                           '0DY50Z0','0DY50Z1','0DY50Z2','0DY6','0DY60Z0','0DY60Z1','0DY60Z2','0DY8','0DY80Z0','0DY80Z1','0DY80Z2','0DYE','0DYE0Z0',
                           '0DYE0Z1','0DYE0Z2','0FY','0FY0','0FY00Z0','0FY00Z1','0FY00Z2','0FYG','0FYG0Z0','0FYG0Z1','0FYG0Z2','0TY','0TY0','0TY00Z0',
                           '0TY00Z1','0TY00Z2','0TY1','0TY10Z0','0TY10Z1','0TY10Z2','0UY','0UY0','0UY00Z0','0UY00Z1','0UY00Z2','0UY1','0UY10Z0',
                           '0UY10Z1','0UY10Z2','0UY9','0UY90Z0','0UY90Z1','0UY90Z2','0WY','0WY2','0WY20Z0','0WY20Z1','0XY','0XYJ','0XYJ0Z0',
                           '0XYJ0Z1','0XYK','0XYK0Z0','0XYK0Z1')

    -----Receipt of chimeric antigen receptor T-cell (CAR-T) or hematopoietic stem cell transplant (HSCT)
              OR pxcode IN ('Q2040','C9073','Q2053','C9076','Q2054','C9081','Q2055','C9098','Q2056','0540T','Q2041','Q2042',
                           'S2150','38204','38205','38206','38207','38208','38209','38210','38211','38212','38213','38214',
                            '38215','38231','38240','38241','38242','38243','65781','81267','81268','86367','86587','86915','0564T',
                            'G0267','30230AZ','30230U2','30230U3','30230U4','30230X0','30230X1','30230X2','30230X3','30230X4','30230Y0',
                            '30230Y1','30230Y2','30230Y3','30230Y4','30233AZ','30233U2','30233U3','30233U4','30233X0','30233X1','30233X2',
                            '30233X3','30233X4','30233Y0','30233Y1','30233Y2','30233Y3','30233Y4','30240AZ','30240U2','30240U3','30240U4',
                            '30240X0','30240X1','30240X2','30240X3','30240X4','30240Y0','30240Y1','30240Y2','30240Y3','30240Y4','30243AZ',
                            '30243U2','30243U3','30243U4','30243X0','30243X1','30243X2','30243X3','30243X4','30243Y0','30243Y1','30243Y2',
                            '30243Y3','30243Y4','30250X0','30250X1','30250Y0','30250Y1','30253X0','30253X1','30253Y0','30253Y1','30260X0',
                            '30260X1','30260Y0','30260Y1','30263X0','30263X1','30263Y0','30263Y1','3E0Q0AZ','3E0Q0E0','3E0Q0E1','3E0Q3AZ',
                            '3E0Q3E0','3E0Q3E1','3E0R0AZ','3E0R0E0','3E0R0E1','3E0R3AZ','3E0R3E0','3E0R3E1','6A550ZT','6A550ZV','6A551ZT','6A551ZV')
  ----ESRD or dialysis treatment
              OR pxcode IN ('G8727','0505F','0507F','36488','36489','36490','36491','36800','36810','36815','36838','36901','36902','36903',
                            '36904','36905','36906','36907','36908','36909','4052F','4053F','4054F','4055F','49418','49421','90935','90937',
                            '90939','90940','90941','90942','90943','90944','90945','90947','90963','90964','90965','90966','90967','90968',
                            '90969','90970','90976','90977','90978','90979','90982','90983','90984','90985','90988','90990','90991','90992',
                            '90994','90999','93985','93986','93990','99512','99559','A4653','A4680','A4690','A4706','A4707','A4708','A4709',
                            'A4714','A4719','A4720','A4721','A4722','A4723','A4724','A4725','A4726','A4730','A4740','A4750','A4755','A4760',
                            'A4765','A4766','A4801','A4802','A4820','A4860','A4870','A4890','A4900','A4901','A4905','A4918','C1750','C1752',
                            'E1520','E1530','E1540','E1550','E1560','E1575','E1580','E1590','E1592','E1594','E1600','E1610','E1615','E1620',
                            'E1625','E1630','E1634','E1636','E1638','E1640','G0365','G0392','G0393','G8081','G8082','G8085','G8714','G8715',
                            'G8956','G9239','G9240','G9241','G9264','G9265','G9266','G9523','K0610','S9335','S9339','B50W','B50W0ZZ','B50W1ZZ',
                            'B50WYZZ','B51W','B51W0ZA','B51W0ZZ','B51W1ZA','B51W1ZZ','B51WYZA','B51WYZZ','B51WZZA','B51WZZZ')
  -----Active treatment with high-dose corticosteroids, immunosuppressive or immunomodulatory therapy
              OR pxcode IN ('117055','1092437','1442981','712566','121191','1986808','1012892','5666','1876366','2288236','2532300',
                            '2121085','614391','1311600','327361','299635','5296','72435','2565265','1492727','1251','1256','2047232',
                            '196102','1112973','2564025','134547','1872251','1828','853491','194000','40048','2105','709271','2346','2555',
                            '44157','44151','3002','3008','3041','3098','190353','15657','1373478','2261783','591781','356988','2104604',
                            '214555','4132','141704','4488','24698','4492','12574','819300','1928588','5657','N.2.2.14786','2373951','191831',
                            '1745099','27169','342369','6466','1011','6674','6718','2531369','103','6851','6996','42405','68149','7145','354770',
                            '274771','2557372','68446','8347','1592254','1369713','662019','8637','196239','2107301','763450','2166040','1923319',
                            '2391541','1599788','1535218','35302','10114','2591404','42316','4582','37776','2274803','1310520','10432','10485',
                            '10473','2053436','612865','1357536','38508','38865','2196092','10996','847083','1538097','2475166')
  )
  UNION ALL
           
            (select patientid from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
            where LABLOINC = '65758-5')
  
  UNION ALL 
  
           (select patientid from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS"
           where (lower(sourcemedadminmedname) = 'DEXAMETHASONE' OR lower(sourcemedadminmedname) = 'BETAMETHASONE'
                 OR lower(sourcemedadminmedname) = 'BUDESONIDE' OR lower(sourcemedadminmedname) = 'CORTISONE'
                 OR lower(sourcemedadminmedname) = 'DEFLAZACORT' OR lower(sourcemedadminmedname) = 'HYDROCORTISONE'
                 OR lower(sourcemedadminmedname) = 'METHYLPREDNISOLONE' OR lower(sourcemedadminmedname) = 'PREDNISOLONE'
                 OR lower(sourcemedadminmedname) = 'PREDNISONE' OR lower(sourcemedadminmedname) = 'TRIAMCINOLONE')
  --------Solid tumors or hematological malignancies on treatment (Cancer therapies)
         OR ( lower(SOURCEMEDADMINMEDNAME) like	lower('%ABARELIX%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ABATACEPT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ABIRATERONE%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ADO%TRASTUZUMAB EMTANSINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AFATINIB%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AFLIBERCEPT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALDESLEUKIN%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALECTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%alemtuzumab%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALLOPURINOL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALTRETAMINE%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AMIFOSTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AMINOGLUTETHIMIDE%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ANASTROZOLE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ARSENIC%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ASPARAGINASE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ATEZOLIZUMAB%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AVELUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AXITINIB%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AZACITIDINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BCG VACCINE%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%belimumab%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BELINOSTAT%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BENDAMUSTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BEVACIZUMAB%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BEXAROTENE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BICALUTAMIDE%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BLEOMYCIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BLINATUMOMAB%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BORTEZOMIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BOSUTINIB%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BRENTUXIMAB%VEDOTIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BUSULFAN%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CABAZITAXEL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CABOZANTINIB%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CAPECITABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CARBOPLATIN%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CARFILZOMIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CARMUSTINE%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CERITINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CETUXIMAB%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CHLORAMBUCIL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CISPLATIN%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CLADRIBINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CLOFARABINE%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%COBIMETINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CRIZOTINIB%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CROMOLYN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CROMOLYN%SODIUM%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CYCLOPHOSPHAMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CYTARABINE%') OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DABRAFENIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DACARBAZINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DACTINOMYCIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DANAZOL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DARATUMUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DASATINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DAUNORUBICIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DECITABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DEGARELIX%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DENILEUKIN%DIFTITOX%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DENOSUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DEXAMETHASONE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DIETHYLSTILBESTROL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DIHEMATOPORPHYRIN%ETHER%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DINUTUXIMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DOCETAXEL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DOXORUBICIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DURVALUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ELOTUZUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ENZALUTAMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%EPIRUBICIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ERIBULIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ERLOTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ESTRADURIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ESTRAMUSTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ETOPOSIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%EVEROLIMUS%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%EXEMESTANE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%FLOXURIDINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%FLUDARABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%FLUOROURACIL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%FLUOXYMESTERONE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%FLUTAMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%FULVESTRANT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%GEFITINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%GEMCITABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%GEMTUZUMAB%OZOGAMICIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%GOSERELIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%HISTRELIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TALIMOGENE%LAHERPAREPVEC%') OR lower(SOURCEMEDADMINMEDNAME) like lower('%HUMAN%HERPESVIRUS%1%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%HYDROXYUREA%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IBRITUMOMAB%TIUXETAN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IBRUTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IDARUBICIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IDELALISIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IFOSFAMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IFOSFAMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%MESNA%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IMATINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%INTERFERON%ALFA%2A%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%INTERFERON%ALFA%2B%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%INTERFERON%ALFACON%1%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%INTERFERON%ALFA%N3%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%INTERFERON%BETA%1A%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%INTERFERON%BETA%1B%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%INTERFERON%GAMMA%1B%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IPILIMUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IRINOTECAN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IXABEPILONE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%IXAZOMIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%KETOCONAZOLE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LANREOTIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LAPATINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LENALIDOMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LENVATINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LETROZOLE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LEUCOVORIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LEUPROLIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LEVAMISOLE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LEVOLEUCOVORIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LOMUSTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%LONSURF%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%MECHLORETHAMINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%MEDROXYPROGESTERONE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%MEGESTROL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%MELPHALAN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%MERCAPTOPURINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%MESNA%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%METHOTREXATE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%METHOXSALEN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%MITOMYCIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%MITOTANE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%MITOXANTRONE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%NATALIZUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%NECITUMUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%NELARABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%NILOTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%NILUTAMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%NIRAPARIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%NIVOLUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%OBINUTUZUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%OCTREOTIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ofatumumab%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%OLAPARIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%OLARATUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%OMACETAXINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%OSIMERTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%OXALIPLATIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PACLITAXEL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PALBOCICLIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PAMIDRONATE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PANITUMUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PANOBINOSTAT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PAZOPANIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PEGASPARGASE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PEMBROLIZUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PEMETREXED%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PENTOSTATIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PERTUZUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PLICAMYCIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%POLYESTRADIOL%PHOSPHATE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%POMALIDOMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PONATINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PORFIMER%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PRALATREXATE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%PROCARBAZINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%RADIUM%CHLORIDE%RA%223%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%RALOXIFENE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%RAMUCIRUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%REGORAFENIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%RIBOCICLIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%rituximab%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ROMIDEPSIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%RUCAPARIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%RUXOLITINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%SAMARIUM%LEXIDRONAM%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%SIPULEUCEL%T%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%SONIDEGIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%SORAFENIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%STREPTOZOCIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%STRONTIUM%89%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%SUNITINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TAMOXIFEN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TEMOZOLOMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TEMSIROLIMUS%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TENIPOSIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TESTOLACTONE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%THALIDOMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%THIOGUANINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%THIOTEPA%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TIPIRACIL %') OR lower(SOURCEMEDADMINMEDNAME) like ('%TRIFLURIDINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TOPOTECAN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TOREMIFENE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TOSITUMOMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TRABECTEDIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TRAMETINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TRASTUZUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TRETINOIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%TRIPTORELIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%URACIL%5%FU%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VALRUBICIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VANDETANIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VEMURAFENIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VENETOCLAX%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VINBLASTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VINCRISTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VINORELBINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VISMODEGIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VORINOSTAT%') )
  )
  ) b on a.patientid = b.patientid  