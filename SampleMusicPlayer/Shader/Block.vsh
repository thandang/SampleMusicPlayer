static const char * BlockVS = STRINGIFY {

    //Attribute
    attribute float a_pID;
    attribute float a_pRadiusOffset;
    attribute float a_pVelocityOffset;
    attribute float a_pDecayOffset;
    attribute float a_pColorOffset;
    attribute float a_pSizeOffset;
    
    //Uniform
    uniform mat4    u_ProjectionMatrix;
    uniform vec2    u_Gravity;
    uniform float   u_Time;
    uniform vec2    u_ePosition;
    uniform float   u_eRadious;
    uniform float   u_eVelocity;
    uniform float   u_eDecay;
    uniform float   u_eSizeStart;
    uniform float   u_eSizeEnd;

    
    //Varying
    varying vec3    v_pColorOffset;
    varying float   v_pGrowth;
    varying float   v_pDecay;
    
    
    void main(void) {
        //TODO: Calculate y position up and down by time from position
        
        // Convert polar angle to cartesian coordinates and calculate radius
        float x = 0.0;
        float y = sin(a_pID);
        float r = u_eRadius * a_pRadiusOffset;
        
        // Lifetime
        float growth = r / (u_eVelocity + a_pVelocityOffset);
        float decay = u_eDecay + a_pDecayOffset;
        
        // Size
        float s = 1.0;
        
        // If blast is growing
        if (u_Time < growth) {
            float time = u_Time / growth;
            y = y * r * time; //TODO: remember to re-calculate again
            s = u_eSize;
        } else {
            float time = (u_Time - growth) / decay;
            y = y * r + u_Gravity * time;
            s = mix(u_eSizeStart, u_eSizeEnd, time);
        }
        
        vec2 position = vec3(x, y) + u_ePosition;
        gl_Position = u_ProjectionMatrix * vec4(position, 0.0, 1.0);
        gl_PointSize = max(0.0, (s + a_pSizeOffset));
        
        // Fragment Shader outputs
        v_pColorOffset = a_pColorOffset;
        v_Growth = growth;
        v_Decay = decay;
    }
}