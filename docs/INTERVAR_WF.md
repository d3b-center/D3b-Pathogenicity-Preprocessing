# InterVar Classification Workflow
This workflow is a critical component in generating scoring metrics needed to classify pathogenicity of variants.
The workflow has three processing steps:
1. Strip VCF input of old annotations. This is done in order to dramatically reduce resource usage of ANNOVAR, which does not require pre-existing annotations
1. Run ANNOVAR latest (software has no versioning, only references) to gather needed scoring metrics
1. Run InterVar v2.2.1

In addition, file compression steps are run to reduce output size.