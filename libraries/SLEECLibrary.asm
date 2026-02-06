// definition of SLEEC rule 
//version: Multi obligation
module SLEECLibrary


import StandardLibrary
export *

signature:
	enum domain TimerUnit={NANOSEC, MILLISEC, SEC, MINUTE, HOUR}
	enum domain TCType = {AFTER, WITHIN} 
	abstract domain Capability 
	
	static doNothing : Capability 
	

definitions:
			
															
	rule r_skip = skip // named rule for no ASM state change (no prescribed obligation)
										
	//SLEEC constructor for 1 condition
	rule r_SLEEC($c0 in Boolean, $o0 in Rule) =
	 if $c0 then $o0 endif
	 
	//SLEEC constructor for 2 conditions
	rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule) =
	 if $c0 and not $c1 then $o0 
	 else if $c0 and $c1 then $o1 endif endif
	
	//SLEEC constructor for 3 conditions
	rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule, $c2 in Boolean, $o2 in Rule) =
	 if $c0 and not $c1 then $o0 
	 else if $c0 and $c1 and not $c2 then $o1 
	 else if $c0 and $c1 and $c2 then $o2 endif endif endif
	
	 //SLEEC constructor for 4 conditions
	 rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule, $c2 in Boolean, $o2 in Rule, $c3 in Boolean, $o3 in Rule) =
	  if ($c0 and not $c1) then $o0 
	  else if ($c0 and $c1 and not $c2) then $o1 
      else if ($c0 and $c1 and $c2 and not $c3) then $o2
      else if ($c0 and $c1 and $c2 and $c3) then $o3 endif endif endif endif
	 

	 //SLEEC constructor for 5 conditions
	 rule r_SLEEC($c0 in Boolean, $o0 in Rule, $c1 in Boolean, $o1 in Rule, $c2 in Boolean, $o2 in Rule, $c3 in Boolean, $o3 in Rule, $c4 in Boolean, $o4 in Rule) =
	  if $c0 and not $c1 then $o0 
	  else if $c0 and $c1 and not $c2 then $o1 
	  else if $c0 and $c1 and $c2 and not $c3 then $o2
	  else if $c0 and $c1 and $c2 and $c3 and not $c4 then $o3
	  else if $c0 and $c1 and $c2 and $c3 and $c4 then $o4
	  endif endif endif endif endif
	 
	