varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

void main()
{
	gl_FragColor = vec4(textureCoordinate.x, textureCoordinate.y, 0.0, 1.0);
}