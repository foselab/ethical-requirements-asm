# SLEEC DSL to AsmetaL Compiler

This is the model compiler component to translate rules written in the SLEEC Domain-Specific Language (DSL) into AsmetaL (`.asm`) models.

## Repository structure
```
model_compiler
|   README.md                                         # This file
|   SLEEC-DSL2AsmetaL.py                              # Parser script compiling SLEEC rules to ASM code
|
├---input                                             # Folder containing sample input SLEEC models
|       Autocar_corrected_san                         # Sample SLEEC rules for autonomous car
|       FireFighter.sleec                             # Sample SLEEC rules for firefighter UAV
|       RoboticAssistiveDressing.sleec                # Sample SLEEC rules for robotic assistive dressing
└---output                                            # Default output folder for compiled AsmetaL models
        Generated_Autocar_corrected_san.asm           # Compiled ASM model for autonomous car
        Generated_Autocar_corrected_sanHeader.asm     # Compiled ASM model header for autonomous car
        Generated_FireFighter.asm                     # Compiled ASM model for firefighter UAV
        Generated_FireFighterHeader.asm               # Compiled ASM model header for firefighter UAV
        Generated_RoboticAssistiveDressing.asm        # Compiled ASM model for robotic assistive dressing
        Generated_RoboticAssistiveDressingHeader.asm  # Compiled ASM model header for robotic assistive dressing
```

## Requirements

- **Python 3.8+**
- **No external dependencies**: The script relies exclusively on Python standard library modules (`re`, `os`, `typing`, `argparse`). No third-party packages (pip dependencies) are required.

## Build and run

Clone or navigate to the repository directory and enter the `model_compiler` folder:

```bash
cd model_compiler
```

To compile a `.sleec` model, run the script passing the path of the target SLEEC file as an argument:

```bash
python SLEEC-DSL2AsmetaL.py <filename_SLEEC_model>
```

### Examples

#### 1. Compile the firefighter UAV case study model
```bash
python SLEEC-DSL2AsmetaL.py ../FireFighter/firefighter.sleec
```

#### 2. Compile the robotic assistive dressing case study model
```bash
python SLEEC-DSL2AsmetaL.py ../RoboticAssistiveDressing/dressingrobot.sleec
```

#### 3. Compile a sample from the input directory
```bash
python SLEEC-DSL2AsmetaL.py input/FireFighter.sleec
```

### Output Example

When running the script, the output files are generated in the `output/` directory (e.g. `model_compiler/output/`):
- `Generated_<name>.asm`: The main ASM model representing the compiled rules.
- `Generated_<name>Header.asm`: The ASM model header containing signatures and definitions.

Console output example:
```text
[OK] Source: input/FireFighter.sleec
[OK] Parsed 9 rules
[OK] Generated 8 obligations
[OK] Output saved to directory: .../model_compiler/output
[OK] File Generated_FireFighter.asm written
[OK] File Generated_FireFighterHeader.asm written

Press Enter to exit...
```

## AsmetaL Incompatibilities & SLEEC DSL Workarounds

During the development and testing of the model compiler, some incompatibilities or differences with the AsmetaL language (specifically regarding data types, comparison operators, variables, and identifiers) were identified. Because of this, certain manual adjustments are required on the input `.sleec` models to ensure the generated AsmetaL code is executable and compiles without errors in ASMETA:

### 1. Handling of Enumerative Domains
Unlike the SLEEC DSL, AsmetaL enum domains are unordered sets and do not support inequality operators like `<`, `>`, `<=`, or `>=`.
- **Workaround for inequalities**: Replace inequalities on textual enums with equality (`=`) or inequality (`!=`) checks, or expand them into logical combinations.
  - *Example 1*: `userDistressed > smedium` could be rewritten as `userDistressed = shigh`.
  - *Example 2*: `withholdingActivityPhysicalHarm >= moderate` could be rewritten as `withholdingActivityPhysicalHarm = moderate or withholdingActivityPhysicalHarm = severe`.
  - *Example 3*: `riskLevel > low` could be rewritten as `riskLevel != low`.

### 2. Naming Conflicts between Capabilities and Monitored Conditions
The starting models often had an action and its associated feedback sharing the same name. However, capabilities and monitored variables/conditions must not share the same name in the DSL to avoid duplicate identifier errors in the generated AsmetaL code.
- **Workaround**: Rename conditions or capabilities to be distinct.
  - *Examples*: 
    - `askIfUserReadyToDrive` (capability) vs `userAskedIfReadyToDrive` (monitored variable)
    - `calculateShortestPath` (capability) vs `shortestPathCalculated` (monitored variable)
    - `carDriving` (capability) vs `driveCar` (monitored variable)
    - `soundAlarm` (capability) vs `alarmSounding` (monitored variable)

### 3. Textual Constants and Placeholders
The compiler cannot distinguish pre-declared constants (like `MAX_RESPONSE_TIME` or symbolic names in comparators) from enumerative values during parsing without additional schema information.
- **Workaround**: Replace symbolic placeholders with explicit numeric values.
  - *Example*: In `DressingRobot`, `CurtainsOpened within MAX_RESPONSE_TIME seconds` was replaced with `CurtainsOpened within 5 seconds`.

### 4. Syntax unsupported by AsmetaL
- **Negative Alternative Obligations**: Alternative obligations using `otherwise` must be positive capabilities. Negative alternatives (e.g., `otherwise not ChangeCurrentDriving`) are not supported and must be removed.
- **Temporal Keyword `eventually`**: The keyword `eventually` (e.g., `TurnOffSensors eventually`) in actions is not supported by AsmetaL and must be omitted.

### 5. Subset Domains and Invariants
Restricted domains (`subsetof`) and system invariants are not deducible from the text of the SLEEC rules and must be manually specified in the AsmetaL models or headers if required.

