# ethical-requirements-asm
This repository provides [ASMETA](https://asmeta.github.io/index.html) models (based on Abstract State Machines) and artifacts for the formal specification and well-formedness analysis of Social, Legal, Ethical, Emphathetic, and
Cultural (SLEEC) requirements, including conflict and redundancy detection.

The repository provides the supplementary material for the paper **Specification and Analysis of Ethical Requirements in Autonomous Systems using Abstract State Machines** submitted to ABZ 2026.

It includes the two case studies:
- **Firefighter UAV**, tasked to tackle fires by interacting with human firefighters, bystanders and teleoperators;
- **Robotic Assistive Dressing (RAD)** system, tasked with assisting a physically impaired user in daily dressing activities;
  
from:
Yaman, Sinem Getir, et al. "Specification, validation and verification of social, legal, ethical, empathetic and cultural requirements for autonomous agents."*Journal of Systems and Software* 220 (2025): 112229.
[https://doi.org/10.1016/j.jss.2024.112229](https://doi.org/10.1016/j.jss.2024.112229)

## Repository structure
```
ethical-requirements-asm
|   README.md                                   # This file
|
├---FireFighter                                 # Firefighter UAV case study models
|       MA_report                               # Report of AsmetaMA (Asmeta Model Advisor)
|       firefighter.asm                         # ASM model encoding the Firefighter UAV case study's SLEEC rules in AsmetaL
|       firefighter4MC.asm                      # Simplified ASM model for AsmetaSMV (Asmeta Model Checker)
|       firefighterHeader.asm                   # Model header: ASM model containing signatures and definitions for the case study
|       firefighter.sleec                       # SLEEC DSL model for the case study
|       scenario1.avalla                        # AsmetaV (ASMETA Validator) scenario 1 specification
|       scenario2.avalla                        # AsmetaV (ASMETA Validator) scenario 2 specification
|       scenario3.avalla                        # AsmetaV (ASMETA Validator) scenario 3 specification
|
├---RoboticAssistiveDressing                    # Robotic Assistive Dressing (RAD) case study models
|       dressingrobot.sleec                     # SLEEC DSL model for the case study
|       dressingrobot.asm                       # ASM model encoding the Robotic Assistive Dressing (RAD) case study's SLEEC rules in AsmetaL
|       dressingrobotHeader.asm                 # ASM model containing signatures and definitions for the case study
|       dressingrobot4MC.asm                    # Simplified ASM model for AsmetaSMV (Asmeta Model Checker)
|       dressingrobotHeader4MC.asm              # Simplified ASM model header for AsmetaSMV (Asmeta Model Checker)
|
└---libraries                                   # ASM support libraries
        CTLLibrary.asm                          # ASM library file containing CTL specification facilities
        LTLLibrary.asm                          # ASM library file containing LTL specification facilities
        SLEECLibrary.asm                        # ASM library file containing SLEEC rule constructors and specification facilities
        StandardLibrary.asm                     # Standard ASM library file containing basic types and functions
```
