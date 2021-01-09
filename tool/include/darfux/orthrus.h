#ifndef __KERNEL__ORTHRUS__
#define __KERNEL__ORTHRUS__

#include <darfux/orthrus_types.h>

#define ORT_OPT_EXIST 1
#define ORT_IMPORTANT_DATA 2
#define ORT_CFQ 4
#define ORT_OPT_TEST 1<<24


#define ORT_DEFAULT_ACCOUNT 1<<16


#define ORT_HDR_MAGIC 233

#define ORT_EXIST(ort_opt) ((ort_opt) && ((ort_opt)->flags & ORT_OPT_EXIST))
#define ORT_IS_CFQ(ort_opt) (ORT_EXIST(ort_opt) && ((ort_opt)->flags & ORT_CFQ))
#define ORT_CLEAR(ort_opt) do{ if(ort_opt){ ((ort_opt)->flags &= ~ORT_OPT_EXIST); } }while(0);
#define ORT_TEST(ort_opt) ((ort_opt) && ((ort_opt)->flags & ORT_OPT_TEST))


#endif
