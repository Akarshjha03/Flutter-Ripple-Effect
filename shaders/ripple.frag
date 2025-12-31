#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
// Support up to 5 concurrent ripples. 
// Format: x (normalized 0-1), y (normalized 0-1), startTime (seconds), power
uniform vec4 uRipples[5]; 
uniform sampler2D uImage;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    vec2 displacement = vec2(0.0);
    float totalDisturbance = 0.0;

    // Aspect ratio correction for distance calculation
    float aspect = uResolution.x / uResolution.y;

    for (int i = 0; i < 5; i++) {
        vec4 ripple = uRipples[i];
        float startTime = ripple.z;
        float power = ripple.w;

        if (startTime > 0.0) {
            float t = uTime - startTime;
            
            // Only calculate if the ripple is alive (e.g., < 2.0 seconds)
            if (t > 0.0 && t < 2.5) {
                vec2 center = ripple.xy;
                
                // Vector from center to current pixel (corrected for aspect)
                vec2 dVec = uv - center;
                dVec.x *= aspect;
                
                float dist = length(dVec);

                // Ripple Logic
                // 1. Expansion speed
                float speed = 0.6;
                float currentRadius = speed * t;
                
                // 2. Wave profile
                // Use a sin wave that decays with distance from its own wavefront center
                float waveWidth = 0.1;
                float distFromWave = dist - currentRadius;
                
                // Gaussian-ish pulse on the ring
                float bump = exp(-pow(distFromWave / waveWidth, 2.0));
                
                // 3. Amplitude decay over time and distance
                float damp = 1.0 / (1.0 + 5.0 * t); // Decay over time
                
                // Calculate final displacement contribution
                // Push pixels outward from center
                float strength = 0.15 * power * bump * damp;
                
                // Direction of displacement
                vec2 dir = normalize(dVec);
                if (dist < 0.001) dir = vec2(0.0); // Safe guard center
                
                displacement -= dir * strength * sin(distFromWave * 50.0);
            }
        }
    }

    vec2 distortedUV = uv + displacement;
    
    // Optional: Chromatic aberration based on displacement strength? 
    // Keeping it simple/premium as requested.
    
    fragColor = texture(uImage, distortedUV);
}
