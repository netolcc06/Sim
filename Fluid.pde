final int N = 80;
final int SCALE = 4;

class Fluid{
  
    int size;
    float dt, diff, visc;
    float[] u, v, u_prev, v_prev;
    float[] dens, dens_prev;
    
    int at(int x, int y){
        return x + y*N;
    }
    
    Fluid(float dt, float diff, float visc, int size){
        
        this.dt = dt; this.diff = diff; this.visc = visc; this.size = (size+2) * (size+2);
        u = new float[this.size];
        v = new float[this.size];
        u_prev = new float[this.size];
        v_prev = new float[this.size];
        dens = new float[this.size];
        dens_prev = new float[this.size];
        
        for(int i =0; i< this.size; i++){
            u[i] = 0;
            v[i] = 0;
            u_prev[i] =0;
            v_prev[i] = 0;
            dens[i] = 0;
            dens_prev[i] = 0;    
        }
    }
    
    void addDensity(int x, int y, float amount){
        int index = this.at(x, y);
        this.dens[index] += amount;
    }
    
    void addVelocity(int x, int y, float amountX, float amountY){
        int index = this.at(x, y);
        this.u[index] += amountX;
        this.v[index] += amountY;
    }
    
    void diffuse(int b, float[] x, float[] x0){
        float a=this.dt*this.diff*N*N;
        for (int k=0 ; k<5 ; k++){
            for (int i=1 ; i<=N ; i++){
                for(int j=1 ; j<=N ; j++){
                    x[this.at(i,j)] = (x0[this.at(i,j)] + a*(x[this.at(i-1,j)]+x[this.at(i+1,j)]+
                                   x[this.at(i,j-1)]+x[this.at(i,j+1)]))/(1+4*a);
                }
            }
            set_bnd (b, x);
        }
    }
    
    void set_bnd(int b, float[] x){
        int i;
        for(i=1 ; i<=N ; i++){
            x[this.at(0 ,i)] = b==1 ? -x[this.at(1,i)] : x[this.at(1,i)];
            x[this.at(N+1,i)] = b==1 ? -x[this.at(N,i)] : x[this.at(N,i)];
            x[this.at(i,0 )] = b==2 ? -x[this.at(i,1)] : x[this.at(i,1)];
            x[this.at(i,N+1)] = b==2 ? -x[this.at(i,N)] : x[this.at(i,N)];
        }
        
        x[this.at(0 ,0 )] = 0.5*(x[this.at(1,0 )]+x[this.at(0 ,1)]);
        x[this.at(0 ,N+1)] = 0.5*(x[this.at(1,N+1)]+x[this.at(0 ,N )]);
        x[this.at(N+1,0 )] = 0.5*(x[this.at(N,0 )]+x[this.at(N+1,1)]);
        x[this.at(N+1,N+1)] = 0.5*(x[this.at(N,N+1)]+x[this.at(N+1,N )]);
    }
    
    void project(float[] u, float[] v, float[] p, float[] div){
        float h;
        h = 1.0/N;
        
        for(int i=1 ; i<=N ; i++) {
            for(int j=1 ; j<=N ; j++) {
                div[this.at(i,j)] = -0.5*h*(u[this.at(i+1,j)]-u[this.at(i-1,j)]+
                v[this.at(i,j+1)]-v[this.at(i,j-1)]);
                p[this.at(i,j)] = 0;
            }
        }
        
        set_bnd (0, div); set_bnd (0, p);
        
        for(int k=0 ; k<5 ; k++){
            for (int i=1 ; i<=N ; i++ ){
                for(int j=1 ; j<=N ; j++ ){
                    p[this.at(i,j)] = (div[this.at(i,j)]+p[this.at(i-1,j)]+p[this.at(i+1,j)]+
                    p[this.at(i,j-1)]+p[this.at(i,j+1)])/4;
                }
            }
            set_bnd(0, p );
        }
        
        for(int i=1 ; i<=N ; i++){
            for(int j=1 ; j<=N ; j++){
                u[this.at(i,j)] -= 0.5*(p[this.at(i+1,j)]-p[this.at(i-1,j)])/h;
                v[this.at(i,j)] -= 0.5*(p[this.at(i,j+1)]-p[this.at(i,j-1)])/h;
            }
        }
        
        set_bnd(1, u); set_bnd(2, v);
    }
    
    float lerp(float a, float b, float x){
        return (1.0-x)*a+x*b;
    }
    
    
    float lerp(float x, float y, float[] d0){
        if (x<0.5) x=0.5; if (x>N+0.5) x=N+ 0.5; 
        if (y<0.5) y=0.5; if (y>N+0.5) y=N+ 0.5;
        
        int ix = (int)x;
        int iy = (int)y;
        
        x -= ix;
        y -= iy;
         
        float P00 = d0[this.at(ix + 0, iy + 0)], P10 = d0[this.at(ix + 1, iy + 0)];
        float P01 = d0[this.at(ix + 0, iy + 1)], P11 = d0[this.at(ix + 1, iy + 1)];
        
        return lerp(lerp(P00, P10, x), lerp(P01, P11, x), y);
    }
    
    void advect(int b, float[] d, float[] d0, float[] u, float[] v){
        
        float x, y;

        for(int i=1 ; i<=N ; i++ ){
            for(int j=1 ; j<=N ; j++ ){
                x = i-this.dt*N*u[this.at(i,j)]; y = j-this.dt*N*v[this.at(i,j)];
                d[this.at(i,j)] = this.lerp(x,y, d0);
            }
        }
        set_bnd(b, d);
    }
   
   //without swap
   void simStep(){
      
       diffuse(1, this.u_prev, this.u);
       diffuse(2, this.v_prev, this.v);
 
       project(this.u_prev, this.v_prev, this.u, this.v);

       advect(1, this.u, this.u_prev, this.u_prev, this.v_prev);
       advect(2, this.v, this.v_prev, this.u_prev, this.v_prev);
    
       project(this.u, this.v, this.u_prev, this.v_prev);
    
       diffuse(0, this.dens_prev, this.dens);
       advect(0, this.dens, this.dens_prev, this.u, this.v);
   }
   
   void renderDensity(){
       for(int i = 0; i< N; i++){
           for(int j = 0; j< N; j++){
               float x = i * SCALE;
               float y = j * SCALE;
               float d = this.dens[this.at(i,j)];
               fill(255,d);
               square(x, y, SCALE);
           }
       }
   }
}
