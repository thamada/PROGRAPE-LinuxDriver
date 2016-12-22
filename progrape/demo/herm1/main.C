//-----------------------------------------------------------------------------
// hermite.C
// Code: Standard 4th order Hermite integrator with constant time step
// Ref.: J. Makino, S. J. Aarseth, PASJ 44, 141 (1992)
// Author: Andreas Ernst Jan, 2006
// Modify: Tsuyoshi Hamada, Nov, 2006
//-----------------------------------------------------------------------------
#include  <iostream>
#include  <cmath>
#include  <cstdlib>
#include  <iomanip> // cout << setw() << setprecision() 
using namespace std;

extern "C" void force(double x[][3], double v[][3], double m[], double p[], double a[][3],
      double j[][3], int n);

extern "C" void debug_position_snap(double x[][3], double Gflops, int n, int nstep);


// Calculate energy

double energy(double m[], double r[][3], double v[][3], double p[], int n) {
  double ekin = 0, epot = 0;
  for (int i = 0; i < n; i++) {
    epot -= 0.5 * m[i] * p[i];
    for (int k = 0; k < 3; k++) ekin += 0.5 * m[i] * v[i][k] * v[i][k];
  }
  return ekin + epot;
}

int main(int argc, char *argv[]) {

// Read initial conditions from stdin, declaration of variables

  if (argc < 3 ) {
    cout << "Usage: hermite <dt> <t_end> <dt_opt>" << endl;
    return 0;
  }

  double dt = atof(argv[1]); // time step
  double dt2 = dt*dt;
  double dt3 = dt2*dt;
  double dt4 = dt2*dt2;
  double dt5 = dt4*dt;
  double t_end = atof(argv[2]);
  double dt_opt = atof(argv[3]);
  double t_opt = 0.0;

  int n;
  cin >> n;

  double t;
  cin >> t;

  double * m = new double[n];
  double * p = new double[n];
  double (* r)[3] = new double[n][3];
  double (* v)[3] = new double[n][3];
  double (* a)[3] = new double[n][3];
  double (* jk)[3] = new double[n][3];
  double (* a2)[3] = new double[n][3];
  double (* a3)[3] = new double[n][3];

  for (int i = 0; i < n ; i++){
    cin >> m[i];
    for (int k = 0; k < 3; k++) cin >> r[i][k];
    for (int k = 0; k < 3; k++) cin >> v[i][k];
  }
  
// Calculate initial acceleration and jerk

  force(r, v, m, p, a, jk, n);



  if(0){
    cout << "DATA: ";
    cout << n << " ";
    cout << t << " ";
    cout << endl;
    cout.precision(6);
    for (int i = 0; i < n; i++) {
      cout << setw(5) << p[i] << "\t";
      for (int k = 0; k < 3; k++) cout << setw(5) << a[i][k] << "\t";
      //      for (int k = 0; k < 3; k++) cout << jk[i][k] << "\t";
      cout << endl;
    }
    exit(0);
  }

  
// Calculate initial total energy

  double e_in = energy(m, r, v, p, n);
  cerr << "Initial total energy E_in = " << e_in << endl;

  double dt_out = 0.01;
  double t_out = dt_out;

  double old_r[n][3], old_v[n][3], old_a[n][3], old_j[n][3];

  for (double t = 0; t < t_end; t += dt) {
    //    usleep (10000);
// Do the prediction

    for (int i = 0; i < n; i++) {
      for (int k = 0; k < 3; k++) {
        old_r[i][k] = r[i][k];
        old_v[i][k] = v[i][k];
        old_a[i][k] = a[i][k];
        old_j[i][k] = jk[i][k];
        r[i][k] += v[i][k]*dt + a[i][k]*dt2/2 + jk[i][k]*dt3/6;
        v[i][k] += a[i][k]*dt + jk[i][k]*dt2/2;
      }
    }
    
// Calculate acceleration and jerk from predicted positions and velocities

    force(r, v, m, p, a, jk, n);
    
// Do the interpolation and correction

    for (int i = 0; i < n; i++) {
      for (int k = 0; k < 3; k++) {
        a2[i][k] = -6*(old_a[i][k]-a[i][k])/dt2
                 -  2*(2*old_j[i][k] + jk[i][k])/dt;
        a3[i][k] = 12*(old_a[i][k]-a[i][k])/dt3
                 +  6*(old_j[i][k]+jk[i][k])/dt2;
            
        v[i][k] = v[i][k] + a2[i][k]*dt3/6
                + a3[i][k]*dt4/24;
        r[i][k] = r[i][k] + a2[i][k]*dt4/24
                + a3[i][k]*dt5/120;
      }
    }
    
// Data output    
    
    if (t >= t_out) {
      debug_position_snap(r, (12345.6789) ,n,  (int)(t/dt) );
      cout << "DATA: ";
      cout << n << " ";
      cout << t << " ";
      for (int i = 0; i < n; i++) {
        cout << m[i] << " ";
        for (int k = 0; k < 3; k++) cout << r[i][k] << " ";
        for (int k = 0; k < 3; k++) cout << v[i][k] << " ";
      }
      cout << endl;
      t_out += dt_out;
    }



    // Energy output      
      
    if (t >= t_opt) {
      double e_cur = energy(m, r, v, p, n);
      cerr << "TIME: " << t << " ENERGY: " << e_cur 
           << " DEE: " << (e_cur-e_in)/e_in << endl;
      t_opt += dt_opt;
    }
  }

  double e_out = energy(m, r, v, p, n);

  cerr << "Initial total energy E_in = " << e_in << endl;
  cerr << "Final total energy E_out = " << e_out << endl;
  cerr << "absolute energy error: E_out - E_in = " << e_out - e_in << endl;
  cerr << "relative energy error: (E_out - E_in) / E_in = "
       << (e_out - e_in) / e_in << endl;
  return 0;
}
//-----------------------------------------------------------------------------
