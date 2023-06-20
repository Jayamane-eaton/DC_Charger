

float xyinterp_f32(float y_1, float y_0, float x_1, float x_0, float x)
{
   float tol = 0.000001;
   float xinterp;
   
   xinterp = x_1 - x_0;
   
   if (xinterp < tol && xinterp > -tol) xinterp = 0.0;
   
   xinterp = (x - x_0) / xinterp;
   
   if (xinterp > 1.0)
      xinterp = 1.0;
   else if (xinterp < 0.0)
      xinterp = 0.0;
   
   return (y_1 - y_0) * xinterp + y_0;
}
