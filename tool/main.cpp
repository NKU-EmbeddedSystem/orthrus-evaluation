#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <error.h>
#include <inttypes.h>
#include <cstdlib>
#include <malloc.h>
#include <ctime>
#include <numeric>
#include <chrono>
#include <unistd.h>
#include <assert.h>


#include "darfux/orthrus.h"

const int BLKSIZE = 512;
inline double getms(struct timespec& time) {
  return time.tv_nsec / 1e6 + time.tv_sec * 1e3;
}

inline double calcu_duration(struct timespec& start, struct timespec& end) {
  return getms(end) - getms(start);
}

struct io_opt{
  int factor;
  bool manual;
  int howlong;
  int interval;
  bool random;
  bool seqpos;
  bool useort;
  bool usebase;
  bool quiet;
  int interval_seq;
  int rw;
};

int test_write(int fd, ort_opt& opt, const io_opt& io_opt);
int main(int argc, char *argv[])
{
  assert(RAND_MAX> 1<<31);
  int opt;
  uint32_t deadline=-1;
  io_opt io_opt = {
    .factor = 1,
    .manual = true,
    .howlong = -1,
    .interval = -1,
    .random = false,
    .seqpos = false,
    .useort = true,
    .usebase = false,
    .quiet = true,
    .interval_seq = -1,
    .rw = 1,
  };
  const char* file_path = "/home/darfux/orthrus_test";
  uint32_t account_id = (uint32_t)getpid();
  while ((opt = getopt (argc, argv, "m:f:l:i:d:r:c:u:s:o:b:q:n:w:")) != -1)
  {
    switch (opt)
    {
      case 'm':
        io_opt.manual = optarg[0]=='1';
        break;
      case 'f':
        io_opt.factor = atoi(optarg);
        break;
      case 'l':
        io_opt.howlong = atoi(optarg)*1000;
        break;
      case 'i':
        io_opt.interval = atoi(optarg);
        break;
      case 'd':
        file_path = optarg;
        break;
      case 'r':
        io_opt.random = optarg[0]=='1';
        break;
      case 'c':
        deadline = atoi(optarg);
        break;
      case 'u':
        account_id = atoi(optarg);
        break;
      case 's':
        io_opt.seqpos = optarg[0]=='1';
        break;
      case 'o':
        io_opt.useort = optarg[0]=='1';
        break;
      case 'b':
        io_opt.usebase = optarg[0]=='1';
        break;
      case 'q':
        io_opt.quiet = optarg[0]=='1';
        break;
      case 'n':
        io_opt.interval_seq = atoi(optarg);
        break;
      case 'w':
        io_opt.rw = atoi(optarg);
        break;
    }
  }

  setbuf(stdout, NULL);
  int fd = open(file_path, O_RDWR|O_DIRECT);
  if(fd<0) {
    perror("open erro:");
    return -1;
  }

  ort_opt ort_opt = {
    .deadline = deadline,
    .flags = 0,
    .account_id = account_id,
  };
  ort_opt.flags |= ORT_IMPORTANT_DATA;
  ort_opt.flags |= ORT_CFQ;
  // ort_opt.flags |= ORT_OPT_TEST;

  test_write(fd, ort_opt, io_opt);

  return 0;
}


int test_write(int fd, ort_opt& opt, const io_opt& io_opt)
{
  struct timespec start, begin, end;
  std::srand(std::time(nullptr)*opt.account_id); // use current time as seed for random generator

  int ret;
  long long buf_size = BLKSIZE*8*io_opt.factor;
  char *buffer = (char*)memalign(BLKSIZE, buf_size);

  clock_gettime(CLOCK_MONOTONIC, &begin);
  clock_gettime(CLOCK_MONOTONIC, &start);
  long long write_out = 0;
  uint64_t total_write_out = 0;
  for(long long i=0; i<BLKSIZE*8*io_opt.factor; i++){
    long long random_variable = std::rand()%26;
    buffer[i] = 'a'+random_variable;
  }
  double duration = 0, pre_duration = 0;
  long long pos = 0;
  long long outsize = BLKSIZE*4*io_opt.factor;
  long long base = io_opt.usebase ? (opt.account_id%9)*BLKSIZE*10000 : 0;
  int counter = io_opt.interval_seq;
  while(io_opt.manual || io_opt.howlong==-1 || duration<io_opt.howlong){

    if(io_opt.seqpos){
      pos += 1;
      pos %= 51200;
    }else{
      pos = std::rand()%10000;
    }

    if(opt.deadline < 0) { opt.deadline = std::rand()%100; }

    clock_gettime(CLOCK_MONOTONIC, &start);

    // printf("writeout to %lld\n", pos*outsize + base);


    ort_opt* oopt = io_opt.useort ? &opt : NULL;
    int syscall_num = io_opt.rw==1 ? 346 : 356;


    ret = syscall(syscall_num, fd, buffer, outsize, pos*outsize + base, oopt);

    if(ret>0) {
      write_out += ret/1024;
      total_write_out += ret;
    }

    clock_gettime(CLOCK_MONOTONIC, &end);

    double milliseconds = calcu_duration(start, end);
    duration = calcu_duration(begin, end);
    double detaT = duration - pre_duration;

    if(!io_opt.quiet) {
      printf("[d] %f\n", milliseconds);
    }
    if(!io_opt.manual && io_opt.interval<=0 && detaT>=1000) {
      printf("[T] %f %lld\n", duration/1000, write_out);
      printf("[A] %ld\n", total_write_out/1024);
      write_out = 0;
      pre_duration = duration;
    }

    if(io_opt.manual){
      if(ret<0){
        perror("Write failed");
      }

      char ch;
      scanf("%c", &ch);
    }else if(io_opt.interval>0) {
      int interval = io_opt.interval;

      if(io_opt.interval_seq > 0 && counter==0) {
        if(io_opt.random) {
          interval = std::rand()%(io_opt.interval-50*(io_opt.interval>50)) + 50;
        }
        interval *= 1000;
        usleep(interval);
        counter = io_opt.interval_seq;
      }else{
        counter--;
      }
    }

  }

  return 0;
}
