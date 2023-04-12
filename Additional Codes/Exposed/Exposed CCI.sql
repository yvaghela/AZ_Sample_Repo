## Comorbidities UNION


select distinct masterpatientid, Condition_Name,age from (

------Diabetes with chronic complications

select distinct masterpatientid,'Diabetes_with_chronic_complications' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate,age_pat.Age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('E10.3211','E10.3212','E10.3213','E10.3219','E10.3291','E10.3292','E10.3293','E10.3299','E10.3311','E10.3312','E10.3313','E10.3319','E10.3391','E10.3392',
                              'E10.3393','E10.3399','E10.3411','E10.3412','E10.3413','E10.3419','E10.3491','E10.3492','E10.3493','E10.3499','E10.3511','E10.3512','E10.3513','E10.3519','E10.352','E10.3521','E10.3522','E10.3523','E10.3529','E10.353','E10.3531','E10.3532','E10.3533','E10.3539','E10.354','E10.3541','E10.3542','E10.3543','E10.3549','E10.355','E10.3551','E10.3552','E10.3553','E10.3559','E10.3591','E10.3592','E10.3593','E10.3599','E10.37','E10.37X1','E10.37X2','E10.37X3','E10.37X9','E11.2','E11.3','E11.31','E11.32','E11.33','E11.34','E11.35','E11.352','E11.353','E11.354','E11.355','E11.37','E11.4','E11.5','E13.2','E13.3','E13.31','E13.32','E13.33','E13.34','E13.35','E13.352','E13.353','E13.354','E13.355','E13.37','E13.4','E13.5','E10.21','E10.22','E11.21','E11.22','E11.29','E13.21','E13.22','E10.2','E10.29','E10.3','E10.31','E10.311','E10.319','E10.32','E10.321','E10.329','E10.33','E10.331','E10.339','E10.34','E10.341','E10.349','E10.35','E10.351','E10.359','E10.36','E10.39','E10.4','E10.40','E10.41','E10.42','E10.43','E10.44','E10.49','E10.5','E10.51','E10.52','E10.59','E11.311','E11.319','E11.321','E11.3211','E11.3212','E11.3213','E11.3219','E11.329','E11.3291','E11.3292','E11.3293','E11.3299','E11.331','E11.3311','E11.3312','E11.3313','E11.3319','E11.339','E11.3391','E11.3392','E11.3393','E11.3399','E11.341','E11.3411','E11.3412','E11.3413','E11.3419','E11.349','E11.3491','E11.3492','E11.3493','E11.3499','E11.351','E11.3511','E11.3512','E11.3513','E11.3519','E11.3521','E11.3522','E11.3523','E11.3529','E11.3531','E11.3532','E11.3533','E11.3539','E11.3541','E11.3542','E11.3543','E11.3549','E11.3551','E11.3552','E11.3553','E11.3559','E11.359','E11.3591','E11.3592','E11.3593','E11.3599','E11.36','E11.37X1','E11.37X2','E11.37X3','E11.37X9','E11.39','E11.40','E11.41','E11.42','E11.43','E11.44','E11.49','E11.51','E11.52','E11.59','E13.29','E13.311','E13.319','E13.321','E13.3211','E13.3212','E13.3213','E13.3219','E13.329','E13.3291','E13.3292','E13.3293','E13.3299','E13.331','E13.3311','E13.3312','E13.3313','E13.3319','E13.339','E13.3391','E13.3392','E13.3393','E13.3399','E13.341','E13.3411','E13.3412','E13.3413','E13.3419','E13.349','E13.3491','E13.3492','E13.3493','E13.3499','E13.351','E13.3511','E13.3512','E13.3513','E13.3519','E13.3521','E13.3522','E13.3523','E13.3529','E13.3531','E13.3532','E13.3533','E13.3539','E13.3541','E13.3542','E13.3543','E13.3549','E13.3551','E13.3552','E13.3553','E13.3559','E13.359','E13.3591','E13.3592','E13.3593','E13.3599',
                              'E13.36','E13.37X1','E13.37X2','E13.37X3','E13.37X9','E13.39','E13.40','E13.41','E13.42','E13.43','E13.44','E13.49','E13.51','E13.52','E13.59') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01' 
             
             
             
UNION ALL             
             
------ Diabetes without chronic complications



select distinct masterpatientid, 'Diabetes_without_chronic_complications' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('E11.0','E11.1','E11.6','E11.61','E11.62','E11.63','E11.64','E13.0','E13.1','E13.6','E13.61','E13.62','E13.63','E13.64',
                              'E10.1','E10.10','E10.11','E10.6','E10.61','E10.610','E10.618','E10.62','E10.620','E10.621','E10.622','E10.628','E10.63','E10.630','E10.638','E10.64','E10.641','E10.649','E10.65','E10.69','E10.8','E10.9','E11.618','E13.618','E11.00','E11.01','E11.10','E11.11','E11.610','E11.620','E11.621','E11.622','E11.628','E11.630','E11.638','E11.641','E11.649','E11.65','E11.69','E11.8','E11.9','E13.00','E13.01','E13.10','E13.11','E13.610',
                              'E13.620','E13.621','E13.622','E13.628','E13.630','E13.638',
                              'E13.641','E13.649','E13.65','E13.69','E13.8','E13.9') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
UNION ALL             
             
------ Chronic kidney disease (CKD)




select distinct masterpatientid,'CKD' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('K76.7','E08.22','E08.29','E09.21','E09.22','E10.21','E10.22','E11.21','E11.22','E11.29','E13.21','E13.22',
                              'I12.0','I12.9','I13.0','I13.1','I13.10','I13.11','I13.2','M32.14','M32.15','M35.04','N01.0','N01.1','N01.2','N01.3','N01.4','N01.5','N01.6','N01.7','N01.8','N01.9','N02.0','N02.1','N02.2','N02.3','N02.4','N02.5','N02.6','N02.7','N02.8','N02.9','N03.0','N03.1','N03.2','N03.3','N03.4','N03.5','N03.6','N03.7','N03.8','N03.9','N04.0','N04.1','N04.2','N04.3','N04.4','N04.5','N04.6','N04.7','N04.8','N04.9','N05.0','N05.1','N05.2','N05.3','N05.4','N05.5','N05.6','N05.7','N05.8','N05.9','N06.0','N06.1','N06.2','N06.3','N06.4','N06.5','N06.6','N06.7','N06.8','N06.9','N07.0','N07.1','N07.2','N07.3','N07.4','N07.5','N07.6','N07.7','N07.8','N07.9','N08','N11.0','N11.1','N11.8','N11.9','N12','N13.0','N13.4','N13.5','N13.6','N13.70','N13.71','N13.721','N13.722','N13.729','N13.731','N13.732','N13.739','N13.8','N13.9','N14.0','N14.1','N14.2','N14.3','N14.4','N15.0','N15.8','N15.9','N16','N18.1','N18.2','N18.3','N18.4','N18.5','N18.6','N18.9','N19','N25.0','N25.1','N25.81','N25.89','N25.9','N26.1','N26.9','N28.89','N28.9','N29','Q61.02','Q61.11','Q61.19','Q61.2','Q61.3','Q61.4','Q61.5','Q61.8','Q62.0','Q62.10','Q62.11','Q62.12',
                              'Q62.2','Q62.31','Q62.32','Q62.39','R94.4','Z49.0','Z49.01','Z49.02','Z49.3','Z49.31','Z49.32','Z99.2') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
UNION ALL             
             
             
------- Congestive heart failure (CHF)


select distinct masterpatientid,'CHF' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate,age_pat.age  from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('P29.0','I42.6','I13.0','I13.2','I09.9','I11.0','I25.5','I42.0','I42.5','I42.7','I42.8','I42.9','I43','I50','I50.1','I50.2','I50.20','I50.21','I50.22','I50.23','I50.3','I50.30','I50.31','I50.32','I50.33','I50.4','I50.40','I50.41','I50.42',
                              'I50.43','I50.8','I50.81','I50.810','I50.811','I50.812',
                              'I50.813','I50.814','I50.82','I50.83','I50.84','I50.89','I50.9') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
UNION ALL             
             
------ Chronic pulmonary disease



select distinct masterpatientid,'Chronic_pulmonary_disease' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate,age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('J41','J44','J47','J60','J61','J62','J62.0','J62.8','J63','J63.0','J63.1','J63.2','J63.3','J63.4','J63.5','J63.6','J64','J65','J66','J67','J68.4','J70.1','J70.3','J40','J41.0','J41.1','J41.8','J42','J43','J43.0','J43.1','J43.2','J43.8','J43.9','J44.0','J44.1','J44.9','J47.0','J47.1','J47.9','J45','J45.2','J45.20','J45.21','J45.22','J45.3','J45.30','J45.31','J45.32','J45.4','J45.40','J45.41','J45.42','J45.5','J45.50','J45.51','J45.52','J45.9','J45.90','J45.901','J45.902','J45.909','J45.99','J45.990','J45.991','J45.998','I27.2','I27.8','I27.81','I27.82','I27.83','I27.89','I27.9','J66.0',
                              'J66.1','J66.2','J66.8','J67.0','J67.1','J67.2',
                              'J67.3','J67.4','J67.5','J67.6','J67.7','J67.8','J67.9') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
 UNION ALL            
             
----- Mild liver disease 


select distinct masterpatientid,'Mild_liver_disease' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('B18','K70.1','K70.3','K71.5','K73','K74','K74.6','K75.8','K76.8','Z94.4','K70.0','K70.10','K70.11','K70.2','K70.9','B18.0','B18.1','B18.2','B18.8','B18.9','K71.3','K71.4','K71.7','K73.0','K73.1','K73.2','K73.8','K73.9','K74.00','K74.01','K74.02','K74.1','K74.2','K74.3','K74.4','K74.5','K74.60','K74.69','K75.2','K75.3','K75.4','K75.81','K75.89',
                              'K75.9','K76.0','K76.1','K76.2','K76.3','K76.4','K76.81','K76.89','K76.9','K77','K74.0') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
 UNION ALL            
             
------Moderate or severe liver disease 



select distinct masterpatientid, 'Moderate_or_severe_liver_disease' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('K70.4','K71.1','K72.1','K72.9','K70.40','K70.41','K71.10','K71.11','K71.51','K72.10','K72.11','K72.90',
                              'K72.91','K76.5','K76.6','K76.7','K76.81','I85','I85.0','I85.00','I85.01','I85.1','I85.10','I85.11','I86.4') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
             
UNION ALL             
------ Dementia


select distinct masterpatientid,'Dementia' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('F01','F01.5','F02','F02.8','F03','F03.9','F05','G30','G30.0','G30.1','G30.8','G30.9','G31.0','G31.01','G31.09','G31.1',
                              'G31.83','F01.50','F01.51','F02.80','F02.81','F03.90','F03.91') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
  UNION ALL           
             
----- Myocardial infarction

select distinct masterpatientid, 'Myocardial_infarction' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('I21','I21.0','I21.01','I21.02','I21.09','I21.1','I21.11','I21.19','I21.2','I21.21','I21.29','I21.3','I21.4',
                              'I21.9','I21.A','I21.A1','I21.A9','I22','I22.0','I22.1','I22.2','I22.8','I22.9','I25.2') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
             
UNION ALL             
-------- Peripheral vascular disease 

select distinct masterpatientid,'Peripheral_vascular_disease' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('Z95.8','Z95.81','Z95.810','Z95.811','Z95.812','Z95.818','Z95.82','Z95.820','Z95.828','Z95.9','I70','I70.0','I70.1',
                              'I70.2','I70.20','I70.201','I70.202','I70.203','I70.208','I70.209','I70.21','I70.211','I70.212','I70.213','I70.218','I70.219','I70.22','I70.221','I70.222','I70.223','I70.228','I70.229','I70.23','I70.231','I70.232','I70.233','I70.234','I70.235','I70.238','I70.239','I70.24','I70.241','I70.242','I70.243','I70.244','I70.245','I70.248','I70.249','I70.25','I70.26','I70.261','I70.262','I70.263','I70.268','I70.269','I70.29','I70.291','I70.292','I70.293','I70.298','I70.299','I70.3','I70.30','I70.301','I70.302','I70.303','I70.308','I70.309','I70.31','I70.311','I70.312','I70.313','I70.318','I70.319','I70.32','I70.321','I70.322','I70.323','I70.328','I70.329','I70.33','I70.331','I70.332','I70.333','I70.334','I70.335','I70.338','I70.339','I70.34','I70.341','I70.342','I70.343','I70.344','I70.345','I70.348','I70.349','I70.35','I70.36','I70.361','I70.362','I70.363','I70.368','I70.369','I70.39','I70.391','I70.392','I70.393','I70.398','I70.399','I70.4','I70.40','I70.401','I70.402','I70.403','I70.408','I70.409','I70.41','I70.411','I70.412','I70.413','I70.418','I70.419','I70.42','I70.421','I70.422','I70.423','I70.428','I70.429','I70.43','I70.431','I70.432','I70.433','I70.434','I70.435','I70.438','I70.439','I70.44','I70.441','I70.442','I70.443','I70.444','I70.445','I70.448','I70.449','I70.45','I70.46','I70.461','I70.462','I70.463','I70.468','I70.469','I70.49','I70.491','I70.492','I70.493','I70.498','I70.499','I70.5','I70.50','I70.501','I70.502','I70.503','I70.508','I70.509','I70.51','I70.511','I70.512','I70.513','I70.518','I70.519','I70.52','I70.521','I70.522','I70.523','I70.528','I70.529','I70.53','I70.531','I70.532','I70.533','I70.534','I70.535','I70.538','I70.539','I70.54','I70.541','I70.542','I70.543','I70.544','I70.545','I70.548','I70.549','I70.55','I70.56','I70.561','I70.562','I70.563','I70.568','I70.569','I70.59','I70.591','I70.592','I70.593','I70.598','I70.599','I70.6','I70.60','I70.601','I70.602','I70.603','I70.608','I70.609','I70.61','I70.611','I70.612','I70.613','I70.618','I70.619','I70.62','I70.621','I70.622','I70.623','I70.628','I70.629','I70.63','I70.631','I70.632','I70.633','I70.634','I70.635','I70.638','I70.639','I70.64','I70.641','I70.642','I70.643','I70.644','I70.645','I70.648','I70.649','I70.65','I70.66','I70.661','I70.662','I70.663','I70.668','I70.669','I70.69','I70.691','I70.692','I70.693','I70.698','I70.699','I70.7','I70.70','I70.701','I70.702','I70.703','I70.708','I70.709','I70.71','I70.711','I70.712','I70.713','I70.718','I70.719','I70.72','I70.721','I70.722','I70.723','I70.728','I70.729','I70.73','I70.731','I70.732','I70.733','I70.734','I70.735','I70.738','I70.739','I70.74','I70.741','I70.742','I70.743','I70.744','I70.745','I70.748','I70.749','I70.75','I70.76','I70.761','I70.762','I70.763','I70.768','I70.769','I70.79','I70.791','I70.792','I70.793','I70.798','I70.799','I70.8','I70.9','I70.90','I70.91','I70.92','I71','I71.0','I71.00','I71.01','I71.02','I71.03','I71.1','I71.2','I71.3','I71.4','I71.5','I71.6','I71.8','I71.9','I73.1','I73.8','I73.81','I73.89','I73.9','I75','I75.0','I75.01','I75.011','I75.012','I75.013','I75.019','I75.02','I75.021','I75.022','I75.023','I75.029','I75.8','I75.81','I75.89','I77.1','I77.7',
                              'I77.70','I77.71','I77.72','I77.73','I77.74','I77.75','I77.76','I77.77','I77.79','I79.0','K55.1','K55.8','K55.9') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
  UNION ALL           
             
------ Cerebrovascular disease 


select distinct masterpatientid,'Cerebrovascular_disease' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('I63.011','I63.013','I63.019','I63.02','I63.031','I63.032','I63.033','I63.039','I63.09','I63.10','I63.111',
                              'I63.113','I63.119','I63.12','I63.131','I63.132','I63.133','I63.139','I63.19','I63.211','I63.212','I63.213',
                              'I63.219','I63.22','I63.231','I63.232','I63.233','I63.239','I63.29','I63.30','I63.311','I63.312','I63.313','I63.319','I63.321','I63.322','I63.323','I63.329','I63.331','I63.332','I63.333','I63.339','I63.341','I63.342','I63.343','I63.349','I63.39','I63.40','I63.411','I63.412','I63.012','I63.429','I63.431','I63.432','I63.433','I63.439','I63.441','I63.442','I63.443','I63.449','I63.49','I63.511','I63.512','I63.513','I63.519','I63.521','I63.522','I63.523','I63.529','I63.531','I63.532','I63.533','I63.539','I63.541','I63.542','I63.543','I63.549','I63.59','I63.6','I63.81','I63.89','I63.9','I63.413','I63.419','I63.421','I63.422','I63.423','I67.6','G45.9','I61.2','I61.3','I61.4','I61.5','I61.6','I61.8','I61.9','I62.00','I62.01','I62.02','I62.03','I62.1','I62.9','I67.4','I61.0','I61.1','I67.7','I68.2','G45.0','G45.1','G45.2','G45.3','G45.8','G46.0','G46.1','G46.2','G46.3','G46.4','G46.5','G46.6','G46.7','G46.8','I60.00','I60.01','I60.02','I60.10','I60.11','I60.12','I60.30','I60.31','I60.32','I60.4','I60.50','I60.51','I60.52','I60.6','I60.7','I60.8','I60.9','I63.8','I65.01','I65.02','I65.03','I65.09','I65.1','I65.21','I65.22','I65.23','I65.29','I65.8','I66.02','I66.03','I66.09','I66.11','I66.12','I66.13','I66.19','I66.21','I66.22','I66.23','I66.29','I66.3','I66.8','I66.9','I67.2','I67.81','I67.82','I67.841','I67.848','I67.89','I69.00','I69.012','I69.013','I69.014','I69.015','I69.018','I69.019','I69.020','I69.021','I69.022','I69.023','I69.028','I69.031','I69.032','I69.033','I69.034','I69.039','I69.041','I69.042','I69.043','I69.044','I69.049','I69.051','I69.052','I69.053','I69.054','I69.059','I69.061','I69.062','I69.063','I69.064','I69.065','I69.069','I69.090','I69.091','I69.011','I66.01','I69.111','I69.112','I69.113','I69.114','I69.115','I69.118','I69.119','I69.120','I69.121','I69.122','I69.123','I69.128','I69.131','I69.132','I69.133','I69.134','I69.139','I69.141','I69.142','I69.143','I69.144','I69.149','I69.151','I69.152','I69.153','I69.154','I69.159','I69.161','I69.110','I69.10','I69.164','I69.165','I69.169','I69.190','I69.191','I69.198','I69.20','I69.211','I69.212','I69.213','I69.214','I69.215','I69.219','I69.310','I69.311','I69.220','I69.221','I69.222','I69.223','I69.228','I69.231','I69.232','I69.233','I69.234','I69.239','I69.241','I69.242','I69.243','I69.244','I69.249','I69.251','I69.252','I69.253','I69.254','I69.259','I69.261','I69.262','I69.263','I69.264','I69.265','I69.269','I69.290','I69.291','I69.298','I69.30','I69.312','I69.313','I69.314','I69.315','I69.210','I69.163','I69.320','I69.321','I69.322','I69.323','I69.328','I69.331','I69.332','I69.333','I69.334','I69.339','I69.341','I69.342','I69.343','I69.344','I69.349','I69.351','I69.352','I69.353','I69.354','I69.359','I69.361','I69.362','I69.363','I69.364','I69.365','I69.369','I69.390','I69.391','I69.398','I69.80','I69.811','I69.812','I69.813','I69.814','I69.815','I69.818','I69.819','I69.820','I69.821','I69.822','I69.823','I69.828','I69.831','I69.832','I69.833','I69.834','I69.839','I69.841','I69.842','I69.843','I69.844','I69.849','I69.851','I69.852','I69.319','I69.810','I69.859','I69.861','I69.862','I69.863','I69.864','I69.865','I69.869','I69.890','I69.891','I69.898','I69.90','I69.911','I69.912','I69.913','I69.914','I69.915','I69.918','I69.920','I69.921','I69.922','I69.923','I69.928','I69.931','I69.932','I69.933','I69.934','I69.939','I69.941','I69.942','I69.943','I69.944','I69.949','I69.951','I69.952','I69.953','I69.954','I69.959','I69.961','I69.962','I69.963','I69.964','I69.965','I69.969','I69.990','I69.991','I69.998','I69.910','I69.854','I67.0','I65.9','I69.098','I69.162','I69.010','I63.50','I63.112','I69.853','I69.218','I69.318','I69.919','G45','G45.4','G46','H34.0','I60','I60.0','I60.1','I60.2','I60.3','I60.5','I61','I62','I62.0','I63','I63.0','I63.01','I63.03','I63.1','I63.11','I63.13','I63.2','I63.21','I63.23','I63.3','I63.31','I63.32','I63.33','I63.34','I63.4','I63.41','I63.42','I63.43','I63.44','I63.5','I63.51','I63.52','I63.53','I63.54','I65','I65.0','I65.2','I66','I66.0','I66.1','I66.2','I67','I67.1','I67.3','I67.5','I67.8','I67.83','I67.84','I67.85','I67.850','I67.858','I67.9','I68','I68.0','I68.8','I69','I69.0','I69.01','I69.02','I69.03','I69.04','I69.05','I69.06','I69.09','I69.092','I69.093','I69.1','I69.11','I69.12','I69.13','I69.14','I69.15','I69.16','I69.19','I69.192','I69.193','I69.2','I69.21','I69.22','I69.23','I69.24','I69.25','I69.26','I69.29','I69.292','I69.293','I69.3','I69.31','I69.32','I69.33','I69.34','I69.35','I69.36','I69.39','I69.392','I69.393','I69.8','I69.81','I69.82','I69.83','I69.84','I69.85','I69.86','I69.89','I69.892','I69.893','I69.9',
                              'I69.91','I69.92','I69.93','I69.94','I69.95','I69.96','I69.99','I69.992','I69.993','I63.00','I63.20') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
             
 UNION ALL            
             
------- Hemiplegia or paraplegia 



select distinct masterpatientid, 'Hemiplegia_or_paraplegia' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('G04.1','G80.0','G80.1','G80.2','G81','G81.0','G81.00','G81.01','G81.02','G81.03','G81.04','G81.1',
                              'G81.10','G81.11','G81.12','G81.13','G81.14','G81.9','G81.90','G81.91','G81.92','G81.93','G81.94','G82','G82.2','G82.20','G82.21','G82.22','G82.5','G82.50','G82.51','G82.52','G82.53','G82.54','G83.0','G83.1','G83.10','G83.11','G83.12','G83.13','G83.14','G83.2','G83.20','G83.21','G83.22',
                              'G83.23','G83.24','G83.3','G83.30','G83.31','G83.32','G83.33','G83.34','G83.4','G83.9','G11.4') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'


UNION ALL

------ Rheumatologic disease 


select distinct masterpatientid, 'Rheumatologic_disease' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('M32.14','M35.04','M32.15','M35.81','M06.329','M05','M06','M31.5','M31.6','M35.9','M32','M32.1',
                              'M32.10','M32.12','M32.13','M32.19','M32.8','M32.9','M33','M33.0','M33.00','M33.01','M33.02','M33.09','M33.1','M33.10','M33.11','M33.12','M33.19','M33.2','M33.20','M33.21','M33.22','M33.29','M33.9','M33.90','M33.91','M33.92','M33.99','M34','M34.0','M34.1','M34.8','M34.81','M34.89','M34.9','M35.0','M35.00','M35.01','M35.02','M35.03','M35.09','M35.1','M35.2','M35.3','M36.0','M06.339','M05.00','M05.011','M05.012','M05.019','M05.021','M05.022','M05.029','M05.031','M05.032','M05.039','M05.041','M05.042','M05.049','M05.051','M05.052','M05.059','M05.061','M05.062','M05.069','M05.071','M05.072','M05.079','M05.09','M05.112','M05.119','M05.121','M05.122','M05.129','M05.131','M05.132','M05.139','M05.141','M05.142','M05.149','M05.151','M05.152','M05.159','M05.161','M05.162','M05.169','M05.171','M05.172','M05.19','M05.20','M05.211','M05.212','M05.219','M05.221','M05.222','M05.229','M05.231','M05.232','M05.239','M05.241','M05.242','M05.249','M05.251','M05.252','M05.259','M05.261','M05.262','M05.269','M05.271','M05.272','M05.279','M05.29','M05.30','M05.311','M05.312','M05.319','M05.321','M05.322','M05.329','M05.331','M05.332','M05.339','M05.341','M05.342','M05.349','M05.351','M05.352','M05.359','M05.111','M05.369','M05.371','M05.372','M05.379','M05.39','M05.40','M05.411','M05.412','M05.419','M05.421','M05.422','M05.429','M05.431','M05.432','M05.439','M05.441','M05.442','M05.449','M05.451','M05.452','M05.459','M05.461','M05.462','M05.469','M05.471','M05.472','M05.49','M05.511','M05.512','M05.519','M05.521','M05.522','M05.529','M05.531','M05.532','M05.539','M05.541','M05.542','M05.549','M05.551','M05.552','M05.559','M05.561','M05.562','M05.569','M05.571','M05.572','M05.579','M05.59','M05.60','M05.611','M05.612','M05.619','M05.621','M05.622','M05.629','M05.631','M05.50','M05.362','M05.641','M05.642','M05.649','M05.651','M05.652','M05.659','M05.661','M05.662','M05.669','M05.671','M05.672','M05.679','M05.69','M05.70','M05.711','M05.712','M05.719','M05.721','M05.722','M05.729','M05.731','M05.732','M05.739','M05.741','M05.742','M05.749','M05.751','M05.752','M05.759','M05.761','M05.762','M05.769','M05.771','M05.772','M05.779','M05.79','M05.7A','M05.80','M05.811','M05.812','M05.819','M05.821','M05.822','M05.829','M05.831','M05.832','M05.839','M05.841','M05.842','M05.849','M05.851','M05.852','M05.639','M05.862','M05.869','M05.871','M05.872','M05.879','M05.89','M05.8A','M05.9','M06.00','M06.011','M06.012','M06.019','M06.021','M06.022','M06.029','M06.031','M06.032','M06.039','M06.041','M06.042','M06.049','M06.051','M06.052','M06.059','M06.061','M06.062','M06.069','M06.071','M06.072','M06.079','M06.08','M06.09','M06.0A','M06.1','M06.20','M06.211','M06.212','M06.219','M06.221','M06.222','M06.229','M06.231','M06.232','M06.239','M06.241','M06.242','M06.249','M06.251','M06.252','M06.259','M06.261','M06.262','M06.269','M06.271','M06.272','M06.279','M06.28','M06.29','M06.30','M06.311','M06.312','M06.319','M06.321','M06.322','M05.861','M06.351','M06.352','M06.359','M06.361','M06.362','M06.369','M06.371','M06.372','M06.379','M06.38','M06.39','M06.4','M06.80','M06.811','M06.812','M06.819','M06.821','M06.822','M06.829','M06.831','M06.832','M06.839','M06.841','M06.842','M06.849','M06.851','M06.852','M06.859','M06.861','M06.862','M06.869','M06.871','M06.872','M06.879','M06.88','M06.89','M06.8A','M06.9','M06.341','M06.342','M34.83','M05.859','M05.10','M05.179','M05.361','M05.479','M05.632','M06.331','M06.332','M06.349','M35.8','M05.0','M05.01','M05.02','M05.03','M05.04','M05.05','M05.06','M05.07','M05.1','M05.11','M05.12','M05.13','M05.14','M05.15','M05.16','M05.17','M05.2','M05.21','M05.22','M05.23','M05.24','M05.25','M05.26','M05.27','M05.3','M05.31','M05.32','M05.33','M05.34','M05.35','M05.36','M05.37','M05.4','M05.41','M05.42','M05.43','M05.44','M05.45','M05.46','M05.47','M05.5','M05.51','M05.52','M05.53','M05.54','M05.55','M05.56','M05.57','M05.6','M05.61','M05.62','M05.63','M05.64','M05.65','M05.66','M05.67','M05.7','M05.71','M05.72','M05.73','M05.74','M05.75','M05.76','M05.77','M05.8','M05.81','M05.82','M05.83','M05.84','M05.85','M05.86','M05.87','M06.0','M06.01','M06.02','M06.03','M06.04','M06.05','M06.06','M06.07','M06.2','M06.21','M06.22','M06.23','M06.24','M06.25','M06.26','M06.27','M06.3','M06.31','M06.32','M06.33','M06.34','M06.35','M06.36','M06.37','M06.8','M06.81','M06.82','M06.83','M06.84','M06.85','M06.86','M06.87','M32.0','M32.11','M33.03','M33.13','M33.93','M34.2','M34.82','M35','M35.05','M35.06',
                              'M35.07','M35.08','M35.0A','M35.0B','M35.0C','M35.4','M35.5','M35.6','M35.7','M35.89') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
UNION ALL             
             
------ Peptic ulcer disease 



select distinct masterpatientid, 'Peptic_ulcer_disease' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('K25','K25.0','K25.1','K25.2','K25.3','K25.4','K25.5','K25.6','K25.7','K25.9','K26','K26.0','K26.1','K26.2',
                              'K26.3','K26.4','K26.5','K26.6','K26.7','K26.9','K27','K27.0','K27.1','K27.2','K27.3',
                              'K27.4','K27.5','K27.6','K27.7','K27.9','K28','K28.0','K28.1','K28.2','K28.3','K28.4','K28.5','K28.6','K28.7','K28.9') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
             
 UNION ALL            
             
------Any malignancy, including leukemia and lymphoma 




select distinct masterpatientid, 'Any_malignancy_including_leukemia_and_lymphoma' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('C00.0','C00.1','C70','C70.1','C70.9','C71.0','C71','C71.1','C71.2','C71.3','C71.4','C71.5',
                              'C71.6','C71.7','C71.8','C71.9','C72.0','C72.1','C72.20','C72.2','C72.21','C72.22','C72.30','C72.3','C72.31',
                              'C72.32','C72.40','C72.4','C72.41','C72.42','C72.50','C72.5','C72.59','C72.9','C00','C00.2','C00.3','C00.4',
                              'C00.5','C00.6','C00.8','C00.9','C02.0','C02.1','C01','C02','C02.2','C02.4','C02.8','C70.0','C03.0','C03.1',
                              'C03.9','C04.8','C04.9','C04','C05.0','C05.1','C05.2','C05','C05.8','C05.9','C06.0','C06.1','C06.2','C06',
                              'C06.80','C06.89','C06.9','C08.0','C08.1','C08.9','C07','C08','C09.0','C09.1','C09.8','C09','C09.9','C10.0','C10.1','C10.2','C10','C10.3','C10.4','C10.8','C10.9','C11.0','C11.1','C11.2','C11','C11.3','C11.8','C11.9','C13.0','C13.1','C13.2','C12','C13','C13.8','C13.9','C14.0','C14.2','C14.8','C15.3','C15.4','C15.5','C15','C15.8','C15.9','C16.0','C16.1','C16.2','C16','C16.3','C16.4','C16.5','C16.8','C16.9','C17.0','C17.1','C17.2','C17','C03','C18.0','C18.1','C18.2','C18','C18.3','C18.4','C18.5','C18.6','C18.7','C18.8','C18.9','C21.0','C21.1','C21.2','C19','C20','C21','C22.0','C22.1','C22.2','C22.3','C22','C22.4','C22.7','C22.9','C24.0','C24.1','C24.8','C24.9','C23','C24','C25.0','C25.1','C25.2','C25.3','C25','C25.4','C25.7','C25.8','C25.9','C26.0','C26.1','C26.9','C30.0','C26','C30.1','C31.0','C31.1','C30','C31.2','C31.3','C31','C31.9','C32.0','C32.1','C32.2','C32.3','C32','C32.8','C32.9','C34.00','C34.01','C34.02','C34.10','C33','C34','C34.0','C34.11','C34.12','C34.2','C34.1','C34.30','C34.31','C34.32','C34.3','C34.8','C34.91','C34.9','C34.92','C38.0','C37','C38','C38.1','C38.2','C38.3','C38.4','C38.8','C39.0','C39','C39.9','C40.00','C40','C40.0','C40.01','C40.02','C40.10','C40.1','C40.11','C40.12','C40.20','C40.2','C40.21','C40.22','C40.30','C40.3','C40.31','C40.32','C40.80','C40.81','C40.82','C40.90','C40.9','C40.91','C40.92','C41.0','C41','C41.1','C41.2','C41.3','C41.4','C41.9','C43.0','C43','C43.10','C43.1','C43.11','C43.111','C43.112','C43.12','C43.121','C43.122','C43.20','C43.2','C43.21','C43.22','C43.30','C43.3','C43.31','C43.39','C43.4','C43.51','C43.5','C43.52','C43.62','C43.70','C43.71','C43.72','C43.7','C43.8','C43.9','C45.0','C45.1','C45.2','C45','C45.7','C45.9','C46.0','C46.1','C46.2','C46','C46.3','C46.4','C46.50','C46.51','C46.52','C46.5','C46.7','C46.9','C47.10','C47.11','C47.12','C47','C47.20','C47.21','C47.22','C47.3','C47.2','C47.4','C47.5','C47.6','C47.8','C47.9','C48.0','C48.1','C48.2','C48.8','C48','C49.0','C49.10','C49.11','C49.12','C49','C49.20','C49.1','C49.21','C49.22','C49.3','C49.2','C49.4','C49.5','C49.6','C49.8','C49.9','C49.A0','C49.A1','C49.A2','C49.A4','C49.A','C49.A5','C43.6','C4A.10','C4A.11','C4A.111','C4A.112','C4A.12','C4A.121','C4A.122','C4A.20','C4A.21','C4A.22','C4A.30','C4A.2','C4A.31','C4A.39','C4A.4','C4A.3','C4A.51','C4A.52','C4A.59','C4A.60','C4A.5','C4A.61','C4A.62','C4A.71','C4A.72','C4A.8','C4A.9','C4A.7','C50.011','C50.012','C50.019','C50.021','C50.022','C50','C50.0','C50.01','C50.029','C50.111','C50.112','C50.02','C50.119','C50.121','C50.122','C50.1','C50.11','C50.211','C50.212','C50.219','C50.12','C50.221','C50.222','C50.2','C50.21','C50.229','C50.311','C50.312','C50.22','C50.319','C50.321','C50.322','C50.3','C50.31','C50.329','C57.02','C50.32','C4A','C50.412','C50.419','C50.421','C50.422','C50.42','C50.429','C50.511','C50.512','C50.5','C50.51','C50.519','C50.521','C50.522','C50.52','C50.529','C50.611','C50.612','C50.6','C50.61','C50.621','C50.622','C50.62','C50.629','C50.811','C50.812','C50.8','C50.81','C50.819','C50.821','C50.822','C50.82','C50.829','C50.911','C50.912','C50.9','C50.91','C50.919','C50.921','C50.922','C50.92','C50.929','C51.0','C51.1','C51','C51.2','C51.8','C51.9','C53.0','C53.1','C52','C53','C53.9','C54.0','C54.1','C54','C54.2','C54.3','C54.8','C54.9','C56.1','C56.2','C55','C56','C56.9','C57.00','C57.01','C57','C57.0','C50.41','C57.12','C57.21','C57.2','C57.22','C57.3','C57.4','C57.7','C57.8','C57.9','C60.0','C58','C60','C60.1','C60.2','C60.8','C60.9','C62.00','C57.10','C62','C62.0','C62.01','C62.02','C62.10','C62.1','C62.11','C62.12','C62.92','C63.00','C63.01','C63','C63.0','C63.02','C63.10','C63.11','C63.1','C63.12','C63.2','C63.7','C63.8','C63.9','C64.1','C64.2','C64','C64.9','C65.1','C65.2','C65','C65.9','C66.1','C66.2','C66','C66.9','C67.0','C67.1','C67','C67.2','C67.3','C67.5','C67.6','C67.7','C67.8','C67.9','C68.0','C68.1','C68','C68.8','C68.9','C69.00','C69.01','C69','C69.0','C69.02','C57.11','C69.12','C69.20','C69.21','C69.22','C69.30','C69.2','C69.31','C69.32','C69.40','C69.3','C69.41','C69.42','C69.50','C69.4','C69.51','C69.52','C69.60','C69.5','C69.61','C69.62','C69.81','C69.6','C69.82','C69.90','C69.91','C69.92','C74.00','C74.01','C69.9','C74.02','C74.10','C74.11','C73','C74','C74.0','C74.12','C74.90','C74.91','C74.1','C74.92','C75.0','C75.1','C74.9','C75.2','C75.3','C75.4','C75','C75.8','C75.9','C76.0','C76.1','C76.2','C76.3','C76.40','C76','C76.41','C76.42','C76.50','C76.51','C76.4','C76.52','C76.8','C7A.00','C76.5','C7A.010','C7A.011','C7A.012','C7A.020','C7A','C7A.0','C7A.01','C7A.02','C69.1','C7A.025','C7A.026','C7A.090','C7A.091','C7A.09','C7A.092','C7A.093','C7A.094','C7A.095','C7A.096','C7A.098','C7A.1','C7A.8','C80.0','C80.1','C80','C80.2','C7A.023','C7A.024','C81.01','C81.02','C81.03','C81','C81.04','C81.05','C81.06','C81.07','C81.08','C81.09','C81.10','C81.11','C81.12','C81.13','C81.1','C81.14','C81.16','C81.17','C81.18','C81.19','C81.20','C81.21','C81.22','C81.23','C81.2','C81.24','C81.25','C81.26','C81.27','C81.28','C81.29','C81.30','C81.31','C81.32','C81.33','C81.3','C81.34','C81.35','C81.36','C81.37','C81.38','C81.39','C81.40','C81.41','C81.42','C81.43','C81.4','C81.44','C81.45','C81.46','C81.70','C81.71','C81.72','C81.7','C81.73','C81.74','C81.75','C81.76','C81.77','C81.78','C81.79','C81.90','C81.91','C81.92','C81.9','C81.93','C81.94','C81.95','C81.96','C81.97','C81.98','C81.99','C82.00','C82.02','C82.03','C82','C82.0','C82.04','C82.05','C82.06','C82.07','C82.08','C82.09','C82.10','C82.11','C82.12','C82.1','C82.13','C82.14','C82.15','C82.16','C82.17','C82.18','C82.19','C82.20','C82.22','C82.23','C82.2','C82.25','C82.26','C82.27','C82.28','C82.29','C82.30','C82.31','C82.32','C82.33','C82.3','C82.34','C82.35','C82.36','C82.37','C82.38','C82.39','C82.40','C82.4','C82.43','C82.45','C82.46','C82.47','C82.48','C82.49','C82.50','C82.51','C82.52','C82.53','C82.5','C82.54','C82.55','C82.56','C82.57','C82.58','C82.59','C82.60','C82.61','C82.62','C82.63','C82.6','C82.65','C82.66','C82.67','C82.68','C82.69','C82.80','C82.81','C82.82','C82.83','C82.8','C82.84','C82.85','C82.86','C82.87','C82.88','C82.89','C82.90','C82.91','C82.92','C82.93','C82.9','C82.94','C82.95','C82.96','C82.97','C82.98','C82.99','C83.00','C83.01','C83.02','C83.03','C83','C83.0','C83.05','C83.06','C83.07','C83.08','C83.09','C83.10','C83.11','C83.12','C83.13','C83.1','C83.15','C83.16','C83.17','C83.18','C83.19','C83.30','C83.3','C83.31','C83.32','C83.33','C83.34','C83.36','C83.37','C83.38','C83.50','C83.51','C83.5','C83.52','C83.54','C83.57','C83.58','C83.59','C83.70','C83.71','C83.7','C83.72','C83.73','C83.74','C83.75','C83.76','C83.77','C83.78','C83.79','C83.80','C83.81','C83.8','C83.82','C83.83','C83.84','C83.85','C83.86','C83.87','C83.88','C83.89','C83.90','C83.91','C83.9','C83.92','C83.93','C83.94','C83.95','C83.96','C83.97','C83.98','C83.99','C84.00','C84.01','C84','C84.0','C84.02','C84.03','C84.04','C84.05','C84.06','C84.07','C84.08','C84.10','C84.11','C84.1','C84.12','C84.13','C84.16','C84.17','C84.18','C84.19','C84.40','C84.41','C84.42','C84.4','C84.43','C84.44','C84.45','C84.46','C84.47','C84.48','C84.49','C84.60','C84.62','C84.63','C84.6','C84.64','C84.65','C84.66','C84.67','C84.68','C84.69','C84.70','C84.71','C84.72','C84.7','C84.73','C84.74','C84.75','C84.76','C84.77','C84.78','C84.79','C84.90','C84.91','C84.92','C84.9','C84.93','C84.94','C84.95','C84.96','C84.97','C84.98','C84.99','C84.A0','C84.A1','C84.A2','C84.A','C84.A3','C84.A4','C84.A6','C84.A7','C84.A8','C84.A9','C84.Z2','C84.Z3','C84.Z4','C84.Z','C84.Z5','C84.Z6','C84.Z7','C84.Z8','C84.Z9','C85.10','C85.11','C85.12','C85.13','C85','C85.1','C85.14','C85.16','C85.17','C85.18','C85.19','C85.20','C85.21','C85.22','C85.23','C85.2','C85.24','C85.25','C85.26','C85.27','C85.28','C85.29','C85.80','C85.81','C85.82','C85.83','C85.8','C85.84','C85.85','C85.86','C85.87','C85.88','C85.89','C85.90','C85.91','C85.92','C85.93','C85.9','C85.94','C85.96','C85.97','C85.98','C85.99','C86.0','C86.1','C86.2','C86.3','C86','C86.4','C86.5','C86.6','C88.2','C88.3','C88','C88.0','C90.01','C90.02','C90.11','C90','C90.0','C90.12','C90.20','C90.21','C90.1','C90.22','C90.30','C90.31','C90.2','C90.32','C91.00','C91.01','C90.3','C91.02','C91.11','C91.12','C91','C91.0','C91.30','C91.31','C91.32','C91.1','C91.40','C91.41','C91.3','C91.42','C91.50','C91.51','C91.4','C91.52','C91.60','C91.61','C91.5','C91.62','C91.90','C91.91','C91.6','C91.92','C91.A0','C91.A1','C91.9','C91.A2','C91.Z0','C91.Z1','C91.A','C91.Z2','C92.01','C92.02','C91.Z','C92.10','C92.11','C92.12','C92','C92.0','C92.20','C92.21','C92.1','C92.22','C92.30','C92.31','C92.2','C92.32','C92.40','C92.41','C92.3','C92.42','C92.50','C92.51','C92.4','C92.5','C92.62','C92.6','C92.90','C92.91','C92.9','C92.92','C92.A1','C92.A2','C92.A','C92.Z0','C92.Z1','C92.Z2','C92.Z','C93.00','C93.01','C93.02','C93','C93.0','C93.10','C93.11','C93.12','C93.1','C93.30','C93.31','C93.32','C93.3','C93.90','C93.91','C93.92','C93.9','C93.Z0','C93.Z1','C93.Z2','C93.Z','C94.01','C94.02','C94.20','C94','C94.0','C94.21','C94.22','C94.2','C94.30','C94.31','C94.32','C94.3','C94.40','C94.41','C94.42','C94.4','C94.6','C94.80','C94.81','C94.82','C94.8','C95.00','C95.01','C95.02','C95','C95.0','C95.11','C95.12','C95.90','C95.1','C95.91','C95.92','C95.9','C96.0','C96.20','C96.21','C96','C96.22','C96.2','C02.9','C81.0','C96.5','C96.6','C96.A','C96.Z','C72','C04.0','C17.3','C06.8','C14','C22.8','C31.8','C34.80','C34.90','C43.59','C43.60','C40.8','C49.A3','C49.A9','C47.1','C50.129','C50.619','C4A.1','C4A.6','C53.8','C50.4','C57.20','C67.4','C57.1','C69.10','C75.5','C69.8','C7A.021','C7A.022','C81.15','C7A.019','C81.47','C81.48','C82.01','C82.24','C82.41','C82.64','C83.04','C83.14','C83.39','C83.53','C83.55','C83.56','C84.09','C84.14',
                              'C84.61','C96.4','C62.9','C62.90','C84.Z0','C85.15','C85.95','C88.8','C88.9','C91.10','C92.00','C92.52','C92.60','C94.00','C95.10','C96.29','C96.9','C61','C56.3','C84.7A','D45','C02.3','C04.1','C16.6','C17.8','C17.9','C21.8','C34.81','C34.82','C43.61','C47.0','C4A.0','C4A.70','C50.411','C62.91','C69.11','C69.80','C7A.029','C81.00','C81.49','C82.21','C82.42','C82.44',
                              'C83.35','C84.15','C84.A5','C84.Z1','C88.4','C90.00','C90.10','C92.61','C92.A0') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             
             
  
 UNION ALL 
  
---- Metastatic solid tumor 


select distinct masterpatientid, 'Metastatic_solid_tumor' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('C79.63','C77','C77.0','C77.1','C77.2','C77.3','C77.4','C77.5','C77.8','C77.9','C78','C78.0','C78.00','C78.01','C78.02','C78.1','C78.2','C78.3','C78.30','C78.39','C78.4','C78.5','C78.6','C78.7','C78.8','C78.80','C78.89','C79','C79.0','C79.00','C79.01','C79.02','C79.1','C79.10','C79.11','C79.19','C79.2','C79.3','C79.31','C79.32','C79.4','C79.40','C79.49','C79.5','C79.51','C79.52','C79.6','C79.60','C79.61','C79.62','C79.7','C79.70','C79.71','C79.72','C79.8','C79.81','C79.82','C79.89',
                              'C79.9','C7B','C7B.0','C7B.00','C7B.01','C7B.02','C7B.03','C7B.04','C7B.09','C7B.1','C7B.8') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
             

UNION ALL
             
----- AIDS/HIV 



select distinct masterpatientid, 'AIDS_HIV' AS Condition_Name, age from (
select age_pat.masterpatientid, age_pat.patientid, age_pat.indexdate, age_pat.age from (
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
 ) evu_exp
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
             
  INNER JOIN (select patientid, dxdate as com_date, SOURCEDXCODEDESCRIPTION	as Name from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN ('B20','B97.35','O98.7','O98.71','O98.711','O98.712','O98.713','O98.719','O98.72','O98.73','Z21') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'
  
  ) order by masterpatientid
  
  
 
  