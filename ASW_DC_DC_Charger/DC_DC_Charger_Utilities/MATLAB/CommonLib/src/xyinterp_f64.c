

double xyinterp_f64(double y_1, double y_0, double x_1, double x_0, double x)
{
   double tol = 0.000001;
   double xinterp;
   
   xinterp = x_1 - x_0;
   
   if (xinterp < tol && xinterp > -tol) xinterp = 0.0;
   
   xinterp = (x - x_0) / xinterp;
   
   if (xinterp > 1.0)
      xinterp = 1.0;
   else if (xinterp < 0.0)
      xinterp = 0.0;
   
   return (y_1 - y_0) * xinterp + y_0;
}
