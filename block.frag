#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec4 vertPosition;
varying vec2 uv;
uniform sampler2D tex;
uniform float fogFar;
uniform float fogNear;
uniform vec3 fogColor;
uniform vec3 sunDirection;
uniform vec2 viewportSize;
const float atlasSize = 512.0;
const float atlasItemSize = 16.0;
const float atlasItemUvSize = atlasItemSize / atlasSize;
const float atlasRowSize = atlasSize / atlasItemSize;
const float uvClampFactor = 0.001;

vec2 faceUv(vec2 uv, int face) {
    uv.y = 1.0 - uv.y;
    uv = vec2(clamp(uv.x, uvClampFactor, 1.0 - uvClampFactor), clamp(uv.y, uvClampFactor, 1.0 - uvClampFactor));
    vec2 ruv = vec2(uv * atlasItemUvSize);
    ruv.x += float(face) * atlasItemUvSize;
    ruv.y += floor(float(face) / atlasRowSize) * atlasItemUvSize;
    return ruv;
}

vec3 light(vec3 color) {
    float dp = dot(vertNormal, sunDirection);
    return mix(color, vec3(0), ((dp + 1.0) / 2.0) * 0.75);
}

void main() {
    float z = gl_FragCoord.z / gl_FragCoord.w;
    z += pow(abs(gl_FragCoord.x / viewportSize.x - 0.5), 2.0) * (fogFar / 2.0);

    if (z >= fogFar) {
        gl_FragColor = vec4(fogColor, 1);
        return;
    }

    int face = int(vertColor.r * 256.0 * 256.0) + int(vertColor.g * 256.0);
    vec2 ruv = faceUv(uv, face);
    vec3 color = texture2D(tex, ruv).rgb;
    color = light(color);

    float fogFactor = clamp((fogFar - z) / (fogFar - fogNear), 0.0, 1.0);
    gl_FragColor = vec4(mix(fogColor, color, fogFactor), 1);
}