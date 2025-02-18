#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform mat4 transform;
uniform mat3 normalMatrix;
uniform vec3 lightNormal;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec4 vertPosition;
varying vec2 uv;

void main() {
    gl_Position = transform * position;
    vertColor = color;
    vertNormal = normal;
    vertLightDir = -lightNormal;
    vertPosition = position;
    uv = texCoord;
}