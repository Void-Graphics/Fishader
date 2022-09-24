#version 120

#define goalHue 40.0 // the desired hue to display [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200 220 230 240 250 260 270 280 290 300 310 320 330 340 350]
#define wiggle 20 // wiggle room [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 115 120 125 130 135 140 145 150 155 160 165 170 175 180 185 190 195 200 220 230 240 250 260 270 280 290 300 310 320 330 340 350]
//#define BLACKEN // Whether or not to blacken the background
//#define TRITANOPIA // Use the other method (fake tritanopia)

uniform sampler2D gcolor;

varying vec2 texcoord;

// All components are in the range [0…1], including hue.
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
	float mask;
	vec3 ogRGB = texture2D(gcolor, texcoord).rgb;
	vec3 black = vec3(0, 0, 0);
	vec3 ogHSV = rgb2hsv(ogRGB).xyz;
	float hue = 360*ogHSV.x;
	if(goalHue < wiggle || goalHue > (360 - wiggle)) {
		mask = (hue < mod(goalHue + wiggle, 360) || hue > mod(goalHue - wiggle, 360)) ? 1 : 0;
	} else {
		mask = (hue < mod(goalHue + wiggle, 360) && hue > mod(goalHue - wiggle, 360)) ? 1 : 0;
	}
	float newMask = 1 - mask;
	#ifdef BLACKEN
		vec3 test = vec3(hue/360, ogHSV.y * newMask, ogHSV.z*newMask*ogHSV.y);
	#else
		vec3 test = vec3(hue/360, ogHSV.y * newMask, ogHSV.z);
	#endif
	// if(effect == 1) {
	// 	vec3 test = vec3(hue/360, ogHSV.y * mask, ogHSV.z*mask*ogHSV.y);
	// } else {
	// 	vec3 test = vec3(hue/360, ogHSV.y * mask, ogHSV.z);
	// }
	vec3 exitHSV = hsv2rgb(test).rgb;
	vec4 toVec4 = vec4(exitHSV, 1);

	// vec3 otherthing = vec3(((ogRGB.r+ogRGB.g+ogRGB.b)/3-(1-ogRGB.b)+ogRGB.r+ogRGB.g),0, 0);
	vec4 whereyellow = vec4(((ogRGB.r+ogRGB.g+ogRGB.b)/3-ogRGB.b),((ogRGB.r+ogRGB.g+ogRGB.b)/3-ogRGB.b),((ogRGB.r+ogRGB.g+ogRGB.b)/3-ogRGB.b),1);
	vec4 whereyellow2 = vec4(whereyellow.xyz*2,1);
	vec3 otherthing = vec3(ogRGB.r-clamp(whereyellow.x,0,1),ogRGB.g-clamp(whereyellow.x,0,1),ogRGB.b+clamp(whereyellow.x,0,1));
	vec4 othervec4 = vec4(otherthing, 1);

	#ifdef TRITANOPIA
		vec4 finalOut = othervec4;
	#else
		vec4 finalOut = toVec4;
	#endif
	

/* DRAWBUFFERS:0 */
	gl_FragData[0] = finalOut; //gcolor
}

