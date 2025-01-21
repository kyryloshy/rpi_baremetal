
// Number to string function
// Arguments:
// x0 - number value
// x1 - string pointer
// x2 - string pointer size (bytes)
// x3 - number base (e.g., 10 for decimal, 2 for binary, 16 for hex)
// Uses:
// 

label num_to_str

str_pre_index lr, sp, -8 // Store the return value

// First step: Count how many digits the number has
mov x4, 0 // The counter
mov x5, 1 // A growing value at a rate of base ^ x4 (counter). Used to check if the input value is less than this value, and if yes, exit the loop

cmp x5, x0 // Compare the growing value to the input value
b.gt 4 // If the growing value is larger, exit the loop
mul x5, x5, x3 // Move to the next digit place (e.g., from 1 to 10, from 10 to 100, ...)
add x4, x4, 1 // Increment the digit counter
b -4 // Repeat

// Here after the loop. Counter now contains the number of digits. But zero for the input value 0 - this should be changed to one:
cmp x4, 0 // Compare n digits to zero
b.ne 2 // If not zero, skip the next instruction
mov x4, 1 // If zero digits, set n digits to one (since zero should be displayed as '0' - one digit)

// Now, check if the string pointer can fit the number
add x5, x4, 1 // x5 is the number of digits + 1 for the null-terminator
cmp x2, x5 // Compare the string size to the needed size
b.ge 4 // Skip next instructions if the string size is greater or equal to the needed size

// If the string can't fit the number, exit with 'errors'
mov x0, 1 // Error '1' in x0
mov x1, x5 // The required size in x1
b num_to_str_return // Return


// If everything's fine, create the appropriate string:
// Actions: the string will be constructed from the end to the start, because that's faster and doesn't require a reverse operation at the end (meaning less memory operations)

// First step: move the string pointer to the end character
add x1, x1, x4 // Increment by the number of digits


// Second step: write the ending null character
mov w5, 0
strb w5, x1 // Write the null character
sub x1, x1, 1 // Move to the previous string character


// Third step: extract the digits in a loop and write them to the string

// Registers:
// x5 - number value left (not x0, because the modulo operation uses x0 - x1)
// x6 - current character pointer
// x2 - string pointer bytesize (not used anymore)
// x3 - number base
// x4 - digits left / string size left

// Copy x0-x1 values, because the modulo function uses them
mov x5, x0
mov x6, x1

// Loop start
label num_to_str_convert_loop

// Perform a modulo operation between the number left and the digit base (e.g., 341 % 10 = 1 - the extracted digit)
mov x0, x5
mov x1, x3
bl modulo
// Now, x0 is the extracted digit

add x0, x0, '0' // ascii encode the digit
strb w0, x6 // Write the character

sub x6, x6, 1 // Move to the previous character in the string
sub x4, x4, 1 // Decrement n digits left

udiv x5, x5, x3 // Remove the parsed digit from the number (e.g., if the number was 341, now it is 341 / 10 = 34)

cmp x4, 0 // Check if no digits are left
b.eq 2 // If yes, skip the repeat (exit the loop)
b num_to_str_convert_loop

// Here after the loop
mov x0, 0 // Set x0 to 0 as a sign of success

label num_to_str_return

// Get the return address
ldr lr, sp
add sp, sp, 8

br lr // Return







// // Modulo operation for positive integers
// // x0 - source
// // x1 - modulo
// // Operation: x0 = x0 % x1
// // Output:
// // x0 - result
// // Uses:
// // x0-x1
// label modulo
// 
// cmp x0, x1
// b.lt 3 // Skip
// sub x0, x0, x1
// b -3 // Repeat
// 
// br lr // Return


// Modulo operation for positive integers
// x0 - source
// x1 - modulo
// Operation: x0 = source - source/modulo * modulo
// Output:
// x0 - result
// Uses:
// x0-x2
label modulo

udiv x2, x0, x1 // x2 = x0 / x1
msub x0, x2, x1, x0 // x0 = x0 - x0 / x1

br lr // Return








// x0 - to divide
// x1 - dividend
// x0 = x0 / x1 (floors the number, so 26 / 4 = 6)
// Uses: x0-x2
label divide

mov x2, x0

mov x0, 0

cmp x2, x1
b.lt 4
sub x2, x2, x1
add x0, x0, 1
b -4

br lr

