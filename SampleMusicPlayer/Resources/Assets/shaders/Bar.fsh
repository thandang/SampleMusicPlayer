uniform sampler2D u_Texture;
uniform highp vec3 u_GrowthColor;

varying highp float v_Growth;

void main(void) {
    highp vec4 texture = texture2D(u_Texture, gl_PointCoord);
    highp vec4 newTextire = texture;
    
    if (v_Growth > 0.5) {
        highp vec4 color = vec4(1.0);
        color.rgb = u_GrowthColor;
        newTextire = texture + color;
    }
    gl_FragColor = newTextire;
}