// We have 512 blocks of heap memory, each block is 8 bytes (or HSRSIZE).
// Heap memory is from 0x6000 to 0x6fff
#define HEAP 0x6000
#define BLOCKS 512
#define HDRSIZE 8

// Heap management allocates blocks in units of 8 bytes, which is the sizeof(Header) 
// typedef struct header { // header is 8 bytes
//    struct header *ptr;  // 4 bytes
//    int size;	    	   // 4 bytes - number of units in block
// } Header;


// static Header base = { &base, 512 };
.data HEAP
.label base
// 4096 bytes allocated to the heap.
// Allocate a minumum of 8 bytes (sizeof a HEADER)
// Set asside 512 blocks. 512 blocks * 8 bytes per block
HEAP                 // base points to itself
BLOCKS               // 512 blocks of sizeof(Header), which is 8
// unsigned char mem[512*8]; // 4096 units * sizeof(header)
// void *memp = (void *)mem;
// memp is label with address of heap
.data 0x7000
// static Header *freep = &base;
.label freep
HEAP


//void free(void *udp) { // udp points to user data, not Header
// NOTE: code preexists Internet. UDP is now User Data Protocol
  //Header *hp, *p;

  //hp = (Header*)udp - 1; // hp points to Header of block with user data
  //for (p = freep; (hp <= p || hp >= p->ptr); p = p->ptr)
  //for (p = freep; !(hp > p && hp < p->ptr); p = p->ptr)
  //    if (p >= p->ptr && (hp > p || hp < p->ptr))
  //        break;
  //if (hp + hp->size == p->ptr) { // collapse freed block with next
  //    hp->size += p->ptr->size;
  //    hp->ptr = p->ptr->ptr;
  //} else                         // add returned block to free list
  //    hp->ptr = p->ptr; <<<--- I want to do this
  //if (p + p->size == hp ){       // collapse freed block with front of circular list
  //    p->size += hp->size;
  //    p->ptr = hp->ptr;
  //} else                         // add returned block to free list
  //    p->ptr = hp;
  //freep = p;
//}

.text 0xb000
// r0 - udp - pointer to user data - passed as parameter
// r1 - hp - pointer to header
// r2 - p - for loop pointer
// r3 - p->ptr
.label dew_free
sub sp, sp, 12       // allocate stack
str r4, [sp, 0]      // save r4. Use it in free
str r5, [sp, 4]      // save r5. Use it in free
str lr, [sp, 8]      // save lr
// --------------------------------------------
sub r1, r0, HDRSIZE  // hp = (Header*)udp - 1
// for (p = freep; (hp <= p || hp >= p->ptr); p = p->ptr)
ldr r2, freep        // p = freep;
.label fre_forloop
ldr r3, [r2, 0]      // put p->ptr in r3
cmp r1, r2           // cmp hp, p
ble fre_dofor        // hp <= p, continue for loop
ldr r3, [r2, 0]      // put p->ptr in r3
cmp r1, r3           // cmp hp, p->ptr
bge fre_dofor
bal fre_fordone
.label fre_dofor
// if (p >= p->ptr && (hp > p || hp < p->ptr)
//     break;
cmp r1, r2           // cmp hp, p
bgt fre_and          // hp > p, check p >= p->ptr
cmp r1, r3           // cmp hp, p->ptr
blt fre_and          // hp < p->ptr, chech p >= p->ptr
bal fre_fordone      // break
.label fre_and
cmp r2, r3           // cmp p, p->ptr
bge fre_fordone      // p >= p->ptr so break
.label fre_contfor
ldr r2, [r2, 0]      // p = p->ptr
bal fre_forloop
.label fre_fordone
// if (hp + hp->size == p->ptr)
ldr r4, [r1, 4]      // hp->size to r4
mul r4, r4, HDRSIZE  // Header *hp and sizeof(Header) is HDRSIZE
add r4, r4, r1       // hp + hp->size to r4
cmp r4, r2           // cmp hp+hp->size, p
bne fre_else
 //    hp->size += p->ptr->size;
ldr r4, [r1, 4]      // hp->size to r4
ldr r5, [r3, 4]      // p->ptr->size to r5
add r4, r4, r5       // hp->size + p->ptr->size to r4
str r4, [r1, 4]      // hp->size += p->ptr->size
 //    hp->ptr = p->ptr->ptr;
ldr r5, [r3, 0]      // p->ptr->ptr to r5
str r5, [r1, 0]      // hp->ptr = p->ptr->ptr
bal fre_endif
.label fre_else
 //} else
 //    hp->ptr = p->ptr;
.label breakhere
str r3, [r1, 0]      // hp->ptr = p->ptr <<<--- I want to do this
.label fre_endif
 //if (p + p->size == hp ){
ldr r4, [r2, 4]      // p->size to r4
mul r4, r4, HDRSIZE  // Header *p and sizeof(Header) is HDRSIZE
add r4, r4, r2       // p + p->size to r4
cmp r1, r4           // cmp hp, (p+p->size)
bne fre_else1
  //    p->size += hp->size;
  //    p->ptr = hp->ptr;
ldr r4, [r1, 4]      // hp->size to r4
ldr r5, [r2, 4]      // p->size to r5
add r5, r5, r4       // p->size + hp->size
str r5, [r2, 4]      // p->size += hp->size
ldr r4, [r1, 0]      // hp->ptr to r4
str r4, [r2, 0]      // p->ptr = hp->ptr
bal fre_endif1
.label fre_else1
  //} else
  //    p->ptr = hp;
str r1, [r2, 0]      // p->ptr = hp
.label fre_endif1
str r2, freep        //freep = p;
// --------------------------------------------
// function exit sequence
ldr r4, [sp, 0]      // restore r4
ldr r5, [sp, 4]      // restore r5
ldr lr, [sp, 8]      // restore lr
add sp, sp, 16       // deallocate stack
mov pc, lr           // return

//  
// morecore - not implemented - just returns 0
//static Header* morecore(int nu) {
  //char *p;
  //Header *hp;

  //if(nu < 4096)
  //    nu = 4096;
    //freemem = sbrk(nunits * sizeof(Header)); // get block from OS - original call
    //p = malloc(nu * sizeof(Header)); // get block from OS - works for this example
    //p = calloc(nu, sizeof(Header)); // get block from OS - works for this example

  //p = (char *)&mem[0];

  //if (p == 0)
  //    return 0;
  //hp = (Header*)p;
  //hp->size = nu;
  //my_free((void*)(hp + 1)); // add this big block to our free list
  //return freep; 
//}
.label morecore
mov r0,0
mov pc, lr

//void *malloc(int nbytes) {
  //Header *p, *prevp;

  //int nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
  //prevp = freep;
  //for(p = prevp->ptr; ; prevp = p, p = p->ptr){
  //    if(p->size >= nunits){
  //        if(p->size == nunits)
  //            prevp->ptr = p->ptr; // remove from free list
  //        else {
  //            p->size -= nunits;   // too big so adjust size
  //            p += p->size;        // p points to block to return, at bottom of free block
  //            p->size = nunits;    // block has nunits - amount requested
  //        }
  //        freep = prevp;           // update freep - circular linked list, can be any Header blk
  //        return (void *)(p + 1);   // return pointer to user data
  //    }
  //    if (p == freep)              // Executed on first call to malloc and when morecore needed
  //        if ((p = morecore(nunits)) == 0)
  //            return 0;
  //}
//}
// r0 has number of bytes to malloc
// r1 is nunits
// r2 is prevp
// r3 is p
.text 0xb100
.label dew_malloc
sub sp, sp, 12
str r4, [sp, 0]
str r5, [sp, 4]
str lr, [sp, 8]
  //int nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
mov r1, HDRSIZE   // sizeof(Header) is HDRSIZE
sub r1, r1, 1     // sizeof(Header)-1 to r1
add r1, r1, r0    // nbytes+sizeof(Header)-1 to r1.
mov r2, HDRSIZE
div r1, r1, r2    // nbytes+sizeof(Header)-1 / sizeof(Header)
add r1, r1, 1     // r1 has nunits
  //prevp = freep;
ldr r2, freep     // r2 has prevp
  //for(p = prevp->ptr; ; prevp = p, p = p->ptr){ // loop has no termination expresion
ldr r3, [r2, 0]   // r3 has p
.label mal_loop
ldr r4, [r3, 4]   // r4 has p->size
  //    if(p->size >= nunits){
cmp r4, r1        // cmp p->size, nunits
blt mal_endif1
  //        if(p->size == nunits)
bgt mal_else2
  //            prevp->ptr = p->ptr; // remove from free list
ldr r4, [r3, 0]   // r4 has p->ptr
str r4, [r2, 0]   // prevp->ptr = p->ptr
bal mal_endif2
.label mal_else2
  //        else {
  //            p->size -= nunits;   // too big so adjust size
  //            p += p->size;        // p points to block to return, at bottom of free block
  //            p->size = nunits;    // block has nunits - amount requested
  //        }
ldr r4, [r3, 4]   // r4 has p->size
sub r5, r4, r1    // r5 = p->size - nunits
str r5, [r3, 4]   // p->size -= nunits
mul r5, r5, HDRSIZE // adjust p->size - sizeof(p) is HDRSIZE
add r3, r3, r5    // p += p->size
str r1, [r3, 4]   // p->size = nunits
.label mal_endif2
  //        freep = prevp;           // update freep - circular linked list, can be any Header blk
  //        return (void *)(p + 1);   // return pointer to user data
str r2, freep     // freep = prevp
add r0, r3, HDRSIZE //  r0 = p + 1 (HDRSIZE is num bytes in Header)
bal mal_ret
.label mal_endif1
  //    if (p == freep)              // Executed on first call to malloc and when morecore needed
  //        if ((p = morecore(nunits)) == 0)
  //            return 0;
ldr r1, freep
cmp r1, r3        // cmp p, freep
blr morecore      // r0 has nunits
mov r3, r0        // p = morecore(nunits)
cmp r3, 0
beq mal_ret
bal mal_loop
.label mal_ret // r0 has return value
// --------------------------------------------
// function exit sequence
ldr r4, [sp, 0]   // restore r4
ldr r5, [sp, 4]   // restore r5
ldr lr, [sp, 8]   // restore lr
add sp, sp, 12    // restore sp
mov pc, lr
