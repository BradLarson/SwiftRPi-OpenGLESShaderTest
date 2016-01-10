// Mandelbrot shader drawn from here:
// https://gist.github.com/davechristian/9427160

precision highp float;

varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;


void main()
{
	float zoom = 3.0;
	float real = (textureCoordinate.x - 0.7) * zoom;
	float imaginary = (textureCoordinate.y - 0.5) * zoom;	
	float const_real = real;
	float const_imaginary = imaginary;
	float z2 = 0.0;
	int iter_count = 0;
	for(int iter = 0; (iter) < 30; ++iter)
	{
	   float temp_real = real;
	   
	   real = (temp_real * temp_real) - (imaginary * imaginary) + const_real;
	   imaginary = 2.0 * temp_real * imaginary + const_imaginary;
	   z2 = real * real + imaginary * imaginary;
	   iter_count = iter;
	   if (z2 > 4.0) 
		  break;
	}
	if (z2 < 4.0)
	   gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	else	
	   gl_FragColor = vec4(mix(vec3(0.0, 0.0, 0.2), vec3(1.0, 1.0, 1.0), fract(float(iter_count)*0.02)), 1.0);
}
