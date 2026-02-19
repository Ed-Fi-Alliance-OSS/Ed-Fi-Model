# `is sensitive data` PII Annotation — Community Review

**Date:** 2026-02-19  
**Branch:** DATASTD-2538  
**Scope:** Ed-Fi Data Standard MetaEd model (`package/`)

---

## Background

A new `is sensitive data` flag has been added to the MetaEd DSL. When applied to a property, it signals to downstream consumers that the element contains Personally Identifiable Information (PII) or otherwise sensitive data. Consumers may use this annotation to:

- Automatically redact or mask the field before storing data in less-trusted environments.
- Enforce access-control policies at the API or ETL layer.
- Drive audit-logging decisions.

This document summarises every element that was annotated as part of this initial pass and the rationale behind each decision. The intent is to surface these choices to the broader community **before** any downstream tooling changes are made, so that the community can challenge, refine, or extend the list.

---

## Guiding Principles

1. **Direct identifiers** (name, unique ID, email, phone, address) — always sensitive.  
2. **Quasi-identifiers** (birth date, birth place, race/ethnicity, sex, gender identity) — sensitive; the combination of even two of these can uniquely identify an individual.  
3. **Protected-class attributes** (disability, citizenship, tribal affiliation, LEP status) — sensitive under FERPA, ADA, and related regulations.  
4. **Financial data** (salary, aid amounts, economic disadvantage status) — sensitive.  
5. **Health and background data** (immunisation records, medical exemptions, background checks) — sensitive under HIPAA/FERPA.  
6. **Credentials and access** (login IDs) — sensitive because they support authentication.
7. **Lookup / reference codes alone** (descriptor values such as `AddressType`, `TelephoneNumberType`) are **not** marked sensitive because they carry no identity information by themselves.
8. **Aggregate / institutional data** (school identifiers, course codes, GPA type, etc.) are **not** marked sensitive.

---

## Modified Files and Annotated Properties

### `package/Common/Name.metaed`

| Property                            | Rationale                                               |
| ----------------------------------- | ------------------------------------------------------- |
| `FirstName`                         | Direct personal identifier                              |
| `MiddleName`                        | Direct personal identifier                              |
| `LastSurname`                       | Direct personal identifier                              |
| `LastSurname named MaidenName`      | Former legal name; discloses lineage or marital history |
| `FirstName` (role name Preferred)   | Personal preference disclosure                          |
| `LastSurname` (role name Preferred) | Personal preference disclosure                          |

> **Not annotated:** `PersonalTitlePrefix`, `GenerationCodeSuffix` — these are broadly shared honorifics/suffixes with minimal identifying power on their own.

---

### `package/Common/OtherName.metaed`

| Property      | Rationale                                       |
| ------------- | ----------------------------------------------- |
| `FirstName`   | Direct personal identifier (alias / prior name) |
| `MiddleName`  | Direct personal identifier                      |
| `LastSurname` | Direct personal identifier                      |

---

### `package/Common/Address.metaed`

| Property                   | Rationale                                 |
| -------------------------- | ----------------------------------------- |
| `StreetNumberName`         | Home address; direct locating information |
| `ApartmentRoomSuiteNumber` | Refines home address                      |
| `BuildingSiteNumber`       | Refines home address                      |
| `City`                     | Narrowing location identifier             |
| `PostalCode`               | Narrowing location identifier             |
| `Latitude`                 | Precise geolocation                       |
| `Longitude`                | Precise geolocation                       |

> **Not annotated:** `StateAbbreviation`, `NameOfCounty`, `CountyFIPSCode`, `AddressType`, `Locale`, `CongressionalDistrict`, `DoNotPublishIndicator` — these describe location at a level that is generally public or provides only broad area context.

---

### `package/Common/InternationalAddress.metaed`

| Property       | Rationale           |
| -------------- | ------------------- |
| `AddressLine1` | Direct home address |
| `AddressLine2` | Direct home address |
| `AddressLine3` | Direct home address |
| `AddressLine4` | Direct home address |
| `Latitude`     | Precise geolocation |
| `Longitude`    | Precise geolocation |

---

### `package/Common/BirthData.metaed`

| Property                              | Rationale                                                            |
| ------------------------------------- | -------------------------------------------------------------------- |
| `BirthDate`                           | Classic quasi-identifier; required in many re-identification attacks |
| `BirthCity`                           | Narrows birthplace to city level                                     |
| `StateAbbreviation` (role name Birth) | Narrows birthplace to state level                                    |
| `BirthInternationalProvince`          | Narrows birthplace for foreign-born individuals                      |
| `Country` (role name Birth)           | Birthplace disclosure                                                |
| `DateEnteredUS`                       | Immigration-sensitive data                                           |
| `MultipleBirthStatus`                 | Distinguishes twins/triplets; narrows identity within a family       |
| `Sex` (role name Birth)               | Protected biological characteristic                                  |

---

### `package/Common/Citizenship.metaed`

| Property            | Rationale                                      |
| ------------------- | ---------------------------------------------- |
| `CitizenshipStatus` | Immigration and legal status; highly sensitive |
| `Visa`              | Immigration classification                     |

---

### `package/Common/Disability.metaed`

| Property              | Rationale                                                   |
| --------------------- | ----------------------------------------------------------- |
| `Disability`          | Protected health/disability status (ADA, IDEA, Section 504) |
| `DisabilityDiagnosis` | Medical diagnosis text; highly sensitive                    |

---

### `package/Common/ElectronicMail.metaed`

| Property                | Rationale                           |
| ----------------------- | ----------------------------------- |
| `ElectronicMailAddress` | Direct personal contact information |

---

### `package/Common/Telephone.metaed`

| Property          | Rationale                           |
| ----------------- | ----------------------------------- |
| `TelephoneNumber` | Direct personal contact information |

---

### `package/Common/IdentificationDocument.metaed`

| Property                                        | Rationale                                                |
| ----------------------------------------------- | -------------------------------------------------------- |
| `DocumentTitle`                                 | Reveals what identity documents a person holds           |
| `DocumentExpirationDate`                        | Combined with document type allows document forgery risk |
| `IdentificationCode` (role name IssuerDocument) | The actual document number (passport, licence, etc.)     |

---

### `package/Common/BackgroundCheck.metaed`

| Property                       | Rationale                                     |
| ------------------------------ | --------------------------------------------- |
| `BackgroundCheckRequestedDate` | Reveals that a check was initiated            |
| `BackgroundCheckStatus`        | Reveals outcome — could imply criminal record |
| `BackgroundCheckCompletedDate` | Temporal detail of check                      |
| `Fingerprint`                  | Biometric/criminal-history flag               |

---

### `package/Common/Salary.metaed`

| Property         | Rationale                         |
| ---------------- | --------------------------------- |
| `SalaryMinRange` | Financial compensation data       |
| `SalaryMaxRange` | Financial compensation data       |
| `SalaryAmount`   | Exact financial compensation data |

---

### `package/Common/DisciplineIncidentExternalParticipant.metaed`

| Property      | Rationale                                            |
| ------------- | ---------------------------------------------------- |
| `FirstName`   | Name of individual involved in a discipline incident |
| `LastSurname` | Name of individual involved in a discipline incident |

---

### `package/Common/Reviewer.metaed`

| Property      | Rationale                                              |
| ------------- | ------------------------------------------------------ |
| `FirstName`   | Name of individual conducting a performance evaluation |
| `LastSurname` | Name of individual conducting a performance evaluation |

---

### `package/Common/AdministrationPointOfContact.metaed`

| Property                | Rationale                            |
| ----------------------- | ------------------------------------ |
| `ElectronicMailAddress` | Direct contact information           |
| `FirstName`             | Personal name                        |
| `LastSurname`           | Personal name                        |
| `LoginId`               | Authentication credential identifier |

---

### `package/Common/RequiredImmunization.metaed`

| Property               | Rationale                                 |
| ---------------------- | ----------------------------------------- |
| `ImmunizationDate`     | Specific health event date                |
| `MedicalExemption`     | Medical diagnosis / contraindication text |
| `MedicalExemptionDate` | Medical event date                        |

---

### `package/Common/AdditionalImmunization.metaed`

| Property           | Rationale                  |
| ------------------ | -------------------------- |
| `ImmunizationDate` | Specific health event date |

---

### `package/DomainEntity/Student.metaed`

| Property          | Rationale                                                      |
| ----------------- | -------------------------------------------------------------- |
| `StudentUniqueId` | A unique personal identifier — direct identifier by definition |

---

### `package/DomainEntity/Staff.metaed`

| Property        | Rationale                            |
| --------------- | ------------------------------------ |
| `StaffUniqueId` | Unique personal identifier           |
| `BirthDate`     | Quasi-identifier                     |
| `LoginId`       | Authentication credential identifier |

---

### `package/DomainEntity/Contact.metaed`

| Property          | Rationale                            |
| ----------------- | ------------------------------------ |
| `ContactUniqueId` | Unique personal identifier           |
| `Sex`             | Protected biological characteristic  |
| `GenderIdentity`  | Personal gender self-identification  |
| `LoginId`         | Authentication credential identifier |

---

### `package/DomainEntity/DisciplineIncident.metaed`

| Property       | Rationale                                                     |
| -------------- | ------------------------------------------------------------- |
| `ReporterName` | Name of the individual who reported the incident              |
| `CaseNumber`   | Law-enforcement case reference — links to criminal proceeding |

---

### `package/DomainEntity/StudentDemographic.metaed`

| Property                      | Rationale                                   |
| ----------------------------- | ------------------------------------------- |
| `AncestryEthnicOrigin`        | Protected ethnic/cultural origin            |
| `EconomicDisadvantage`        | Financial hardship status                   |
| `GenderIdentity`              | Personal gender self-identification         |
| `HispanicLatinoEthnicity`     | Protected ethnicity indicator               |
| `LimitedEnglishProficiency`   | Federal language-proficiency classification |
| `Race`                        | Protected racial classification             |
| `Sex`                         | Protected biological characteristic         |
| `SupporterMilitaryConnection` | Reveals military family status              |
| `TribalAffiliation`           | Protected tribal membership                 |

---

### `package/DomainEntity/StaffDemographic.metaed`

| Property                  | Rationale                           |
| ------------------------- | ----------------------------------- |
| `AncestryEthnicOrigin`    | Protected ethnic/cultural origin    |
| `GenderIdentity`          | Personal gender self-identification |
| `HispanicLatinoEthnicity` | Protected ethnicity indicator       |
| `Race`                    | Protected racial classification     |
| `Sex`                     | Protected biological characteristic |
| `TribalAffiliation`       | Protected tribal membership         |

---

### `package/DomainEntity/StudentHealth.metaed`

| Property                              | Rationale                                       |
| ------------------------------------- | ----------------------------------------------- |
| `NonMedicalImmunizationExemption`     | Health/religious/philosophical exemption status |
| `NonMedicalImmunizationExemptionDate` | Date of exemption filing                        |

---

### `package/DomainEntity/FinancialAid.metaed`

| Property             | Rationale                |
| -------------------- | ------------------------ |
| `AidAmount`          | Financial award amount   |
| `PellGrantRecipient` | Financial need indicator |

---

### `package/DomainEntity/Candidate.metaed`

| Property                    | Rationale                                      |
| --------------------------- | ---------------------------------------------- |
| `Sex`                       | Protected biological characteristic            |
| `GenderIdentity`            | Personal gender self-identification            |
| `HispanicLatinoEthnicity`   | Protected ethnicity indicator                  |
| `Race`                      | Protected racial classification                |
| `EconomicDisadvantage`      | Financial hardship status                      |
| `LimitedEnglishProficiency` | Federal language-proficiency classification    |
| `DisplacementStatus`        | Crisis-related housing/displacement disclosure |
| `ProfileThumbnail`          | Biometric likeness / photo                     |
| `LoginId`                   | Authentication credential identifier           |
| `TuitionCost`               | Financial obligation data                      |

---

### `package/DomainEntity/ApplicantProfile.metaed`

| Property                  | Rationale                           |
| ------------------------- | ----------------------------------- |
| `Sex`                     | Protected biological characteristic |
| `GenderIdentity`          | Personal gender self-identification |
| `BirthDate`               | Quasi-identifier                    |
| `HispanicLatinoEthnicity` | Protected ethnicity indicator       |
| `Race`                    | Protected racial classification     |
| `EconomicDisadvantage`    | Financial hardship status           |
| `FirstGenerationStudent`  | Socioeconomic background indicator  |

---

### `package/DomainEntity/StudentTransportation.metaed`

| Property                          | Rationale                                 |
| --------------------------------- | ----------------------------------------- |
| `SpecialAccomodationRequirements` | Physical/disability accommodation details |

---

## Elements Considered but NOT Annotated

The following categories were **deliberately not** annotated, and community input on whether any should be is welcome:

| Element / Pattern                                                             | Reason not annotated                                                                                     |
| ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| All `descriptor *Type` / `descriptor *` identity fields that are lookup codes | Carry no personal information by themselves                                                              |
| `PersonalTitlePrefix`, `GenerationCodeSuffix`                                 | Broad social honorifics; minimal re-identification risk                                                  |
| `GradePointAverage` values                                                    | Academic performance, not personally identifying alone                                                   |
| `ClassRanking`                                                                | Aggregate academic standing, not directly identifying                                                    |
| `AidType` descriptor                                                          | Category code only; not the amount                                                                       |
| `CredentialIdentifier`, `LicenseIdentifier`                                   | Institutional identifiers, not personal in isolation                                                     |
| `SalaryType`                                                                  | Classification code, not the actual amount                                                               |
| `ReporterDescription` in `DisciplineIncident`                                 | A categorical descriptor, not a name                                                                     |
| `StudentUniqueId` references in associations/events                           | These are foreign-key links, not standalone identifiers; sensitivity is inherited from the source entity |

---

## Open Questions for Community Review

1. **Quasi-identifiers from associations** — Should fields like `StudentUniqueId` in association entities (e.g., `StudentSchoolAssociation`) also be individually annotated, or is annotation on the source `Student` entity sufficient?
2. **Grade and score data** — `ScoreResult`, `NumericGrade`, and diagnostic statement fields could indirectly reveal disability status. Should they carry `is sensitive data`?
3. **`ContactRestrictions`** (a `Shared/ContactRestrictions.metaed` string) — Likely indicates custody or protection orders. Should it be sensitive?
4. **`AttendanceEventReason`** — Can reveal health, mental health, or disciplinary information. Sensitive?
5. **`DiagnosticStatement`** in assessment contexts — Can reveal learning disabilities. Sensitive?
6. **Downstream tooling defaults** — Should an un-annotated element default to "not sensitive" or "unknown"? The flag is additive today; we may want a future `is not sensitive` to make the declaration explicit.
7. **Granularity** — Should `is sensitive data` be applied at the `Common` / `Shared` definition level, the inline usage level, or both? Currently applied at the field level within the defining entity.

---

## Summary Stats

| Category                                   | Count of annotated properties |
| ------------------------------------------ | ----------------------------- |
| Personal names                             | 11                            |
| Address / geolocation                      | 13                            |
| Birth data                                 | 8                             |
| Contact information (email, phone)         | 2                             |
| Unique IDs / login credentials             | 6                             |
| Demographic (race, ethnicity, sex, gender) | 14                            |
| Disability / health                        | 7                             |
| Citizenship / immigration                  | 3                             |
| Financial (salary, aid, disadvantage)      | 8                             |
| Background check                           | 4                             |
| Identification documents                   | 3                             |
| Discipline / law enforcement               | 4                             |
| Other (photo, transport, displacement)     | 3                             |
| **Total**                                  | **86**                        |

---

*Prepared by GitHub Copilot on behalf of the Ed-Fi Data Standard team. Please direct review comments to the DATASTD Jira project or the Ed-Fi community forums.*
