# SLEEC DSL to AsmetaL PARSER
# ============================================================================
#
import re
import os
from typing import NamedTuple, Optional, List, Dict, Set

# ============================================================================
# CONSTANTS & REGEX
# ============================================================================

# Pattern to recognize time constraints in format "within N [unit]"
TIMING_REGEX = re.compile(r'within\s+(\d+)\s+(nanosecond|nanosec|nano|millisecond|millisec|milli|second|sec|minute|min|hour|hr)s?', re.IGNORECASE)
# Pattern to recognize comparison operators
OPERATOR_REGEX = re.compile(r'\s*(>=|<=|==|!=|=|>|<)\s*')
# Pattern to recognize 'unless' blocks
UNLESS_REGEX = re.compile(r'unless\s+(.+?)(?=unless\b|$)', re.IGNORECASE)

import argparse

# Reserved keywords
RESERVED_KEYWORDS = {'true', 'false', 'and', 'or', 'if', 'then', 'else', 'not'}

# ============================================================================
# DATA STRUCTURES
# ============================================================================

class TimeConstraint(NamedTuple):
    """Represents a time constraint (value and unit)."""
    value: str
    unit: str

class Obligation(NamedTuple):
    """
    Represents an obligation (action) to be performed.
    Attributes:
        capabilities: list of action names (e.g. ["informUser", "referToHumanCarer"])
        is_blocked: True if the action is blocked/forbidden
        time_constraint: TimeConstraint
        alternative: alternative capability or None
    """
    capabilities: List[str]
    is_blocked: bool
    time_constraint: TimeConstraint
    alternative: Optional[str]

    @property
    def asmetaL_name(self) -> str:
        """Automatically generates the AsmetaL rule name for this obligation."""
        # For naming, we concatenate all capabilities with 'And'
        base_name = 'And'.join([cap[0].upper() + cap[1:] for cap in self.capabilities])
        name = base_name[0].lower() + base_name[1:] if base_name else ''
        
        if self.is_blocked:
            name = 'not' + name[0].upper() + name[1:]
        
        if self.time_constraint.value:
            num = self.time_constraint.value
            unit_map = {
                'NANOSEC': 'NanoSeconds',
                'MILLISEC': 'MilliSeconds',
                'SEC': 'Seconds',
                'MINUTE': 'Minutes',
                'HOUR': 'Hours'
            }
            # Default to Seconds if unknown, though parser should handle it
            unit_suffix = unit_map.get(self.time_constraint.unit, 'Seconds')
            name += f'Within{num}{unit_suffix}'
        
        if self.alternative:
            alt_name = self.alternative[0].upper() + self.alternative[1:]
            name += f'Otherwise{alt_name}'
        
        return f'r_{name}'

class UnlessClause(NamedTuple):
    """Represents an "unless" clause (alternative) in a rule."""
    condition: str
    obligation: Obligation

class SLEEC_Rule(NamedTuple):
    """
    Represents a complete SLEEC rule.
    Attributes:
        name: name of the rule (e.g. "Rule1")
        condition: main condition
        main_obligation
        unless_clauses: list of UnlessClause
    """
    name: str
    condition: str
    main_obligation: Obligation
    unless_clauses: List[UnlessClause]

def to_camel_case(text: str) -> str:
    """Converts a string to camelCase (lower first letter)."""
    return text[0].lower() + text[1:] if text else ''


def parse_obligation(text: str) -> Obligation:
    """
    Parses an obligation string into an Obligation object.

    Args:
        text: The obligation string (e.g., "then SoundAlarm within 5 minutes").

    Returns:
        Obligation: The parsed obligation object.

    Raises:
        ValueError: If the obligation capability name is invalid.
    """
    text = text.strip()
    # If 'not' is present, is_blocked is True (capability is blocked)
    is_blocked = bool(re.search(r'\bnot\b', text, re.I))
    text = re.sub(r'\bnot\b\s*', '', text, flags=re.I).strip()
    
    time_constraint = TimeConstraint('', '')
    match = TIMING_REGEX.search(text)
    if match:
        value = match.group(1)
        raw_unit = match.group(2).lower()
        if 'nano' in raw_unit:
            unit = 'NANOSEC'
        elif 'milli' in raw_unit:
            unit = 'MILLISEC'
        elif 'sec' in raw_unit:
            unit = 'SEC'
        elif 'min' in raw_unit:
            unit = 'MINUTE'
        elif 'hour' in raw_unit or 'hr' in raw_unit:
            unit = 'HOUR'
        else:
            unit = 'SEC' # Default fallback
            
        time_constraint = TimeConstraint(value, unit)
        text = TIMING_REGEX.sub('', text).strip()

    alternative = None
    otherwise_match = re.search(r'\s+otherwise\s+(.+)$', text, re.I)
    if otherwise_match:
        alternative = to_camel_case(otherwise_match.group(1).strip())
        text = text[:otherwise_match.start()].strip()
    
    
    if alternative and not time_constraint.value:
        raise ValueError("Alternative 'otherwise' clause requires a time constraint (e.g. 'within 5 minutes')")

    # Split raw capabilities based on 'and'
    raw_capabilities = re.split(r'\s+and\s+', text, flags=re.I)
    
    parsed_capabilities = []
    for raw_cap in raw_capabilities:
        capability_name = to_camel_case(raw_cap.strip())
        
        # 1. Check for leftover 'within' or digits (indicates malformed time constraint)
        if 'within' in capability_name.lower():
             raise ValueError(f"Invalid capability name '{raw_cap}'. It contains 'within', possibly due to a malformed time constraint.")
        
        # 2. Check for spaces or non-alphanumeric characters (capability must be a single identifier)
        if not re.match(r'^[a-zA-Z][a-zA-Z0-9_]*$', capability_name):
             raise ValueError(f"Invalid capability name '{raw_cap}'. Must be a single alphanumeric identifier (no spaces).")
             
        parsed_capabilities.append(capability_name)

    return Obligation(capabilities=parsed_capabilities, is_blocked=is_blocked, time_constraint=time_constraint, alternative=alternative)

def normalize_condition(text: str) -> str:
    """
    Converts a DSL condition string into standard AsmetaL format.
    
    Performs validation including:
    - Balancing parentheses.
    - Checking for invalid operator sequences (e.g. "and or").
    - Standardizing spacing around operators and parentheses.

    Args:
        text (str): The raw condition string from the DSL.

    Returns:
        str: The normalized condition string (e.g., "cameraStarted and personNearby").
    """
    # Examples: "CameraStarted AND PersonNearby" -> "cameraStarted and personNearby"
    if not text.strip():
        return 'true'
    
    # Replace operators with spaces: ">= " -> " >= "
    result = OPERATOR_REGEX.sub(r' \1 ', text)
    
    # Enhancement: Add spaces around parentheses to prevent merging with words
    result = result.replace('(', ' ( ').replace(')', ' ) ')
    
    # Validation 1: Check for unbalanced parentheses
    if result.count('(') != result.count(')'):
        raise ValueError(f"Invalid condition syntax: {text}")

    # Validation 2: Check for tokens sequence errors (Generic Check)
    # Tokenize the normalized string
    tokens = result.split()
    logic_ops = {'and', 'or', 'not'}
    
    for i in range(len(tokens) - 1):
        curr = tokens[i]
        next_t = tokens[i+1]
        
        curr_low = curr.lower()
        next_low = next_t.lower()
        
        # Check for invalid operator sequence (e.g. "and or", "not not", "or and")
        if curr_low in logic_ops and next_low in logic_ops:
             # Exception: 'and not', 'or not' are allowed. 'not not' is NOT allowed.
             if next_low == 'not' and curr_low != 'not':
                 pass # OK
             else:
                 raise ValueError(f"Invalid condition syntax: {text}")

        # Check for adjacent variables (missing operator)
        # Skip parentheses and operators
        if curr in ['(', ')'] or next_t in ['(', ')']:
            continue
        if curr_low in logic_ops or next_low in logic_ops:
            continue
        if re.match(r'^(>=|<=|==|!=|=|>|<)$', curr) or re.match(r'^(>=|<=|==|!=|=|>|<)$', next_t):
            continue
            
        # If we are here, both are likely identifiers (variables or values)
        # Check if they look like identifiers (alphanumeric)
        if re.match(r'^[a-zA-Z0-9_]+$', curr) and re.match(r'^[a-zA-Z0-9_]+$', next_t):
             raise ValueError(f"Invalid condition syntax: {text}")
    
    # Process words: lower case reserved, camelCase others
    def convert_word(match):
        word = match.group(0)
        return word.lower() if word.lower() in RESERVED_KEYWORDS else to_camel_case(word)

    result = re.sub(r'\b[A-Za-z_]\w*\b', convert_word, result)
    
    # Spacing for logical keywords (and, or, not)
    for keyword in ['and', 'or', 'not']:
        result = re.sub(rf'\s+{keyword}\s+', f' {keyword} ', result, flags=re.I)
        
    return result.strip()

def parse_unless_blocks(text_block):
    # Parses 'unless' blocks iteratively
    unless_clauses = []
    blocks = UNLESS_REGEX.findall(text_block)
    
    for idx, block in enumerate(blocks):
        block = block.strip()
        then_match = re.search(r'\bthen\b', block, re.I)
        
        if then_match:
            unless_cond = normalize_condition(block[:then_match.start()].strip())
            unless_obligation = parse_obligation(block[then_match.end():].strip())
        else:
            # Feature: Implicit unless -> skip
            # If 'then' is missing, it means "unless condition, do nothing (skip)"
            unless_cond = normalize_condition(block)
            unless_obligation = Obligation(capabilities=['skip'], is_blocked=False, time_constraint=TimeConstraint('',''), alternative=None)
        
        if unless_obligation.alternative and idx < len(blocks) - 1:
            raise ValueError(f"otherwise clause must be the last alternative in rule.")
        
        unless_clauses.append(UnlessClause(condition=unless_cond, obligation=unless_obligation))
    return unless_clauses

def parse_SLEEC_rule(rule_name, SLEEC_DSL_rule_string):
    # Parses a complete SLEEC rule: when <condition> then <obligation> [unless <condition> then <obligation>]*
    normalized = re.sub(r'\s+', ' ', SLEEC_DSL_rule_string.strip())
    
    match = re.match(r'(.+?)\s+then\s+(.+?)(?:\s+unless|$)', normalized, re.I)
    if not match:
        raise ValueError(f"Invalid rule: {normalized[:50]}")
    
    main_cond = normalize_condition(match.group(1).strip())
    main_obligation = parse_obligation(match.group(2).strip())
    
    unless_clauses = []
    if 'unless' in normalized:
        unless_start_idx = normalized.find('unless', match.end(2))
        if unless_start_idx >= 0:
            unless_clauses = parse_unless_blocks(normalized[unless_start_idx:])
    
    if main_obligation.alternative and unless_clauses:
        raise ValueError(f"otherwise clause must be the last alternative in rule: {normalized[:60]}")
    
    return SLEEC_Rule(name=rule_name, condition=main_cond, main_obligation=main_obligation, unless_clauses=unless_clauses)

def collect_variables(rules):
    # Extracts all monitored variables and infers their types (Integer, Custom Enum, vs Boolean).
    # Returns: tuple (monitored_variables_dict, enum_domains_dict)
    
    monitored_variables = {}
    enum_domains = {}
    
    for rule in rules:
        all_conditions = [rule.condition] + [u.condition for u in rule.unless_clauses]
        
        for condition in all_conditions:
            # 1. Parse comparison pairs (left op right)
            comparisons = re.findall(r'\b([a-zA-Z_][a-zA-Z0-9_]*)\s*(>=|<=|==|!=|=|>|<)\s*([a-zA-Z0-9_]+)\b', condition)
            
            comparison_vars = set()
            for left, op, right in comparisons:
                if left.lower() in RESERVED_KEYWORDS:
                    continue
                
                comparison_vars.add(left)
                
                # Check for invalid enum inequality early
                if not right.isdigit() and op in ('>', '<', '>=', '<='):
                    raise ValueError(f"SLEEC Parser Error: operator '{op}' is not supported for textual enum value '{right}'. AsmetaL Enums strictly require '=' or '!='. Use numeric values for inequalities.")
                
                # If value is numeric, force Integer.
                if right.isdigit():
                    # It's an Integer comparison
                    if left in monitored_variables and monitored_variables[left] not in ('Integer', 'Numeric'):
                        if monitored_variables[left] == 'Boolean':
                            raise ValueError(f"Type conflict for variable '{left}': used as both Integer and Boolean.")
                    monitored_variables[left] = 'Integer'
                else:
                    # Operator is =, ==, != AND right is not a digit -> Enum value comparison
                    type_name = left[0].upper() + left[1:]
                    
                    if left in monitored_variables:
                        if monitored_variables[left] == 'Boolean':
                            raise ValueError(f"Type conflict for variable '{left}': used as both Enum {type_name} and Boolean.")
                        elif monitored_variables[left] == 'Integer':
                            # It was previously categorized as Integer (e.g. by >), we must respect AsmetaL limits
                            # and keep it as Integer. We skip generating the enum element here.
                            continue
                            
                    monitored_variables[left] = type_name
                    
                    if type_name not in enum_domains:
                        enum_domains[type_name] = set()
                    
                    enum_domains[type_name].add(right.upper())
            
            # 2. Identify all other boolean variables
            all_candidates = re.findall(r'\b([a-zA-Z][a-zA-Z0-9]*)\b', condition)
            
            for var in all_candidates:
                if var.lower() not in RESERVED_KEYWORDS:
                    if var in comparison_vars:
                         continue # Already processed
                    
                    is_enum_value = False
                    for type_name, values in enum_domains.items():
                        if var.upper() in values:
                            is_enum_value = True
                            break
                    if is_enum_value:
                        continue
                        
                    if var in monitored_variables:
                        if monitored_variables[var] != 'Boolean':
                            raise ValueError(f"Type conflict for variable '{var}': previously inferred as {monitored_variables[var]}, now used as Boolean.")
                    else:
                        monitored_variables[var] = 'Boolean'
            
            # 3. Check for invalid identifiers starting with numbers
            invalid_candidates = re.findall(r'\b([0-9][a-zA-Z0-9]*)\b', condition)
            for inv in invalid_candidates:
                 if not inv.isdigit() and not any(inv.upper() in vals for vals in enum_domains.values()):
                      raise ValueError(f"Invalid variable name '{inv}': cannot start with a number.")

    return monitored_variables, enum_domains

def collect_obligations(rules) -> Dict[str, Obligation]:
    # Collects all unique obligations from parsed SLEEC rules.
    # 
    # Returns: dict {asmetaL_rule_name: Obligation}
    obligations = {}
    for rule in rules:
        # Main Obligation
        obligations[rule.main_obligation.asmetaL_name] = rule.main_obligation
        # Obligations from unless clauses
        for unless_clause in rule.unless_clauses:
            obligations[unless_clause.obligation.asmetaL_name] = unless_clause.obligation
    return obligations

def generate_obligation_rules(obligations: Dict[str, Obligation]):
    # Generates AsmetaL rule definitions for obligations.
    lines = []


    for obl_name, obl in sorted(obligations.items()):
        
        if 'skip' in obl.capabilities:
            # 'skip' refers to the standard AsmetaL rule `r_skip` which does nothing.
            # We do NOT generate a new rule for it here because it is already defined in the library.
            continue

        inner_calls = []
        for capability in obl.capabilities:
            if capability == 'doNothing':
                 params = ['doNothing']
            else:
                params = [capability]
                if obl.is_blocked:
                    params.append('false')
                
                tc = obl.time_constraint
                if tc and tc.value:
                    params.extend(['WITHIN', tc.value, tc.unit, obl.alternative or 'doNothing'])
            
            rule_body = ','.join(params)
            inner_calls.append(f"r_setObligation[{rule_body}]")
            
        if len(inner_calls) > 1:
            # Wrap in a par block if there are multiple simultaneous capabilities
            rule_content = "par " + " ".join(inner_calls) + " endpar"
        else:
            rule_content = inner_calls[0]
            
        rule = f"rule {obl_name} = {rule_content}"
        lines.append('\t\t' + rule)
    
    return '\n'.join(lines)

def extract_capability_names_from_obligations(obligations: Dict[str, Obligation]):
    # Extracts unique capability names from obligation values.
    # 
    # Analyzes obligation dictionaries retrieving both main capability
    # and potential alternative.
    capabilities = set()
    for obl in obligations.values():
        for cap in obl.capabilities:
            if cap and cap not in ['doNothing', 'skip']:
                capabilities.add(cap)
        if obl.alternative and obl.alternative not in ['doNothing', 'skip']:
            capabilities.add(obl.alternative)
    return sorted(list(capabilities))

def generate_header(obligations, monitored_variables, enum_domains, module_name):
    # Generates the SLEECHeader AsmetaL module with capability definitions and monitored variables.
    # 
    # Arguments:
    # - obligations: dictionary of obligation rules
    # - monitored_variables: dictionary of types {var_name: type}
    # - enum_domains: dictionary of {type_name: set_of_enum_values}
    # - module_name: name of the module to generate
    # extract unique capability names from obligation rules
    cap_ids = extract_capability_names_from_obligations(obligations)
    cap_ids.insert(0, 'doNothing')
    
    # generate enum values and static declarations for capabilities
    cap_enum = ','.join(cap_id.upper() for cap_id in cap_ids)
    
    # generate enum domains
    domain_declarations = []
    for domain_name, values in sorted(enum_domains.items()):
        val_str = ' | '.join(sorted(values))
        domain_declarations.append(f"enum domain {domain_name} = {{{val_str}}}")
    
    domain_defs = '\n\t'.join(domain_declarations)
    if domain_defs:
        domain_defs += '\n\t'
    static_caps = '\n\t'.join([f"static {cap_id}: Capability" for cap_id in cap_ids if cap_id != 'doNothing'])
    id_cases = '\n\t\t\t'.join([f"case {cap_id} : {cap_id.upper()}" for cap_id in cap_ids])
    
    # generate monitored variable declarations
    monitored_vars = '\n\t'.join([f"monitored {var}: {monitored_variables[var]}" for var in sorted(monitored_variables.keys())])
    
    header = f"""module {module_name}

import libraries/StandardLibrary
import libraries/SLEECLibrary
export *

signature:
	/* DOMAIN-SPECIFIC SIGNATURE */
	
	{domain_defs}enum domain CapabilityID = {{{cap_enum}}}
	
	//(input) events and measures
	{monitored_vars}
	
	//System's capabilities
	{static_caps}
	static id: Capability -> CapabilityID

	/* DOMAIN-GENERIC SIGNATURE */
	//(output) events as obligations that arise from the SLEEC rules for the system (robot) to act
	out outObligation: CapabilityID -> Boolean
	out outConstraint: CapabilityID -> Prod(TCType,Integer,TimerUnit,CapabilityID)

definitions:

	/* DOMAIN-GENERIC DEFINITIONS */
	
	function id($c in Capability) = 
		switch $c
			{id_cases}
		endswitch

	rule r_setObligation($c in Capability) = 
	par 
		outObligation(id($c)) := true
		outConstraint(id($c)) := undef
	endpar
	
	rule r_setObligation($c in Capability, $v in Boolean) = 
	par 
		outObligation(id($c)) := $v
		outConstraint(id($c)) := undef
	endpar
	
	rule r_setObligation($c in Capability, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability) = 
	par 
		outObligation(id($c)) := true  
		if (isDef($alt) and $type=WITHIN) then outConstraint(id($c)) := ($type,$t,$u,id($alt))
		else outConstraint(id($c)) := ($type,$t,$u,id(doNothing)) endif
	endpar
	
	rule r_setObligation($c in Capability, $v in Boolean, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability) = 
	par 
		outObligation(id($c)) := $v  
		if (isDef($alt) and $type=WITHIN) then outConstraint(id($c)) := ($type,$t,$u,id($alt))
		else outConstraint(id($c)) := ($type,$t,$u,id(doNothing)) endif
	endpar
	
	rule r_setObligation($c in Capability, $v in Boolean, $type in TCType, $t in Integer, $u in TimerUnit, $alt in Capability, $guard in Boolean) = 
	par 
		outObligation(id($c)) := $v  
		if (isDef($alt) and $type=WITHIN and $guard) then outConstraint(id($c)) := ($type,$t,$u,id($alt))
		else outConstraint(id($c)) := ($type,$t,$u,id(doNothing)) endif
	endpar
"""
    
    return header

def generate_sleec_rules(rules, enum_domains):
    # Generates calls to SLEEC rules in AsmetaL output
    def apply_enums(cond):
        for vals in enum_domains.values():
            for val in vals:
                cond = re.sub(rf'\b{val}\b', val, cond, flags=re.I)
        return cond

    lines = []
    for rule in rules:
        cond = apply_enums(rule.condition)
        items = [f"{cond}, <<{rule.main_obligation.asmetaL_name}>>"]
        for unless_clause in rule.unless_clauses:
            items.append(f"{apply_enums(unless_clause.condition)}, <<{unless_clause.obligation.asmetaL_name}>>")
        body = ',\n\t           '.join(items)
        lines.append(f"\trule r_{rule.name} =\n\t  r_SLEEC[{body}\n\t  ]")
    return '\n\n'.join(lines)

def main():
    # Parses SLEEC DSL rules and generates AsmetaL files
    
    # 1. Setup Argument Parser
    parser = argparse.ArgumentParser(description='Compile SLEEC DSL to AsmetaL.')
    parser.add_argument('input_file', help='Path to input .sleec file')
    args = parser.parse_args()

    # 2. Determine paths
    input_path = args.input_file
    
    if not os.path.exists(input_path):
        print(f"[ERROR] Input file not found: {input_path}")
        return

    # Automatically create an 'output' directory at the same level as the parser script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, 'output')

    os.makedirs(output_path, exist_ok=True)
    
    # Extract base filename for dynamic naming
    base_name = os.path.splitext(os.path.basename(input_path))[0]
    generated_asm_name = f"Generated_{base_name}"
    generated_header_name = f"Generated_{base_name}Header"
    
    # Read input DSL file
    try:
        with open(input_path, 'r') as f:
            file_string = f.read()
    except FileNotFoundError:
        print(f"[ERROR] Input file not found: {input_path}")
        return
    
    # Remove any comments from input file (lines starting with //)
    file_string = re.sub(r'//.*?(?=\n|$)', '', file_string, flags=re.MULTILINE)
    
    # Extract individual rule blocks (each rule starts with a name followed by "when")
    # Captures: (rule_name, content)
    rule_matches = re.findall(r'(\w+)\s+when\s+(.+?)(?=\w+\s+when|$)', file_string, re.I | re.DOTALL)
    
    # Parse SLEEC rules with error handling
    rules = []
    seen_rule_names = set()
    
    for rule_name, rule_content in rule_matches:
        if rule_name in seen_rule_names:
            print(f"[ERROR] Duplicate rule name found: {rule_name}")
            continue # Or return/stop
        seen_rule_names.add(rule_name)
        
        try:
            rules.append(parse_SLEEC_rule(rule_name, rule_content))
        except ValueError as e:
            print(f"[ERROR] {e}")
            continue
    
    if not rules:
        print(f"[ERROR] No SLEEC rules found in the input file")
        return
    
    try:
        # Extract monitored variables and infer their types from conditions
        monitored_variables, enum_domains = collect_variables(rules)
        
        # Generate obligation rules and SLEEC rules
        # 1. collect_obligations: Collects unique obligation objects
        obligations = collect_obligations(rules)
        # 2. generate_obligation_rules: Translates objects to AsmetaL code
        obligation_rules = generate_obligation_rules(obligations)
        sleec_rules = generate_sleec_rules(rules, enum_domains)
        
        # Extract capability names from obligations
        capabilities = set(extract_capability_names_from_obligations(obligations))
        capabilities.add('doNothing')
        
        # Check for name conflicts between capabilities and monitored variables
        conflicts = capabilities & set(monitored_variables.keys())
        if conflicts:
            print(f"[ERROR] Name conflict: the following identifiers are both capabilities and monitored variables: {', '.join(sorted(conflicts))}")
            print(f"[ERROR] In SLEEC DSL, capabilities and monitored variables must have different names.")
            return
            
    except ValueError as e:
        print(f"[ERROR] Semantic Error: {e}")
        return
    
    # Build SLEEC.asm output template
    output = f"""//Auto-generated from SLEEC DSL

asm {generated_asm_name}

import libraries/StandardLibrary
import libraries/CTLLibrary
import libraries/SLEECLibrary
import {generated_header_name}

signature:

definitions:

\t/* DOMAIN-SPECIFIC CONTROL RULES */
{obligation_rules}

\t//SLEEC rules
{sleec_rules}

\t\trule r_Reset =
\t\tforall $c in Capability do 
\t\t\tpar
\t\t\t\toutConstraint(id($c)) := undef
\t\t\t\toutObligation(id($c)) := undef
\t\t\tendpar


\tmain rule r_Main =
\t\tseq
\t\t\tr_Reset[]
\t\t\tpar
"""
    
    # Add all SLEEC rule calls to main rule
    for rule in rules:
        output += f"\t\t\t\tr_{rule.name}[]\n"
    output += """\t\t\tendpar
\t\tendseq

default init s0:
"""
    
    # Write SLEEC.asm file
    asm_filename = f"{generated_asm_name}.asm"
    with open(os.path.join(output_path, asm_filename), 'w') as f:
        f.write(output)
    
    # Write SLEECHeader.asm file
    header_output = generate_header(obligations, monitored_variables, enum_domains, generated_header_name)
    header_filename = f"{generated_header_name}.asm"
    with open(os.path.join(output_path, header_filename), 'w') as f:
        f.write(header_output)
    
    # Print operation summary
    print(f"[OK] Source: {input_path}")
    print(f"[OK] Parsed {len(rules)} rules")
    print(f"[OK] Generated {len(obligations)} obligations")
    print(f"[OK] Output saved to directory: {output_path}")
    print(f"[OK] File {asm_filename} written")
    print(f"[OK] File {header_filename} written")

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"\n[FATAL ERROR] Execution failed: {e}")
    finally:
        # Final pause to allow reading on cmd/PowerShell on Windows
        input("\nPress Enter to exit...")