
attribute float a_pSizeOffset;
attribute vec4  SourceColor; //Color input from vertex shader
attribute float a_pPositionYOffset;

//Uniform
uniform mat4    u_ProjectionMatrix;
uniform float   u_eSizeStart;
uniform float   u_eSizeEnd;
uniform vec2    u_ePosition;
uniform float   u_Time;
uniform vec2    u_Gravity;


varying vec4    DestinationColor; //Color output from vertex shader and also input to fragment shader


//Config for growth up first
uniform float   u_eDelta;


void main(void) {
    float x = 0.0;
    float y = 0.0;
    
    // Size
    float s = 1.0;
    vec2 position = u_ePosition;
    if (u_eDelta != 0.0) {
        y = y + u_eDelta - a_pPositionYOffset;
        s = mix(u_eSizeStart, u_eSizeEnd, 1.0);
        position = vec2(x, y) + u_ePosition;
    }
    
    s = mix(u_eSizeStart, u_eSizeEnd, 1.0);
    
    gl_Position = u_ProjectionMatrix * vec4(position, x, 1.0);
    gl_PointSize = max(0.0, (s + a_pSizeOffset));
    
    DestinationColor = SourceColor;
}