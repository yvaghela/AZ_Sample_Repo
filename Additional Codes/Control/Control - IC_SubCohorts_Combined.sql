 -- Sub-cohort: receipt of solid organ or islet transplant and taking immunosuppressive therapy---------------------------------
 

WITH solid_organ as (
select distinct masterpatientid, inclusion_both.patientid,DATE('2022-02-24') AS indexdate  from   
( select masterpatientid,a_pat.patientid,a_pat.dataownerid from (select masterpatientid, patientid,dataownerid from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" 
where dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
  and DATEDIFF(year,BIRTHDATE,DATE('2022-02-24')) >= 12                                                                       ) a_pat

 INNER JOIN (select patientid, encounterdate
             from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_ENCOUNTERS" 
                          ) en
             on a_pat.patientid = en.patientid
             where (encounterdate >= ((DATE('2022-02-24'))-365) AND encounterdate < DATE('2022-02-24') AND encounterdate is not null) 
                                                             ) inclusion_both
             
 INNER JOIN (Select patientid, dxdate from (
                          SELECT patientid, pxdate as dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PROCEDURES"
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
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_DIAGNOSES"
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
                                     ),
                                     
   immuno_therapies as ( Select patientid, medadminstartdate as drug_date
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
                                                                      '%voclosporin%') AND medadminstartdate is NOT NULL
                        
                        UNION ALL
                        
                        Select patientid, ORDERDATE as drug_date
                        from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDORDERS"
                        where SOURCERXMEDNAME ILIKE ANY ('%alemtuzumab%','%belimumab%','%IBRUTINIB%','%ofatumumab%','%rituximab%',
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
                                                                      '%voclosporin%') AND ORDERDATE is NOT NULL
                        
                        UNION ALL
                        
                        Select patientid, filleddate as drug_date
                        from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDFILLS"
                        where SOURCEDRUGNAME ILIKE ANY ('%alemtuzumab%','%belimumab%','%IBRUTINIB%','%ofatumumab%','%rituximab%',
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
                                                                      '%voclosporin%') AND filleddate is NOT NULL
                      
                        )
                        
             select distinct solid_organ.masterpatientid from solid_organ
             inner join immuno_therapies
             on solid_organ.patientid = immuno_therapies.patientid
             where drug_date >= ((indexdate) -365) AND drug_date < indexdate
             
             
 ---- Sub-cohort: receipt of CAR-T therapy---------------------------------
 
 
Select distinct masterpatientid from( select masterpatientid,inclusion_both.patientid  from   
( select masterpatientid,a_pat.patientid,a_pat.dataownerid from (select masterpatientid, patientid,dataownerid from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" 
where dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
  and DATEDIFF(year,BIRTHDATE,DATE('2022-02-24')) >= 12                                                                       ) a_pat

 INNER JOIN (select patientid, encounterdate
             from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_ENCOUNTERS" 
                          ) en
             on a_pat.patientid = en.patientid
             where (encounterdate >= ((DATE('2022-02-24'))-365) AND encounterdate < DATE('2022-02-24') AND encounterdate is not null) 
                                                             ) inclusion_both
             
         inner join (
           select patientid, pxdate as dxdate
           from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PROCEDURES"
           where pxcode IN ('Q2040','C9073','Q2053','C9076','Q2054','C9081','Q2055','C9098','Q2056','0540T','Q2041','Q2042')
         ) CAR_T on inclusion_both.patientid = CAR_T.patientid
         where dxdate >= ((DATE('2022-02-24')) - 365) and (dxdate < DATE('2022-02-24')))
         
         
         
---------- Sub-cohort: receipt HSCT  ____________________________________________________________________________________
  
  select distinct masterpatientid from(
select distinct masterpatientid, inclusion_both.patientid,DATE('2022-02-24') AS indexdate  from   
( select masterpatientid,a_pat.patientid,a_pat.dataownerid from (select masterpatientid, patientid,dataownerid from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" 
where dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
  and DATEDIFF(year,BIRTHDATE,DATE('2022-02-24')) >= 12                                                                       ) a_pat

 INNER JOIN (select patientid, encounterdate
             from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_ENCOUNTERS" 
                          ) en
             on a_pat.patientid = en.patientid
             where (encounterdate >= ((DATE('2022-02-24'))-365) AND encounterdate < DATE('2022-02-24') AND encounterdate is not null) 
                                                             ) inclusion_both
             
  inner join (Select patientid, dxdate from (
                          SELECT patientid, pxdate as dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PROCEDURES"
                          where pxcode in ('S2150','38204','38205','38206','38207','38208','38209','38210','38211','38212','38213','38214','38215',
                                           '38231','38240','38241','38242','38243','65781','81267','81268','86367','86587','86915','0564T','G0267','30230AZ',
                                           '30230U2','30230U3','30230U4','30230X0','30230X1','30230X2','30230X3','30230X4','30230Y0','30230Y1','30230Y2','30230Y3',
                                           '30230Y4','30233AZ','30233U2','30233U3','30233U4','30233X0','30233X1','30233X2','30233X3','30233X4','30233Y0','30233Y1','30233Y2',
                                           '30233Y3','30233Y4','30240AZ','30240U2','30240U3','30240U4','30240X0','30240X1','30240X2','30240X3','30240X4','30240Y0','30240Y1',
                                           '30240Y2','30240Y3','30240Y4','30243AZ','30243U2','30243U3','30243U4','30243X0','30243X1','30243X2','30243X3','30243X4','30243Y0',
                                           '30243Y1','30243Y2','30243Y3','30243Y4','30250X0','30250X1','30250Y0','30250Y1','30253X0','30253X1','30253Y0','30253Y1','30260X0',
                                           '30260X1','30260Y0','30260Y1','30263X0','30263X1','30263Y0','30263Y1','3E0Q0AZ','3E0Q0E0','3E0Q0E1','3E0Q3AZ','3E0Q3E0','3E0Q3E1',
                                           '3E0R0AZ','3E0R0E0','3E0R0E1','3E0R3AZ','3E0R3E0','3E0R3E1','6A550ZT','6A550ZV','6A551ZT','6A551ZV'
                          ) 
                                            and pxdate is not null
                        UNION ALL
                          SELECT patientid, dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_DIAGNOSES"
                          where dxcode in ( 'Z52.001','Z52.011','Z52.091','Z94.84'
                          ) and dxdate is not null)) HSCT
                                           on inclusion_both.patientid = HSCT.patientid
         where dxdate >= ((indexdate) - 365) and dxdate < indexdate)
              

--------- Sub-cohort: active treatment with Anti-CD20/CD52/B-cell depleting therapy-----------------
 
  select distinct masterpatientid from(
select distinct masterpatientid, inclusion_both.patientid,DATE('2022-02-24') AS indexdate  from   
( select masterpatientid,a_pat.patientid,a_pat.dataownerid from (select masterpatientid, patientid,dataownerid from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" 
where dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
  and DATEDIFF(year,BIRTHDATE,DATE('2022-02-24')) >= 12                                                                       ) a_pat

 INNER JOIN (select patientid, encounterdate
             from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_ENCOUNTERS" 
                          ) en
             on a_pat.patientid = en.patientid
             where (encounterdate >= ((DATE('2022-02-24'))-365) AND encounterdate < DATE('2022-02-24') AND encounterdate is not null) 
                                                             ) inclusion_both
             
  inner join ( select patientid, dxdate from (
             select patientid, medadminstartdate as dxdate
             from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDADMINS"
              where lower(sourcemedadminmedname) like '%alemtuzumab%' or lower(sourcemedadminmedname) like'%belimumab%'
                                      or lower(sourcemedadminmedname) like '%ofatumumab%' or lower(sourcemedadminmedname) like'%rituximab%' or
                                      lower(sourcemedadminmedname) like'%ocrelizumab%'
    and medadminstartdate is not null
        UNION ALL
              select patientid, orderdate as dxdate
              from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDORDERS"
              where lower(SOURCERXMEDNAME) like '%alemtuzumab%' or lower(SOURCERXMEDNAME) like'%belimumab%'
                                      or lower(SOURCERXMEDNAME) like '%ofatumumab%' or lower(SOURCERXMEDNAME) like'%rituximab%' or
                                      lower(SOURCERXMEDNAME) like'%ocrelizumab%'
    and orderdate is not null
        UNION ALL
              select patientid,filleddate as dxdate
              from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDFILLS"
              where lower(SOURCEDRUGNAME) like '%alemtuzumab%' or lower(SOURCEDRUGNAME) like'%belimumab%'
                                      or lower(SOURCEDRUGNAME) like '%ofatumumab%' or lower(SOURCEDRUGNAME) like'%rituximab%' or
                                      lower(SOURCEDRUGNAME) like'%ocrelizumab%'
    and filleddate is not null
              )
             ) Anti_CD20_CD52_B_cell_depleting_therapy
             
             on inclusion_both.patientid = Anti_CD20_CD52_B_cell_depleting_therapy.patientid
             where dxdate >= ((indexdate) - 365) and dxdate < indexdate)
             
             
---------             
------------- Sub-cohort: solid tumors on treatment---------------------------------

select distinct masterpatientid from (
select distinct masterpatientid, inclusion_both.patientid,DATE('2022-02-24') AS indexdate  from   
( select masterpatientid,a_pat.patientid,a_pat.dataownerid from (select masterpatientid, patientid,dataownerid from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" 
where dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
  and DATEDIFF(year,BIRTHDATE,DATE('2022-02-24')) >= 12                                                                       ) a_pat

 INNER JOIN (select patientid, encounterdate
             from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_ENCOUNTERS" 
                          ) en
             on a_pat.patientid = en.patientid
             where (encounterdate >= ((DATE('2022-02-24'))-365) AND encounterdate < DATE('2022-02-24') AND encounterdate is not null) 
                                                             ) inclusion_both
             
   inner join (select patientid, dxdate
              from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_DIAGNOSES"
               where dxcode IN ('C00.0','C00.1','C70','C70.1','C70.9','C71.0','C71','C71.1','C71.2','C71.3','C71.4','C71.5','C71.6','C71.7','C71.8',
                                'C71.9','C72.0','C72.1','C72.20','C72.2','C72.21','C72.22','C72.30','C72.3','C72.31','C72.32','C72.40','C72.4','C72.41',
                                'C72.42','C72.50','C72.5','C72.59','C72.9','C00','C00.2','C00.3','C00.4','C00.5','C00.6','C00.8','C00.9','C02.0','C02.1',
                                'C01','C02','C02.2','C02.4','C02.8','C70.0','C03.0','C03.1','C03.9','C04.8','C04.9','C04','C05.0','C05.1','C05.2','C05',
                                'C05.8','C05.9','C06.0','C06.1','C06.2','C06','C06.80','C06.89','C06.9','C08.0','C08.1','C08.9','C07','C08','C09.0','C09.1',
                                'C09.8','C09','C09.9','C10.0','C10.1','C10.2','C10','C10.3','C10.4','C10.8','C10.9','C11.0','C11.1','C11.2','C11','C11.3',
                                'C11.8','C11.9','C13.0','C13.1','C13.2','C12','C13','C13.8','C13.9','C14.0','C14.2','C14.8','C15.3','C15.4','C15.5','C15',
                                'C15.8','C15.9','C16.0','C16.1','C16.2','C16','C16.3','C16.4','C16.5','C16.8','C16.9','C17.0','C17.1','C17.2','C17','C03','C18.0',
                                'C18.1','C18.2','C18','C18.3','C18.4','C18.5','C18.6','C18.7','C18.8','C18.9','C21.0','C21.1','C21.2','C19','C20','C21','C22.0',
                                'C22.1','C22.2','C22.3','C22','C22.4','C22.7','C22.9','C24.0','C24.1','C24.8','C24.9','C23','C24','C25.0','C25.1','C25.2','C25.3',
                                'C25','C25.4','C25.7','C25.8','C25.9','C26.0','C26.1','C26.9','C30.0','C26','C30.1','C31.0','C31.1','C30','C31.2','C31.3','C31','C31.9',
                                'C32.0','C32.1','C32.2','C32.3','C32','C32.8','C32.9','C34.00','C34.01','C34.02','C34.10','C33','C34','C34.0','C34.11','C34.12',
                                'C34.2','C34.1','C34.30','C34.31','C34.32','C34.3','C34.8','C34.91','C34.9','C34.92','C38.0','C37','C38','C38.1','C38.2','C38.3',
                                'C38.4','C38.8','C39.0','C39','C39.9','C40.00','C40','C40.0','C40.01','C40.02','C40.10','C40.1','C40.11','C40.12','C40.20','C40.2',
                                'C40.21','C40.22','C40.30','C40.3','C40.31','C40.32','C40.80','C40.81','C40.82','C40.90','C40.9','C40.91','C40.92','C41.0','C41',
                                'C41.1','C41.2','C41.3','C41.4','C41.9','C43.0','C43','C43.10','C43.1','C43.11','C43.111','C43.112','C43.12','C43.121','C43.122',
                                'C43.20','C43.2','C43.21','C43.22','C43.30','C43.3','C43.31','C43.39','C43.4','C43.51','C43.5','C43.52','C43.62','C43.70','C43.71',
                                'C43.72','C43.7','C43.8','C43.9','C45.0','C45.1','C45.2','C45','C45.7','C45.9','C46.0','C46.1','C46.2','C46','C46.3','C46.4','C46.50',
                                'C46.51','C46.52','C46.5','C46.7','C46.9','C47.10','C47.11','C47.12','C47','C47.20','C47.21','C47.22','C47.3','C47.2','C47.4','C47.5',
                                'C47.6','C47.8','C47.9','C48.0','C48.1','C48.2','C48.8','C48','C49.0','C49.10','C49.11','C49.12','C49','C49.20','C49.1','C49.21','C49.22',
                                'C49.3','C49.2','C49.4','C49.5','C49.6','C49.8','C49.9','C49.A0','C49.A1','C49.A2','C49.A4','C49.A','C49.A5','C43.6','C4A.10','C4A.11',
                                'C4A.111','C4A.112','C4A.12','C4A.121','C4A.122','C4A.20','C4A.21','C4A.22','C4A.30','C4A.2','C4A.31','C4A.39','C4A.4','C4A.3','C4A.51',
                                'C4A.52','C4A.59','C4A.60','C4A.5','C4A.61','C4A.62','C4A.71','C4A.72','C4A.8','C4A.9','C4A.7','C50.011','C50.012','C50.019','C50.021',
                                'C50.022','C50','C50.0','C50.01','C50.029','C50.111','C50.112','C50.02','C50.119','C50.121','C50.122','C50.1','C50.11','C50.211','C50.212',
                                'C50.219','C50.12','C50.221','C50.222','C50.2','C50.21','C50.229','C50.311','C50.312','C50.22','C50.319','C50.321','C50.322','C50.3',
                                'C50.31','C50.329','C57.02','C50.32','C4A','C50.412','C50.419','C50.421','C50.422','C50.42','C50.429','C50.511','C50.512','C50.5','C50.51',
                                'C50.519','C50.521','C50.522','C50.52','C50.529','C50.611','C50.612','C50.6','C50.61','C50.621','C50.622','C50.62','C50.629','C50.811',
                                'C50.812','C50.8','C50.81','C50.819','C50.821','C50.822','C50.82','C50.829','C50.911','C50.912','C50.9','C50.91','C50.919','C50.921',
                                'C50.922','C50.92','C50.929','C51.0','C51.1','C51','C51.2','C51.8','C51.9','C53.0','C53.1','C52','C53','C53.9','C54.0','C54.1','C54',
                                'C54.2','C54.3','C54.8','C54.9','C56.1','C56.2','C55','C56','C56.9','C57.00','C57.01','C57','C57.0','C50.41','C57.12','C57.21','C57.2',
                                'C57.22','C57.3','C57.4','C57.7','C57.8','C57.9','C60.0','C58','C60','C60.1','C60.2','C60.8','C60.9','C62.00','C57.10','C62','C62.0',
                                'C62.01','C62.02','C62.10','C62.1','C62.11','C62.12','C62.92','C63.00','C63.01','C63','C63.0','C63.02','C63.10','C63.11','C63.1','C63.12',
                                'C63.2','C63.7','C63.8','C63.9','C64.1','C64.2','C64','C64.9','C65.1','C65.2','C65','C65.9','C66.1','C66.2','C66','C66.9','C67.0','C67.1',
                                'C67','C67.2','C67.3','C67.5','C67.6','C67.7','C67.8','C67.9','C68.0','C68.1','C68','C68.8','C68.9','C69.00','C69.01','C69','C69.0','C69.02',
                                'C57.11','C69.12','C69.20','C69.21','C69.22','C69.30','C69.2','C69.31','C69.32','C69.40','C69.3','C69.41','C69.42','C69.50','C69.4','C69.51',
                                'C69.52','C69.60','C69.5','C69.61','C69.62','C69.81','C69.6','C69.82','C69.90','C69.91','C69.92','C74.00','C74.01','C69.9','C74.02','C74.10',
                                'C74.11','C73','C74','C74.0','C74.12','C74.90','C74.91','C74.1','C74.92','C75.0','C75.1','C74.9','C75.2','C75.3','C75.4','C75','C75.8',
                                'C75.9','C76.0','C76.1','C76.2','C76.3','C76.40','C76','C76.41','C76.42','C76.50','C76.51','C76.4','C76.52','C76.8','C7A.00','C76.5',
                                'C7A.010','C7A.011','C7A.012','C7A.020','C7A','C7A.0','C7A.01','C7A.02','C69.1','C7A.025','C7A.026','C7A.090','C7A.091','C7A.09','C7A.092',
                                'C7A.093','C7A.094','C7A.095','C7A.096','C7A.098','C7A.1','C7A.8','C80.0','C80.1','C80','C80.2','C7A.023','C7A.024','C02.9','C72',
                                'C04.0','C17.3','C06.8','C14','C22.8','C31.8','C34.80','C34.90','C43.59','C43.60','C40.8','C49.A3','C49.A9','C47.1','C50.129','C50.619',
                                'C4A.1','C4A.6','C53.8','C50.4','C57.20','C67.4','C57.1','C69.10','C75.5','C69.8','C7A.021','C7A.022','C7A.019','C62.9','C62.90',
                                'C61','C56.3','D45','C02.3','C04.1','C16.6','C17.8','C17.9','C21.8','C34.81','C34.82','C43.61','C47.0','C4A.0','C4A.70','C50.411',
                                'C62.91','C69.11','C69.80','C7A.029',
                               
                               'C79.63','C77','C77.0','C77.1','C77.2','C77.3','C77.4','C77.5','C77.8','C77.9','C78','C78.0','C78.00','C78.01','C78.02','C78.1',
                                'C78.2','C78.3','C78.30','C78.39','C78.4','C78.5','C78.6','C78.7','C78.8','C78.80','C78.89','C79','C79.0','C79.00','C79.01','C79.02',
                                'C79.1','C79.10','C79.11','C79.19','C79.2','C79.3','C79.31','C79.32','C79.4','C79.40','C79.49','C79.5','C79.51','C79.52','C79.6','C79.60',
                                'C79.61','C79.62','C79.7','C79.70','C79.71','C79.72','C79.8','C79.81','C79.82','C79.89','C79.9','C7B','C7B.0','C7B.00','C7B.01','C7B.02',
                                'C7B.03','C7B.04','C7B.09','C7B.1','C7B.8')
              ) tumor_codes
              on tumor_codes.patientid = inclusion_both.patientid
              where dxdate >= ((indexdate) - 365) and dxdate < indexdate  
              ) tumor_evu_pat
              
   inner join (
                 Select patientid, drug_date from (
                                                    select patientid, medadminstartdate as drug_date
                                                    from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDADMINS"
                                                    where  ( lower(SOURCEMEDADMINMEDNAME) like	lower('%ABARELIX%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ABATACEPT%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ABIRATERONE%')
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%ADO%TRASTUZUMAB%EMTANSINE%')
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
OR lower(SOURCEMEDADMINMEDNAME) like	lower('%URACIL%5-FU%')
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
                                                    from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDORDERS"
                                                   where (lower(SOURCERXMEDNAME) like	lower('%ABARELIX%')
OR lower(SOURCERXMEDNAME) like	lower('%ABATACEPT%')
OR lower(SOURCERXMEDNAME) like	lower('%ABIRATERONE%')
OR lower(SOURCERXMEDNAME) like	lower('%ADO%TRASTUZUMAB%EMTANSINE%')
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
                                                    from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_MEDFILLS"
                                                    where (  lower(SOURCEDRUGNAME) like	lower('%ABARELIX%')
OR lower(SOURCEDRUGNAME) like	lower('%ABATACEPT%')
OR lower(SOURCEDRUGNAME) like	lower('%ABIRATERONE%')
OR lower(SOURCEDRUGNAME) like	lower('%ADO%TRASTUZUMAB%EMTANSINE%')
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
OR lower(SOURCEDRUGNAME) like	lower('%TALIMOGENE%LAHERPAREPVEC%') OR lower(SOURCEDRUGNAME) like lower('%HUMAN%HERPESVIRUS 1%')
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


                                                    and filleddate is not null))
   ) cancer_therapies
   
   on tumor_evu_pat.patientid =  cancer_therapies.patientid
   where drug_date >= ((indexdate) - 365) and drug_date < indexdate 
   
   
 ------------- Sub-cohort: Solid organ transplant, high risk---------------

select distinct masterpatientid from (select distinct solid_organ_evu.masterpatientid from (
select distinct masterpatientid, inclusion_both.patientid,DATE('2022-02-24') AS indexdate  from   
( select masterpatientid,a_pat.patientid,a_pat.dataownerid from (select masterpatientid, patientid,dataownerid from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" 
where dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
  and DATEDIFF(year,BIRTHDATE,DATE('2022-02-24')) >= 12                                                                       ) a_pat

 INNER JOIN (select patientid, encounterdate
             from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_ENCOUNTERS" 
                          ) en
             on a_pat.patientid = en.patientid
             where (encounterdate >= ((DATE('2022-02-24'))-365) AND encounterdate < DATE('2022-02-24') AND encounterdate is not null) 
                                                             ) inclusion_both
             
 INNER JOIN (Select patientid, dxdate from (
                          SELECT patientid, pxdate as dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PROCEDURES"
                          where pxcode in ('0055U','0087U','0088U','0141T','0142T','0143T','0584T','0585T','0586T','23440','29868','32851','32852','32853','32854','33927',
                                           '33929','33935','33945','38240','38241','38242','38243','43625','44135','44136','44137','47135','47136','48160','48554','48556',
                                           '50340','50360','50365','50366','50370','50380','60510','60512','65710','65720','65725','65730','65740','65745','65750','65755',
                                           '65756','65767','65780','65781','65782','76776','76778','81595','G0341','G0342','G0343','G8727','S2052','S2053','S2054','S2060',
                                           'S2065','S2102','S2103','S2109','S2142','S2150','S2152','02Y','02YA','02YA0Z0','02YA0Z1','02YA0Z2','07Y','07YM','07YM0Z0','07YM0Z1',
                                           '07YM0Z2','07YP','07YP0Z0','07YP0Z1','07YP0Z2','0BY','0BYC','0BYC0Z0','0BYC0Z1','0BYC0Z2','0BYD','0BYD0Z0','0BYD0Z1','0BYD0Z2','0BYF',
                                           '0BYF0Z0','0BYF0Z1','0BYF0Z2','0BYG','0BYG0Z0','0BYG0Z1','0BYG0Z2','0BYH','0BYH0Z0','0BYH0Z1','0BYH0Z2','0BYJ','0BYJ0Z0','0BYJ0Z1',
                                           '0BYJ0Z2','0BYK','0BYK0Z0','0BYK0Z1','0BYK0Z2','0BYL','0BYL0Z0','0BYL0Z1','0BYL0Z2','0BYM','0BYM0Z0','0BYM0Z1','0BYM0Z2','0DY','0DY5',
                                           '0DY50Z0','0DY50Z1','0DY50Z2','0DY6','0DY60Z0','0DY60Z1','0DY60Z2','0DY8','0DY80Z0','0DY80Z1','0DY80Z2','0DYE','0DYE0Z0','0DYE0Z1',
                                           '0DYE0Z2','0FY','0FY0','0FY00Z0','0FY00Z1','0FY00Z2','0FYG','0FYG0Z0','0FYG0Z1','0FYG0Z2','0TY','0TY0','0TY00Z0','0TY00Z1','0TY00Z2',
                                           '0TY1','0TY10Z0','0TY10Z1','0TY10Z2','0UY','0UY0','0UY00Z0','0UY00Z1','0UY00Z2','0UY1','0UY10Z0','0UY10Z1','0UY10Z2','0UY9','0UY90Z0',
                                           '0UY90Z1','0UY90Z2','0WY','0WY2','0WY20Z0','0WY20Z1','0XY','0XYJ','0XYJ0Z0','0XYJ0Z1','0XYK','0XYK0Z0','0XYK0Z1') 
                                            and pxdate is not null
                        UNION ALL
                          SELECT patientid, dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_DIAGNOSES"
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
                                     ) solid_organ_evu
                                     
     inner join (select patientid, dxdate as GVHD_dxdate from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_DIAGNOSES"
                    where dxcode IN ('D89.810','D89.811','D89.812','D89.813')
                 ) GVHD
                on solid_organ_evu.patientid = GVHD.patientid
                 where GVHD_dxdate < indexdate
                 
     UNION ALL
     
select distinct solid_organ_age.masterpatientid from (
select distinct masterpatientid, inclusion_both.patientid,DATE('2022-02-24') AS indexdate,age  from   
( select masterpatientid,a_pat.patientid,a_pat.dataownerid,age from (select masterpatientid, patientid,dataownerid,DATEDIFF(days,BIRTHDATE,DATE('2022-02-24')) as age 
                                                                     from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" 
where dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
  and DATEDIFF(year,BIRTHDATE,DATE('2022-02-24')) >= 12                                                                       ) a_pat

 INNER JOIN (select patientid, encounterdate
             from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_ENCOUNTERS" 
                          ) en
             on a_pat.patientid = en.patientid
             where (encounterdate >= ((DATE('2022-02-24'))-365) AND encounterdate < DATE('2022-02-24') AND encounterdate is not null) 
                                                             ) inclusion_both
             
 INNER JOIN (Select patientid, dxdate from (
                          SELECT patientid, pxdate as dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PROCEDURES"
                          where pxcode in ('0055U','0087U','0088U','0141T','0142T','0143T','0584T','0585T','0586T','23440','29868','32851','32852','32853','32854','33927',
                                           '33929','33935','33945','38240','38241','38242','38243','43625','44135','44136','44137','47135','47136','48160','48554','48556',
                                           '50340','50360','50365','50366','50370','50380','60510','60512','65710','65720','65725','65730','65740','65745','65750','65755',
                                           '65756','65767','65780','65781','65782','76776','76778','81595','G0341','G0342','G0343','G8727','S2052','S2053','S2054','S2060',
                                           'S2065','S2102','S2103','S2109','S2142','S2150','S2152','02Y','02YA','02YA0Z0','02YA0Z1','02YA0Z2','07Y','07YM','07YM0Z0','07YM0Z1',
                                           '07YM0Z2','07YP','07YP0Z0','07YP0Z1','07YP0Z2','0BY','0BYC','0BYC0Z0','0BYC0Z1','0BYC0Z2','0BYD','0BYD0Z0','0BYD0Z1','0BYD0Z2','0BYF',
                                           '0BYF0Z0','0BYF0Z1','0BYF0Z2','0BYG','0BYG0Z0','0BYG0Z1','0BYG0Z2','0BYH','0BYH0Z0','0BYH0Z1','0BYH0Z2','0BYJ','0BYJ0Z0','0BYJ0Z1',
                                           '0BYJ0Z2','0BYK','0BYK0Z0','0BYK0Z1','0BYK0Z2','0BYL','0BYL0Z0','0BYL0Z1','0BYL0Z2','0BYM','0BYM0Z0','0BYM0Z1','0BYM0Z2','0DY','0DY5',
                                           '0DY50Z0','0DY50Z1','0DY50Z2','0DY6','0DY60Z0','0DY60Z1','0DY60Z2','0DY8','0DY80Z0','0DY80Z1','0DY80Z2','0DYE','0DYE0Z0','0DYE0Z1',
                                           '0DYE0Z2','0FY','0FY0','0FY00Z0','0FY00Z1','0FY00Z2','0FYG','0FYG0Z0','0FYG0Z1','0FYG0Z2','0TY','0TY0','0TY00Z0','0TY00Z1','0TY00Z2',
                                           '0TY1','0TY10Z0','0TY10Z1','0TY10Z2','0UY','0UY0','0UY00Z0','0UY00Z1','0UY00Z2','0UY1','0UY10Z0','0UY10Z1','0UY10Z2','0UY9','0UY90Z0',
                                           '0UY90Z1','0UY90Z2','0WY','0WY2','0WY20Z0','0WY20Z1','0XY','0XYJ','0XYJ0Z0','0XYJ0Z1','0XYK','0XYK0Z0','0XYK0Z1') 
                                            and pxdate is not null
                        UNION ALL
                          SELECT patientid, dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_DIAGNOSES"
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
                                     where dxdate < indexdate and age >=65
                                     ) solid_organ_age)
                                     
                                     
                                     
  ---  ------------ Sub-cohort: Solid organ transplant, others--------
  
  
select distinct masterpatientid from (select distinct solid_organ_evu.masterpatientid from (
select distinct masterpatientid, inclusion_both.patientid,DATE('2022-02-24') AS indexdate  from   
( select masterpatientid,a_pat.patientid,a_pat.dataownerid from (select masterpatientid, patientid,dataownerid from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" 
where dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
  and DATEDIFF(year,BIRTHDATE,DATE('2022-02-24')) >= 12                                                                       ) a_pat

 INNER JOIN (select patientid, encounterdate
             from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_ENCOUNTERS" 
                          ) en
             on a_pat.patientid = en.patientid
             where (encounterdate >= ((DATE('2022-02-24'))-365) AND encounterdate < DATE('2022-02-24') AND encounterdate is not null) 
                                                             ) inclusion_both
             
 INNER JOIN (Select patientid, dxdate from (
                          SELECT patientid, pxdate as dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PROCEDURES"
                          where pxcode in ('0055U','0087U','0088U','0141T','0142T','0143T','0584T','0585T','0586T','23440','29868','32851','32852','32853','32854','33927',
                                           '33929','33935','33945','38240','38241','38242','38243','43625','44135','44136','44137','47135','47136','48160','48554','48556',
                                           '50340','50360','50365','50366','50370','50380','60510','60512','65710','65720','65725','65730','65740','65745','65750','65755',
                                           '65756','65767','65780','65781','65782','76776','76778','81595','G0341','G0342','G0343','G8727','S2052','S2053','S2054','S2060',
                                           'S2065','S2102','S2103','S2109','S2142','S2150','S2152','02Y','02YA','02YA0Z0','02YA0Z1','02YA0Z2','07Y','07YM','07YM0Z0','07YM0Z1',
                                           '07YM0Z2','07YP','07YP0Z0','07YP0Z1','07YP0Z2','0BY','0BYC','0BYC0Z0','0BYC0Z1','0BYC0Z2','0BYD','0BYD0Z0','0BYD0Z1','0BYD0Z2','0BYF',
                                           '0BYF0Z0','0BYF0Z1','0BYF0Z2','0BYG','0BYG0Z0','0BYG0Z1','0BYG0Z2','0BYH','0BYH0Z0','0BYH0Z1','0BYH0Z2','0BYJ','0BYJ0Z0','0BYJ0Z1',
                                           '0BYJ0Z2','0BYK','0BYK0Z0','0BYK0Z1','0BYK0Z2','0BYL','0BYL0Z0','0BYL0Z1','0BYL0Z2','0BYM','0BYM0Z0','0BYM0Z1','0BYM0Z2','0DY','0DY5',
                                           '0DY50Z0','0DY50Z1','0DY50Z2','0DY6','0DY60Z0','0DY60Z1','0DY60Z2','0DY8','0DY80Z0','0DY80Z1','0DY80Z2','0DYE','0DYE0Z0','0DYE0Z1',
                                           '0DYE0Z2','0FY','0FY0','0FY00Z0','0FY00Z1','0FY00Z2','0FYG','0FYG0Z0','0FYG0Z1','0FYG0Z2','0TY','0TY0','0TY00Z0','0TY00Z1','0TY00Z2',
                                           '0TY1','0TY10Z0','0TY10Z1','0TY10Z2','0UY','0UY0','0UY00Z0','0UY00Z1','0UY00Z2','0UY1','0UY10Z0','0UY10Z1','0UY10Z2','0UY9','0UY90Z0',
                                           '0UY90Z1','0UY90Z2','0WY','0WY2','0WY20Z0','0WY20Z1','0XY','0XYJ','0XYJ0Z0','0XYJ0Z1','0XYK','0XYK0Z0','0XYK0Z1') 
                                            and pxdate is not null
                        UNION ALL
                          SELECT patientid, dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_DIAGNOSES"
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
                                     ) solid_organ_evu
                                     
     inner join (select patientid, dxdate as GVHD_dxdate from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_DIAGNOSES"
                    where dxcode IN ('D89.810','D89.811','D89.812','D89.813')
                 ) GVHD
                on solid_organ_evu.patientid = GVHD.patientid
                 where GVHD_dxdate < indexdate
                 
     UNION ALL
     
select distinct solid_organ_age.masterpatientid from (
select distinct masterpatientid, inclusion_both.patientid,DATE('2022-02-24') AS indexdate,age  from   
( select masterpatientid,a_pat.patientid,a_pat.dataownerid,age from (select masterpatientid, patientid,dataownerid,DATEDIFF(days,BIRTHDATE,DATE('2022-02-24')) as age from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PATIENTS" 
where dataownerid IN('137301f961d1fd77b33c529c9be609e52c35aca429583fc49b93ffb36487101a','1cbb8cafcbcfc22addedb1d9e2034afe0a29bb5b74f1f230dfd58e12322a3e11',
'5540c5b22e7435d6eb2a63e3a80b623d75eb34812013cb78575843f661f9bbc7','5fdd0ff9ae31f6c7ce6a195bd1a13b382143b8b6e70780fc18acf579dfc5e54b',
'6b952660a48d81f2da56f80a7a695446ea01ba3942c0ee6da3f38dafb5d60920','7804f6717b418811a9797e1805a921fb5b9582943c78e3924925d551c650a2a3',
'86d8165865fdd068bbb2b235990d6ea56c39fac4a5dc1cc53f65d6bc675e6363','a3bc2a45e2fb93d0ea261db098c16e6d8156fcbca543157de8deffbb156c8901',
'c48925c0b23c35d71a975a18c9478d371ad8c12b94b3e179bd1db880d48e56df','c877ef723bbc0de29171dcaa993fe3b86064bb0d0d7be4523bb0b71688ebbb72')
  and DATEDIFF(year,BIRTHDATE,DATE('2022-02-24')) >= 12                                                                       ) a_pat

 INNER JOIN (select patientid, encounterdate
             from "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_ENCOUNTERS" 
                          ) en
             on a_pat.patientid = en.patientid
             where (encounterdate >= ((DATE('2022-02-24'))-365) AND encounterdate < DATE('2022-02-24') AND encounterdate is not null) 
                                                             ) inclusion_both
             
 INNER JOIN (Select patientid, dxdate from (
                          SELECT patientid, pxdate as dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_PROCEDURES"
                          where pxcode in ('0055U','0087U','0088U','0141T','0142T','0143T','0584T','0585T','0586T','23440','29868','32851','32852','32853','32854','33927',
                                           '33929','33935','33945','38240','38241','38242','38243','43625','44135','44136','44137','47135','47136','48160','48554','48556',
                                           '50340','50360','50365','50366','50370','50380','60510','60512','65710','65720','65725','65730','65740','65745','65750','65755',
                                           '65756','65767','65780','65781','65782','76776','76778','81595','G0341','G0342','G0343','G8727','S2052','S2053','S2054','S2060',
                                           'S2065','S2102','S2103','S2109','S2142','S2150','S2152','02Y','02YA','02YA0Z0','02YA0Z1','02YA0Z2','07Y','07YM','07YM0Z0','07YM0Z1',
                                           '07YM0Z2','07YP','07YP0Z0','07YP0Z1','07YP0Z2','0BY','0BYC','0BYC0Z0','0BYC0Z1','0BYC0Z2','0BYD','0BYD0Z0','0BYD0Z1','0BYD0Z2','0BYF',
                                           '0BYF0Z0','0BYF0Z1','0BYF0Z2','0BYG','0BYG0Z0','0BYG0Z1','0BYG0Z2','0BYH','0BYH0Z0','0BYH0Z1','0BYH0Z2','0BYJ','0BYJ0Z0','0BYJ0Z1',
                                           '0BYJ0Z2','0BYK','0BYK0Z0','0BYK0Z1','0BYK0Z2','0BYL','0BYL0Z0','0BYL0Z1','0BYL0Z2','0BYM','0BYM0Z0','0BYM0Z1','0BYM0Z2','0DY','0DY5',
                                           '0DY50Z0','0DY50Z1','0DY50Z2','0DY6','0DY60Z0','0DY60Z1','0DY60Z2','0DY8','0DY80Z0','0DY80Z1','0DY80Z2','0DYE','0DYE0Z0','0DYE0Z1',
                                           '0DYE0Z2','0FY','0FY0','0FY00Z0','0FY00Z1','0FY00Z2','0FYG','0FYG0Z0','0FYG0Z1','0FYG0Z2','0TY','0TY0','0TY00Z0','0TY00Z1','0TY00Z2',
                                           '0TY1','0TY10Z0','0TY10Z1','0TY10Z2','0UY','0UY0','0UY00Z0','0UY00Z1','0UY00Z2','0UY1','0UY10Z0','0UY10Z1','0UY10Z2','0UY9','0UY90Z0',
                                           '0UY90Z1','0UY90Z2','0WY','0WY2','0WY20Z0','0WY20Z1','0XY','0XYJ','0XYJ0Z0','0XYJ0Z1','0XYK','0XYK0Z0','0XYK0Z1') 
                                            and pxdate is not null
                        UNION ALL
                          SELECT patientid, dxdate
                          FROM "DEID_PLATFORM"."GRATICULESOW3A"."VW_DEID_DIAGNOSES"
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
                                     where dxdate < indexdate and age < 65
                                     ) solid_organ_age)
                                     
                                     
-----
