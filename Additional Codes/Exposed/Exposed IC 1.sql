## Receipt of solid organ or islet transplant


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
             
 INNER JOIN (Select patientid, dxdate from (
                          SELECT patientid, pxdate as dxdate
                          FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES"
                          where pxcode in ('0055U','0087U','0088U','0141T','0142T','0143T','0584T','0585T','0586T','23440','29868','32851','32852','32853','32854',
                                           '33927','33929','33935','33945','38240','38241','38242','38243','43625','44135','44136','44137','47135','47136','48160',
                                           '48554','48556','50340','50360','50365','50366','50370','50380','60510','60512','65710','65720','65725','65730','65740',
                                           '65745','65750','65755','65756','65767','65780','65781','65782','76776','76778','81595','G0341','G0342','G0343','G8727',
                                           'S2052','S2053','S2054','S2060','S2065','S2102','S2103','S2109','S2142','S2150','S2152','02Y','02YA','02YA0Z0','02YA0Z1',
                                           '02YA0Z2','07Y','07YM','07YM0Z0','07YM0Z1','07YM0Z2','07YP','07YP0Z0','07YP0Z1','07YP0Z2',
                                           '0BY','0BYC','0BYC0Z0','0BYC0Z1','0BYC0Z2','0BYD','0BYD0Z0','0BYD0Z1','0BYD0Z2','0BYF','0BYF0Z0','0BYF0Z1','0BYF0Z2','0BYG',
                                           '0BYG0Z0','0BYG0Z1','0BYG0Z2','0BYH','0BYH0Z0','0BYH0Z1','0BYH0Z2','0BYJ','0BYJ0Z0','0BYJ0Z1','0BYJ0Z2','0BYK','0BYK0Z0',
                                           '0BYK0Z1','0BYK0Z2','0BYL','0BYL0Z0','0BYL0Z1','0BYL0Z2','0BYM','0BYM0Z0','0BYM0Z1','0BYM0Z2','0DY','0DY5','0DY50Z0','0DY50Z1',
                                           '0DY50Z2','0DY6','0DY60Z0','0DY60Z1','0DY60Z2','0DY8','0DY80Z0','0DY80Z1','0DY80Z2','0DYE','0DYE0Z0','0DYE0Z1','0DYE0Z2','0FY',
                                           '0FY0','0FY00Z0','0FY00Z1','0FY00Z2','0FYG','0FYG0Z0','0FYG0Z1','0FYG0Z2','0TY','0TY0','0TY00Z0','0TY00Z1','0TY00Z2','0TY1',
                                           '0TY10Z0','0TY10Z1','0TY10Z2','0UY','0UY0','0UY00Z0','0UY00Z1','0UY00Z2','0UY1','0UY10Z0','0UY10Z1','0UY10Z2','0UY9','0UY90Z0',
                                           '0UY90Z1','0UY90Z2','0WY','0WY2','0WY20Z0','0WY20Z1','0XY','0XYJ','0XYJ0Z0','0XYJ0Z1','0XYK','0XYK0Z0','0XYK0Z1') 
                                            and pxdate is not null
                        UNION ALL
                          SELECT patientid, dxdate
                          FROM "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                          where dxcode in ('C80.2','I25.750','I25.751','I25.758','I25.759','I25.760','I25.761','I25.768','I25.769','I25.811',
                                           'I25.812','M31.11','T86.10','T86.11','T86.12','T86.13','T86.19','T86.20','T86.21','T86.22','T86.23',
                                           'T86.290','T86.298','T86.30','T86.31','T86.32','T86.33','T86.39','T86.40','T86.41','T86.42','T86.43',
                                           'T86.49','T86.810','T86.811','T86.812','T86.818','T86.819','T86.8401','T86.8402','T86.8403','T86.8409',
                                           'T86.8411','T86.8412','T86.8413','T86.8419','T86.8421','T86.8422','T86.8423','T86.8429','T86.8481',
                                           'T86.8482','T86.8483','T86.8489','T86.8491','T86.8492','T86.8493','T86.8499','T86.850','T86.851',
                                           'T86.852','T86.858','T86.859','T86.890','T86.891','T86.892','T86.898','T86.899','T86.90','T86.91',
                                           'T86.92','T86.93','T86.99','Y83.0','Z48.21','Z48.22','Z48.23','Z48.24','Z48.280','Z48.288','Z48.298',
                                           'Z94.0','Z94.1','Z94.2','Z94.3','Z94.4','Z94.5','Z94.6','Z94.7','Z94.82','Z94.83','Z94.89','Z94.9',
                                           'Z98.85',
                                          '429490004','737294004','429054002','13160009','30700006','33167004','44165003','58797008','313039003',
                                           '62438007','119596005','120158008','183655000','213148006','213152006','233933006','235911006','236570004',
                                           '236583003','254289008','269295009','312603000','429257001','431505005','441751006','444855007','737295003',
                                           '737296002','737297006','737298001','737299009','739024006','739025007','739027004','792842004','16058671000119103',
                                           '16058711000119104','16058831000119102','16058871000119104','233844002','233934000','213151004','432843002','432773004',
                                           '431896008','431186002','428103008','234520000','234519006','431953002','431862001','432782005','431456004','234522008','58797008',
                                           '426136000','707148007','213150003','236584009','236572007','236574008','236575009','236576005','236577001','236571000','236573002',
                                           '236582008','236578006','236579003','236580000','236581001','236587002','236588007','236589004','277010001','236569000','236614007',
                                           '1144941009','145781000119106','733207001','434270001','433804007','433600001','434238001','233634002','431223003','432774005',
                                           '432958009','431507002','79369007','431506006','433809002','434271002','433592008','434202008','233979001','234004000','234077006',
                                           '234008002','234079009','233971003','234066000','262945004','16058751000119103','235912004','213153001','213192008','314760005',
                                           '433087001','95742008','432265007','16058791000119108','314002005','420505005','421187003','420571002','432908002','432777003',
                                           '431222008','432772009','236585005','236586006','213086000','213085001','213127009','235910007','1197150002','1230342001','213088004',
                                           '314551004','314552006','314553001','314554007','737300001','739026008','271976009','213072004','213195005','213126000','281436001',
                                           '213084002','281437005','213083008','281435002','281438000','213087009','307210003','239185002','239182004','239187005','239183009',
                                           '403678005','403682007','403681000','403680004','427435004','427889009','428575007','427927008','122511000119103','429450002','429362002',
                                           '429514007','121131000119109','122491000119108','121121000119106','427928003','129781000119105','122501000119101','762618008','429451003',
                                           '703048006','713825007','122531000119108','128631000119109','236436003','277011002','445260006','445261005','234001008','773275000',
                                           '63541000119109','720587009','254290004','445964006','122521000119105','722957003','722956007','722958008','762316003','1156197003',
                                           '92831004','1153358006','348741000119101','348291000119100','174699007','61535006','70536003','6471000179103','175899003','782655004',
                                           '313030004','52213001','765478004','765479007','175902000','711411006','711413009','175901007','236138007','71947008','174691005','67562009',
                                           '345797001','76077004','277451006','174693008','174694002','174692003','18027006','27280000','28009009','174426002','174425003','426356008',
                                           '174427006','32413006','47058000','32477003','232973007','174802006','174809002','232974001','174808005','405768001','88039007','429332008',
                                           '62511003','232660006','232658009','232659001','232657004','271581005','39447008','33621000','91243005','22122007','721215004','52384003',
                                           '77556000','176337003','82316003','56283009','425616008','426463009','439008003','8773000','32956007','67075000','77368008',
                                           '34538004','120065003','58385009','713157005','34905004','62399001','29931007','359938001','359936002','265506006','3607009','7621005',
                                           '14377006','19463006','441754003','80070000','71221009','49624000','57363000','7937001','34815006','180000003','88417001','69428003',
                                           '120050004','119932003','119931005','870382003','120012005','119619005','119846002','9844000','37326001','71890008','55230008','764926003',
                                           '287239002','426984008','119743004','119757002','18919000','25263003','45669002','85503007','54636000','29507009','17228008','85890008',
                                           '75479001','27462006','50128001','21030008','90939008','9162006','269701007','270677005','671007','19811006','48772004','3268008','52771009',
                                           '119906009','359641007','14970003','59654003','264581005','56908006') and dxdate is not null)) solid_organ_transplant
            
                                     on inclusion_both.patientid = solid_organ_transplant.patientid
                                     where dxdate < indexdate
                                     
                                     
                                     
                                     
  ## Moderate or severe primary immunodeficiency
  
  
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
             
  inner join (select patientid, dxdate
               from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
               where dxcode IN ('D80.0','D80.1','D80.2','D80.3','D80.4','D80.5','D80.6','D80.7','D80.8','D80.9','D81.0',
                                'D81.1','D81.2','D81.30','D81.31','D81.32','D81.39','D81.4','D81.5','D81.6','D81.7',
                                'D81.810','D81.818','D81.819','D81.89','D81.9','D82.0','D82.1','D82.2','D82.3','D82.4','D82.8',
                                'D82.9','D83.0','D83.1','D83.2','D83.8','D83.9','D84.0','D84.1','D84.81','D84.821','D84.822','D84.89','D84.9',
                               '234532001','36138009','58606001','33286000','23238000','8808004','36070007','44940001','50926003','55602000',
                                '60743005','82286005','88714009','119250001','234539005','190979003','190980000','190981001','190986006','31323000',
                                '190996002','190997006','190998001','191001007','191002000','191008001','191011000','191012007','191013002','191018006',
                                '234645009','267460002','442459007','767263007','789777007','707152007','737307003','735536003','784393004',
                                '24181002','48119005','9893005','703525006','703540008','719685004','719824001','722288007','721903007','724275005',
                                '724276006','68504005','116133005','722281001','764858009','65880007','22406001','234534000','234533006','1230295000',
                                '4434006','764946008','766879006','403837005','763668009','766705006','765327005','89655007','718882006','725137007',
                                '111584000','350353007','351287008','89454001','770942003','770947009','775909002','783201001','783058007','783200000',
                                '782759001','783199003','1003381002','37548006','387759001','29272001','40197009','77330006','26252007','82317007',
                                '21527007','76243000','773702002','774211005','778023004','770625006','773730002','778024005','771515001','783099001',
                                '254067002','723995003','773404000','1177173001','1177175008','234146006','190995003','111396008','720520009','363009005',
                                '1187623009','58034007','403836001','783248004','783249007','403835002','363040003','1197428008','234583001','716871006',
                                '720986005','765145001','45390000','111587007','49555001','36980009','71904008','3439009','722067005','720853005','724361001',
                                '765188009','763623001','783617001','234570002','234571003','362993009','718107000','716378008','715982006','721977007',
                                '720345008','725135004','724177005','725136003','725290000','987840791000119102','771517009','782751003','1179284005',
                                '1229942009','1229941002','1229940001','717811007','724179008','766983005','771309000','773488000','771479000','234572005',
                                '783743009','782750002','783142006','784340000','829973009','1186712009','1186714005','1179288008','1179286007','1186715006',
                                '1179285006','1179300002','1197477000','1197478005','1197205005','1197479002','1222681008','449853003','703538003','702444009',
                                '1197361002','1197362009','711480000','719827008','768560008','77121009','1162830004','1162828001','778028008','778045003',
                                '771333006','773662009','770687001','773646003','773664005','770785002','783245001','784339002','234632005','718232007','722290008',
                                '718717004','723508002','723334006','723443003','724015007','763713000','234633000','234634006','234635007','234636008','234637004',
                                '234638009','234639001','234640004','234631003','234641000','7990002','234542004','234541006','234540007','234543009','449187006',
                                '449384005','234553005','234555003','234554004','818950005','726078000','699861000','234573000','234574006','105602005','17182001',
                                '713530002','421312009','1144929002','350691000119103','1162505005','105601003','70349007','303011007','234576008','767658000',
                                '234423001','248693006','784392009','247860002','78378009','24974008','46359005','416729007','41814009','234425008','772126000',
                                '191347008','234424007','267540007','191338000','129643009','47318007','56918001','3902000','276628009','1156296001','55444004',
                                '722925004','80255009','722926003','276576000','14333004','191345000','129641006','1156300000','65623009','111585004','32092008',
                                '409089005','414850009','735435002','735434003','47144000','80369006','63484008','234426009','71610005','129639005','127067009',
                                '302874002','234577004','234591005','234436001','234437005','430478003','1156801007','1197594000','1153417000','190959006',
                                '782915004','713444005','398250003','234581004','1187233008','234582006','234580003','71436005','1197482007','234585008',
                                '234589002','234590006','234433009','234587000','234588005','234586009','234578009','234579001','1197483002','234564008',
                                '234566005','234565009','234556002','234557006','234558001','234560004','234561000','234559009','234562007','234563002',
                                '783205005','234584007','1186652002','1186719000','1173999006','1186721005','1186720006','1186654001','1186725001','1172895006',
                                '718230004','721877008','721876004','719814009','725151007','725432008','725431001','723385003','725150008','723384004',
                                '723386002','716869006','1197415001','1172892009','24419001','24743004','771078002','234604001','81166004','234605000','234607008',
                                '234593008','771443008','234594002','234595001','234596000','234597009','234598004','234599007','234600005','234601009',
                                '234602002','234628004','234629007','234630002','234618008','39674000','234621005','783621008','778027003','234627009',
                                '783007005','234623008','234626000','234624002','234622003','234619000','234620006','234625001','234608003','263661007',
                                '234613004','234609006','234611002','234612009','234615006','234617003','1162263002','234616007','234614005','18827005',
                                '1197476009','1197366007','417167007','234544003','12631000119106','234550008','234546001','234548000','234549008',
                                '16894711000119103','16894671000119102','234547005','29260007','840472009','234551007','234552000','62479008','10746341000119109',
                                '420721002','697965002','421766003','421102007','420938005','420384005','421597001','700053002','422189002','420801006',
                                '421706001','421983003','422282000','420302007','420524008','421283008','420691000','422136003','421929001','421660003',
                                '445945000','422337001','421415007','420554003','421883002','420403001','420877009','421047005','422127002','421403008',
                                '420818005','421571007','421431004','421454008','420764009','421708000','420945005','421710003','420544002','420787001',
                                '421077004','421508002','420395004','420549007','420321004','421998001','420452002','230202002','421315006','422089004',
                                '420718004','421827003','420244003','420774007','421529006','420614009','421023003','420900006','421460008','420308006',
                                '422012004','420658009','421230000','421272004','421394009','420281004','422194002','421874007','422177004','421671002',
                                '234642007','234643002','783150002','103079001','10838971000119103','771073006','103081004','103077004','103080003','103078009',
                                '402792003','402791005','422189002','420801006','421706001','421983003','422282000','420302007','420524008','421283008',
                                '420691000','422136003','421929001','421660003','445945000','422337001','421415007','420554003','421883002','420403001',
                                '420877009','421047005','422127002','421403008','420818005','421571007','421431004','421454008','420764009','421708000',
                                '420945005','421710003','420544002','420787001','421077004','421508002','420395004','420549007','420321004','421998001',
                                '420452002','230202002','421315006','422089004','420718004','421827003','420244003','420774007','421529006','420614009',
                                '421023003','420900006','416729007','421460008','420308006','421312009','422012004','420658009','421230000','421272004',
                                '421394009','420281004','422194002','421874007','422177004','421671002','234642007','234643002','783150002','234645009',
                                '103079001','771073006','191008001','103081004','103077004','103080003','103078009','191013002','191011000','191012007',
                                '403837005','403836001','783248004','783249007','403835002','773730002','16318001000119107','16318061000119108','1197476009',
                                '234542004','234541006','190979003','234540007','190981001','190980000','716871006','720986005','55602000','765145001',
                                '45390000','111587007','49555001','36980009','71904008','22406001','3439009','190996002','111584000','350353007','351287008',
                                '191001007','191002000','190997006','722067005','720853005','724361001','765188009','763623001','783617001','789777007',
                                '190998001','234570002','234571003','362993009','718107000','716378008','715982006','721977007','720345008','725135004',
                                '724177005','725136003','725290000','44940001','771517009','782751003','1179284005','1229942009','1229941002','1229940001',
                                '719685004','719824001','717811007','724275005','724179008','766879006','766983005','771309000','773488000','774211005',
                                '771479000','770625006','771515001','234572005','783743009','783099001','782750002','783142006','784340000','254067002',
                                '723995003','773404000','1177173001','1177175008','234146006','829973009','1186712009','1187623009','1186714005','1179288008',
                                '1179286007','1186715006','1179285006','1179300002','1197477000','1197478005','1197205005','1197428008','1197479002',
                                '1222681008',
                                '31323000')) Primary_Immunodeficiency_Diagnoses
             on inclusion_both.patientid = Primary_Immunodeficiency_Diagnoses.patientid
             where (dxdate >= ((indexdate) - 365) AND dxdate < indexdate)
             
             
             
             
  ## ESRD or dialysis treatment
  
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
             
             inner join (Select patientid, dxdate from (
                                      SELECT patientid, pxdate as dxdate
                                      FROM "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES"
                                      where pxcode in ('G8727','0505F','0507F','36488','36489','36490','36491','36800','36810','36815','36838','36901',
                                                       '36902','36903','36904','36905','36906','36907','36908','36909','4052F','4053F','4054F','4055F',
                                                       '49418','49421','90935','90937','90939','90940','90941','90942','90943','90944','90945','90947',
                                                       '90963','90964','90965','90966','90967','90968','90969','90970','90976','90977','90978','90979',
                                                       '90982','90983','90984','90985','90988','90990','90991','90992','90994','90999','93985','93986',
                                                       '93990','99512','99559','A4653','A4680','A4690','A4706','A4707','A4708','A4709','A4714','A4719',
                                                       'A4720','A4721','A4722','A4723','A4724','A4725','A4726','A4730','A4740','A4750','A4755','A4760',
                                                       'A4765','A4766','A4801','A4802','A4820','A4860','A4870','A4890','A4900','A4901','A4905','A4918',
                                                       'C1750','C1752','E1520','E1530','E1540','E1550','E1560','E1575','E1580','E1590','E1592','E1594',
                                                       'E1600','E1610','E1615','E1620','E1625','E1630','E1634','E1636','E1638','E1640','G0365','G0392',
                                                       'G0393','G8081','G8082','G8085','G8714','G8715','G8956','G9239','G9240','G9241','G9264','G9265',
                                                       'G9266','G9523','K0610','S9335','S9339','B50W','B50W0ZZ','B50W1ZZ','B50WYZZ','B51W','B51W0ZA',
                                                       'B51W0ZZ','B51W1ZA','B51W1ZZ','B51WYZA','B51WYZZ','B51WZZA','B51WZZZ') 
                                                        and pxdate is not null
                                    UNION ALL
                                      SELECT patientid, dxdate
                                      FROM "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                                      where dxcode in ('Z49.01','Z49.02','Z49.31','Z49.32','Z99.2') and dxdate is not null
                                    UNION ALL
                                      SELECT patientid, dxdate
                                      FROM "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                                      where dxcode in ('I12.0','I13.11','I13.2','N18.6') and dxdate is not null)) ESRD
                      ON inclusion_both.patientid = ESRD.patientid
                                   where (dxdate >= ((indexdate) - 365) AND dxdate < indexdate)
                                   
                                   
                                   
  ##Solid tumors or hematological malignancies on treatment
  
  
WITH  ST_or_HM as (
 select distinct inclusion_both.masterpatientid, inclusion_both.indexdate, inclusion_both.patientid from (
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
             
  ---------any_malignancy_or_metastatic_solid_tumor           
   inner join (Select patientid, dxdate from (
                                                      SELECT patientid, dxdate
                                                      FROM "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                                                      where dxcode in ('C00.0','C00.1','C70','C70.1','C70.9','C71.0','C71','C71.1','C71.2','C71.3',
                                                                       'C71.4','C71.5','C71.6','C71.7','C71.8','C71.9','C72.0','C72.1','C72.20','C72.2',
                                                                       'C72.21','C72.22','C72.30','C72.3','C72.31','C72.32','C72.40','C72.4','C72.41',
                                                                       'C72.42','C72.50','C72.5','C72.59','C72.9','C00','C00.2','C00.3','C00.4','C00.5',
                                                                       'C00.6','C00.8','C00.9','C02.0','C02.1','C01','C02','C02.2','C02.4','C02.8','C70.0',
                                                                       'C03.0','C03.1','C03.9','C04.8','C04.9','C04','C05.0','C05.1','C05.2','C05',
                                                                       'C05.8','C05.9','C06.0','C06.1','C06.2','C06','C06.80','C06.89','C06.9','C08.0',
                                                                       'C08.1','C08.9','C07','C08','C09.0','C09.1','C09.8','C09','C09.9','C10.0','C10.1',
                                                                       'C10.2','C10','C10.3','C10.4','C10.8','C10.9','C11.0','C11.1','C11.2','C11','C11.3',
                                                                       'C11.8','C11.9','C13.0','C13.1','C13.2','C12','C13','C13.8','C13.9','C14.0','C14.2',
                                                                       'C14.8','C15.3','C15.4','C15.5','C15','C15.8','C15.9','C16.0','C16.1','C16.2','C16',
                                                                       'C16.3','C16.4','C16.5','C16.8','C16.9','C17.0','C17.1','C17.2','C17','C03','C18.0',
                                                                       'C18.1','C18.2','C18','C18.3','C18.4','C18.5','C18.6','C18.7','C18.8','C18.9','C21.0',
                                                                       'C21.1','C21.2','C19','C20','C21','C22.0','C22.1','C22.2','C22.3','C22','C22.4',
                                                                       'C22.7','C22.9','C24.0','C24.1','C24.8','C24.9','C23','C24','C25.0','C25.1','C25.2',
                                                                       'C25.3','C25','C25.4','C25.7','C25.8','C25.9','C26.0','C26.1','C26.9','C30.0','C26',
                                                                       'C30.1','C31.0','C31.1','C30','C31.2','C31.3','C31','C31.9','C32.0','C32.1','C32.2',
                                                                       'C32.3','C32','C32.8','C32.9','C34.00','C34.01','C34.02','C34.10','C33','C34','C34.0',
                                                                       'C34.11','C34.12','C34.2','C34.1','C34.30','C34.31','C34.32','C34.3','C34.8','C34.91',
                                                                       'C34.9','C34.92','C38.0','C37','C38','C38.1','C38.2','C38.3','C38.4','C38.8','C39.0',
                                                                       'C39','C39.9','C40.00','C40','C40.0','C40.01','C40.02','C40.10','C40.1','C40.11',
                                                                       'C40.12','C40.20','C40.2','C40.21','C40.22','C40.30','C40.3','C40.31','C40.32',
                                                                       'C40.80','C40.81','C40.82','C40.90','C40.9','C40.91','C40.92','C41.0','C41','C41.1',
                                                                       'C41.2','C41.3','C41.4','C41.9','C43.0','C43','C43.10','C43.1','C43.11','C43.111',
                                                                       'C43.112','C43.12','C43.121','C43.122','C43.20','C43.2','C43.21','C43.22','C43.30',
                                                                       'C43.3','C43.31','C43.39','C43.4','C43.51','C43.5','C43.52','C43.62','C43.70','C43.71',
                                                                       'C43.72','C43.7','C43.8','C43.9','C45.0','C45.1','C45.2','C45','C45.7','C45.9','C46.0',
                                                                       'C46.1','C46.2','C46','C46.3','C46.4','C46.50','C46.51','C46.52','C46.5','C46.7','C46.9',
                                                                       'C47.10','C47.11','C47.12','C47','C47.20','C47.21','C47.22','C47.3','C47.2','C47.4',
                                                                       'C47.5','C47.6','C47.8','C47.9','C48.0','C48.1','C48.2','C48.8','C48','C49.0','C49.10',
                                                                       'C49.11','C49.12','C49','C49.20','C49.1','C49.21','C49.22','C49.3','C49.2','C49.4',
                                                                       'C49.5','C49.6','C49.8','C49.9','C49.A0','C49.A1','C49.A2','C49.A4','C49.A','C49.A5',
                                                                       'C43.6','C4A.10','C4A.11','C4A.111','C4A.112','C4A.12','C4A.121','C4A.122','C4A.20',
                                                                       'C4A.21','C4A.22','C4A.30','C4A.2','C4A.31','C4A.39','C4A.4','C4A.3','C4A.51','C4A.52',
                                                                       'C4A.59','C4A.60','C4A.5','C4A.61','C4A.62','C4A.71','C4A.72','C4A.8','C4A.9','C4A.7',
                                                                       'C50.011','C50.012','C50.019','C50.021','C50.022','C50','C50.0','C50.01','C50.029',
                                                                       'C50.111','C50.112','C50.02','C50.119','C50.121','C50.122','C50.1','C50.11','C50.211',
                                                                       'C50.212','C50.219','C50.12','C50.221','C50.222','C50.2','C50.21','C50.229','C50.311',
                                                                       'C50.312','C50.22','C50.319','C50.321','C50.322','C50.3','C50.31','C50.329','C57.02',
                                                                       'C50.32','C4A','C50.412','C50.419','C50.421','C50.422','C50.42','C50.429','C50.511',
                                                                       'C50.512','C50.5','C50.51','C50.519','C50.521','C50.522','C50.52','C50.529','C50.611',
                                                                       'C50.612','C50.6','C50.61','C50.621','C50.622','C50.62','C50.629','C50.811','C50.812',
                                                                       'C50.8','C50.81','C50.819','C50.821','C50.822','C50.82','C50.829','C50.911','C50.912',
                                                                       'C50.9','C50.91','C50.919','C50.921','C50.922','C50.92','C50.929','C51.0','C51.1','C51',
                                                                       'C51.2','C51.8','C51.9','C53.0','C53.1','C52','C53','C53.9','C54.0','C54.1','C54',
                                                                       'C54.2','C54.3','C54.8','C54.9','C56.1','C56.2','C55','C56','C56.9','C57.00','C57.01',
                                                                       'C57','C57.0','C50.41','C57.12','C57.21','C57.2','C57.22','C57.3','C57.4','C57.7',
                                                                       'C57.8','C57.9','C60.0','C58','C60','C60.1','C60.2','C60.8','C60.9','C62.00','C57.10',
                                                                       'C62','C62.0','C62.01','C62.02','C62.10','C62.1','C62.11','C62.12','C62.92','C63.00',
                                                                       'C63.01','C63','C63.0','C63.02','C63.10','C63.11','C63.1','C63.12','C63.2','C63.7',
                                                                       'C63.8','C63.9','C64.1','C64.2','C64','C64.9','C65.1','C65.2','C65','C65.9','C66.1',
                                                                       'C66.2','C66','C66.9','C67.0','C67.1','C67','C67.2','C67.3','C67.5','C67.6','C67.7',
                                                                       'C67.8','C67.9','C68.0','C68.1','C68','C68.8','C68.9','C69.00','C69.01','C69','C69.0',
                                                                       'C69.02','C57.11','C69.12','C69.20','C69.21','C69.22','C69.30','C69.2','C69.31','C69.32',
                                                                       'C69.40','C69.3','C69.41','C69.42','C69.50','C69.4','C69.51','C69.52','C69.60','C69.5',
                                                                       'C69.61','C69.62','C69.81','C69.6','C69.82','C69.90','C69.91','C69.92','C74.00','C74.01',
                                                                       'C69.9','C74.02','C74.10','C74.11','C73','C74','C74.0','C74.12','C74.90','C74.91',
                                                                       'C74.1','C74.92','C75.0','C75.1','C74.9','C75.2','C75.3','C75.4','C75','C75.8','C75.9',
                                                                       'C76.0','C76.1','C76.2','C76.3','C76.40','C76','C76.41','C76.42','C76.50','C76.51',
                                                                       'C76.4','C76.52','C76.8','C7A.00','C76.5','C7A.010','C7A.011','C7A.012','C7A.020','C7A',
                                                                       'C7A.0','C7A.01','C7A.02','C69.1','C7A.025','C7A.026','C7A.090','C7A.091','C7A.09',
                                                                       'C7A.092','C7A.093','C7A.094','C7A.095','C7A.096','C7A.098','C7A.1','C7A.8','C80.0',
                                                                       'C80.1','C80','C80.2','C7A.023','C7A.024','C81.01','C81.02','C81.03','C81','C81.04',
                                                                       'C81.05','C81.06','C81.07','C81.08','C81.09','C81.10','C81.11','C81.12','C81.13','C81.1',
                                                                       'C81.14','C81.16','C81.17','C81.18','C81.19','C81.20','C81.21','C81.22','C81.23','C81.2',
                                                                       'C81.24','C81.25','C81.26','C81.27','C81.28','C81.29','C81.30','C81.31','C81.32','C81.33',
                                                                       'C81.3','C81.34','C81.35','C81.36','C81.37','C81.38','C81.39','C81.40','C81.41','C81.42',
                                                                       'C81.43','C81.4','C81.44','C81.45','C81.46','C81.70','C81.71','C81.72','C81.7','C81.73',
                                                                       'C81.74','C81.75','C81.76','C81.77','C81.78','C81.79','C81.90','C81.91','C81.92','C81.9',
                                                                       'C81.93','C81.94','C81.95','C81.96','C81.97','C81.98','C81.99','C82.00','C82.02','C82.03',
                                                                       'C82','C82.0','C82.04','C82.05','C82.06','C82.07','C82.08','C82.09','C82.10','C82.11',
                                                                       'C82.12','C82.1','C82.13','C82.14','C82.15','C82.16','C82.17','C82.18','C82.19','C82.20',
                                                                       'C82.22','C82.23','C82.2','C82.25','C82.26','C82.27','C82.28','C82.29','C82.30','C82.31',
                                                                       'C82.32','C82.33','C82.3','C82.34','C82.35','C82.36','C82.37','C82.38','C82.39','C82.40',
                                                                       'C82.4','C82.43','C82.45','C82.46','C82.47','C82.48','C82.49','C82.50','C82.51','C82.52',
                                                                       'C82.53','C82.5','C82.54','C82.55','C82.56','C82.57','C82.58','C82.59','C82.60','C82.61',
                                                                       'C82.62','C82.63','C82.6','C82.65','C82.66','C82.67','C82.68','C82.69','C82.80','C82.81',
                                                                       'C82.82','C82.83','C82.8','C82.84','C82.85','C82.86','C82.87','C82.88','C82.89','C82.90',
                                                                       'C82.91','C82.92','C82.93','C82.9','C82.94','C82.95','C82.96','C82.97','C82.98','C82.99',
                                                                       'C83.00','C83.01','C83.02','C83.03','C83','C83.0','C83.05','C83.06','C83.07','C83.08',
                                                                       'C83.09','C83.10','C83.11','C83.12','C83.13','C83.1','C83.15','C83.16','C83.17','C83.18',
                                                                       'C83.19','C83.30','C83.3','C83.31','C83.32','C83.33','C83.34','C83.36','C83.37','C83.38',
                                                                       'C83.50','C83.51','C83.5','C83.52','C83.54','C83.57','C83.58','C83.59','C83.70','C83.71',
                                                                       'C83.7','C83.72','C83.73','C83.74','C83.75','C83.76','C83.77','C83.78','C83.79','C83.80',
                                                                       'C83.81','C83.8','C83.82','C83.83','C83.84','C83.85','C83.86','C83.87','C83.88','C83.89',
                                                                       'C83.90','C83.91','C83.9','C83.92','C83.93','C83.94','C83.95','C83.96','C83.97','C83.98',
                                                                       'C83.99','C84.00','C84.01','C84','C84.0','C84.02','C84.03','C84.04','C84.05','C84.06',
                                                                       'C84.07','C84.08','C84.10','C84.11','C84.1','C84.12','C84.13','C84.16','C84.17','C84.18',
                                                                       'C84.19','C84.40','C84.41','C84.42','C84.4','C84.43','C84.44','C84.45','C84.46','C84.47',
                                                                       'C84.48','C84.49','C84.60','C84.62','C84.63','C84.6','C84.64','C84.65','C84.66','C84.67',
                                                                       'C84.68','C84.69','C84.70','C84.71','C84.72','C84.7','C84.73','C84.74','C84.75','C84.76',
                                                                       'C84.77','C84.78','C84.79','C84.90','C84.91','C84.92','C84.9','C84.93','C84.94','C84.95',
                                                                       'C84.96','C84.97','C84.98','C84.99','C84.A0','C84.A1','C84.A2','C84.A','C84.A3','C84.A4',
                                                                       'C84.A6','C84.A7','C84.A8','C84.A9','C84.Z2','C84.Z3','C84.Z4','C84.Z','C84.Z5','C84.Z6',
                                                                       'C84.Z7','C84.Z8','C84.Z9','C85.10','C85.11','C85.12','C85.13','C85','C85.1','C85.14',
                                                                       'C85.16','C85.17','C85.18','C85.19','C85.20','C85.21','C85.22','C85.23','C85.2','C85.24',
                                                                       'C85.25','C85.26','C85.27','C85.28','C85.29','C85.80','C85.81','C85.82','C85.83','C85.8',
                                                                       'C85.84','C85.85','C85.86','C85.87','C85.88','C85.89','C85.90','C85.91','C85.92','C85.93',
                                                                       'C85.9','C85.94','C85.96','C85.97','C85.98','C85.99','C86.0','C86.1','C86.2','C86.3','C86',
                                                                       'C86.4','C86.5','C86.6','C88.2','C88.3','C88','C88.0','C90.01','C90.02','C90.11','C90',
                                                                       'C90.0','C90.12','C90.20','C90.21','C90.1','C90.22','C90.30','C90.31','C90.2','C90.32',
                                                                       'C91.00','C91.01','C90.3','C91.02','C91.11','C91.12','C91','C91.0','C91.30','C91.31',
                                                                       'C91.32','C91.1','C91.40','C91.41','C91.3','C91.42','C91.50','C91.51','C91.4','C91.52',
                                                                       'C91.60','C91.61','C91.5','C91.62','C91.90','C91.91','C91.6','C91.92','C91.A0','C91.A1',
                                                                       'C91.9','C91.A2','C91.Z0','C91.Z1','C91.A','C91.Z2','C92.01','C92.02','C91.Z','C92.10',
                                                                       'C92.11','C92.12','C92','C92.0','C92.20','C92.21','C92.1','C92.22','C92.30','C92.31',
                                                                       'C92.2','C92.32','C92.40','C92.41','C92.3','C92.42','C92.50','C92.51','C92.4','C92.5',
                                                                       'C92.62','C92.6','C92.90','C92.91','C92.9','C92.92','C92.A1','C92.A2','C92.A','C92.Z0',
                                                                       'C92.Z1','C92.Z2','C92.Z','C93.00','C93.01','C93.02','C93','C93.0','C93.10','C93.11',
                                                                       'C93.12','C93.1','C93.30','C93.31','C93.32','C93.3','C93.90','C93.91','C93.92','C93.9',
                                                                       'C93.Z0','C93.Z1','C93.Z2','C93.Z','C94.01','C94.02','C94.20','C94','C94.0','C94.21',
                                                                       'C94.22','C94.2','C94.30','C94.31','C94.32','C94.3','C94.40','C94.41','C94.42','C94.4',
                                                                       'C94.6','C94.80','C94.81','C94.82','C94.8','C95.00','C95.01','C95.02','C95','C95.0',
                                                                       'C95.11','C95.12','C95.90','C95.1','C95.91','C95.92','C95.9','C96.0','C96.20','C96.21',
                                                                       'C96','C96.22','C96.2','C02.9','C81.0','C96.5','C96.6','C96.A','C96.Z','C72','C04.0',
                                                                       'C17.3','C06.8','C14','C22.8','C31.8','C34.80','C34.90','C43.59','C43.60','C40.8','C49.A3',
                                                                       'C49.A9','C47.1','C50.129','C50.619','C4A.1','C4A.6','C53.8','C50.4','C57.20','C67.4',
                                                                       'C57.1','C69.10','C75.5','C69.8','C7A.021','C7A.022','C81.15','C7A.019','C81.47','C81.48',
                                                                       'C82.01','C82.24','C82.41','C82.64','C83.04','C83.14','C83.39','C83.53','C83.55','C83.56',
                                                                       'C84.09','C84.14','C84.61','C96.4','C62.9','C62.90','C84.Z0','C85.15','C85.95','C88.8',
                                                                       'C88.9','C91.10','C92.00','C92.52','C92.60','C94.00','C95.10','C96.29','C96.9','C61',
                                                                       'C56.3','C84.7A','D45','C02.3','C04.1','C16.6','C17.8','C17.9','C21.8','C34.81','C34.82',
                                                                       'C43.61','C47.0','C4A.0','C4A.70','C50.411','C62.91','C69.11','C69.80','C7A.029','C81.00',
                                                                       'C81.49','C82.21','C82.42','C82.44','C83.35','C84.15','C84.A5','C84.Z1','C88.4','C90.00',
                                                                       'C90.10','C92.61','C92.A0',
                                                                      '91855006','91854005','91857003','91856007','12301000132103','277602003','413441006',
'91858008','413442004','91860005','445448008','444911000','91861009','109991003',
'110004001','425869007','110007008','404136008','716655008','109982002','448212009',
'404134006','109844006','277589003','277571004','277473004','109979007','277619001',
'118617000','188512009','188515006','188511002','188513004','188514005','188517003',
'188516007','92516002','92511007','92512000','92812005','92811003','92813000','92814006',
'188745007','122881000119107','92818009','92817004','127225006','277613000','449220000',
'847741000000106','404148006','109962001','109966003','109965004','109968002','109964000',
'93451002','426642002','188718006','445269007','414166008','715414009','308121000',
'702786004','109972003','109971005','109970006','420120006','446124001','446925001',
'445737002','445736006','118613001','93151007','39795003','68979007','109843000','
716859000','109988003','118605002','118599009','93528000','93520007','93521006',
'93522004','93523009','93524003','93525002','93526001','93527005','118610003',
'93492006','188587006','188591001','188586002','93487009','93488004','93489007',
'188593003','188592008','93501005','93493001','93494007','93495008','93496009',
'93497000','93498005','188562004','93500006','118609008','93510002','188577007',
'188580008','188576003','93505001','93506000','93507009','188582000','93509007',
'118608000','93519001','188567005','188570009','188566001','93514006','93515007',
'93516008','188572001','93518009','118602004','188536008','93530003','93531004','93532006',
'93533001','93534007','188541000','93536009','188529007','188524002','93541001',
'93542008','93543003','188531003','118606001','93547002','93548007','93549004',
'93550004','93551000','93552007','188551004','93554008','275524009','427374007',
'109985000','109842005','445227008','109385007','109389001','109390005','109391009',
'109392002','109388009','109386008','188029000','118614007','129000002','277637000',
'441962003','93141006','93133006','93134000','93135004','93136003','93137007','93138002',
'93139005','93140007','93143009','93142004','93152000','93144003','93145002','93146001',
'188648000','188645002','188649008','93150008','109841003','118607005','109976000',
'188725004','122951000119108','93169003','188498009','188487008','188502002','188505000',
'188501009','188503007','188500005','188504001','188507008','188506004','118612006',
'93190006','93182006','93183001','93184007','93185008','93186009','93187000','93188005',
'93189002','109980005','118600007','188676008','93199007','93191005','93192003','93193008',
'93194002','93195001','93196000','93197009','93198004','118615008','93200005','93201009',
'93202002','93203007','93204001','93205000','188032002','188030005','269581007','188044004',
'93655004','93215006','93224002','93225001','93640008','93641007','93643005','93651008',
'93653006','269579005','269580008','109383000','254645002','188366002','443488001',
'188242006','187833006','188156001','187900002','188280007','188015001','187999008',
'188019007','188009001','187991006','188189001','448675008','188261005','188191009',
'188241004','271323007','93870000','187767006','430621000','187828007','188147009',
'188163001','187906008','188256008','187952001','188326001','188327005','188325002',
'188321006','188322004','188324003','188339002','188243001','187760008','443679004',
'188361007','187637005','188247000','188157005','188180002','188478004','254980001',
'363406005','255077007','254611009','255056009','363357005','187653008','363504005',
'269475001','187752007','187692001','254969001','363505006','363418001','363484005',
'187801002','255072001','363509000','302816009','363432004','255052006','363503004',
'363438000','443487006','441559006','447100004','116691000119101','110002002','397009000',
'188669003','188668006','421418009','188754005','94148006','109378008','109853004',
'188744006','109989006','94704006','118618005','94715001','94707004','94708009',
'94709001','94710006','94711005','94712003','188627002','94714002','445738007',
'188732008','122901000119109','94716000','94719007','94718004','126675008','363227003',
'371481006','127016006','126920004','387837005','127230005','269476000','95194004',
'95186006','95187002','95188007','188612002','188609000','188613007','95192000',
'95193005','118601006','447989004','109267002','109847004','109879008','109347009',
'109348004','109912006','109911004','109371002','109838007','109835005','109948008',
'109886000','109878000','109830000','109384006','109368005','109369002','109822001',
'109833003','109824000','109887009','109874003','109367000','109832008','109831001',
'109848009','109919002','109839004','109851002','109837002','109349007','109836006',
'109823006','110013004','109885001','109977009','95210003','122981000119101','95209008',
'415111003','415112005','109992005','307649006','404143002','722529000','372087000',
'148911000119107','371962007','93659005','371963002','93665005','371966005','371967001',
'93669004','93670003','93671004','93672006','371968006','93674007','93675008',
'93676009','93679002','128466006','93683002','372092003','353421000119109',
'353501000119104','93687001','371970002','93689003','93715005','93716006',
'93717002','371971003','93725000','93723007','371975007','93727008','93726004','109834009',
'372137005','373090000','373091001','373089009','373088001','93728003','371976008','93738008',
'93740003','93743001','371977004','93744007','93745008','93746009','93747000','93748005',
'93749002','371978009','93755007','93756008','371980003','109840002','93761005','371981004',
'93764002','93766000','93767009','93768004','109876001','93771007','449803009','93773005',
'93775003','93779009','371983001','93781006','93783009','371984007','93787005','93789008',
'446189008','371986009','371987000','93796005','93797001','93802007','93807001','93808006',
'93809003','372139008','363745004','371989002','93816002','93818001','371990006','371991005',
'93824007','372119009','93825008','93826009','93829002','93831006','93832004','109357005',
'93835002','93836001','93837005','371992003','93839008','447109003','93841009','93843007',
'93844001','93846004','93848003','93849006','93850006','93851005','423195009','371993008',
'93854002','109370001','371995001','93860002','93861003','93862005','93863000','93867004',
'93868009','371996000','95214007','93871001','371997009','93874009','93875005','372110008',
'93876006','371998004','93882009','93883004','93884005','93885006','93886007','93889000',
'93890009','93891008','109915008','93894000','372112000','371999007','93915004','93917007',
'226521000119108','93923002','93928006','93931007','372001002','93932000',
'93933005','93934004','372002009','372003004','93939009','93941005','93942003',
'93943008','93944002','93946000','93948004','372004005','93951006','372115003',
'93953009','372005006','422736007','109921007','109947003','109931000','93961004',
'93962006','93964007','721567004','93966009','93967000','93968005','93969002','93970001',
'93971002','93972009','372006007','93974005','93976007','93977003','93978008','93980002',
'93984006','93985007','93986008','93987004','93989001','94092006','372107001','93994001',
'372009000','94003005','94004004','94006002','94048009','94049001','372010005','94050001',
'94057003','94059000','94062002','94063007','372012002','372013007','94067008','94068003',
'94069006','94071006','94072004','372014001','94075002','94076001','94077005','94078000',
'94080006','94082003','94086000','94087009','372016004','372017008','94096009','94098005',
'94101009','372020000','94102002','94103007','94104001','94105000','94109006','94111002',
'94113004','372022008','94115006','94116007','372133009','372135002','94117003','94118008',
'372023003','94120006','94121005','94122003','94123008','94124002','94125001','94126000',
'372024009','10708511000119100','94129007','372025005','94132005','94134006','94135007',
'372026006','372027002','372028007','94138009','94140004','94143002','94144008','444910004',
'415287001','373168002','95224004','95225003','95226002','188492005','188489006','188493000',
'95230004','95231000','446643000','254601002','302855005','427056005','188726003','426370008',
'188746008','188736006','425749006','118611004','95264000','188632001','188635004','188631008',
'188633006','95260009','188634000','95261008','188637007','95263006','277567002','109975001',
'190818004') 
                                                          and dxdate is not null
                                          UNION ALL
                                                      SELECT patientid, dxdate 
                                                      FROM "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                                                      where dxcode in ('C79.63','C77','C77.0','C77.1','C77.2','C77.3','C77.4','C77.5','C77.8','C77.9',
                                                                       'C78','C78.0','C78.00','C78.01','C78.02','C78.1','C78.2','C78.3','C78.30','C78.39',
                                                                       'C78.4','C78.5','C78.6','C78.7','C78.8','C78.80','C78.89','C79','C79.0','C79.00',
                                                                       'C79.01','C79.02','C79.1','C79.10','C79.11','C79.19','C79.2','C79.3','C79.31',
                                                                       'C79.32','C79.4','C79.40','C79.49','C79.5','C79.51','C79.52','C79.6','C79.60',
                                                                       'C79.61','C79.62','C79.7','C79.70','C79.71','C79.72','C79.8','C79.81','C79.82',
                                                                       'C79.89','C79.9','C7B','C7B.0','C7B.00','C7B.01','C7B.02','C7B.03','C7B.04','C7B.09',
                                                                       'C7B.1','C7B.8',
                                                                      '430556008','363346000','127250009','127267002','127245003','127232002','127261001',
                                                                       '127274007','127254000','254289008','372087000','94161006','94186002','94222008',
                                                                       '94217008','94225005','188462001','94246001','94297009','94313005','94347008',
                                                                       '94348003','94350006','94351005','94360002','94365007','353741000119106','369523007',
                                                                       '94381002','813671000000107','94391008','94392001','94395004','94396003','94398002',
                                                                       '94409002','94442001','94455000','94493005','269473008','94515004','94628003','188445006',
                                                                       '353561000119103','369530001','94579000','94580002','94649002','274088005','94663008',
                                                                       '128462008'
                                                                      ) and dxdate is not null)) any_malignancy_or_metastatic_solid_tumor 
                                      ON inclusion_both.patientid = any_malignancy_or_metastatic_solid_tumor.patientid
                                      where (dxdate >= ((indexdate) - 365) AND dxdate < indexdate)
  
  ),
  
 -------------------
 
 cancer_codes as 
   (Select patientid, drug_date from (
                                                    select patientid, medadminstartdate as drug_date
                                                    from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS"
                                                    where  ( lower(SOURCEMEDADMINMEDNAME) like	lower('%ABARELIX%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ABATACEPT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ABIRATERONE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ADO%TRASTUZUMAB EMTANSINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AFATINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AFLIBERCEPT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALDESLEUKIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALECTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%alemtuzumab%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALLOPURINOL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALTRETAMINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AMIFOSTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AMINOGLUTETHIMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ANASTROZOLE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ARSENIC%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ASPARAGINASE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ATEZOLIZUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AVELUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AXITINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AZACITIDINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BCG VACCINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%belimumab%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BELINOSTAT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BENDAMUSTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BEVACIZUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BEXAROTENE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BICALUTAMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BLEOMYCIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BLINATUMOMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BORTEZOMIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BOSUTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BRENTUXIMAB%VEDOTIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BUSULFAN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CABAZITAXEL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CABOZANTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CAPECITABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CARBOPLATIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CARFILZOMIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CARMUSTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CERITINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CETUXIMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CHLORAMBUCIL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CISPLATIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CLADRIBINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CLOFARABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%COBIMETINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CRIZOTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CROMOLYN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CROMOLYN%SODIUM%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CYCLOPHOSPHAMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CYTARABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DABRAFENIB%')
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
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VORINOSTAT%')


                                                    and medadminstartdate is not null)
                                                union all
                                                    select patientid, orderdate as drug_date
                                                    from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS"
                                                   where (lower(SOURCERXMEDNAME) like	lower('%ABARELIX%')
OR lower(SOURCERXMEDNAME) like	lower('%ABATACEPT%')
OR lower(SOURCERXMEDNAME) like	lower('%ABIRATERONE%')
OR lower(SOURCERXMEDNAME) like	lower('%ADO%TRASTUZUMAB EMTANSINE%')
OR lower(SOURCERXMEDNAME) like	lower('%AFATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%AFLIBERCEPT%')
OR lower(SOURCERXMEDNAME) like	lower('%ALDESLEUKIN%')
OR lower(SOURCERXMEDNAME) like	lower('%ALECTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%alemtuzumab%')
OR lower(SOURCERXMEDNAME) like	lower('%ALLOPURINOL%')
OR lower(SOURCERXMEDNAME) like	lower('%ALTRETAMINE%')
OR lower(SOURCERXMEDNAME) like	lower('%AMIFOSTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%AMINOGLUTETHIMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%ANASTROZOLE%')
OR lower(SOURCERXMEDNAME) like	lower('%ARSENIC%')
OR lower(SOURCERXMEDNAME) like	lower('%ASPARAGINASE%')
OR lower(SOURCERXMEDNAME) like	lower('%ATEZOLIZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%AVELUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%AXITINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%AZACITIDINE%')
OR lower(SOURCERXMEDNAME) like	lower('%BCG VACCINE%')
OR lower(SOURCERXMEDNAME) like	lower('%belimumab%')
OR lower(SOURCERXMEDNAME) like	lower('%BELINOSTAT%')
OR lower(SOURCERXMEDNAME) like	lower('%BENDAMUSTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%BEVACIZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%BEXAROTENE%')
OR lower(SOURCERXMEDNAME) like	lower('%BICALUTAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%BLEOMYCIN%')
OR lower(SOURCERXMEDNAME) like	lower('%BLINATUMOMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%BORTEZOMIB%')
OR lower(SOURCERXMEDNAME) like	lower('%BOSUTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%BRENTUXIMAB%VEDOTIN%')
OR lower(SOURCERXMEDNAME) like	lower('%BUSULFAN%')
OR lower(SOURCERXMEDNAME) like	lower('%CABAZITAXEL%')
OR lower(SOURCERXMEDNAME) like	lower('%CABOZANTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%CAPECITABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%CARBOPLATIN%')
OR lower(SOURCERXMEDNAME) like	lower('%CARFILZOMIB%')
OR lower(SOURCERXMEDNAME) like	lower('%CARMUSTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%CERITINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%CETUXIMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%CHLORAMBUCIL%')
OR lower(SOURCERXMEDNAME) like	lower('%CISPLATIN%')
OR lower(SOURCERXMEDNAME) like	lower('%CLADRIBINE%')
OR lower(SOURCERXMEDNAME) like	lower('%CLOFARABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%COBIMETINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%CRIZOTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%CROMOLYN%')
OR lower(SOURCERXMEDNAME) like	lower('%CROMOLYN%SODIUM%')
OR lower(SOURCERXMEDNAME) like	lower('%CYCLOPHOSPHAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%CYTARABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%DABRAFENIB%')
OR lower(SOURCERXMEDNAME) like	lower('%DACARBAZINE%')
OR lower(SOURCERXMEDNAME) like	lower('%DACTINOMYCIN%')
OR lower(SOURCERXMEDNAME) like	lower('%DANAZOL%')
OR lower(SOURCERXMEDNAME) like	lower('%DARATUMUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%DASATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%DAUNORUBICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%DECITABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%DEGARELIX%')
OR lower(SOURCERXMEDNAME) like	lower('%DENILEUKIN%DIFTITOX%')
OR lower(SOURCERXMEDNAME) like	lower('%DENOSUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%DEXAMETHASONE%')
OR lower(SOURCERXMEDNAME) like	lower('%DIETHYLSTILBESTROL%')
OR lower(SOURCERXMEDNAME) like	lower('%DIHEMATOPORPHYRIN%ETHER%')
OR lower(SOURCERXMEDNAME) like	lower('%DINUTUXIMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%DOCETAXEL%')
OR lower(SOURCERXMEDNAME) like	lower('%DOXORUBICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%DURVALUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%ELOTUZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%ENZALUTAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%EPIRUBICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%ERIBULIN%')
OR lower(SOURCERXMEDNAME) like	lower('%ERLOTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%ESTRADURIN%')
OR lower(SOURCERXMEDNAME) like	lower('%ESTRAMUSTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%ETOPOSIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%EVEROLIMUS%')
OR lower(SOURCERXMEDNAME) like	lower('%EXEMESTANE%')
OR lower(SOURCERXMEDNAME) like	lower('%FLOXURIDINE%')
OR lower(SOURCERXMEDNAME) like	lower('%FLUDARABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%FLUOROURACIL%')
OR lower(SOURCERXMEDNAME) like	lower('%FLUOXYMESTERONE%')
OR lower(SOURCERXMEDNAME) like	lower('%FLUTAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%FULVESTRANT%')
OR lower(SOURCERXMEDNAME) like	lower('%GEFITINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%GEMCITABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%GEMTUZUMAB%OZOGAMICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%GOSERELIN%')
OR lower(SOURCERXMEDNAME) like	lower('%HISTRELIN%')
OR lower(SOURCERXMEDNAME) like	lower('%TALIMOGENE%LAHERPAREPVEC%') OR lower(SOURCERXMEDNAME) like lower('%HUMAN%HERPESVIRUS%1%')
OR lower(SOURCERXMEDNAME) like	lower('%HYDROXYUREA%')
OR lower(SOURCERXMEDNAME) like	lower('%IBRITUMOMAB%TIUXETAN%')
OR lower(SOURCERXMEDNAME) like	lower('%IBRUTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%IDARUBICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%IDELALISIB%')
OR lower(SOURCERXMEDNAME) like	lower('%IFOSFAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%IFOSFAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%MESNA%')
OR lower(SOURCERXMEDNAME) like	lower('%IMATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%ALFA%2A%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%ALFA%2B%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%ALFACON%1%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%ALFA%N3%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%BETA%1A%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%BETA%1B%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%GAMMA%1B%')
OR lower(SOURCERXMEDNAME) like	lower('%IPILIMUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%IRINOTECAN%')
OR lower(SOURCERXMEDNAME) like	lower('%IXABEPILONE%')
OR lower(SOURCERXMEDNAME) like	lower('%IXAZOMIB%')
OR lower(SOURCERXMEDNAME) like	lower('%KETOCONAZOLE%')
OR lower(SOURCERXMEDNAME) like	lower('%LANREOTIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%LAPATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%LENALIDOMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%LENVATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%LETROZOLE%')
OR lower(SOURCERXMEDNAME) like	lower('%LEUCOVORIN%')
OR lower(SOURCERXMEDNAME) like	lower('%LEUPROLIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%LEVAMISOLE%')
OR lower(SOURCERXMEDNAME) like	lower('%LEVOLEUCOVORIN%')
OR lower(SOURCERXMEDNAME) like	lower('%LOMUSTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%LONSURF%')
OR lower(SOURCERXMEDNAME) like	lower('%MECHLORETHAMINE%')
OR lower(SOURCERXMEDNAME) like	lower('%MEDROXYPROGESTERONE%')
OR lower(SOURCERXMEDNAME) like	lower('%MEGESTROL%')
OR lower(SOURCERXMEDNAME) like	lower('%MELPHALAN%')
OR lower(SOURCERXMEDNAME) like	lower('%MERCAPTOPURINE%')
OR lower(SOURCERXMEDNAME) like	lower('%MESNA%')
OR lower(SOURCERXMEDNAME) like	lower('%METHOTREXATE%')
OR lower(SOURCERXMEDNAME) like	lower('%METHOXSALEN%')
OR lower(SOURCERXMEDNAME) like	lower('%MITOMYCIN%')
OR lower(SOURCERXMEDNAME) like	lower('%MITOTANE%')
OR lower(SOURCERXMEDNAME) like	lower('%MITOXANTRONE%')
OR lower(SOURCERXMEDNAME) like	lower('%NATALIZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%NECITUMUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%NELARABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%NILOTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%NILUTAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%NIRAPARIB%')
OR lower(SOURCERXMEDNAME) like	lower('%NIVOLUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%OBINUTUZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%OCTREOTIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%ofatumumab%')
OR lower(SOURCERXMEDNAME) like	lower('%OLAPARIB%')
OR lower(SOURCERXMEDNAME) like	lower('%OLARATUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%OMACETAXINE%')
OR lower(SOURCERXMEDNAME) like	lower('%OSIMERTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%OXALIPLATIN%')
OR lower(SOURCERXMEDNAME) like	lower('%PACLITAXEL%')
OR lower(SOURCERXMEDNAME) like	lower('%PALBOCICLIB%')
OR lower(SOURCERXMEDNAME) like	lower('%PAMIDRONATE%')
OR lower(SOURCERXMEDNAME) like	lower('%PANITUMUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%PANOBINOSTAT%')
OR lower(SOURCERXMEDNAME) like	lower('%PAZOPANIB%')
OR lower(SOURCERXMEDNAME) like	lower('%PEGASPARGASE%')
OR lower(SOURCERXMEDNAME) like	lower('%PEMBROLIZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%PEMETREXED%')
OR lower(SOURCERXMEDNAME) like	lower('%PENTOSTATIN%')
OR lower(SOURCERXMEDNAME) like	lower('%PERTUZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%PLICAMYCIN%')
OR lower(SOURCERXMEDNAME) like	lower('%POLYESTRADIOL%PHOSPHATE%')
OR lower(SOURCERXMEDNAME) like	lower('%POMALIDOMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%PONATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%PORFIMER%')
OR lower(SOURCERXMEDNAME) like	lower('%PRALATREXATE%')
OR lower(SOURCERXMEDNAME) like	lower('%PROCARBAZINE%')
OR lower(SOURCERXMEDNAME) like	lower('%RADIUM%CHLORIDE%RA%223%')
OR lower(SOURCERXMEDNAME) like	lower('%RALOXIFENE%')
OR lower(SOURCERXMEDNAME) like	lower('%RAMUCIRUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%REGORAFENIB%')
OR lower(SOURCERXMEDNAME) like	lower('%RIBOCICLIB%')
OR lower(SOURCERXMEDNAME) like	lower('%rituximab%')
OR lower(SOURCERXMEDNAME) like	lower('%ROMIDEPSIN%')
OR lower(SOURCERXMEDNAME) like	lower('%RUCAPARIB%')
OR lower(SOURCERXMEDNAME) like	lower('%RUXOLITINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%SAMARIUM%LEXIDRONAM%')
OR lower(SOURCERXMEDNAME) like	lower('%SIPULEUCEL%T%')
OR lower(SOURCERXMEDNAME) like	lower('%SONIDEGIB%')
OR lower(SOURCERXMEDNAME) like	lower('%SORAFENIB%')
OR lower(SOURCERXMEDNAME) like	lower('%STREPTOZOCIN%')
OR lower(SOURCERXMEDNAME) like	lower('%STRONTIUM%89%')
OR lower(SOURCERXMEDNAME) like	lower('%SUNITINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%TAMOXIFEN%')
OR lower(SOURCERXMEDNAME) like	lower('%TEMOZOLOMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%TEMSIROLIMUS%')
OR lower(SOURCERXMEDNAME) like	lower('%TENIPOSIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%TESTOLACTONE%')
OR lower(SOURCERXMEDNAME) like	lower('%THALIDOMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%THIOGUANINE%')
OR lower(SOURCERXMEDNAME) like	lower('%THIOTEPA%')
OR lower(SOURCERXMEDNAME) like	lower('%TIPIRACIL %') OR lower(SOURCERXMEDNAME) like ('%TRIFLURIDINE%')
OR lower(SOURCERXMEDNAME) like	lower('%TOPOTECAN%')
OR lower(SOURCERXMEDNAME) like	lower('%TOREMIFENE%')
OR lower(SOURCERXMEDNAME) like	lower('%TOSITUMOMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%TRABECTEDIN%')
OR lower(SOURCERXMEDNAME) like	lower('%TRAMETINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%TRASTUZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%TRETINOIN%')
OR lower(SOURCERXMEDNAME) like	lower('%TRIPTORELIN%')
OR lower(SOURCERXMEDNAME) like	lower('%URACIL%5%FU%')
OR lower(SOURCERXMEDNAME) like	lower('%VALRUBICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%VANDETANIB%')
OR lower(SOURCERXMEDNAME) like	lower('%VEMURAFENIB%')
OR lower(SOURCERXMEDNAME) like	lower('%VENETOCLAX%')
OR lower(SOURCERXMEDNAME) like	lower('%VINBLASTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%VINCRISTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%VINORELBINE%')
OR lower(SOURCERXMEDNAME) like	lower('%VISMODEGIB%')
OR lower(SOURCERXMEDNAME) like	lower('%VORINOSTAT%')

 
                                                    and orderdate is not null)
                                                union all
                                                    select patientid, filleddate as drug_date
                                                    from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS"
                                                    where (  lower(SOURCEDRUGNAME) like	lower('%ABARELIX%')
OR lower(SOURCEDRUGNAME) like	lower('%ABATACEPT%')
OR lower(SOURCEDRUGNAME) like	lower('%ABIRATERONE%')
OR lower(SOURCEDRUGNAME) like	lower('%ADO%TRASTUZUMAB EMTANSINE%')
OR lower(SOURCEDRUGNAME) like	lower('%AFATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%AFLIBERCEPT%')
OR lower(SOURCEDRUGNAME) like	lower('%ALDESLEUKIN%')
OR lower(SOURCEDRUGNAME) like	lower('%ALECTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%alemtuzumab%')
OR lower(SOURCEDRUGNAME) like	lower('%ALLOPURINOL%')
OR lower(SOURCEDRUGNAME) like	lower('%ALTRETAMINE%')
OR lower(SOURCEDRUGNAME) like	lower('%AMIFOSTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%AMINOGLUTETHIMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%ANASTROZOLE%')
OR lower(SOURCEDRUGNAME) like	lower('%ARSENIC%')
OR lower(SOURCEDRUGNAME) like	lower('%ASPARAGINASE%')
OR lower(SOURCEDRUGNAME) like	lower('%ATEZOLIZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%AVELUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%AXITINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%AZACITIDINE%')
OR lower(SOURCEDRUGNAME) like	lower('%BCG VACCINE%')
OR lower(SOURCEDRUGNAME) like	lower('%belimumab%')
OR lower(SOURCEDRUGNAME) like	lower('%BELINOSTAT%')
OR lower(SOURCEDRUGNAME) like	lower('%BENDAMUSTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%BEVACIZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%BEXAROTENE%')
OR lower(SOURCEDRUGNAME) like	lower('%BICALUTAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%BLEOMYCIN%')
OR lower(SOURCEDRUGNAME) like	lower('%BLINATUMOMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%BORTEZOMIB%')
OR lower(SOURCEDRUGNAME) like	lower('%BOSUTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%BRENTUXIMAB%VEDOTIN%')
OR lower(SOURCEDRUGNAME) like	lower('%BUSULFAN%')
OR lower(SOURCEDRUGNAME) like	lower('%CABAZITAXEL%')
OR lower(SOURCEDRUGNAME) like	lower('%CABOZANTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%CAPECITABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%CARBOPLATIN%')
OR lower(SOURCEDRUGNAME) like	lower('%CARFILZOMIB%')
OR lower(SOURCEDRUGNAME) like	lower('%CARMUSTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%CERITINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%CETUXIMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%CHLORAMBUCIL%')
OR lower(SOURCEDRUGNAME) like	lower('%CISPLATIN%')
OR lower(SOURCEDRUGNAME) like	lower('%CLADRIBINE%')
OR lower(SOURCEDRUGNAME) like	lower('%CLOFARABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%COBIMETINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%CRIZOTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%CROMOLYN%')
OR lower(SOURCEDRUGNAME) like	lower('%CROMOLYN%SODIUM%')
OR lower(SOURCEDRUGNAME) like	lower('%CYCLOPHOSPHAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%CYTARABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%DABRAFENIB%')
OR lower(SOURCEDRUGNAME) like	lower('%DACARBAZINE%')
OR lower(SOURCEDRUGNAME) like	lower('%DACTINOMYCIN%')
OR lower(SOURCEDRUGNAME) like	lower('%DANAZOL%')
OR lower(SOURCEDRUGNAME) like	lower('%DARATUMUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%DASATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%DAUNORUBICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%DECITABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%DEGARELIX%')
OR lower(SOURCEDRUGNAME) like	lower('%DENILEUKIN%DIFTITOX%')
OR lower(SOURCEDRUGNAME) like	lower('%DENOSUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%DEXAMETHASONE%')
OR lower(SOURCEDRUGNAME) like	lower('%DIETHYLSTILBESTROL%')
OR lower(SOURCEDRUGNAME) like	lower('%DIHEMATOPORPHYRIN%ETHER%')
OR lower(SOURCEDRUGNAME) like	lower('%DINUTUXIMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%DOCETAXEL%')
OR lower(SOURCEDRUGNAME) like	lower('%DOXORUBICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%DURVALUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%ELOTUZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%ENZALUTAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%EPIRUBICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%ERIBULIN%')
OR lower(SOURCEDRUGNAME) like	lower('%ERLOTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%ESTRADURIN%')
OR lower(SOURCEDRUGNAME) like	lower('%ESTRAMUSTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%ETOPOSIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%EVEROLIMUS%')
OR lower(SOURCEDRUGNAME) like	lower('%EXEMESTANE%')
OR lower(SOURCEDRUGNAME) like	lower('%FLOXURIDINE%')
OR lower(SOURCEDRUGNAME) like	lower('%FLUDARABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%FLUOROURACIL%')
OR lower(SOURCEDRUGNAME) like	lower('%FLUOXYMESTERONE%')
OR lower(SOURCEDRUGNAME) like	lower('%FLUTAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%FULVESTRANT%')
OR lower(SOURCEDRUGNAME) like	lower('%GEFITINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%GEMCITABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%GEMTUZUMAB%OZOGAMICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%GOSERELIN%')
OR lower(SOURCEDRUGNAME) like	lower('%HISTRELIN%')
OR lower(SOURCEDRUGNAME) like	lower('%TALIMOGENE%LAHERPAREPVEC%') OR lower(SOURCEDRUGNAME) like lower('%HUMAN%HERPESVIRUS%1%')
OR lower(SOURCEDRUGNAME) like	lower('%HYDROXYUREA%')
OR lower(SOURCEDRUGNAME) like	lower('%IBRITUMOMAB%TIUXETAN%')
OR lower(SOURCEDRUGNAME) like	lower('%IBRUTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%IDARUBICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%IDELALISIB%')
OR lower(SOURCEDRUGNAME) like	lower('%IFOSFAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%IFOSFAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%MESNA%')
OR lower(SOURCEDRUGNAME) like	lower('%IMATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%ALFA%2A%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%ALFA%2B%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%ALFACON%1%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%ALFA%N3%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%BETA%1A%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%BETA%1B%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%GAMMA%1B%')
OR lower(SOURCEDRUGNAME) like	lower('%IPILIMUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%IRINOTECAN%')
OR lower(SOURCEDRUGNAME) like	lower('%IXABEPILONE%')
OR lower(SOURCEDRUGNAME) like	lower('%IXAZOMIB%')
OR lower(SOURCEDRUGNAME) like	lower('%KETOCONAZOLE%')
OR lower(SOURCEDRUGNAME) like	lower('%LANREOTIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%LAPATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%LENALIDOMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%LENVATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%LETROZOLE%')
OR lower(SOURCEDRUGNAME) like	lower('%LEUCOVORIN%')
OR lower(SOURCEDRUGNAME) like	lower('%LEUPROLIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%LEVAMISOLE%')
OR lower(SOURCEDRUGNAME) like	lower('%LEVOLEUCOVORIN%')
OR lower(SOURCEDRUGNAME) like	lower('%LOMUSTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%LONSURF%')
OR lower(SOURCEDRUGNAME) like	lower('%MECHLORETHAMINE%')
OR lower(SOURCEDRUGNAME) like	lower('%MEDROXYPROGESTERONE%')
OR lower(SOURCEDRUGNAME) like	lower('%MEGESTROL%')
OR lower(SOURCEDRUGNAME) like	lower('%MELPHALAN%')
OR lower(SOURCEDRUGNAME) like	lower('%MERCAPTOPURINE%')
OR lower(SOURCEDRUGNAME) like	lower('%MESNA%')
OR lower(SOURCEDRUGNAME) like	lower('%METHOTREXATE%')
OR lower(SOURCEDRUGNAME) like	lower('%METHOXSALEN%')
OR lower(SOURCEDRUGNAME) like	lower('%MITOMYCIN%')
OR lower(SOURCEDRUGNAME) like	lower('%MITOTANE%')
OR lower(SOURCEDRUGNAME) like	lower('%MITOXANTRONE%')
OR lower(SOURCEDRUGNAME) like	lower('%NATALIZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%NECITUMUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%NELARABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%NILOTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%NILUTAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%NIRAPARIB%')
OR lower(SOURCEDRUGNAME) like	lower('%NIVOLUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%OBINUTUZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%OCTREOTIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%ofatumumab%')
OR lower(SOURCEDRUGNAME) like	lower('%OLAPARIB%')
OR lower(SOURCEDRUGNAME) like	lower('%OLARATUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%OMACETAXINE%')
OR lower(SOURCEDRUGNAME) like	lower('%OSIMERTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%OXALIPLATIN%')
OR lower(SOURCEDRUGNAME) like	lower('%PACLITAXEL%')
OR lower(SOURCEDRUGNAME) like	lower('%PALBOCICLIB%')
OR lower(SOURCEDRUGNAME) like	lower('%PAMIDRONATE%')
OR lower(SOURCEDRUGNAME) like	lower('%PANITUMUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%PANOBINOSTAT%')
OR lower(SOURCEDRUGNAME) like	lower('%PAZOPANIB%')
OR lower(SOURCEDRUGNAME) like	lower('%PEGASPARGASE%')
OR lower(SOURCEDRUGNAME) like	lower('%PEMBROLIZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%PEMETREXED%')
OR lower(SOURCEDRUGNAME) like	lower('%PENTOSTATIN%')
OR lower(SOURCEDRUGNAME) like	lower('%PERTUZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%PLICAMYCIN%')
OR lower(SOURCEDRUGNAME) like	lower('%POLYESTRADIOL%PHOSPHATE%')
OR lower(SOURCEDRUGNAME) like	lower('%POMALIDOMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%PONATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%PORFIMER%')
OR lower(SOURCEDRUGNAME) like	lower('%PRALATREXATE%')
OR lower(SOURCEDRUGNAME) like	lower('%PROCARBAZINE%')
OR lower(SOURCEDRUGNAME) like	lower('%RADIUM%CHLORIDE%RA%223%')
OR lower(SOURCEDRUGNAME) like	lower('%RALOXIFENE%')
OR lower(SOURCEDRUGNAME) like	lower('%RAMUCIRUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%REGORAFENIB%')
OR lower(SOURCEDRUGNAME) like	lower('%RIBOCICLIB%')
OR lower(SOURCEDRUGNAME) like	lower('%rituximab%')
OR lower(SOURCEDRUGNAME) like	lower('%ROMIDEPSIN%')
OR lower(SOURCEDRUGNAME) like	lower('%RUCAPARIB%')
OR lower(SOURCEDRUGNAME) like	lower('%RUXOLITINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%SAMARIUM%LEXIDRONAM%')
OR lower(SOURCEDRUGNAME) like	lower('%SIPULEUCEL%T%')
OR lower(SOURCEDRUGNAME) like	lower('%SONIDEGIB%')
OR lower(SOURCEDRUGNAME) like	lower('%SORAFENIB%')
OR lower(SOURCEDRUGNAME) like	lower('%STREPTOZOCIN%')
OR lower(SOURCEDRUGNAME) like	lower('%STRONTIUM%89%')
OR lower(SOURCEDRUGNAME) like	lower('%SUNITINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%TAMOXIFEN%')
OR lower(SOURCEDRUGNAME) like	lower('%TEMOZOLOMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%TEMSIROLIMUS%')
OR lower(SOURCEDRUGNAME) like	lower('%TENIPOSIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%TESTOLACTONE%')
OR lower(SOURCEDRUGNAME) like	lower('%THALIDOMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%THIOGUANINE%')
OR lower(SOURCEDRUGNAME) like	lower('%THIOTEPA%')
OR lower(SOURCEDRUGNAME) like	lower('%TIPIRACIL %') OR lower(SOURCEDRUGNAME) like ('%TRIFLURIDINE%')
OR lower(SOURCEDRUGNAME) like	lower('%TOPOTECAN%')
OR lower(SOURCEDRUGNAME) like	lower('%TOREMIFENE%')
OR lower(SOURCEDRUGNAME) like	lower('%TOSITUMOMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%TRABECTEDIN%')
OR lower(SOURCEDRUGNAME) like	lower('%TRAMETINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%TRASTUZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%TRETINOIN%')
OR lower(SOURCEDRUGNAME) like	lower('%TRIPTORELIN%')
OR lower(SOURCEDRUGNAME) like	lower('%URACIL %5%FU%')
OR lower(SOURCEDRUGNAME) like	lower('%VALRUBICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%VANDETANIB%')
OR lower(SOURCEDRUGNAME) like	lower('%VEMURAFENIB%')
OR lower(SOURCEDRUGNAME) like	lower('%VENETOCLAX%')
OR lower(SOURCEDRUGNAME) like	lower('%VINBLASTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%VINCRISTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%VINORELBINE%')
OR lower(SOURCEDRUGNAME) like	lower('%VISMODEGIB%')
OR lower(SOURCEDRUGNAME) like	lower('%VORINOSTAT%')


                                                    and filleddate is not null)))
                                                    
                                                    
 select distinct masterpatientid from ST_or_HM
 inner join cancer_codes
 on ST_or_HM.patientid = cancer_codes.patientid
 where drug_date >= ((indexdate)-365) AND drug_date < indexdate
 
 
   
   
     ##Solid tumors or hematological malignancies on treatment (NOT IN USE)
   
   
   select distinct masterpatientid from
   (select inclusion_both.masterpatientid, inclusion_both.patientid, 
    inclusion_both.indexdate from (
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
     
 
  inner join (Select patientid, dxdate from (
                                                      SELECT patientid, dxdate
                                                      FROM "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                                                      where dxcode in ('C00.0','C00.1','C70','C70.1','C70.9','C71.0','C71','C71.1','C71.2','C71.3',
                                                                       'C71.4','C71.5','C71.6','C71.7','C71.8','C71.9','C72.0','C72.1','C72.20','C72.2',
                                                                       'C72.21','C72.22','C72.30','C72.3','C72.31','C72.32','C72.40','C72.4','C72.41',
                                                                       'C72.42','C72.50','C72.5','C72.59','C72.9','C00','C00.2','C00.3','C00.4','C00.5',
                                                                       'C00.6','C00.8','C00.9','C02.0','C02.1','C01','C02','C02.2','C02.4','C02.8','C70.0',
                                                                       'C03.0','C03.1','C03.9','C04.8','C04.9','C04','C05.0','C05.1','C05.2','C05',
                                                                       'C05.8','C05.9','C06.0','C06.1','C06.2','C06','C06.80','C06.89','C06.9','C08.0',
                                                                       'C08.1','C08.9','C07','C08','C09.0','C09.1','C09.8','C09','C09.9','C10.0','C10.1',
                                                                       'C10.2','C10','C10.3','C10.4','C10.8','C10.9','C11.0','C11.1','C11.2','C11','C11.3',
                                                                       'C11.8','C11.9','C13.0','C13.1','C13.2','C12','C13','C13.8','C13.9','C14.0','C14.2',
                                                                       'C14.8','C15.3','C15.4','C15.5','C15','C15.8','C15.9','C16.0','C16.1','C16.2','C16',
                                                                       'C16.3','C16.4','C16.5','C16.8','C16.9','C17.0','C17.1','C17.2','C17','C03','C18.0',
                                                                       'C18.1','C18.2','C18','C18.3','C18.4','C18.5','C18.6','C18.7','C18.8','C18.9','C21.0',
                                                                       'C21.1','C21.2','C19','C20','C21','C22.0','C22.1','C22.2','C22.3','C22','C22.4',
                                                                       'C22.7','C22.9','C24.0','C24.1','C24.8','C24.9','C23','C24','C25.0','C25.1','C25.2',
                                                                       'C25.3','C25','C25.4','C25.7','C25.8','C25.9','C26.0','C26.1','C26.9','C30.0','C26',
                                                                       'C30.1','C31.0','C31.1','C30','C31.2','C31.3','C31','C31.9','C32.0','C32.1','C32.2',
                                                                       'C32.3','C32','C32.8','C32.9','C34.00','C34.01','C34.02','C34.10','C33','C34','C34.0',
                                                                       'C34.11','C34.12','C34.2','C34.1','C34.30','C34.31','C34.32','C34.3','C34.8','C34.91',
                                                                       'C34.9','C34.92','C38.0','C37','C38','C38.1','C38.2','C38.3','C38.4','C38.8','C39.0',
                                                                       'C39','C39.9','C40.00','C40','C40.0','C40.01','C40.02','C40.10','C40.1','C40.11',
                                                                       'C40.12','C40.20','C40.2','C40.21','C40.22','C40.30','C40.3','C40.31','C40.32',
                                                                       'C40.80','C40.81','C40.82','C40.90','C40.9','C40.91','C40.92','C41.0','C41','C41.1',
                                                                       'C41.2','C41.3','C41.4','C41.9','C43.0','C43','C43.10','C43.1','C43.11','C43.111',
                                                                       'C43.112','C43.12','C43.121','C43.122','C43.20','C43.2','C43.21','C43.22','C43.30',
                                                                       'C43.3','C43.31','C43.39','C43.4','C43.51','C43.5','C43.52','C43.62','C43.70','C43.71',
                                                                       'C43.72','C43.7','C43.8','C43.9','C45.0','C45.1','C45.2','C45','C45.7','C45.9','C46.0',
                                                                       'C46.1','C46.2','C46','C46.3','C46.4','C46.50','C46.51','C46.52','C46.5','C46.7','C46.9',
                                                                       'C47.10','C47.11','C47.12','C47','C47.20','C47.21','C47.22','C47.3','C47.2','C47.4',
                                                                       'C47.5','C47.6','C47.8','C47.9','C48.0','C48.1','C48.2','C48.8','C48','C49.0','C49.10',
                                                                       'C49.11','C49.12','C49','C49.20','C49.1','C49.21','C49.22','C49.3','C49.2','C49.4',
                                                                       'C49.5','C49.6','C49.8','C49.9','C49.A0','C49.A1','C49.A2','C49.A4','C49.A','C49.A5',
                                                                       'C43.6','C4A.10','C4A.11','C4A.111','C4A.112','C4A.12','C4A.121','C4A.122','C4A.20',
                                                                       'C4A.21','C4A.22','C4A.30','C4A.2','C4A.31','C4A.39','C4A.4','C4A.3','C4A.51','C4A.52',
                                                                       'C4A.59','C4A.60','C4A.5','C4A.61','C4A.62','C4A.71','C4A.72','C4A.8','C4A.9','C4A.7',
                                                                       'C50.011','C50.012','C50.019','C50.021','C50.022','C50','C50.0','C50.01','C50.029',
                                                                       'C50.111','C50.112','C50.02','C50.119','C50.121','C50.122','C50.1','C50.11','C50.211',
                                                                       'C50.212','C50.219','C50.12','C50.221','C50.222','C50.2','C50.21','C50.229','C50.311',
                                                                       'C50.312','C50.22','C50.319','C50.321','C50.322','C50.3','C50.31','C50.329','C57.02',
                                                                       'C50.32','C4A','C50.412','C50.419','C50.421','C50.422','C50.42','C50.429','C50.511',
                                                                       'C50.512','C50.5','C50.51','C50.519','C50.521','C50.522','C50.52','C50.529','C50.611',
                                                                       'C50.612','C50.6','C50.61','C50.621','C50.622','C50.62','C50.629','C50.811','C50.812',
                                                                       'C50.8','C50.81','C50.819','C50.821','C50.822','C50.82','C50.829','C50.911','C50.912',
                                                                       'C50.9','C50.91','C50.919','C50.921','C50.922','C50.92','C50.929','C51.0','C51.1','C51',
                                                                       'C51.2','C51.8','C51.9','C53.0','C53.1','C52','C53','C53.9','C54.0','C54.1','C54',
                                                                       'C54.2','C54.3','C54.8','C54.9','C56.1','C56.2','C55','C56','C56.9','C57.00','C57.01',
                                                                       'C57','C57.0','C50.41','C57.12','C57.21','C57.2','C57.22','C57.3','C57.4','C57.7',
                                                                       'C57.8','C57.9','C60.0','C58','C60','C60.1','C60.2','C60.8','C60.9','C62.00','C57.10',
                                                                       'C62','C62.0','C62.01','C62.02','C62.10','C62.1','C62.11','C62.12','C62.92','C63.00',
                                                                       'C63.01','C63','C63.0','C63.02','C63.10','C63.11','C63.1','C63.12','C63.2','C63.7',
                                                                       'C63.8','C63.9','C64.1','C64.2','C64','C64.9','C65.1','C65.2','C65','C65.9','C66.1',
                                                                       'C66.2','C66','C66.9','C67.0','C67.1','C67','C67.2','C67.3','C67.5','C67.6','C67.7',
                                                                       'C67.8','C67.9','C68.0','C68.1','C68','C68.8','C68.9','C69.00','C69.01','C69','C69.0',
                                                                       'C69.02','C57.11','C69.12','C69.20','C69.21','C69.22','C69.30','C69.2','C69.31','C69.32',
                                                                       'C69.40','C69.3','C69.41','C69.42','C69.50','C69.4','C69.51','C69.52','C69.60','C69.5',
                                                                       'C69.61','C69.62','C69.81','C69.6','C69.82','C69.90','C69.91','C69.92','C74.00','C74.01',
                                                                       'C69.9','C74.02','C74.10','C74.11','C73','C74','C74.0','C74.12','C74.90','C74.91',
                                                                       'C74.1','C74.92','C75.0','C75.1','C74.9','C75.2','C75.3','C75.4','C75','C75.8','C75.9',
                                                                       'C76.0','C76.1','C76.2','C76.3','C76.40','C76','C76.41','C76.42','C76.50','C76.51',
                                                                       'C76.4','C76.52','C76.8','C7A.00','C76.5','C7A.010','C7A.011','C7A.012','C7A.020','C7A',
                                                                       'C7A.0','C7A.01','C7A.02','C69.1','C7A.025','C7A.026','C7A.090','C7A.091','C7A.09',
                                                                       'C7A.092','C7A.093','C7A.094','C7A.095','C7A.096','C7A.098','C7A.1','C7A.8','C80.0',
                                                                       'C80.1','C80','C80.2','C7A.023','C7A.024','C81.01','C81.02','C81.03','C81','C81.04',
                                                                       'C81.05','C81.06','C81.07','C81.08','C81.09','C81.10','C81.11','C81.12','C81.13','C81.1',
                                                                       'C81.14','C81.16','C81.17','C81.18','C81.19','C81.20','C81.21','C81.22','C81.23','C81.2',
                                                                       'C81.24','C81.25','C81.26','C81.27','C81.28','C81.29','C81.30','C81.31','C81.32','C81.33',
                                                                       'C81.3','C81.34','C81.35','C81.36','C81.37','C81.38','C81.39','C81.40','C81.41','C81.42',
                                                                       'C81.43','C81.4','C81.44','C81.45','C81.46','C81.70','C81.71','C81.72','C81.7','C81.73',
                                                                       'C81.74','C81.75','C81.76','C81.77','C81.78','C81.79','C81.90','C81.91','C81.92','C81.9',
                                                                       'C81.93','C81.94','C81.95','C81.96','C81.97','C81.98','C81.99','C82.00','C82.02','C82.03',
                                                                       'C82','C82.0','C82.04','C82.05','C82.06','C82.07','C82.08','C82.09','C82.10','C82.11',
                                                                       'C82.12','C82.1','C82.13','C82.14','C82.15','C82.16','C82.17','C82.18','C82.19','C82.20',
                                                                       'C82.22','C82.23','C82.2','C82.25','C82.26','C82.27','C82.28','C82.29','C82.30','C82.31',
                                                                       'C82.32','C82.33','C82.3','C82.34','C82.35','C82.36','C82.37','C82.38','C82.39','C82.40',
                                                                       'C82.4','C82.43','C82.45','C82.46','C82.47','C82.48','C82.49','C82.50','C82.51','C82.52',
                                                                       'C82.53','C82.5','C82.54','C82.55','C82.56','C82.57','C82.58','C82.59','C82.60','C82.61',
                                                                       'C82.62','C82.63','C82.6','C82.65','C82.66','C82.67','C82.68','C82.69','C82.80','C82.81',
                                                                       'C82.82','C82.83','C82.8','C82.84','C82.85','C82.86','C82.87','C82.88','C82.89','C82.90',
                                                                       'C82.91','C82.92','C82.93','C82.9','C82.94','C82.95','C82.96','C82.97','C82.98','C82.99',
                                                                       'C83.00','C83.01','C83.02','C83.03','C83','C83.0','C83.05','C83.06','C83.07','C83.08',
                                                                       'C83.09','C83.10','C83.11','C83.12','C83.13','C83.1','C83.15','C83.16','C83.17','C83.18',
                                                                       'C83.19','C83.30','C83.3','C83.31','C83.32','C83.33','C83.34','C83.36','C83.37','C83.38',
                                                                       'C83.50','C83.51','C83.5','C83.52','C83.54','C83.57','C83.58','C83.59','C83.70','C83.71',
                                                                       'C83.7','C83.72','C83.73','C83.74','C83.75','C83.76','C83.77','C83.78','C83.79','C83.80',
                                                                       'C83.81','C83.8','C83.82','C83.83','C83.84','C83.85','C83.86','C83.87','C83.88','C83.89',
                                                                       'C83.90','C83.91','C83.9','C83.92','C83.93','C83.94','C83.95','C83.96','C83.97','C83.98',
                                                                       'C83.99','C84.00','C84.01','C84','C84.0','C84.02','C84.03','C84.04','C84.05','C84.06',
                                                                       'C84.07','C84.08','C84.10','C84.11','C84.1','C84.12','C84.13','C84.16','C84.17','C84.18',
                                                                       'C84.19','C84.40','C84.41','C84.42','C84.4','C84.43','C84.44','C84.45','C84.46','C84.47',
                                                                       'C84.48','C84.49','C84.60','C84.62','C84.63','C84.6','C84.64','C84.65','C84.66','C84.67',
                                                                       'C84.68','C84.69','C84.70','C84.71','C84.72','C84.7','C84.73','C84.74','C84.75','C84.76',
                                                                       'C84.77','C84.78','C84.79','C84.90','C84.91','C84.92','C84.9','C84.93','C84.94','C84.95',
                                                                       'C84.96','C84.97','C84.98','C84.99','C84.A0','C84.A1','C84.A2','C84.A','C84.A3','C84.A4',
                                                                       'C84.A6','C84.A7','C84.A8','C84.A9','C84.Z2','C84.Z3','C84.Z4','C84.Z','C84.Z5','C84.Z6',
                                                                       'C84.Z7','C84.Z8','C84.Z9','C85.10','C85.11','C85.12','C85.13','C85','C85.1','C85.14',
                                                                       'C85.16','C85.17','C85.18','C85.19','C85.20','C85.21','C85.22','C85.23','C85.2','C85.24',
                                                                       'C85.25','C85.26','C85.27','C85.28','C85.29','C85.80','C85.81','C85.82','C85.83','C85.8',
                                                                       'C85.84','C85.85','C85.86','C85.87','C85.88','C85.89','C85.90','C85.91','C85.92','C85.93',
                                                                       'C85.9','C85.94','C85.96','C85.97','C85.98','C85.99','C86.0','C86.1','C86.2','C86.3','C86',
                                                                       'C86.4','C86.5','C86.6','C88.2','C88.3','C88','C88.0','C90.01','C90.02','C90.11','C90',
                                                                       'C90.0','C90.12','C90.20','C90.21','C90.1','C90.22','C90.30','C90.31','C90.2','C90.32',
                                                                       'C91.00','C91.01','C90.3','C91.02','C91.11','C91.12','C91','C91.0','C91.30','C91.31',
                                                                       'C91.32','C91.1','C91.40','C91.41','C91.3','C91.42','C91.50','C91.51','C91.4','C91.52',
                                                                       'C91.60','C91.61','C91.5','C91.62','C91.90','C91.91','C91.6','C91.92','C91.A0','C91.A1',
                                                                       'C91.9','C91.A2','C91.Z0','C91.Z1','C91.A','C91.Z2','C92.01','C92.02','C91.Z','C92.10',
                                                                       'C92.11','C92.12','C92','C92.0','C92.20','C92.21','C92.1','C92.22','C92.30','C92.31',
                                                                       'C92.2','C92.32','C92.40','C92.41','C92.3','C92.42','C92.50','C92.51','C92.4','C92.5',
                                                                       'C92.62','C92.6','C92.90','C92.91','C92.9','C92.92','C92.A1','C92.A2','C92.A','C92.Z0',
                                                                       'C92.Z1','C92.Z2','C92.Z','C93.00','C93.01','C93.02','C93','C93.0','C93.10','C93.11',
                                                                       'C93.12','C93.1','C93.30','C93.31','C93.32','C93.3','C93.90','C93.91','C93.92','C93.9',
                                                                       'C93.Z0','C93.Z1','C93.Z2','C93.Z','C94.01','C94.02','C94.20','C94','C94.0','C94.21',
                                                                       'C94.22','C94.2','C94.30','C94.31','C94.32','C94.3','C94.40','C94.41','C94.42','C94.4',
                                                                       'C94.6','C94.80','C94.81','C94.82','C94.8','C95.00','C95.01','C95.02','C95','C95.0',
                                                                       'C95.11','C95.12','C95.90','C95.1','C95.91','C95.92','C95.9','C96.0','C96.20','C96.21',
                                                                       'C96','C96.22','C96.2','C02.9','C81.0','C96.5','C96.6','C96.A','C96.Z','C72','C04.0',
                                                                       'C17.3','C06.8','C14','C22.8','C31.8','C34.80','C34.90','C43.59','C43.60','C40.8','C49.A3',
                                                                       'C49.A9','C47.1','C50.129','C50.619','C4A.1','C4A.6','C53.8','C50.4','C57.20','C67.4',
                                                                       'C57.1','C69.10','C75.5','C69.8','C7A.021','C7A.022','C81.15','C7A.019','C81.47','C81.48',
                                                                       'C82.01','C82.24','C82.41','C82.64','C83.04','C83.14','C83.39','C83.53','C83.55','C83.56',
                                                                       'C84.09','C84.14','C84.61','C96.4','C62.9','C62.90','C84.Z0','C85.15','C85.95','C88.8',
                                                                       'C88.9','C91.10','C92.00','C92.52','C92.60','C94.00','C95.10','C96.29','C96.9','C61',
                                                                       'C56.3','C84.7A','D45','C02.3','C04.1','C16.6','C17.8','C17.9','C21.8','C34.81','C34.82',
                                                                       'C43.61','C47.0','C4A.0','C4A.70','C50.411','C62.91','C69.11','C69.80','C7A.029','C81.00',
                                                                       'C81.49','C82.21','C82.42','C82.44','C83.35','C84.15','C84.A5','C84.Z1','C88.4','C90.00',
                                                                       'C90.10','C92.61','C92.A0',
                                                                      '91855006','91854005','91857003','91856007','12301000132103','277602003','413441006',
'91858008','413442004','91860005','445448008','444911000','91861009','109991003',
'110004001','425869007','110007008','404136008','716655008','109982002','448212009',
'404134006','109844006','277589003','277571004','277473004','109979007','277619001',
'118617000','188512009','188515006','188511002','188513004','188514005','188517003',
'188516007','92516002','92511007','92512000','92812005','92811003','92813000','92814006',
'188745007','122881000119107','92818009','92817004','127225006','277613000','449220000',
'847741000000106','404148006','109962001','109966003','109965004','109968002','109964000',
'93451002','426642002','188718006','445269007','414166008','715414009','308121000',
'702786004','109972003','109971005','109970006','420120006','446124001','446925001',
'445737002','445736006','118613001','93151007','39795003','68979007','109843000','
716859000','109988003','118605002','118599009','93528000','93520007','93521006',
'93522004','93523009','93524003','93525002','93526001','93527005','118610003',
'93492006','188587006','188591001','188586002','93487009','93488004','93489007',
'188593003','188592008','93501005','93493001','93494007','93495008','93496009',
'93497000','93498005','188562004','93500006','118609008','93510002','188577007',
'188580008','188576003','93505001','93506000','93507009','188582000','93509007',
'118608000','93519001','188567005','188570009','188566001','93514006','93515007',
'93516008','188572001','93518009','118602004','188536008','93530003','93531004','93532006',
'93533001','93534007','188541000','93536009','188529007','188524002','93541001',
'93542008','93543003','188531003','118606001','93547002','93548007','93549004',
'93550004','93551000','93552007','188551004','93554008','275524009','427374007',
'109985000','109842005','445227008','109385007','109389001','109390005','109391009',
'109392002','109388009','109386008','188029000','118614007','129000002','277637000',
'441962003','93141006','93133006','93134000','93135004','93136003','93137007','93138002',
'93139005','93140007','93143009','93142004','93152000','93144003','93145002','93146001',
'188648000','188645002','188649008','93150008','109841003','118607005','109976000',
'188725004','122951000119108','93169003','188498009','188487008','188502002','188505000',
'188501009','188503007','188500005','188504001','188507008','188506004','118612006',
'93190006','93182006','93183001','93184007','93185008','93186009','93187000','93188005',
'93189002','109980005','118600007','188676008','93199007','93191005','93192003','93193008',
'93194002','93195001','93196000','93197009','93198004','118615008','93200005','93201009',
'93202002','93203007','93204001','93205000','188032002','188030005','269581007','188044004',
'93655004','93215006','93224002','93225001','93640008','93641007','93643005','93651008',
'93653006','269579005','269580008','109383000','254645002','188366002','443488001',
'188242006','187833006','188156001','187900002','188280007','188015001','187999008',
'188019007','188009001','187991006','188189001','448675008','188261005','188191009',
'188241004','271323007','93870000','187767006','430621000','187828007','188147009',
'188163001','187906008','188256008','187952001','188326001','188327005','188325002',
'188321006','188322004','188324003','188339002','188243001','187760008','443679004',
'188361007','187637005','188247000','188157005','188180002','188478004','254980001',
'363406005','255077007','254611009','255056009','363357005','187653008','363504005',
'269475001','187752007','187692001','254969001','363505006','363418001','363484005',
'187801002','255072001','363509000','302816009','363432004','255052006','363503004',
'363438000','443487006','441559006','447100004','116691000119101','110002002','397009000',
'188669003','188668006','421418009','188754005','94148006','109378008','109853004',
'188744006','109989006','94704006','118618005','94715001','94707004','94708009',
'94709001','94710006','94711005','94712003','188627002','94714002','445738007',
'188732008','122901000119109','94716000','94719007','94718004','126675008','363227003',
'371481006','127016006','126920004','387837005','127230005','269476000','95194004',
'95186006','95187002','95188007','188612002','188609000','188613007','95192000',
'95193005','118601006','447989004','109267002','109847004','109879008','109347009',
'109348004','109912006','109911004','109371002','109838007','109835005','109948008',
'109886000','109878000','109830000','109384006','109368005','109369002','109822001',
'109833003','109824000','109887009','109874003','109367000','109832008','109831001',
'109848009','109919002','109839004','109851002','109837002','109349007','109836006',
'109823006','110013004','109885001','109977009','95210003','122981000119101','95209008',
'415111003','415112005','109992005','307649006','404143002','722529000','372087000',
'148911000119107','371962007','93659005','371963002','93665005','371966005','371967001',
'93669004','93670003','93671004','93672006','371968006','93674007','93675008',
'93676009','93679002','128466006','93683002','372092003','353421000119109',
'353501000119104','93687001','371970002','93689003','93715005','93716006',
'93717002','371971003','93725000','93723007','371975007','93727008','93726004','109834009',
'372137005','373090000','373091001','373089009','373088001','93728003','371976008','93738008',
'93740003','93743001','371977004','93744007','93745008','93746009','93747000','93748005',
'93749002','371978009','93755007','93756008','371980003','109840002','93761005','371981004',
'93764002','93766000','93767009','93768004','109876001','93771007','449803009','93773005',
'93775003','93779009','371983001','93781006','93783009','371984007','93787005','93789008',
'446189008','371986009','371987000','93796005','93797001','93802007','93807001','93808006',
'93809003','372139008','363745004','371989002','93816002','93818001','371990006','371991005',
'93824007','372119009','93825008','93826009','93829002','93831006','93832004','109357005',
'93835002','93836001','93837005','371992003','93839008','447109003','93841009','93843007',
'93844001','93846004','93848003','93849006','93850006','93851005','423195009','371993008',
'93854002','109370001','371995001','93860002','93861003','93862005','93863000','93867004',
'93868009','371996000','95214007','93871001','371997009','93874009','93875005','372110008',
'93876006','371998004','93882009','93883004','93884005','93885006','93886007','93889000',
'93890009','93891008','109915008','93894000','372112000','371999007','93915004','93917007',
'226521000119108','93923002','93928006','93931007','372001002','93932000',
'93933005','93934004','372002009','372003004','93939009','93941005','93942003',
'93943008','93944002','93946000','93948004','372004005','93951006','372115003',
'93953009','372005006','422736007','109921007','109947003','109931000','93961004',
'93962006','93964007','721567004','93966009','93967000','93968005','93969002','93970001',
'93971002','93972009','372006007','93974005','93976007','93977003','93978008','93980002',
'93984006','93985007','93986008','93987004','93989001','94092006','372107001','93994001',
'372009000','94003005','94004004','94006002','94048009','94049001','372010005','94050001',
'94057003','94059000','94062002','94063007','372012002','372013007','94067008','94068003',
'94069006','94071006','94072004','372014001','94075002','94076001','94077005','94078000',
'94080006','94082003','94086000','94087009','372016004','372017008','94096009','94098005',
'94101009','372020000','94102002','94103007','94104001','94105000','94109006','94111002',
'94113004','372022008','94115006','94116007','372133009','372135002','94117003','94118008',
'372023003','94120006','94121005','94122003','94123008','94124002','94125001','94126000',
'372024009','10708511000119100','94129007','372025005','94132005','94134006','94135007',
'372026006','372027002','372028007','94138009','94140004','94143002','94144008','444910004',
'415287001','373168002','95224004','95225003','95226002','188492005','188489006','188493000',
'95230004','95231000','446643000','254601002','302855005','427056005','188726003','426370008',
'188746008','188736006','425749006','118611004','95264000','188632001','188635004','188631008',
'188633006','95260009','188634000','95261008','188637007','95263006','277567002','109975001',
'190818004') 
                                                          and dxdate is not null
                                          UNION ALL
                                                      SELECT patientid, dxdate 
                                                      FROM "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
                                                      where dxcode in ('C79.63','C77','C77.0','C77.1','C77.2','C77.3','C77.4','C77.5','C77.8','C77.9',
                                                                       'C78','C78.0','C78.00','C78.01','C78.02','C78.1','C78.2','C78.3','C78.30','C78.39',
                                                                       'C78.4','C78.5','C78.6','C78.7','C78.8','C78.80','C78.89','C79','C79.0','C79.00',
                                                                       'C79.01','C79.02','C79.1','C79.10','C79.11','C79.19','C79.2','C79.3','C79.31',
                                                                       'C79.32','C79.4','C79.40','C79.49','C79.5','C79.51','C79.52','C79.6','C79.60',
                                                                       'C79.61','C79.62','C79.7','C79.70','C79.71','C79.72','C79.8','C79.81','C79.82',
                                                                       'C79.89','C79.9','C7B','C7B.0','C7B.00','C7B.01','C7B.02','C7B.03','C7B.04','C7B.09',
                                                                       'C7B.1','C7B.8',
                                                                      '430556008','363346000','127250009','127267002','127245003','127232002','127261001',
                                                                       '127274007','127254000','254289008','372087000','94161006','94186002','94222008',
                                                                       '94217008','94225005','188462001','94246001','94297009','94313005','94347008',
                                                                       '94348003','94350006','94351005','94360002','94365007','353741000119106','369523007',
                                                                       '94381002','813671000000107','94391008','94392001','94395004','94396003','94398002',
                                                                       '94409002','94442001','94455000','94493005','269473008','94515004','94628003','188445006',
                                                                       '353561000119103','369530001','94579000','94580002','94649002','274088005','94663008',
                                                                       '128462008'
                                                                      ) and dxdate is not null)) any_malignancy_or_metastatic_solid_tumor 
                                      ON inclusion_both.patientid = any_malignancy_or_metastatic_solid_tumor.patientid
                                      where dxdate >= ((indexdate)-365) AND dxdate < indexdate) any_malignancy_or_metastatic_solid_tumor_condition1
                                      inner join (Select patientid, drug_date from (
                                                    select patientid, medadminstartdate as drug_date
                                                    from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS"
                                                    where  ( lower(SOURCEMEDADMINMEDNAME) like	lower('%ABARELIX%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ABATACEPT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ABIRATERONE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ADO%TRASTUZUMAB EMTANSINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AFATINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AFLIBERCEPT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALDESLEUKIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALECTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%alemtuzumab%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALLOPURINOL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ALTRETAMINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AMIFOSTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AMINOGLUTETHIMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ANASTROZOLE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ARSENIC%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ASPARAGINASE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ATEZOLIZUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AVELUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AXITINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%AZACITIDINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BCG VACCINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%belimumab%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BELINOSTAT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BENDAMUSTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BEVACIZUMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BEXAROTENE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BICALUTAMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BLEOMYCIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BLINATUMOMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BORTEZOMIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BOSUTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BRENTUXIMAB%VEDOTIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%BUSULFAN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CABAZITAXEL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CABOZANTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CAPECITABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CARBOPLATIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CARFILZOMIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CARMUSTINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CERITINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CETUXIMAB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CHLORAMBUCIL%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CISPLATIN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CLADRIBINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CLOFARABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%COBIMETINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CRIZOTINIB%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CROMOLYN%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CROMOLYN%SODIUM%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CYCLOPHOSPHAMIDE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%CYTARABINE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%DABRAFENIB%')
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
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%VORINOSTAT%')


                                                    and medadminstartdate is not null)
                                                union all
                                                    select patientid, orderdate as drug_date
                                                    from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS"
                                                   where (lower(SOURCERXMEDNAME) like	lower('%ABARELIX%')
OR lower(SOURCERXMEDNAME) like	lower('%ABATACEPT%')
OR lower(SOURCERXMEDNAME) like	lower('%ABIRATERONE%')
OR lower(SOURCERXMEDNAME) like	lower('%ADO%TRASTUZUMAB EMTANSINE%')
OR lower(SOURCERXMEDNAME) like	lower('%AFATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%AFLIBERCEPT%')
OR lower(SOURCERXMEDNAME) like	lower('%ALDESLEUKIN%')
OR lower(SOURCERXMEDNAME) like	lower('%ALECTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%alemtuzumab%')
OR lower(SOURCERXMEDNAME) like	lower('%ALLOPURINOL%')
OR lower(SOURCERXMEDNAME) like	lower('%ALTRETAMINE%')
OR lower(SOURCERXMEDNAME) like	lower('%AMIFOSTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%AMINOGLUTETHIMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%ANASTROZOLE%')
OR lower(SOURCERXMEDNAME) like	lower('%ARSENIC%')
OR lower(SOURCERXMEDNAME) like	lower('%ASPARAGINASE%')
OR lower(SOURCERXMEDNAME) like	lower('%ATEZOLIZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%AVELUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%AXITINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%AZACITIDINE%')
OR lower(SOURCERXMEDNAME) like	lower('%BCG VACCINE%')
OR lower(SOURCERXMEDNAME) like	lower('%belimumab%')
OR lower(SOURCERXMEDNAME) like	lower('%BELINOSTAT%')
OR lower(SOURCERXMEDNAME) like	lower('%BENDAMUSTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%BEVACIZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%BEXAROTENE%')
OR lower(SOURCERXMEDNAME) like	lower('%BICALUTAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%BLEOMYCIN%')
OR lower(SOURCERXMEDNAME) like	lower('%BLINATUMOMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%BORTEZOMIB%')
OR lower(SOURCERXMEDNAME) like	lower('%BOSUTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%BRENTUXIMAB%VEDOTIN%')
OR lower(SOURCERXMEDNAME) like	lower('%BUSULFAN%')
OR lower(SOURCERXMEDNAME) like	lower('%CABAZITAXEL%')
OR lower(SOURCERXMEDNAME) like	lower('%CABOZANTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%CAPECITABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%CARBOPLATIN%')
OR lower(SOURCERXMEDNAME) like	lower('%CARFILZOMIB%')
OR lower(SOURCERXMEDNAME) like	lower('%CARMUSTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%CERITINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%CETUXIMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%CHLORAMBUCIL%')
OR lower(SOURCERXMEDNAME) like	lower('%CISPLATIN%')
OR lower(SOURCERXMEDNAME) like	lower('%CLADRIBINE%')
OR lower(SOURCERXMEDNAME) like	lower('%CLOFARABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%COBIMETINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%CRIZOTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%CROMOLYN%')
OR lower(SOURCERXMEDNAME) like	lower('%CROMOLYN%SODIUM%')
OR lower(SOURCERXMEDNAME) like	lower('%CYCLOPHOSPHAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%CYTARABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%DABRAFENIB%')
OR lower(SOURCERXMEDNAME) like	lower('%DACARBAZINE%')
OR lower(SOURCERXMEDNAME) like	lower('%DACTINOMYCIN%')
OR lower(SOURCERXMEDNAME) like	lower('%DANAZOL%')
OR lower(SOURCERXMEDNAME) like	lower('%DARATUMUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%DASATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%DAUNORUBICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%DECITABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%DEGARELIX%')
OR lower(SOURCERXMEDNAME) like	lower('%DENILEUKIN%DIFTITOX%')
OR lower(SOURCERXMEDNAME) like	lower('%DENOSUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%DEXAMETHASONE%')
OR lower(SOURCERXMEDNAME) like	lower('%DIETHYLSTILBESTROL%')
OR lower(SOURCERXMEDNAME) like	lower('%DIHEMATOPORPHYRIN%ETHER%')
OR lower(SOURCERXMEDNAME) like	lower('%DINUTUXIMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%DOCETAXEL%')
OR lower(SOURCERXMEDNAME) like	lower('%DOXORUBICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%DURVALUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%ELOTUZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%ENZALUTAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%EPIRUBICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%ERIBULIN%')
OR lower(SOURCERXMEDNAME) like	lower('%ERLOTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%ESTRADURIN%')
OR lower(SOURCERXMEDNAME) like	lower('%ESTRAMUSTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%ETOPOSIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%EVEROLIMUS%')
OR lower(SOURCERXMEDNAME) like	lower('%EXEMESTANE%')
OR lower(SOURCERXMEDNAME) like	lower('%FLOXURIDINE%')
OR lower(SOURCERXMEDNAME) like	lower('%FLUDARABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%FLUOROURACIL%')
OR lower(SOURCERXMEDNAME) like	lower('%FLUOXYMESTERONE%')
OR lower(SOURCERXMEDNAME) like	lower('%FLUTAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%FULVESTRANT%')
OR lower(SOURCERXMEDNAME) like	lower('%GEFITINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%GEMCITABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%GEMTUZUMAB%OZOGAMICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%GOSERELIN%')
OR lower(SOURCERXMEDNAME) like	lower('%HISTRELIN%')
OR lower(SOURCERXMEDNAME) like	lower('%TALIMOGENE%LAHERPAREPVEC%') OR lower(SOURCERXMEDNAME) like lower('%HUMAN%HERPESVIRUS%1%')
OR lower(SOURCERXMEDNAME) like	lower('%HYDROXYUREA%')
OR lower(SOURCERXMEDNAME) like	lower('%IBRITUMOMAB%TIUXETAN%')
OR lower(SOURCERXMEDNAME) like	lower('%IBRUTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%IDARUBICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%IDELALISIB%')
OR lower(SOURCERXMEDNAME) like	lower('%IFOSFAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%IFOSFAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%MESNA%')
OR lower(SOURCERXMEDNAME) like	lower('%IMATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%ALFA%2A%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%ALFA%2B%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%ALFACON%1%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%ALFA%N3%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%BETA%1A%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%BETA%1B%')
OR lower(SOURCERXMEDNAME) like	lower('%INTERFERON%GAMMA%1B%')
OR lower(SOURCERXMEDNAME) like	lower('%IPILIMUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%IRINOTECAN%')
OR lower(SOURCERXMEDNAME) like	lower('%IXABEPILONE%')
OR lower(SOURCERXMEDNAME) like	lower('%IXAZOMIB%')
OR lower(SOURCERXMEDNAME) like	lower('%KETOCONAZOLE%')
OR lower(SOURCERXMEDNAME) like	lower('%LANREOTIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%LAPATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%LENALIDOMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%LENVATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%LETROZOLE%')
OR lower(SOURCERXMEDNAME) like	lower('%LEUCOVORIN%')
OR lower(SOURCERXMEDNAME) like	lower('%LEUPROLIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%LEVAMISOLE%')
OR lower(SOURCERXMEDNAME) like	lower('%LEVOLEUCOVORIN%')
OR lower(SOURCERXMEDNAME) like	lower('%LOMUSTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%LONSURF%')
OR lower(SOURCERXMEDNAME) like	lower('%MECHLORETHAMINE%')
OR lower(SOURCERXMEDNAME) like	lower('%MEDROXYPROGESTERONE%')
OR lower(SOURCERXMEDNAME) like	lower('%MEGESTROL%')
OR lower(SOURCERXMEDNAME) like	lower('%MELPHALAN%')
OR lower(SOURCERXMEDNAME) like	lower('%MERCAPTOPURINE%')
OR lower(SOURCERXMEDNAME) like	lower('%MESNA%')
OR lower(SOURCERXMEDNAME) like	lower('%METHOTREXATE%')
OR lower(SOURCERXMEDNAME) like	lower('%METHOXSALEN%')
OR lower(SOURCERXMEDNAME) like	lower('%MITOMYCIN%')
OR lower(SOURCERXMEDNAME) like	lower('%MITOTANE%')
OR lower(SOURCERXMEDNAME) like	lower('%MITOXANTRONE%')
OR lower(SOURCERXMEDNAME) like	lower('%NATALIZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%NECITUMUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%NELARABINE%')
OR lower(SOURCERXMEDNAME) like	lower('%NILOTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%NILUTAMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%NIRAPARIB%')
OR lower(SOURCERXMEDNAME) like	lower('%NIVOLUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%OBINUTUZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%OCTREOTIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%ofatumumab%')
OR lower(SOURCERXMEDNAME) like	lower('%OLAPARIB%')
OR lower(SOURCERXMEDNAME) like	lower('%OLARATUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%OMACETAXINE%')
OR lower(SOURCERXMEDNAME) like	lower('%OSIMERTINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%OXALIPLATIN%')
OR lower(SOURCERXMEDNAME) like	lower('%PACLITAXEL%')
OR lower(SOURCERXMEDNAME) like	lower('%PALBOCICLIB%')
OR lower(SOURCERXMEDNAME) like	lower('%PAMIDRONATE%')
OR lower(SOURCERXMEDNAME) like	lower('%PANITUMUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%PANOBINOSTAT%')
OR lower(SOURCERXMEDNAME) like	lower('%PAZOPANIB%')
OR lower(SOURCERXMEDNAME) like	lower('%PEGASPARGASE%')
OR lower(SOURCERXMEDNAME) like	lower('%PEMBROLIZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%PEMETREXED%')
OR lower(SOURCERXMEDNAME) like	lower('%PENTOSTATIN%')
OR lower(SOURCERXMEDNAME) like	lower('%PERTUZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%PLICAMYCIN%')
OR lower(SOURCERXMEDNAME) like	lower('%POLYESTRADIOL%PHOSPHATE%')
OR lower(SOURCERXMEDNAME) like	lower('%POMALIDOMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%PONATINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%PORFIMER%')
OR lower(SOURCERXMEDNAME) like	lower('%PRALATREXATE%')
OR lower(SOURCERXMEDNAME) like	lower('%PROCARBAZINE%')
OR lower(SOURCERXMEDNAME) like	lower('%RADIUM%CHLORIDE%RA%223%')
OR lower(SOURCERXMEDNAME) like	lower('%RALOXIFENE%')
OR lower(SOURCERXMEDNAME) like	lower('%RAMUCIRUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%REGORAFENIB%')
OR lower(SOURCERXMEDNAME) like	lower('%RIBOCICLIB%')
OR lower(SOURCERXMEDNAME) like	lower('%rituximab%')
OR lower(SOURCERXMEDNAME) like	lower('%ROMIDEPSIN%')
OR lower(SOURCERXMEDNAME) like	lower('%RUCAPARIB%')
OR lower(SOURCERXMEDNAME) like	lower('%RUXOLITINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%SAMARIUM%LEXIDRONAM%')
OR lower(SOURCERXMEDNAME) like	lower('%SIPULEUCEL%T%')
OR lower(SOURCERXMEDNAME) like	lower('%SONIDEGIB%')
OR lower(SOURCERXMEDNAME) like	lower('%SORAFENIB%')
OR lower(SOURCERXMEDNAME) like	lower('%STREPTOZOCIN%')
OR lower(SOURCERXMEDNAME) like	lower('%STRONTIUM%89%')
OR lower(SOURCERXMEDNAME) like	lower('%SUNITINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%TAMOXIFEN%')
OR lower(SOURCERXMEDNAME) like	lower('%TEMOZOLOMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%TEMSIROLIMUS%')
OR lower(SOURCERXMEDNAME) like	lower('%TENIPOSIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%TESTOLACTONE%')
OR lower(SOURCERXMEDNAME) like	lower('%THALIDOMIDE%')
OR lower(SOURCERXMEDNAME) like	lower('%THIOGUANINE%')
OR lower(SOURCERXMEDNAME) like	lower('%THIOTEPA%')
OR lower(SOURCERXMEDNAME) like	lower('%TIPIRACIL %') OR lower(SOURCERXMEDNAME) like ('%TRIFLURIDINE%')
OR lower(SOURCERXMEDNAME) like	lower('%TOPOTECAN%')
OR lower(SOURCERXMEDNAME) like	lower('%TOREMIFENE%')
OR lower(SOURCERXMEDNAME) like	lower('%TOSITUMOMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%TRABECTEDIN%')
OR lower(SOURCERXMEDNAME) like	lower('%TRAMETINIB%')
OR lower(SOURCERXMEDNAME) like	lower('%TRASTUZUMAB%')
OR lower(SOURCERXMEDNAME) like	lower('%TRETINOIN%')
OR lower(SOURCERXMEDNAME) like	lower('%TRIPTORELIN%')
OR lower(SOURCERXMEDNAME) like	lower('%URACIL%5%FU%')
OR lower(SOURCERXMEDNAME) like	lower('%VALRUBICIN%')
OR lower(SOURCERXMEDNAME) like	lower('%VANDETANIB%')
OR lower(SOURCERXMEDNAME) like	lower('%VEMURAFENIB%')
OR lower(SOURCERXMEDNAME) like	lower('%VENETOCLAX%')
OR lower(SOURCERXMEDNAME) like	lower('%VINBLASTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%VINCRISTINE%')
OR lower(SOURCERXMEDNAME) like	lower('%VINORELBINE%')
OR lower(SOURCERXMEDNAME) like	lower('%VISMODEGIB%')
OR lower(SOURCERXMEDNAME) like	lower('%VORINOSTAT%')

 
                                                    and orderdate is not null)
                                                union all
                                                    select patientid, filleddate as drug_date
                                                    from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS"
                                                    where (  lower(SOURCEDRUGNAME) like	lower('%ABARELIX%')
OR lower(SOURCEDRUGNAME) like	lower('%ABATACEPT%')
OR lower(SOURCEDRUGNAME) like	lower('%ABIRATERONE%')
OR lower(SOURCEDRUGNAME) like	lower('%ADO%TRASTUZUMAB EMTANSINE%')
OR lower(SOURCEDRUGNAME) like	lower('%AFATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%AFLIBERCEPT%')
OR lower(SOURCEDRUGNAME) like	lower('%ALDESLEUKIN%')
OR lower(SOURCEDRUGNAME) like	lower('%ALECTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%alemtuzumab%')
OR lower(SOURCEDRUGNAME) like	lower('%ALLOPURINOL%')
OR lower(SOURCEDRUGNAME) like	lower('%ALTRETAMINE%')
OR lower(SOURCEDRUGNAME) like	lower('%AMIFOSTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%AMINOGLUTETHIMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%ANASTROZOLE%')
OR lower(SOURCEDRUGNAME) like	lower('%ARSENIC%')
OR lower(SOURCEDRUGNAME) like	lower('%ASPARAGINASE%')
OR lower(SOURCEDRUGNAME) like	lower('%ATEZOLIZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%AVELUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%AXITINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%AZACITIDINE%')
OR lower(SOURCEDRUGNAME) like	lower('%BCG VACCINE%')
OR lower(SOURCEDRUGNAME) like	lower('%belimumab%')
OR lower(SOURCEDRUGNAME) like	lower('%BELINOSTAT%')
OR lower(SOURCEDRUGNAME) like	lower('%BENDAMUSTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%BEVACIZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%BEXAROTENE%')
OR lower(SOURCEDRUGNAME) like	lower('%BICALUTAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%BLEOMYCIN%')
OR lower(SOURCEDRUGNAME) like	lower('%BLINATUMOMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%BORTEZOMIB%')
OR lower(SOURCEDRUGNAME) like	lower('%BOSUTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%BRENTUXIMAB%VEDOTIN%')
OR lower(SOURCEDRUGNAME) like	lower('%BUSULFAN%')
OR lower(SOURCEDRUGNAME) like	lower('%CABAZITAXEL%')
OR lower(SOURCEDRUGNAME) like	lower('%CABOZANTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%CAPECITABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%CARBOPLATIN%')
OR lower(SOURCEDRUGNAME) like	lower('%CARFILZOMIB%')
OR lower(SOURCEDRUGNAME) like	lower('%CARMUSTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%CERITINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%CETUXIMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%CHLORAMBUCIL%')
OR lower(SOURCEDRUGNAME) like	lower('%CISPLATIN%')
OR lower(SOURCEDRUGNAME) like	lower('%CLADRIBINE%')
OR lower(SOURCEDRUGNAME) like	lower('%CLOFARABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%COBIMETINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%CRIZOTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%CROMOLYN%')
OR lower(SOURCEDRUGNAME) like	lower('%CROMOLYN%SODIUM%')
OR lower(SOURCEDRUGNAME) like	lower('%CYCLOPHOSPHAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%CYTARABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%DABRAFENIB%')
OR lower(SOURCEDRUGNAME) like	lower('%DACARBAZINE%')
OR lower(SOURCEDRUGNAME) like	lower('%DACTINOMYCIN%')
OR lower(SOURCEDRUGNAME) like	lower('%DANAZOL%')
OR lower(SOURCEDRUGNAME) like	lower('%DARATUMUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%DASATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%DAUNORUBICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%DECITABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%DEGARELIX%')
OR lower(SOURCEDRUGNAME) like	lower('%DENILEUKIN%DIFTITOX%')
OR lower(SOURCEDRUGNAME) like	lower('%DENOSUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%DEXAMETHASONE%')
OR lower(SOURCEDRUGNAME) like	lower('%DIETHYLSTILBESTROL%')
OR lower(SOURCEDRUGNAME) like	lower('%DIHEMATOPORPHYRIN%ETHER%')
OR lower(SOURCEDRUGNAME) like	lower('%DINUTUXIMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%DOCETAXEL%')
OR lower(SOURCEDRUGNAME) like	lower('%DOXORUBICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%DURVALUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%ELOTUZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%ENZALUTAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%EPIRUBICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%ERIBULIN%')
OR lower(SOURCEDRUGNAME) like	lower('%ERLOTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%ESTRADURIN%')
OR lower(SOURCEDRUGNAME) like	lower('%ESTRAMUSTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%ETOPOSIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%EVEROLIMUS%')
OR lower(SOURCEDRUGNAME) like	lower('%EXEMESTANE%')
OR lower(SOURCEDRUGNAME) like	lower('%FLOXURIDINE%')
OR lower(SOURCEDRUGNAME) like	lower('%FLUDARABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%FLUOROURACIL%')
OR lower(SOURCEDRUGNAME) like	lower('%FLUOXYMESTERONE%')
OR lower(SOURCEDRUGNAME) like	lower('%FLUTAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%FULVESTRANT%')
OR lower(SOURCEDRUGNAME) like	lower('%GEFITINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%GEMCITABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%GEMTUZUMAB%OZOGAMICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%GOSERELIN%')
OR lower(SOURCEDRUGNAME) like	lower('%HISTRELIN%')
OR lower(SOURCEDRUGNAME) like	lower('%TALIMOGENE%LAHERPAREPVEC%') OR lower(SOURCEDRUGNAME) like lower('%HUMAN%HERPESVIRUS%1%')
OR lower(SOURCEDRUGNAME) like	lower('%HYDROXYUREA%')
OR lower(SOURCEDRUGNAME) like	lower('%IBRITUMOMAB%TIUXETAN%')
OR lower(SOURCEDRUGNAME) like	lower('%IBRUTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%IDARUBICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%IDELALISIB%')
OR lower(SOURCEDRUGNAME) like	lower('%IFOSFAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%IFOSFAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%MESNA%')
OR lower(SOURCEDRUGNAME) like	lower('%IMATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%ALFA%2A%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%ALFA%2B%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%ALFACON%1%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%ALFA%N3%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%BETA%1A%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%BETA%1B%')
OR lower(SOURCEDRUGNAME) like	lower('%INTERFERON%GAMMA%1B%')
OR lower(SOURCEDRUGNAME) like	lower('%IPILIMUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%IRINOTECAN%')
OR lower(SOURCEDRUGNAME) like	lower('%IXABEPILONE%')
OR lower(SOURCEDRUGNAME) like	lower('%IXAZOMIB%')
OR lower(SOURCEDRUGNAME) like	lower('%KETOCONAZOLE%')
OR lower(SOURCEDRUGNAME) like	lower('%LANREOTIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%LAPATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%LENALIDOMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%LENVATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%LETROZOLE%')
OR lower(SOURCEDRUGNAME) like	lower('%LEUCOVORIN%')
OR lower(SOURCEDRUGNAME) like	lower('%LEUPROLIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%LEVAMISOLE%')
OR lower(SOURCEDRUGNAME) like	lower('%LEVOLEUCOVORIN%')
OR lower(SOURCEDRUGNAME) like	lower('%LOMUSTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%LONSURF%')
OR lower(SOURCEDRUGNAME) like	lower('%MECHLORETHAMINE%')
OR lower(SOURCEDRUGNAME) like	lower('%MEDROXYPROGESTERONE%')
OR lower(SOURCEDRUGNAME) like	lower('%MEGESTROL%')
OR lower(SOURCEDRUGNAME) like	lower('%MELPHALAN%')
OR lower(SOURCEDRUGNAME) like	lower('%MERCAPTOPURINE%')
OR lower(SOURCEDRUGNAME) like	lower('%MESNA%')
OR lower(SOURCEDRUGNAME) like	lower('%METHOTREXATE%')
OR lower(SOURCEDRUGNAME) like	lower('%METHOXSALEN%')
OR lower(SOURCEDRUGNAME) like	lower('%MITOMYCIN%')
OR lower(SOURCEDRUGNAME) like	lower('%MITOTANE%')
OR lower(SOURCEDRUGNAME) like	lower('%MITOXANTRONE%')
OR lower(SOURCEDRUGNAME) like	lower('%NATALIZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%NECITUMUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%NELARABINE%')
OR lower(SOURCEDRUGNAME) like	lower('%NILOTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%NILUTAMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%NIRAPARIB%')
OR lower(SOURCEDRUGNAME) like	lower('%NIVOLUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%OBINUTUZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%OCTREOTIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%ofatumumab%')
OR lower(SOURCEDRUGNAME) like	lower('%OLAPARIB%')
OR lower(SOURCEDRUGNAME) like	lower('%OLARATUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%OMACETAXINE%')
OR lower(SOURCEDRUGNAME) like	lower('%OSIMERTINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%OXALIPLATIN%')
OR lower(SOURCEDRUGNAME) like	lower('%PACLITAXEL%')
OR lower(SOURCEDRUGNAME) like	lower('%PALBOCICLIB%')
OR lower(SOURCEDRUGNAME) like	lower('%PAMIDRONATE%')
OR lower(SOURCEDRUGNAME) like	lower('%PANITUMUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%PANOBINOSTAT%')
OR lower(SOURCEDRUGNAME) like	lower('%PAZOPANIB%')
OR lower(SOURCEDRUGNAME) like	lower('%PEGASPARGASE%')
OR lower(SOURCEDRUGNAME) like	lower('%PEMBROLIZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%PEMETREXED%')
OR lower(SOURCEDRUGNAME) like	lower('%PENTOSTATIN%')
OR lower(SOURCEDRUGNAME) like	lower('%PERTUZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%PLICAMYCIN%')
OR lower(SOURCEDRUGNAME) like	lower('%POLYESTRADIOL%PHOSPHATE%')
OR lower(SOURCEDRUGNAME) like	lower('%POMALIDOMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%PONATINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%PORFIMER%')
OR lower(SOURCEDRUGNAME) like	lower('%PRALATREXATE%')
OR lower(SOURCEDRUGNAME) like	lower('%PROCARBAZINE%')
OR lower(SOURCEDRUGNAME) like	lower('%RADIUM%CHLORIDE%RA%223%')
OR lower(SOURCEDRUGNAME) like	lower('%RALOXIFENE%')
OR lower(SOURCEDRUGNAME) like	lower('%RAMUCIRUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%REGORAFENIB%')
OR lower(SOURCEDRUGNAME) like	lower('%RIBOCICLIB%')
OR lower(SOURCEDRUGNAME) like	lower('%rituximab%')
OR lower(SOURCEDRUGNAME) like	lower('%ROMIDEPSIN%')
OR lower(SOURCEDRUGNAME) like	lower('%RUCAPARIB%')
OR lower(SOURCEDRUGNAME) like	lower('%RUXOLITINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%SAMARIUM%LEXIDRONAM%')
OR lower(SOURCEDRUGNAME) like	lower('%SIPULEUCEL%T%')
OR lower(SOURCEDRUGNAME) like	lower('%SONIDEGIB%')
OR lower(SOURCEDRUGNAME) like	lower('%SORAFENIB%')
OR lower(SOURCEDRUGNAME) like	lower('%STREPTOZOCIN%')
OR lower(SOURCEDRUGNAME) like	lower('%STRONTIUM%89%')
OR lower(SOURCEDRUGNAME) like	lower('%SUNITINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%TAMOXIFEN%')
OR lower(SOURCEDRUGNAME) like	lower('%TEMOZOLOMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%TEMSIROLIMUS%')
OR lower(SOURCEDRUGNAME) like	lower('%TENIPOSIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%TESTOLACTONE%')
OR lower(SOURCEDRUGNAME) like	lower('%THALIDOMIDE%')
OR lower(SOURCEDRUGNAME) like	lower('%THIOGUANINE%')
OR lower(SOURCEDRUGNAME) like	lower('%THIOTEPA%')
OR lower(SOURCEDRUGNAME) like	lower('%TIPIRACIL %') OR lower(SOURCEDRUGNAME) like ('%TRIFLURIDINE%')
OR lower(SOURCEDRUGNAME) like	lower('%TOPOTECAN%')
OR lower(SOURCEDRUGNAME) like	lower('%TOREMIFENE%')
OR lower(SOURCEDRUGNAME) like	lower('%TOSITUMOMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%TRABECTEDIN%')
OR lower(SOURCEDRUGNAME) like	lower('%TRAMETINIB%')
OR lower(SOURCEDRUGNAME) like	lower('%TRASTUZUMAB%')
OR lower(SOURCEDRUGNAME) like	lower('%TRETINOIN%')
OR lower(SOURCEDRUGNAME) like	lower('%TRIPTORELIN%')
OR lower(SOURCEDRUGNAME) like	lower('%URACIL %5%FU%')
OR lower(SOURCEDRUGNAME) like	lower('%VALRUBICIN%')
OR lower(SOURCEDRUGNAME) like	lower('%VANDETANIB%')
OR lower(SOURCEDRUGNAME) like	lower('%VEMURAFENIB%')
OR lower(SOURCEDRUGNAME) like	lower('%VENETOCLAX%')
OR lower(SOURCEDRUGNAME) like	lower('%VINBLASTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%VINCRISTINE%')
OR lower(SOURCEDRUGNAME) like	lower('%VINORELBINE%')
OR lower(SOURCEDRUGNAME) like	lower('%VISMODEGIB%')
OR lower(SOURCEDRUGNAME) like	lower('%VORINOSTAT%')


                                                    and filleddate is not null))) cancer_therapies
                                ON any_malignancy_or_metastatic_solid_tumor_condition1.patientid = cancer_therapies.patientid
                                where drug_date >= ((indexdate)-365) AND drug_date < indexdate
								
							
							
