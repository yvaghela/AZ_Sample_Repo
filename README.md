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


#Exposed Cohort
###Total Exposed Population
EVUSHELD or its components may be coded as a 'drug_exposure' using MEDADMINS or BILLINGS or PROCEDURES or MEDFILLS or MEDORDERS tables. Within N3C, as of Release-v105-2023-01-05, EVUSHELD only appears as a drug_exposure [link to workbook demonstrating this]. EVUSHELD doesn't appear at all within the CMS extract available as of Release-v104-2022-12-15.

N3C drug_exposure start date may not correspond to visit date and can be years in the past or future. Intersecting the provided visit_occurrence_id with the visit_occurrence table provides a more reliable estimate of the encounter date.

The drug_exposure may be a prescription, an administration, or unspecified - in this analysis, earliest encounter date is used as the exposure index date in all cases.

Eligible Exposed Population
12 and over, based on person table DOB and index date
EUA PrEP eligibility condition observed in a 24 month period prior to index date
Non-zero visits in the 12 months prior to index date, with visit not tied to eligibility condition
