#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec4 vertPosition;
varying vec2 uv;
const int BLOCK_FACES = 6;
const int MAX_BLOCK_TYPES = 64;
uniform sampler2D tex;
uniform int faces[BLOCK_FACES*MAX_BLOCK_TYPES];
uniform float fogFar;
uniform float fogNear;
const float atlasSize = 512.0;
const float atlasItemSize = 16.0;
const float atlasItemUvSize = atlasItemSize / atlasSize;
const float uvClampFactor = 0.001;

vec2 faceUv(vec2 uv, int face, int offset) {
    uv -= vec2(offset);
    uv.y = 1.0 - uv.y;
    uv = vec2(clamp(uv.x, uvClampFactor, 1.0 - uvClampFactor), clamp(uv.y, uvClampFactor, 1.0 - uvClampFactor));
    vec2 ruv = vec2(uv * atlasItemUvSize);
    ruv.x += float(face) * atlasItemUvSize;
    return ruv;
}

void main() {
    vec2 ruv;
    float totalUV = uv.x + uv.y;
    int blockId = int(vertColor.r * 256.0);
    int faceOffset = blockId * BLOCK_FACES;

    if (vertNormal.y > 0.99) ruv = faceUv(uv, faces[0 + faceOffset], blockId);
    else if (vertNormal.y < -0.99) ruv = faceUv(uv, faces[1 + faceOffset], blockId);
    else if (vertNormal.x > 0.99) ruv = faceUv(uv, faces[2 + faceOffset], blockId);
    else if (vertNormal.x < -0.99) ruv = faceUv(uv, faces[3 + faceOffset], blockId);
    else if (vertNormal.z > 0.99) ruv = faceUv(uv, faces[4 + faceOffset], blockId);
    else if (vertNormal.z < -0.99) ruv = faceUv(uv, faces[5 + faceOffset], blockId);

    vec3 color = texture2D(tex, ruv).rgb;
    float z = gl_FragCoord.z / gl_FragCoord.w;
    float fogFactor = clamp((fogFar - z) / (fogFar - fogNear), 0.0, 1.0);
    gl_FragColor = mix(vec4(1, 1, 1, 1), vec4(color, 1), fogFactor);
}