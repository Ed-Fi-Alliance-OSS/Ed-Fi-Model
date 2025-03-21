# Ed-Fi-Model

Package containing the MetaEd grammar files for the Ed-Fi Data Standard.

## Authoring

Install the MetaEd extension in Visual Studio. See
[MetaEd IDE](https://docs.ed-fi.org/reference/metaed) documentation for more
information.

## Build Script

If you have NodeJs installed, you can perform the MetaEd > Build operation
directly at the command line, without needing to open the MetaEd IDE.

```shell
# One time dependency installation
npm install

# Alternative: force download of the latest MetaEd
npm ci

# Run the build process
npm start
```

The output is formatted for use in Visual Studio and looks a little confusing at first. You will see that each line is a JSON object, and you will see embedded color codes such as `\u001b[90m`. The color coding does not work when running this way; please ignore that. Each line has a `level` listed; look for `"level":"error"`. These _must_ be corrected. There are also warnings about deprecation, which in this context you can ignore.

```shell
{"level":"info","message":"- edfiUnified, tech version 7.3.0"}
{"level":"info","message":"- edfiUnifiedAdvanced, tech version 7.3.0"}
{"level":"info","message":"- edfiOdsRelational, tech version 7.3.0"}
{"level":"info","message":"- edfiApiSchema, tech version 7.3.0"}
{"level":"info","message":"- edfiOdsSqlServer, tech version 7.3.0"}
{"level":"info","message":"- edfiOdsPostgresql, tech version 7.3.0"}
{"level":"info","message":"- edfiXsd, tech version 7.3.0"}
{"level":"info","message":"- edfiOdsChangeQuery, tech version 7.3.0"}
{"level":"info","message":"- edfiOdsChangeQuerySqlServer, tech version 7.3.0"}
{"level":"info","message":"- edfiOdsChangeQueryPostgresql, tech version 7.3.0"}
{"level":"info","message":"- edfiOdsRecordOwnership, tech version 7.3.0"}
{"level":"info","message":"- edfiOdsRecordOwnershipSqlServer, tech version 7.3.0"}
{"level":"info","message":"- edfiOdsRecordOwnershipPostgresql, tech version 7.3.0"}
{"level":"info","message":"- edfiOdsApi, tech version 7.3.0"}
{"level":"info","message":"- edfiXmlDictionary, tech version 7.3.0"}
{"level":"info","message":"- edfiSqlDictionary, tech version 7.3.0"}
{"level":"info","message":"- edfiHandbook, tech version 7.3.0"}
{"level":"info","message":"Loading .metaed files"}
{"level":"info","message":"- package (830 .metaed files loaded)"}
{"level":"info","message":"Running plugins"}
{"level":"info","message":"- edfiUnified"}
{"level":"info","message":"- edfiUnifiedAdvanced"}
{"level":"info","message":"- edfiOdsRelational"}
{"level":"info","message":"- edfiApiSchema"}
{"level":"info","message":"- edfiOdsSqlServer"}
{"level":"info","message":"- edfiOdsPostgresql"}
{"level":"info","message":"- edfiXsd"}
{"level":"info","message":"- edfiOdsChangeQuery"}
{"level":"info","message":"- edfiOdsChangeQuerySqlServer"}
{"level":"info","message":"- edfiOdsChangeQueryPostgresql"}
{"level":"info","message":"- edfiOdsRecordOwnership"}
{"level":"info","message":"- edfiOdsRecordOwnershipSqlServer"}
{"level":"info","message":"- edfiOdsRecordOwnershipPostgresql"}
{"level":"info","message":"- edfiOdsApi"}
{"level":"info","message":"- edfiXmlDictionary"}
{"level":"info","message":"- edfiSqlDictionary"}
{"level":"info","message":"- edfiHandbook"}
{"level":"info","message":"Writing output"}
{"level":"info","message":"- Artifact Directory: D:\\ed-fi\\Ed-Fi-Model\\package\\MetaEdOutput"}
(node:68540) [DEP0147] DeprecationWarning: In future versions of Node.js, fs.rmdir(path, { recursive: true }) will be removed. Use fs.rm(path, { recursive: true }) instead
{"level":"warn","message":"  HispanicLatinoEthnicity is deprecated.  \u001b[90mD:\\ed-fi\\Ed-Fi-Model\\package\\Association\\StudentEducationOrganizationAssociation.metaed (33:10)\u001b[39m"}
{"level":"warn","message":"  SchoolChoiceTransfer is deprecated.  \u001b[90mD:\\ed-fi\\Ed-Fi-Model\\package\\Association\\StudentSchoolAssociation.metaed (34:10)\u001b[39m"}
{"level":"warn","message":"  HispanicLatinoEthnicity is deprecated.  \u001b[90mD:\\ed-fi\\Ed-Fi-Model\\package\\DomainEntity\\ApplicantProfile.metaed (30:10)\u001b[39m"}
{"level":"warn","message":"  HispanicLatinoEthnicity is deprecated.  \u001b[90mD:\\ed-fi\\Ed-Fi-Model\\package\\DomainEntity\\Candidate.metaed (39:8)\u001b[39m"}
{"level":"warn","message":"  HispanicLatinoEthnicity is deprecated.  \u001b[90mD:\\ed-fi\\Ed-Fi-Model\\package\\DomainEntity\\RecruitmentEventAttendance.metaed (18:10)\u001b[39m"}
{"level":"warn","message":"  HispanicLatinoEthnicity is deprecated.  \u001b[90mD:\\ed-fi\\Ed-Fi-Model\\package\\DomainEntity\\Staff.metaed (45:10)\u001b[39m"}
{"level":"warn","message":"  Sex is deprecated.  \u001b[90mD:\\ed-fi\\Ed-Fi-Model\\package\\DomainEntity\\Contact.metaed (16:16)\u001b[39m"}
{"level":"info","message":"Done in \u001b[32m6.51s\u001b[39m."}
```

## Legal Information

Copyright (C) 2025 Ed-Fi Alliance, LLC. All rights reserved.
