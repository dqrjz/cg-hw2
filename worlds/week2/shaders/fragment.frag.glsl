#version 300 es        // NEWER VERSION OF GLSL
precision highp float; // HIGH PRECISION FLOATS

uniform float uTime;   // TIME, IN SECONDS
in vec3 vPos;          // POSITION IN IMAGE
out vec4 fragColor;    // RESULT WILL GO HERE

const int NS = 3; // Number of spheres in the scene
const int NL = 3; // Number of light sources in the scene
const float FL = 5.; // Focal length
const vec3 BG_COLOR = vec3(0., 0., 0.); // background color (default: black)

// Declarations of arrays for spheres, lights and phong shading:
vec3 Ldir[NL], Lcol[NL], Ambient[NS], Diffuse[NS];
vec4 Sphere[NS], Specular[NS];

// Function that finds the distance along a ray to a sphere
float raySphere(vec3 V, vec3 W, vec4 S) {
    vec3 Vp = V - S.xyz;
    float delta = dot(W, Vp) * dot(W, Vp) - dot(Vp, Vp) + S.w * S.w;
    if (delta < 0.) {
        return -1.;
    }
    float t;
    if (delta == 0.) {
        t = - dot(W, Vp);
    } else {
        t = - dot(W, Vp) - sqrt(delta);
    }
    if (t < 0.) {
        return -1.;
    } else {
        return t;
    }
}

// Function that checks whether the point is in shadow from any other sphere in the scene
bool isInShadow(vec3 P, vec3 L){
    for (int i = 0; i < NS; i++) {
        if (raySphere(P, L, Sphere[i]) > 0.001) {
            return true;
        }
    }
    return false;
}

void main() {
    // SET THE VALUES OF THE SPHERES AND LIGHTS
    Ldir[0] = normalize(vec3(1.,.5,.5));
    Lcol[0] = vec3(1.,1.,1.);

    Ldir[1] = normalize(vec3(-1.,0.,-2.));
    Lcol[1] = vec3(.1,.07,.05);

    Ldir[2] = normalize(vec3(-.5,-.5,.3));
    Lcol[2] = vec3(.9,0.,.9);

    Sphere[0]   = vec4(.2,0.,.1,.5);
    Ambient[0]  = vec3(0.,.1,.1);
    Diffuse[0]  = vec3(0.,.5,.5);
    Specular[0] = vec4(0.,1.,1.,10.); // 4th value is specular power

    Sphere[1]   = vec4(-.4,.4,-.1,.3);
    Ambient[1]  = vec3(.1,.1,0.);
    Diffuse[1]  = vec3(.5,.5,0.);
    Specular[1] = vec4(1.,1.,1.,20.); // 4th value is specular power

    Sphere[2]   = vec4(-.4,-.4,.5,.2);
    Ambient[2]  = vec3(.1,.1,0.);
    Diffuse[2]  = vec3(.5,.5,0.);
    Specular[2] = vec4(1.,1.,1.,20.); // 4th value is specular power

    // RAY TRACE
    vec3 N, P;
    vec3 V = vec3(0., 0., FL);
    vec3 W = normalize(vec3(vPos.xy, -FL));
    float tMin = 1000.;
    float t;
    int Si = -1;
    for (int i = 0; i < NS; i++) {
        t = raySphere(V, W, Sphere[i]);
        if (t > 0. && t < tMin) {
            P = V + t * W;
            N = normalize(P - Sphere[i].xyz);
            tMin = t;
            Si = i;
        }
    }

    // PHONG SHADING
    vec3 color;
    if (Si == -1) {
        color = BG_COLOR; 
    } else {
        color = Ambient[Si];
        vec3 R;
        for (int i = 0; i < NL; i++) {
            R = 2. * dot(N, Ldir[i]) * N - Ldir[i];
            if (!isInShadow(P, Ldir[i])) {
                color += Lcol[i] * (Diffuse[Si] * max(0., dot(N, Ldir[i])));
                color += Lcol[i] * (Specular[Si].xyz * pow(max(0., dot(-W, R)), Specular[Si].w));
            }
        }
    }

    fragColor = vec4(sqrt(color), 1.0);
}
