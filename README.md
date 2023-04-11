# AZ Evusheld Project (US)

An Observational Study to Assess the Real-world Effectiveness of EVUSHELD™ (Tixagevimab/Cilgavimab) as Pre-exposure Prophylaxis Against COVID-19 Among EVUSHELD-eligible Populations in the United States Department of Defense Healthcare System. 

## Study Objective and Hypothesis

### Primary Objectives

1. To assess the effectiveness of EVUSHELD as PrEP against COVID-19 hospitalizations up to 6 months following its initial administration
2. To compare all-cause mortality up to 6 months following the initial dose of EVUSHELD, among patients who did and did not receive EVUSHELD as PrEP

### Secondary Objectives

1. To assess the effectiveness of EVUSHELD as PrEP against a composite outcome of COVID-19 hospitalizations/all-cause mortality up to 6 months following its initial administration
2. To assess the effectiveness of EVUSHELD as PrEP against outcomes listed below up to 6 months following its initial administration:
     (a) Documented SARS-CoV-2 infection
     (b) Medically attended COVID-19
     (c) Medically attended acute-care COVID-19
     (d) COVID-19 intensive care unit (ICU) admission
     (e) COVID-19-related mortality
     (f) Levels of COVID-19 disease severity
   
## Study Design

Total EVUSHELD exposed population was found by finding patients exposed to Evusheld with valid drug exposure date First exvusheld dose exposure for every patient is taken as the indexdate. Amongst the exposed population, patient with age >=12 years and having a medical encounter 12 months prior to the indexdate are considered as the eligible population for the study. This group is taken as the base cohort for further analysis. Amongst the eligible population, patients count for different immunocompromised conditions, clinical outcomes and clinical discretion is found.


## MasterpatientID vs PatientID

One masterpatientid maybe be linked to multiple pateintid, supposedly as the data comes from multiple hospital facilities and they might have different patientids for the same person. So Loopback has linked all the patientids of the same patient to a unique masterpatientid. And this is the reason our analysis is on MASTERPATIENTID.

## Refresh
For the analysis IsActive = 1 and IsDeleted = 0 filter is applied to all the tables used to get the latest non deleted record for a particular patient.
 
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

**Eligible Exposed Population**
* 12 and over, based on person table DOB and index date
* Non-zero visits in the 12 months prior to index date, with visit not tied to eligibility condition

### 1. Refresh - Total Immunocompromised & 2. Refresh - IC Sub Cohorts 1&2
The `eligible evusheld exposed population` patients are tested against various parent and sub cohort immunocompromised conditions provided AZ. ICD codes and concept names are used to determine IC conditions.

### Refresh - Exposed Demographics
Demographics analysis like gender, ethnicity, race & age distribution for the `eligible evusheld exposed population` patients.

## Outcome Analysis - Exposed Cohort

### Refresh - Exposed Outcomes

Clinical outcomes for the eligible exposed population is found outcomes like all cause hospitalization, covid hospitalization, mortality etc. ICD and LOINC codes are used to determine `covid diagnosis` from diagnosis and labresults table respectively. The eligible population cohort and encounter table intersection is done using `encounterid` to get covid diagnosis corresponding to a particular encounter only. Covid diagnosis date range for an encounter is taken as >=-14 till <= encounterdate as a patient can be diagnosed with covid before getting hospitalized.

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
