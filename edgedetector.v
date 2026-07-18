
// Level or pulse? A debounced signal is still a level ? held high for as long as you hold the button. 
// If you toggle an LED on the level, it toggles every clock cycle while your finger is down. So you need 
// an edge detector: register the debounced signal, compare it to its previous value, emit a single-cycle 
// pulse on the 0?1 transition. Harris & Harris Interview Question 3.5 is exactly this circuit, which tells 
// you something about how often it comes up.