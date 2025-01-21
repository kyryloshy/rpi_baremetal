align 8
label DYNAMIC_MEMORY_START
bytes 8, 0x100000

label DYNAMIC_MEMORY_END
bytes 8, 0x150000

label DYNAMIC_MEMORY_RESERVED_LIST_START
bytes 8, 0

// Documentation
//
// Reserved regions linked list node structure:
// 0 - start address (8 bytes)
// 8 - region size (8 bytes)
// 16 - next node address (8 bytes)


// Memory allocate function
// Arguments:
// x0 - region size
// Output:
// x0 - start address for the requested region
// Uses:
// x0 - x9
label mem_alloc

str_pre_index lr, sp, -8

mov x5, x0 // Save the requested region size in x5

// x6 will hold the check address / the potential region start address
ldr x6, DYNAMIC_MEMORY_START

ldr x7, DYNAMIC_MEMORY_END // Load the dynamic memory range end into x7



label mem_alloc_region_find_loop

// Check for the potential value being properly aligned by 8
mov x0, 8
udiv x1, x6, x0 // Floored division
msub x1, x0, x1, x6 // Calculate the remainder

cmp x1, 0 // Check if already aligned
b.eq 3 // If yes, skip the alignment part

sub x0, x0, x1 // Calculate how much to add until the address is divisible by 8
add x6, x6, x0

// Now the potential region start address is aligned to an 8-byte boundary

// Check if the potential address exceeds the dynamic memory range
add x0, x6, x5 // Calculate the region's endpoint
cmp x0, x7
b.lt 3 // Skip the fault logic if less than the dynamic memory range endpoint
mov x6, 0 // Set the start address to zero as a fault sign
b mem_alloc_region_find_loop_end // Exit the loop


// Check if the potential region overlaps any existing reserved regions
mov x0, x5 // Setup the arguments
mov x1, x6
bl is_mem_region_reserved

// x0 now contains either zero (when not reserved), or the endpoint address of the reserved region

cmp x0, 0 // Check if not reserved
b.eq mem_alloc_region_find_loop_end // If not, break out of the loop

// If reserved, jump to the endpoint of the reserved region
mov x6, x0 // Set the next potential region start address to the end of the reserved region

b mem_alloc_region_find_loop // Repeat

label mem_alloc_region_find_loop_end




// Here after the loop when a fitting region address was either found or not
// First, check if the address was found or not

cmp x6, 0
b.ne 4 // If not zero, skip the error logic
// Here if a fitting address was not found. Action: move 0 to x0, and return
mov x0, 0
ldr_post_index lr, sp, 8
br lr // Return

// Here if a fitting region start address was found



mov x8, x6 // Store the region's newly found address in x8
mov x9, x5 // Store the region's size in x9

// Next action: find an address for the region's node to store info (mostly the same logic as finding an address for the requested region)

mov x5, 24 // Move the node size into x5
// x6 will hold the check address / the potential node start address
ldr x6, DYNAMIC_MEMORY_START
ldr x7, DYNAMIC_MEMORY_END // Load the dynamic memory range end into x7


// Initiate the loop
label mem_alloc_node_find_loop

// Check for the potential value being properly aligned by 8
mov x0, 8
udiv x1, x6, x0 // Floored division
msub x1, x0, x1, x6 // Calculate the remainder

cmp x1, 0 // Check if already aligned
b.eq 3 // If yes, skip the alignment part

sub x0, x0, x1 // Calculate how much to add until the address is divisible by 8
add x6, x6, x0

// Now the potential region start address is aligned to an 8-byte boundary

// Check if the potential address exceeds the dynamic memory range
add x0, x6, x5 // Calculate the region's endpoint
cmp x0, x7
b.lt 3 // Skip the fault logic if less than the dynamic memory range endpoint
mov x6, 0 // Set the start address to zero as a fault sign
b mem_alloc_node_find_loop_end // Exit the loop


// Checks if the potential address is valid
// First, check if the potential address is the same as the region's newly found address
// If yes, jump to the end of the region, because the system node and the region should NOT be in the same location
cmp x6, x8
b.ne 3 // If not equal, skip this jumping logic
add x6, x6, x9 // If equal, add the region's size and repeat the loop to effectively skip the requested region found
b mem_alloc_node_find_loop // Repeat

// Here when the potential address doesn't interfere with the found address for the requested region

// Check if the potential region overlaps any existing reserved regions
mov x0, x5 // Setup the arguments
mov x1, x6
bl is_mem_region_reserved

// x0 now contains either zero (when not reserved), or the endpoint address of the reserved region

cmp x0, 0 // Check if not reserved
b.eq mem_alloc_node_find_loop_end // If not, break out of the loop

// If reserved, jump to the endpoint of the reserved region
mov x6, x0 // Set the next potential region start address to the end of the reserved region

b mem_alloc_node_find_loop // Repeat

label mem_alloc_node_find_loop_end



// Here after the loop. Check if an address for the system node was found
cmp x6, 0 // Check if zero (meaning error)
b.ne 4 // If not, skip the error logic
mov x0, 0
ldr_post_index lr, sp, 8
br lr // Return


// Here when the region and the node addresses are valid

// Action: fill in the node with correct information

str_unsigned x8, x6, 0 // Region start address
str_unsigned x9, x6, 8 // Region size
mov x0, 0
str_unsigned x0, x6, 16 // Next node's address (zero, since this will be the last node now)

// Next action: find the last node in the linked list to link the new one with



ldr x0, DYNAMIC_MEMORY_RESERVED_LIST_START

cmp x0, 0 // Check if there aren't any nodes
b.ne mem_alloc_link_nodes // If there are nodes, run the linking logic

// If there aren't any nodes, write this node's address to the list start location
adr x0, DYNAMIC_MEMORY_RESERVED_LIST_START
str x6, x0

mov x0, x8
ldr_post_index lr, sp, 8
br lr // Return



label mem_alloc_link_nodes

label mem_alloc_find_last_node_loop
ldr_unsigned x1, x0, 16 // Load the address of the next node
cmp x1, 0
b.eq 3 // If zero (meaning the x0 is the last node), exit the loop
// If not, go to the next node and repeat
mov x0, x1
b mem_alloc_find_last_node_loop

label mem_alloc_find_last_node_loop_end



// x0 now contains the last node
// Action: link the new node with the previously last node

str_unsigned x6, x0, 16 // Write the address of the new node to the linking field of the last node

// Time to return
// Output the allocated address for the new region
mov x0, x8
ldr_post_index lr, sp, 8
br lr // Return








// Is memory region reserved function
// Checks if the input memory region overlaps any already reserved memory region, and if yes, returns the node address of the overlapping region
// Arguments:
// x0 - region size
// x1 - region start address
// Output:
// x0 - zero if not reserved. If not zero, x0 is the endpoint address of the overlapping region
// Uses:
// x0 - x4
label is_mem_region_reserved

str_pre_index lr, sp, -8

add x2, x0, x1 // Store the endpoint of the input region in x2

ldr x0, DYNAMIC_MEMORY_RESERVED_LIST_START // Load the address of the first node of the reserved regions linked list

label is_mem_region_reserved_loop

cmp x0, 0 // If no more node found (the node address is 0), exit the loop
b.eq is_mem_region_reserved_loop_end

// Load the reserved region's points / parameters
ldr_unsigned x3, x0, 0 // region start address
ldr_unsigned x4, x0, 8 // region size

add x4, x3, x4 // Compute x4 to be the region endpoint instead of size (x4 = region start + region size)

// Check if the selected region and the current node region overlap by doing 'r1_start < r2_end && r2_start < r1_end' (x1 < x4 && x3 < x2)

cmp x1, x4
b.ge is_mem_region_reserved_no_region_overlap

cmp x3, x2
b.ge is_mem_region_reserved_no_region_overlap

// Here if the two regions overlap
// Action: return to the caller with x0 containing the endpoint of the overlapping region (x4 is already equal to that)
mov x0, x4
ldr_post_index lr, sp, 8 // Load the return address
br lr // Return

label is_mem_region_reserved_no_region_overlap
// Here if there isn't any region (the user reserved region) overlap

// Now check if there is overlap between the input region and the current system's reserved region struct
mov x3, x0
add x4, x3, 24 // x4 is the start of the node, plus the node's size

// Perform the same logic
cmp x1, x4
b.ge is_mem_region_reserved_no_node_overlap
cmp x3, x2
b.ge is_mem_region_reserved_no_node_overlap
// Here if there's overlap between the input region and the system node
// Action: return to the caller with x0 containing the endpoint of the node (x4 has it already, so move to x0)
mov x0, x4
ldr_post_index lr, sp, 8 // Load the return address
br lr // Return

label is_mem_region_reserved_no_node_overlap
// Now, there isn't any overlap or conflicts with the current node / region, so move to the next one and repeat

// Move to the next node
ldr_unsigned x0, x0, 16

b is_mem_region_reserved_loop // Repeat

label is_mem_region_reserved_loop_end

// Here if no conflicts with any of the reserved region nodes were found. Return zero in this case

mov x0, 0
ldr_post_index lr, sp, 8
br lr





// Memory free function
// Arguments:
// x0 - start address for the region to free
// Output:
// x0 - status (0 - everything fine, 1 - region to free not found)
// Uses:
//
label mem_free

// First action: find the node to delete
ldr x1, DYNAMIC_MEMORY_RESERVED_LIST_START

cmp x1, 0 // Check if no nodes exist (reserved list empty)
b.ne 2 // Skip the error return if nodes exist
b mem_free_node_not_found_error

// Check if the first node contains the requested region to free
ldr_unsigned x2, x1, 0 // Load the node's region address
cmp x2, x0 // Compare to the input address
b.ne 6 // If not equal, skip to the loop logic

// If the first node contains the region to free, set the next node as the list start
ldr_unsigned x2, x1, 16 // Load the next node's address
adr x1, DYNAMIC_MEMORY_RESERVED_LIST_START // Load the address of the list start
str x2, x1 // Write the next node as the list start
mov x0, 0 // Set status to success
br lr // Return


// Here if the requested region is not the first one

label mem_free_node_find_loop

mov x2, x1 // x2 will contain the previous node
ldr_unsigned x1, x2, 16 // x1 is the next node

cmp x1, 0 // Check if the end was reached
b.eq mem_free_node_not_found_error // If yes, meaning the needed node was not found, return an error

ldr_unsigned x3, x1, 0
cmp x3, x0 // Check if the start address matches up with the current node's one
b.eq 2 // Skip the repeat if yes

b mem_free_node_find_loop // Repeat


// Here when the node to delete is in x1 and the previous node is in x2

// Link the node after the one to delete and the one before together, effectively removing the current one
ldr_unsigned x0, x1, 16 // Load the address of the next node
str_unsigned x0, x2, 16 // Store the address of the next node in the previous node's link field

mov x0, 0 // Set status to success
br lr // Return


label mem_free_node_not_found_error
mov x0, 1 // Set output to an error status
br lr // Return



