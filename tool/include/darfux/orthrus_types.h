#ifndef __KERNEL__ORTHRUS__TYPES__
#define __KERNEL__ORTHRUS__TYPES__


typedef uint16_t ort_magic_t;

struct ort_opt{
  uint32_t deadline;
  uint32_t flags;
  uint32_t account_id;
};


#endif
