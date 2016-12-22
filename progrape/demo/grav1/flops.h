//============================================================================
struct flops_member {
  double Gflops;
  double start_time;
  double force_time;
  int nbody;
  int times;
  int nstep;
  int nskip;
};

void flops_initialize(struct flops_member *fm, int n, int nskip);
void flops_check(struct flops_member *fm);

void flops_ftime_init(struct flops_member *fm);
void flops_ftime_save(struct flops_member *fm);


