## Comorbidities

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
             
  INNER JOIN (select patientid, dxdate as com_date from 
              "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES" 
             where dxcode IN (
            'I27.8','I27.81','I25.751','I25.758','I25.759','I25.760','I25.768','I25.769','I25.811','I25.812','I27.82','I26.92','I26.93','I26.94','I26.99','I26.01','I26.02','I26.09','I26.90','I23.7','I23.8','I24.0','I24','I24.1','I24.8','I24.9','I25.10','I25','I25.1','I42.6','I01','I01.0','I01.1','I01.2','I01.8','I01.9','I02.0','I05','I05.0','I05.1','I05.2','I05.8','I05.9','I06','I06.0','I06.1','I06.2','I06.8','I06.9','I07','I07.0','I07.1','I07.2','I07.8','I07.9','I08','I08.0','I08.1','I08.2','I08.3','I08.8','I08.9','I09','I09.0','I09.1','I09.2','I09.8','I09.89','I09.9','I20.0','I20','I20.1','I20.8','I20.9','I21','I21.0','I21.02','I21.09','I21.11','I21.1','I21.19','I21.21','I21.2','I21.29','I21.3','I21.4','I21.9','I21.A1','I21.A','I21.A9','I22.0','I22','I22.1','I22.2','I22.8','I22.9','I23.0','I23','I23.1','I23.2','I23.3','I23.4','I23.5','I25.11','I25.111','I25.118','I25.119','I25.2','I25.3','I25.41','I25.4','I25.42','I25.5','I25.6','I25.700','I25.7','I25.70','I25.701','I25.708','I25.709','I25.710','I25.71','I25.718','I25.719','I25.720','I25.721','I25.72','I25.728','I25.729','I25.730','I25.731','I25.73','I25.738','I25.739','I25.790','I25.791','I25.75','I25.76','I25.79','I25.798','I25.799','I25.810','I25.82','I25.8','I25.81','I25.83','I25.84','I25.89','I25.9','I26','I26.0','I26.9','I27','I27.1','I27.83','I27.89','I27.9','I28','I28.0','I28.1','I28.8','I28.9','I30','I30.0','I30.1','I30.8','I30.9','I31','I31.0','I31.1','I31.2','I31.3','I31.4','I31.8','I31.9','I32','I33','I33.0','I33.9','I34','I34.0','I34.1','I34.2','I34.8','I34.9','I35','I35.0','I35.1','I35.2','I35.8','I35.9','I36','I36.0','I36.1','I36.2','I36.8','I36.9','I37','I37.0','I37.1','I37.2','I37.8','I37.9','I38','I39','I40','I40.0','I40.1','I40.8','I40.9','I41','I42','I42.0','I42.3','I42.4','I42.5','I42.7','I42.8','I42.9','I43','I44','I44.0','I44.1','I44.2','I44.3','I44.30','I44.39','I44.4','I44.5','I44.6','I44.60','I44.69','I44.7','I45','I45.0','I45.1','I45.10','I45.19','I45.2','I45.3','I45.4','I45.5','I45.6','I45.8','I45.81','I45.89','I45.9','I46','I46.2','I46.8','I46.9','I47','I47.0','I47.1','I47.2','I47.9','I48','I48.1','I48.11','I48.19','I48.2','I48.20','I48.21','I48.91','I48.3','I48.4','I48.9','I48.92','I49','I49.0','I49.01','I49.02','I49.1','I49.2','I49.3','I49.4','I49.40','I49.49','I49.5','I49.8','I49.9','I51','I51.1','I70.201','I51.2','I51.3','I51.4','I51.5','I51.7','I51.8','I51.81','I51.89','I51.9','I52','I70','I70.1','I70.0','I70.2','I70.20','I70.202','I70.203','I70.208','I70.211','I70.212','I70.21','I70.213','I70.218','I70.219','I70.221','I70.222','I70.22','I70.223','I70.228','I70.229','I70.231','I70.232','I70.23','I70.233','I70.234','I70.235','I70.238','I70.239','I70.241','I70.242','I70.24','I70.243','I70.244','I70.245','I70.248','I70.249','I70.25','I70.261','I70.262','I70.26','I70.263','I70.268','I70.269','I70.291','I70.292','I70.29','I70.293','I70.298','I70.3','I70.30','I70.302','I70.303','I70.308','I70.309','I70.311','I70.31','I70.312','I70.313','I70.318','I70.319','I70.321','I70.32','I70.322','I70.323','I70.328','I70.329','I70.331','I70.33','I70.332','I70.333','I70.334','I70.335','I70.338','I70.339','I70.341','I70.34','I70.342','I70.343','I70.344','I70.345','I70.348','I70.349','I70.35','I70.361','I70.36','I70.362','I70.363','I70.368','I70.369','I70.391','I70.39','I70.392','I70.393','I70.398','I70.399','I70.299','I70.4','I70.40','I70.402','I70.403','I70.408','I70.409','I70.411','I70.41','I70.412','I70.413','I70.418','I70.419','I70.421','I70.42','I70.422','I70.423','I70.428','I70.429','I70.431','I70.43','I70.432','I70.433','I70.434','I70.435','I70.438','I70.439','I70.441','I70.44','I70.442','I70.443','I70.444','I70.445','I70.448','I70.449','I70.45','I70.461','I70.46','I70.462','I70.463','I70.469','I70.491','I70.492','I70.49','I70.493','I70.498','I70.499','I70.501','I70.5','I70.50','I70.508','I70.509','I70.511','I70.51','I70.512','I70.513','I70.518','I70.519','I70.521','I70.52','I70.522','I70.523','I70.528','I70.529','I70.531','I70.53','I70.532','I70.533','I70.534','I70.535','I70.538','I70.539','I70.541','I70.54','I70.542','I70.543','I70.544','I70.545','I70.548','I70.549','I70.55','I70.561','I70.56','I70.562','I70.563','I70.568','I70.569','I70.591','I70.59','I70.592','I70.593','I70.598','I70.599','I70.601','I70.6','I70.60','I70.503','I70.608','I70.609','I70.611','I70.61','I70.612','I70.613','I70.618','I70.619','I70.621','I70.62','I70.622','I70.623','I70.628','I70.629','I70.631','I70.63','I70.632','I70.633','I70.634','I70.635','I70.638','I70.639','I70.641','I70.64','I70.642','I70.643','I70.644','I70.645','I70.648','I70.649','I70.65','I70.661','I70.66','I70.662','I70.663','I70.668','I70.669','I70.691','I70.69','I70.692','I70.693','I70.698','I70.699','I70.701','I70.7','I70.70','I70.702','I70.703','I70.708','I70.602','I70.71','I70.712','I70.713','I70.718','I70.719','I70.721','I70.72','I70.722','I70.723','I70.728','I70.729','I70.731','I70.73','I70.732','I70.733','I70.734','I70.735','I70.738','I70.739','I70.741','I70.74','I70.742','I70.743','I70.744','I70.745','I70.748','I70.749','I70.75','I70.761','I70.76','I70.762','I70.763','I70.768','I70.769','I70.791','I70.79','I70.792','I70.793','I70.798','I70.799','I70.8','I70.90','I70.9','I70.91','I70.92','I71.00','I71','I71.0','I71.01','I71.02','I71.03','I71.1','I71.2','I71.3','I71.4','I70.711','I71.8','I71.9','I72.0','I72','I72.1','I72.2','I72.3','I72.4','I72.5','I72.6','I72.8','I72.9','I73.01','I73','I73.00','I73.1','I73.81','I73.8','I73.89','I73.9','I74.01','I74','I74.0','I74.09','I74.10','I74.1','I74.11','I74.19','I74.2','I74.3','I74.4','I74.5','I74.8','I74.9','I77.0','I75','I75.0','I75.01','I75.011','I75.012','I75.013','I75.019','I75.02','I75.021','I75.022','I75.023','I75.029','I75.8','I75.81','I75.89','I76','I77','I77.1','I73.0','I71.5','I71.6','I77.4','I77.5','I79.1','I77.70','I77.7','I77.71','I77.72','I77.73','I77.74','I77.75','I77.76','I77.77','I77.79','I77.810','I77.8','I77.81','I77.811','I77.812','I77.819','I77.89','I77.9','I79.0','I78','I78.0','I78.1','I78.8','I78.9','I79','I80.01','I80.02','I80.03','I80','I80.0','I80.10','I80.11','I80.12','I80.13','I80.1','I80.201','I80.202','I80.203','I80.209','I80.2','I80.20','I80.211','I80.212','I80.213','I80.219','I80.21','I80.221','I80.222','I80.223','I80.229','I80.22','I80.231','I80.232','I80.233','I80.239','I80.23','I80.241','I80.242','I77.6','I80.243','I80.24','I80.249','I80.251','I80.252','I80.25','I80.00','I77.2','I77.3','I80.293','I80.29','I80.299','I80.3','I80.8','I80.9','I81','I82.0','I82.210','I82.1','I82','I82.211','I82.220','I82.2','I82.21','I82.221','I82.290','I82.22','I82.291','I82.3','I82.29','I82.401','I82.402','I82.403','I82.4','I82.40','I82.409','I82.411','I82.412','I82.413','I82.41','I82.419','I82.421','I82.422','I82.423','I82.42','I82.429','I82.431','I82.432','I82.433','I82.43','I82.439','I82.441','I82.442','I82.443','I82.44','I82.449','I82.451','I82.452','I82.493','I82.45','I82.453','I82.459','I82.461','I82.462','I82.46','I82.463','I82.469','I82.491','I82.492','I82.49','I82.499','I80.253','I80.259','I82.4Y','I80.292','I82.4Z1','I82.4Z2','I82.4Z3','I82.4Z','I82.4Z9','I82.501','I82.502','I82.503','I82.5','I82.50','I82.509','I82.511','I82.512','I82.513','I82.51','I82.519','I82.521','I82.522','I82.523','I82.52','I82.529','I82.531','I82.532','I82.533','I82.53','I82.539','I82.541','I82.542','I82.543','I82.54','I82.549','I82.551','I82.552','I82.593','I82.55','I82.553','I82.559','I82.561','I82.562','I82.56','I82.563','I82.569','I82.591','I82.592','I82.59','I82.599','I82.5Y1','I82.5Y2','I82.5Y3','I82.5Y','I82.5Y9','I82.5Z1','I82.5Z2','I82.5Z3','I82.5Z','I82.5Z9','I82.4Y2','I82.4Y3','I82.4Y9','I82.6','I82.60','I82.611','I82.612','I82.613','I82.619','I82.61','I82.621','I82.622','I82.623','I82.629','I82.62','I82.701','I82.702','I82.703','I82.709','I82.7','I82.70','I82.711','I82.712','I82.713','I82.719','I82.71','I82.721','I82.722','I82.723','I82.729','I82.72','I82.811','I82.812','I82.813','I82.819','I82.8','I82.81','I82.890','I82.891','I82.90','I82.91','I82.89','I82.A11','I82.A12','I82.9','I82.A13','I82.A19','I82.A','I82.A1','I82.A21','I82.A22','I82.A23','I82.A29','I82.A2','I82.B11','I82.B12','I82.B13','I82.B19','I82.B','I82.B1','I82.B21','I82.602','I82.609','I82.B2','I97.0','I82.C12','I82.C13','I82.C','I82.C1','I82.C19','I82.C21','I82.C22','I82.C23','I82.C2','I82.C29','I82.B23','I82.B29','I83','I83.0','I83.00','I83.001','I83.002','I83.003','I83.004','I83.005','I83.008','I83.009','I83.01','I83.011','I83.012','I83.013','I83.014','I83.015','I83.018','I83.019','I83.02','I83.021','I83.022','I83.023','I83.024','I83.025','I83.028','I83.029','I83.1','I83.10','I83.11','I83.12','I83.2','I83.20','I83.201','I83.202','I83.203','I83.204','I83.205','I83.208','I83.209','I83.21','I83.211','I83.212','I83.213','I83.214','I83.215','I83.218','I83.219','I82.C11','I83.22','I83.221','I83.222','I83.223','I83.224','I83.225','I83.228','I83.229','I83.8','I83.81','I83.811','I83.812','I83.813','I83.819','I83.89','I83.891','I83.892','I83.893','I83.899','I83.9','I83.90','I83.91','I83.92','I83.93','I85','I85.0','I85.00','I85.01','I85.1','I85.10','I85.11','I86','I86.0','I86.1','I86.2','I86.3','I86.4','I86.8','I87','I87.0','I87.00','I87.001','I87.002','I87.003','I87.009','I87.01','I87.011','I87.012','I87.013','I87.019','I87.02','I87.021','I87.022','I87.023','I87.029','I87.03','I87.031','I87.032','I87.033',
               'I87.039','I87.09','I87.091','I87.092','I87.093','I87.099','I87.1','I87.2','I87.8','I87.9','I88','I88.0','I88.1','I88.8','I88.9','I89','I89.0','I89.1','I89.8','I89.9','I95','I95.0','I95.1','I95.2','I95.3','I95.8','I95.81','I95.89','I95.9','I96','I97','I97.1','I97.11','I97.110','I97.111','I97.12','I97.120','I97.121','I97.19','I97.190','I97.191','I97.2','I97.4','I97.41','I97.410','I97.411','I97.418','I97.42','I97.5','I97.51','I97.52','I97.6','I97.61','I97.610','I97.611','I97.618','I97.62','I97.620','I97.621','I97.622','I97.63','I97.630','I97.631','I97.638','I97.64','I97.640','I97.641','I97.648','I97.7','I97.71','I97.710','I97.711','I97.79','I97.790','I97.791','I97.8','I97.81','I97.811','I97.820','I97.82','I97.821','I97.88','I97.89','I99','I99.8','I99.9','I48.0','I21.01','I23.6','I25.110','I25.711','I25.750','I25.761','I51.0','I97.810','I70.209',
               'I70.301','I70.401','I70.468','I70.502','I70.603','I70.709','I79.8','I82.601','I82.B22','I80.291','I82.4Y1','I82.603') ) Comorbidities
             on inclusion_both.patientid = Comorbidities.patientid
             where com_date < indexdate AND com_date >= '2020-01-01'