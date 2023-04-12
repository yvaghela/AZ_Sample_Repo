select distinct masterpatientid, encounterdate, admitdate, dischargedate,encountertype from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" en
                     inner join "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS"
                     on en.patientid  = "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS".patientid
                     where encountertype IN ('EI','IP') order by masterpatientid
                     --and admitdate is null and dischargedate is null
                     
                     ----- 38, 0017325ff17ab11be6168658e2f58194d1f23d6a654a513a9497b639f4eb25d4, 2022-09-21, 2022-09-21, NULL
                     
            ----RESULT: for diff entries of the same person  - encounterdates are diff but the in one entry admit date is available and
                        ---for other entry its NULL eg: 0010c7b1eeeabb4f095117c813316644e050b9ca654faeea87e4a297aaa05547
                        
                        -----
                       
                     
                     select admitdate from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" where encountertype IN ('EI','IP')
                     select dischargedate from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" where encountertype IN ('EI','IP')
                      select patientid from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" where encountertype IN ('EI','IP')
                      
                   ----to get %   
                       select count(admitdate), count(dischargedate), count(patientid) 
                       from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" where encountertype IN ('EI','IP')
                       
                       
                       select distinct patientid, encounterdate---, admitdate, dischargedate
                       from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS" where encountertype IN ('EI','IP') and admitdate is not null
                       order by patientid
                       
                       ---- ONly 1 entery and discharge date is null. Row = 68
                       ----001e02d71700ceadc9ca41c5c994c384d7e20073f255a68685caa2822363b393, 2022-02-25, 2022-02-25, NULL
                     
                     
                     
                       
                       
                       
                       
                       select patientid from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
                       where encountertype IN ('EI','IP') and admitdate = encounterdate and admitdate is NOT NULL
                       
                       
                       select patientid from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
                       where encountertype IN ('EI','IP') and admitdate is NOT NULL
                       
                       
                       
 -------------------------------------------------------22/02/23 ANALYSIS ------------------------------------------------------------------------------
 
 select count(patientid),count(admitdate), count(dischargedate) from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
where ENCOUNTERTYPE IN ('EI', 'IP') AND admitdate is not null AND dischargedate is not null



select count(distinct patientid),count(admitdate), count(dischargedate) from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS"
where ENCOUNTERTYPE IN ('EI', 'IP')



select PDX from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
where PDX is NULL




_______________________________________________________________________________________________________________________________________________________________


 ## Advanced or untreated human immunodeficiency virus (HIV) infection

select distinct HIV_PAT.patientid from (
select distinct patientid from(
select distinct g.patientid, g.medadminstartdate,dxdate from(
select DISTINCT e.PATIENTID, e.medadminstartdate,dxdate from(
select c.patientid, c.medadminstartdate from
(select * from (
   select a.patientid,a.medadminstartdate, (year(a.medadminstartdate) - year(b.Date)) as age from (select * from (
     select patientid, medadminstartdate, row_number () over (partition by patientid order by medadminstartdate ASC) as row1 from (
        select patientid, medadminstartdate 
        from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDADMINS"
        where ndc in ('0310-7442-02','0310-8895-01','0310-1061-01','0310-8861-02')
        OR lower(sourcemedadminmedname) like '%tixagev%' OR lower(sourcemedadminmedname) like'%cilgav%'
     UNION ALL
        select patientid, pxdate as medadminstartdate
        from "HRPCI"."GRATICULESOW3"."VW_DEID_PROCEDURES"
        where  pxcode IN ('Q0220','Q0221','M0220','M0221')
       OR (lower(SOURCEPXCODEDESCRIPTION) like '%tixagev%'  OR lower(SOURCEPXCODEDESCRIPTION) like '%cilgav%')
     UNION ALL
        select patientid, orderdate as medadminstartdate
        from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDORDERS"
        where lower(SOURCERXMEDNAME) like '%tixagev%' OR lower(SOURCERXMEDNAME) like'%cilgav%'
     UNION ALL
         select distinct(patientid), FILLEDDATE as medadminstartdate
         from "HRPCI"."GRATICULESOW3"."VW_DEID_MEDFILLS"
         where NDC IN ('00310744202','00310889501','00310106101','00310886102')
         OR lower(SOURCEDRUGNAME) like '%tixagev%' OR lower(SOURCEDRUGNAME) like'%cilgav%'
     ))
     where row1 = 1 and medadminstartdate is not null) a
  inner join (select patientid, date(birthdate) as Date
             from "HRPCI"."GRATICULESOW3"."VW_DEID_PATIENTS") b
      on a.patientid = b.patientid)
      where age >=12) c
  inner join (select patientid, encounterdate
              from "HRPCI"."GRATICULESOW3"."VW_DEID_ENCOUNTERS") d
      on c.patientid = d.patientid
      where (encounterdate > ((medadminstartdate)-365) AND encounterdate < medadminstartdate AND encounterdate is not null)) e
  inner join (select patientid, dxdate
               from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
               where dxcode IN ('B20','B97.35','O98.7','O98.71','O98.711','O98.712','O98.713','O98.719','O98.72','O98.73','Z21')) f
             on e.patientid = f.patientid)g)
             where (dxdate > ((medadminstartdate) - 365) AND dxdate < medadminstartdate)
             
       ) HIV_PAT
          inner join (select patientid, LABLOINC,RESULTNUM
                     from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS"
                     where LABLOINC = '4210858' AND RESULTNUM < '200') -- OR RESULTNUM < '15%')
                     
                 -----------------------------------------------------------------------------  
                     
                   WITH aa as  ( select distinct lab.patientid,SOURCELABNAME,SOURCELABCODEDESCRIPTION,LABPXCODEDESCRIPTION,RESULTNUM,RESULTUNIT 
                     from "HRPCI"."GRATICULESOW3"."VW_DEID_LABRESULTS" lab
                     inner join (select patientid, dxdate
               from "HRPCI"."GRATICULESOW3"."VW_DEID_DIAGNOSES"
               where dxcode IN ('B20','B97.35','O98.7','O98.71','O98.711','O98.712','O98.713','O98.719','O98.72','O98.73','Z21')) f
               where  (SOURCELABNAME ILIKE '%CD4%') order by SOURCELABNAME) --OR SOURCELABCODEDESCRIPTION ILIKE '%CD4%' OR LABPXCODEDESCRIPTION ilike '%CD4%')
               
               select distinct SOURCELABNAME, LABPXCODEDESCRIPTION,RESULTUNIT  from aa 
               where SOURCELABNAME  NOT like '%/%' AND lower(SOURCELABNAME)  NOT like '%ratio%' AND lower(SOURCELABNAME)  NOT like '%cd45%' 
               AND SOURCELABNAME not like '%CD4+CD%' AND SOURCELABNAME not like '%+CD4%' AND SOURCELABNAME not like '%:%'
               AND SOURCELABNAME not like '%CD3%' AND SOURCELABNAME not like '%ACD4N%' AND SOURCELABNAME not like '%CD4N%' 
               AND lower(SOURCELABNAME) not like '%chimerism%' AND lower(SOURCELABNAME)  NOT like '%atp%'
               AND lower(SOURCELABNAME) not like '%platelets%'  AND lower(SOURCELABNAME)  NOT like '%gamma%'
               AND lower(resultunit) not like '%fl%' AND lower(resultunit) not like '%pg%' AND lower(resultunit) not like '%dl%'
       
               order by SOURCELABNAME
               
               
               
               
               
               
               
               where  RESULTUNIT ILIKE '%/mm%'
                    
                   -- where RESULTNUM < '200' AND RESULTUNIT ILIKE 'cells' 
                    
                  --  AND LABPXCODEDESCRIPTION ilike 'CD'
                   --  AND (SOURCELABNAME ILIKE 'CD4' OR SOURCELABCODEDESCRIPTION ILIKE 'CD4' OR LABPXCODEDESCRIPTION ilike 'CD')
             
    