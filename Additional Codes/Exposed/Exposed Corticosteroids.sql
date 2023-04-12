## Active treatment with high-dose corticosteroids, immunosuppressive or immunomodulatory therapy


                     
----EVU PAT query

 WITH immuno_pat as (
select distinct masterpatientid from (
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
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both                     
                     
INNER JOIN (   Select patientid, medadminstartdate as dxdate
                        from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS"
                        where SOURCEMEDADMINMEDNAME ILIKE ANY ('%alemtuzumab%','%belimumab%','%IBRUTINIB%','%ofatumumab%','%rituximab%',
                                                                      '%acalabrutinib%','%fingolimod%','%IMMUNOGLOBULIN G%','%ocrelizumab%','%ozanimod%',
                                                                      '%ponesimod%','%siponimod%','%abatacept%','%abetimus%','%adalimumab%','%alefacept%',
                                                                      '%altretamine%','%anakinra%','%anifrolumab%','%apremilast%','%azacitidine%',
                                                                      '%azathioprine%','%baricitinib%','%basiliximab%','%belatacept%','%belumosudil%',
                                                                      '%bendamustine%','%brodalumab%','%busulfan%','%canakinumab%','%capecitabine%',
                                                                      '%carboplatin%','%carmustine%','%certolizumab pegol%','%chlorambucil%','%cisplatin%',
                                                                      '%cladribine%','%clofarabine%','%cyclophosphamide%','%cyclosporine%','%cytarabine%',
                                                                      '%dacarbazine%','%daclizumab%','%decitabine%','%dimethyl fumarate%','%diroximel fumarate%',
                                                                      '%eculizumab%','%efalizumab%','%emapalumab%','%etanercept%','%ethoglucid%','%everolimus%',
                                                                      '%floxuridine%','%fludarabine%','%fluorouracil%','%gemcitabine%','%golimumab%','%guselkumab%',
                                                                      '%ifosfamide%','%IMMUNOGLOBULIN G and HYALURONIDASE%','%inebilizumab%','%infliximab%',
                                                                      '%ixekizumab%','%leflunomide%','%lenalidomide%','%lomustine%',
                                                                      '%lymphocyte immune globulin, anti-thymocyte globulin%','%mechlorethamine%',
                                                                      '%melphalan%','%melphalan flufenamide%','%mercaptopurine%','%methotrexate%',
                                                                      '%mitobronitol%','%muromonab-CD3%','%mycophenolate mofetil%','%mycophenolic acid%',
                                                                      '%natalizumab%','%nelarabine%','%pegcetacoplan%','%pemetrexed%','%pipobroman%',
                                                                      '%pirfenidone%','%pomalidomide%','%pralatrexate%','%prednimustine%','%raltitrexed%',
                                                                      '%ravulizumab%','%rilonacept%','%risankizumab%','%sarilumab%','%satralizumab%',
                                                                      '%secukinumab%','%siltuximab%','%sirolimus%','%streptozocin%','%sutimlimab%','%tacrolimus%',
                                                                      '%tegafur%','%temozolomide%','%Teprotumumab%','%teriflunomide%','%thalidomide%',
                                                                      '%thioguanine%','%thiotepa%','%tildrakizumab%','%tocilizumab%','%tofacitinib%','%treosulfan%',
                                                                      '%trofosfamide%','%upadacitinib%','%uracil mustard%','%ustekinumab%','%vedolizumab%',
                                                                      '%voclosporin%') 
                                                                   
                                                                       ) immuno_names
                   on inclusion_both.patientid = immuno_names.patientid
                     where dxdate >= ((indexdate) - 365) and dxdate < indexdate 
                     ),
  
  
   corti_pat as (  
     select distinct masterpatientid from (
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
   ) evu_age where row1 =1 and age is NOT NULL ) aa
   where age >=12 
   ) age_pat
   
 INNER JOIN (select patientid, encounterdate
             from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" 
                          ) en
             on age_pat.patientid = en.patientid
             where (encounterdate >= ((indexdate)-365) AND encounterdate < indexdate AND encounterdate is not null)
             
             ) inclusion_both
     
  
    INNER JOIN (
                 select * from (select patientid, ((DOSE*RXQUANTITY)/rxsupply_updated) as daily_dose,SOURCERXMEDNAME,drugdate from (
                  select patientid,SourceRxMedName,ORDERDATE as drugdate,REGEXP_SUBSTR(RXDOSEORDERED,'\\d*') as DOSE,RXQUANTITY,RXENDDATE,RXSTARTDATE,
                  case 
                  when rxdayssupply is null then (RXENDDATE-RXSTARTDATE) end as rxsupply_updated
                 from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS"
                 where SourceRxMedName ILIKE ANY ('%Betamethasone%','%BUDESONIDE%','%CORTISONE%','%DEFLAZACORT%','%HYDROCORTISONE%',
                                                  '%METHYLPREDNISOLONE%','%PREDNISOLONE%',
                                           '%PREDNISONE%','%TRIAMCINOLONE%') AND  rxsupply_updated != '0'  AND rxsupply_updated is NOT NULL
                AND DOSE is NOT NULL AND  RXQUANTITY is NOT NULL ) )
                 WHERE (SOURCERXMEDNAME ILIKE '%Betamethasone%' AND daily_dose >= 3)
                 OR (SOURCERXMEDNAME ILIKE '%Budesonide%' AND daily_dose >= 1.5)
                 OR (SOURCERXMEDNAME ILIKE '%Cortisone %' AND daily_dose >= 100)
                 OR (SOURCERXMEDNAME ILIKE '%Deflazacort%' AND daily_dose >= 24)
                 OR (SOURCERXMEDNAME ILIKE '%Dexamethasone%' AND daily_dose >= 3)
                 OR (SOURCERXMEDNAME ILIKE '%Hydrocortisone%' AND daily_dose >= 80)
                 OR (SOURCERXMEDNAME ILIKE '%Methylprednisolone%' AND daily_dose >= 16)
                 OR (SOURCERXMEDNAME ILIKE '%Prednisolone%' AND daily_dose >= 20)
                 OR (SOURCERXMEDNAME ILIKE '%Prednisone%' AND daily_dose >= 20)
                 OR (SOURCERXMEDNAME ILIKE '%Triamcinolone%' AND daily_dose >= 16)
                  
                
  
  UNION ALL 
              
              select * from (select patientid, ((DOSE*FILLEDQUANTITY)/DAYSSUPPLY) as daily_dose,SourceDrugName, drugdate from (
                  select patientid,SourceDrugName,FILLEDDATE as drugdate,REGEXP_SUBSTR(DOSAGE,'[\\d*]') as DOSE, DAYSSUPPLY,FILLEDQUANTITY
                 from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS"
                 where SourceDrugName ILIKE ANY ('%Betamethasone%','%BUDESONIDE%','%CORTISONE%','%DEFLAZACORT%','%HYDROCORTISONE%',
                                                 '%METHYLPREDNISOLONE%','%PREDNISOLONE%',
                                           '%PREDNISONE%','%TRIAMCINOLONE%') AND  DAYSSUPPLY != '0'  AND DAYSSUPPLY is NOT NULL
                AND DOSE is NOT NULL AND  FILLEDQUANTITY is NOT NULL ) )
                 WHERE (SourceDrugName ILIKE '%Betamethasone%' AND daily_dose >= 3)
                 OR (SourceDrugName ILIKE '%Budesonide%' AND daily_dose >= 1.5)
                 OR (SourceDrugName ILIKE '%Cortisone %' AND daily_dose >= 100)
                 OR (SourceDrugName ILIKE '%Deflazacort%' AND daily_dose >= 24)
                 OR (SourceDrugName ILIKE '%Dexamethasone%' AND daily_dose >= 3)
                 OR (SourceDrugName ILIKE '%Hydrocortisone%' AND daily_dose >= 80)
                 OR (SourceDrugName ILIKE '%Methylprednisolone%' AND daily_dose >= 16)
                 OR (SourceDrugName ILIKE '%Prednisolone%' AND daily_dose >= 20)
                 OR (SourceDrugName ILIKE '%Prednisone%' AND daily_dose >= 20)
                 OR (SourceDrugName ILIKE '%Triamcinolone%' AND daily_dose >= 16)  ) corti_names
        on inclusion_both.patientid = corti_names.patientid
     where drugdate >= ((indexdate) - 30) and drugdate < indexdate 
   ) 
                     
       select distinct MASTERPATIENTID from immuno_pat
    UNION ALL
        select distinct MASTERPATIENTID from corti_pat     
              
  
  
  