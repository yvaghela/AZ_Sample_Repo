# AZ Evusheld Project (US)

An Observational Study to Assess the Real-world Effectiveness of EVUSHELD™ (Tixagevimab/Cilgavimab) as Pre-exposure Prophylaxis Against COVID-19 Among EVUSHELD-eligible Populations in the United States Department of Defense Healthcare System. 

# Study Objective and Hypothesis

**Primary Objectives**

1. To assess the effectiveness of EVUSHELD as PrEP against COVID-19 hospitalizations up to 6 months following its initial administration
2. To compare all-cause mortality up to 6 months following the initial dose of EVUSHELD, among patients who did and did not receive EVUSHELD as PrEP

**Secondary Objectives**

1. To assess the effectiveness of EVUSHELD as PrEP against a composite outcome of COVID-19 hospitalizations/all-cause mortality up to 6 months following its initial administration
2. To assess the effectiveness of EVUSHELD as PrEP against outcomes listed below up to 6 months following its initial administration:
     (a) Documented SARS-CoV-2 infection
     (b) Medically attended COVID-19
     (c) Medically attended acute-care COVID-19
     (d) COVID-19 intensive care unit (ICU) admission
     (e) COVID-19-related mortality
     (f) Levels of COVID-19 disease severity

# Contains in Repositories

**Priliminary Analysis**

Prilimnary Analysis folders for _EVUSHELD Exposed_ and _EVUSHELD Unexposed_ cohorts contains high level analysis like _**EVUSHELD Exposed**_ which contains patients exposed to EVUSHELD (combination product of tixagevimab and cilgavimab) 

# MasterpatientID & PatientID use

One masterpatientid maybe be linked to multiple pateintid, supposedly as the data comes from multiple hospital facilities and they might have different patientids for the same person. So Loopback has linked all the patientids of the same patient to a unique masterpatientid. And this is the reason our analysis is on MASTERPATIENTID.

# Refresh
 For the analysis IsActive = 1 and IsDeleted = 0 filter is applied to all the tables used to get the latest non deleted record for a particular patient.

# Exposed Cohort

##Total Exposed Population
EVUSHELD or its components may be coded as a 'drug_exposure' using _MEDADMINS_ or _BILLINGS_ or _PROCEDURES_ or _MEDFILLS_ or _MEDORDERS_ tables.

Drug_exposure start date (medadminstartdate) may not correspond to encounter date and can be years in the past or future.

The Evusheld 'drug_exposure' may be a prescription, an administration, or unspecified - in this analysis, earliest drug_exposure date is used as the exposure 'index_date' in all cases.

##Eligible Exposed Population
*12 and over, based on person table DOB and index date
*EUA PrEP eligibility condition observed in a 24 month period prior to index date
*Non-zero visits in the 12 months prior to index date, with visit not tied to eligibility condition
