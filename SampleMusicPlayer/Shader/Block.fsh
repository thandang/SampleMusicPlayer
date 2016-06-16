//static const char * BlockFS = STRINGIFY {
    //Uniform
    uniform sampler2D u_Texture;
    
    void main(void) {
        // Texture
        highp vec4 texture = texture2D(u_Texture, gl_PointCoord);
        gl_FragColor = texture;
    }
//}