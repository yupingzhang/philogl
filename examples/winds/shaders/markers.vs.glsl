#define PI2 1.5707963267949

attribute vec3 position;
attribute vec2 texCoord1;

uniform mat4 worldMatrix;
uniform mat4 projectionMatrix;
uniform sampler2D sampler1;

uniform float lat;
uniform float lon;
uniform vec3 data;

varying vec2 vTexCoord;
varying vec3 vColor;

float getHue(vec4 sampling) {
  float r = sampling.r;
  float g = sampling.g;
  float b = sampling.b;
  float maxComp = max( max(r, g), b);
  float minComp = min( min(r, g), b);
  float c = maxComp - minComp;
  float hue;
  if (c <= 0.01) {
      hue = -1.;
  } else {
    if (maxComp == r) {
      hue = mod((g - b) / c, 6.);
    } else if (maxComp == g) {
      hue = (b - r) / c + 2.;
    } else {
      hue = (r - g) / c + 4.;
    }
    hue *= 60.; //hue [0, 360)
  }
  return hue;
}

vec3 getRGB(float h, float s, float v) {
  float c = v * s;
  float hp = h / 60.;
  float x = c * (1. - abs( mod(hp, 2.) - 1. ));
  vec3 rgbp;

  if (h < 1.) {
    rgbp = vec3(c, x, 0);
  } else if (h < 2.) {
    rgbp = vec3(x, c, 0);
  } else if (h < 3.) {
    rgbp = vec3(0, c, x);
  } else if (h < 4.) {
    rgbp = vec3(0, x, c);
  } else if (h < 5.) {
    rgbp = vec3(x, 0, c);
  } else {
    rgbp = vec3(c, 0, x);
  }

  float m = v - c;

  return rgbp + vec3(m);
}

void main(void) {
  vec3 pos = vec3(lon, lat, 0);

  float scale = data.y / 300.;
  float h = data.z / 250.;

  const float offset = (4096. - 3764.) / 2. * (1. / 4096.);
  const float fromy = 25.;
  const float toy = 50.;
  const float fromx = 65.;
  const float tox = 125.;

  const float fromyt = -0.25;
  const float toyt = 0.25;
  const float fromxt = 0.5 - offset;
  const float toxt = -0.5 + offset;

  pos.x  = (pos.x - fromx) / (tox - fromx) * (toxt - fromxt) + fromxt;
  pos.y  = (pos.y - fromy) / (toy - fromy) * (toyt - fromyt) + fromyt;
  
  vec4 sampling = texture2D(sampler1, vec2(pos.x + 0.5, pos.y + 0.25 * 2.));
  float hue = getHue(sampling);
  
  if (hue == -1.) {
      pos.z = -.01;
  } else {
    float z;
    if (texCoord1.s <= 0.5 && texCoord1.s >= 0.25) {
      z = mod((360. - hue - 5.), 360.);
    } else {
      z = mod((360. - hue + 2.), 360.);
    }
    if (z < 0.) {
      z += 360.;
    }
    pos.z = exp(z / 3600.) -1.01;
  }
  
  pos.z += .01;

  pos = vec3(position.xy * scale, 0) + pos;

  vTexCoord = texCoord1;
  vColor = getRGB((1. - h) * 360., .8, .8);
  gl_Position = projectionMatrix * worldMatrix * vec4(pos, 1);
}



