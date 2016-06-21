uniform sampler2D u_Texture;
varying highp vec4 DestinationColor;

void main(void) {
    highp vec4 texture = texture2D(u_Texture, gl_PointCoord);
    gl_FragColor = texture;
//    gl_FragColor = DestinationColor;
}