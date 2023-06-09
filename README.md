# Retrospective Observational Study of EVUSHELD Utilization in Immunocompromised Patients
An Observational Study to Assess the Real-world Effectiveness of EVUSHELD™ (Tixagevimab/Cilgavimab) against COVID-19 among EVUSHELD-eligible Populations in the United States Department of Defense Healthcare System. 

## Study Overview
The purpose of this study is to describe EVUSHELD patterns of use (e.g. number of patients receiving EVUSHELD as PrEP or treatment, timing of EVUSHELD doses, etc.), the sociodemographic and clinical characteristics of patients who have received and have not received EVUSHELD, and explore the availability and reliability of key variables (i.e. exposures, covariates, and outcome measures) that may be used in the evaluation of EVUSHELD real world effectiveness as part of an observational, retrospective or hybrid study design.
   
## Study Population
The exposure of interest is defined as administration of EVUSHELD, and the date of initial administration is deemed the index date; those unexposed are defined as individuals with similar conditions/indications of immune compromise as the exposed, but who have not been administered EVUSHELD.
The index date for the unexposed cohort is the date of EVUSHELD authorisation in the United States (24th Feb 2022).

## Loopback Data Overview
Loopback addresses data pipeline and preparation needs of the clinical data researcher, serving as a ‘project-ready’ real-world data (RWD) resource for electronic health record (EHR) data. De-duplicated, normalized to a common data model, and enriched with an expanding range of researcher-friendly attributes.

![loopback numbers](https://user-images.githubusercontent.com/129261496/231142282-d98113b4-a824-4bfd-b6ae-4b7c56488546.png)

## Lag Analysis
For Lag Analysis since there was no information on when the record was created in the database, we have taken the table creation date as the reference `anchor date`. Then Domain Lag is calculated by finding out the difference between the latest event date for a `domain` (Diagnosis, Encounter, Procedures, Lab Results and Medications) and the anchor date.

## Refresh
For the analysis `IsActive = 1` and `IsDeleted = 0` filter is applied to all the tables used to get the latest non deleted record for a particular patient.

## MasterpatientID vs PatientID
One masterpatientid maybe be linked to multiple pateintid, as the data may come from multiple hospital facilities and they might have different patientids for the same patient. So Loopback has linked all the patientids of the same patient to a unique masterpatientid. And this is the reason our analysis is on MASTERPATIENTID.
 
## Directories in Repository
Repositry contains the following 8 directories:

1. Preliminary Analysis - Exposed Cohort: Premiliminary analysis like total evusheld exposed patients and exposures, patients falling under AZ defined inclusion                                                 criteria, demographics, total immunocompromised patients etc. 
2.  Outcome Analysis -Exposed Cohort: Clinical outcomes analysis of evusheld exposed patients.
3.  Comorbidity - Analysis Exposed Cohort: Comorbidities and CCI score analysis of exposed patients.
4.  Comorbidity Analysis - Clinical Discretion: Comorbidities, demographics and CCI score analysis of patients following under clinical discretion.
5.  Preliminary Analysis - Unexposed Cohort: Premiliminary analysis like total unexposed patients, patients falling under AZ defined inclusion                                                                      criteria, demographics, total immunocompromised patients etc.
6.  Outcome Analysis - Unexposed Cohort: Clinical outcomes analysis of the unexposed cohort.
7.  Comorbidity Analysis - Unexposed Cohort: Comorbidities and CCI score analysis of unexposed patients.
8.  Additional Analysis - Additional analysis like Lag analysis and Clinical notes analysis


## Preliminary Analysis - Exposed Cohort

### Refresh - EVUSHELD Exposed Cohort
For finding exposed population: EVUSHELD or its components may be coded as a `drug_exposure` using `MEDADMINS` or `BILLINGS` or `PROCEDURES` or `MEDFILLS` or `MEDORDERS` tables. NDC codes and concept names are used to identify evusheld exposures. Drug_exposure start date (medadminstartdate) may not correspond to encounter date and can be years in the past or future. The Evusheld `drug_exposure` may be a prescription, an administration, or unspecified - in this analysis, earliest drug_exposure date is used as the exposure `index_date` in all cases.

Eligible Exposed Population:
* 12 and over, based on person table DOB and index date
* Non-zero visits in the 12 months prior to index date, with visit not tied to eligibility condition

### Refresh - Total Immunocompromised & Refresh - IC Sub Cohorts 1&2
The `eligible evusheld exposed population` patients are tested against various parent and sub cohort immunocompromised conditions provided by AZ. ICD codes and concept names are used to determine IC conditions. Cancer, Immunosuppressive & corticosteroid therapies are identified using `concept names`. And for HIV/AIDS CD4 cell count is identified using `SOURCELABNAME` from the `LABRESULTS` table.

### Refresh - Exposed Demographics
Demographics analysis like `gender`, `ethnicity`, `race` & `age` distribution for the eligible evusheld exposed population patients.

## Outcome Analysis - Exposed Cohort

### Refresh - Exposed Outcomes

Clinical outcomes for the eligible exposed population is found outcomes like all cause hospitalization, covid hospitalization, mortality etc. ICD and LOINC codes are used to determine `covid diagnosis` from diagnosis and labresults table respectively. The eligible population cohort and encounter table intersection is done using `encounterid` to get covid diagnosis corresponding to a particular encounter only. Covid diagnosis date range for an encounter is taken as `>=-14 till <= encounterdate` as a patient can be diagnosed with covid before getting hospitalized.

## Comorbidity Analysis - Exposed Cohort

### Refresh - Exposed Other Comorbidities
Evusheld exposed eligible population is analysised for comorbidities distribution, other than the charlson comorbidities. ICD codes are used to determine comorbidities.

### Refresh - Exposed CCI
Patients with Charlson comorbidities amongst Evusheld exposed eligible population group are found to develop CCI scores for these pateints. Charlson Comordibities counts(ICD codes) are also found using the same code. 

## Comorbidity Analysis - Clinical Discretion

### Refresh - Clinical Discretion Demographics

Evusheld exposed patients that don't fall under any or both of the two eligible criteria make the clinical discretion group. Demographics analysis like gender and age distribution for patients falling under clinical discretion.

### Refresh - Discretion Other Comorbidities

Clinical discretion group is analysised for different comorbidities provided by AZ. ICD codes were used to find all comorbidities provided by AZ.

### Refresh - CCI Clinical Discretion

Patients with Charlson comorbidities amongst clinical discretion group are found to develop CCI scores for these pateints. Charlson Comordibities counts(ICD codes) are also found using the same code. 


## Preliminary Analysis - Unexposed Cohort

### Refresh - Unexposed Cohort Analysis
For finding total population `masterpatientid` from the `patients` tables are found. Amongst these pateints eligible unexposed population is as:

Eligible criteria:
* 12 and over, based on person table DOB and index date
* Non-zero visits in the 12 months prior to index date, with visit not tied to eligibility condition

### Refresh - Unexposed Total IC & IC Sub Cohorts
The patients satisfying the eligible criteria are tested against various parent and sub cohort immunocompromised conditions provided AZ. ICD codes and concept names are used to determine IC conditions. `Total IC cohort` was defined by doing a `union` of the 8 IC parent conditions.

`Total IC cohort` is considered the `base cohort` for further analysis.


## Outcome Analysis - Unexposed Cohort

### Refresh - Unexposed Outcomes

Clinical outcomes for the Total IC cohort is found outcomes like all cause hospitalization, covid hospitalization, mortality etc. ICD and LOINC codes are used to determine `covid diagnosis` from diagnosis and labresults table respectively. The eligible population cohort and encounter table intersection is done using `encounterid` to get covid diagnosis corresponding to a particular encounter only. Covid diagnosis date range for an encounter is taken as `>=-14 till <= encounterdate` as a patient can be diagnosed with covid before getting hospitalized.

## Comorbidity Analysis - Unexposed Cohort

### Refresh - Unexposed CCI & Comorbidities
Total IC cohort is analysised for comorbidities distribution, other than the charlson comorbidities. ICD codes are used to determine comorbidities.

Patients with `Charlson comorbidities` amongst Evusheld exposed Total IC cohort are found to develop CCI scores for these pateints. Charlson Comordibities counts(ICD codes) are also found using the same code. 
