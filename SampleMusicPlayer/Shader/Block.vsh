
attribute float     a_pSizeOffset;

//Uniform
uniform mat4    u_ProjectionMatrix;
uniform float   u_eSizeStart;
uniform float   u_eSizeEnd;
uniform vec2    u_ePosition;

//Config for growth up first
uniform float   u_eDelta;


//Varying - Using for out put for vertex shader and input for fragment shader



void main(void) {
    //TODO: Calculate y position up and down by time from position
    
    float x = 0.0; //Only change y variable
    float y = 0.0;
    
    // Size
    float s = 1.0;
    vec2 position = u_ePosition;
    if (u_eDelta != 0.0) {
        y = y + u_eDelta;
        position = vec2(x, y) + u_ePosition;
    }

    s = mix(u_eSizeStart, u_eSizeEnd, 1.0);

    gl_Position = u_ProjectionMatrix * vec4(position, x, 1.0);
    gl_PointSize = max(0.0, (s + a_pSizeOffset));
}