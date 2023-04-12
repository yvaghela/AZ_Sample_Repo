 WITH immuno_pat as (
select masterpatientid, all_pat.patientid 
  from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" all_pat                     
                     
INNER JOIN (   Select patientid, medadminstartdate as dxdate
                        from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDADMINS"
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
                   on all_pat.patientid = immuno_names.patientid
                     where dxdate >= ('2021-02-24') and dxdate < ('2022-02-24') 
                     ),
  
  
   corti_pat as (
     select masterpatientid, all_pat.patientid 
  from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" all_pat
  
    INNER JOIN (
                 select * from (select patientid, ((DOSE*RXQUANTITY)/rxsupply_updated) as daily_dose,SOURCERXMEDNAME,drugdate from (
                  select patientid,SourceRxMedName,ORDERDATE as drugdate,REGEXP_SUBSTR(RXDOSEORDERED,'\\d*') as DOSE,RXQUANTITY,RXENDDATE,RXSTARTDATE,
                  case 
                  when rxdayssupply is null then (RXENDDATE-RXSTARTDATE) end as rxsupply_updated
                 from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDORDERS"
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
                 from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDFILLS"
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
        on all_pat.patientid = corti_names.patientid
     where drugdate >= ('2022-01-24') and drugdate < ('2022-02-24') 
   ) 
                     
       select distinct MASTERPATIENTID from immuno_pat
    UNION ALL
        select distinct MASTERPATIENTID from corti_pat 