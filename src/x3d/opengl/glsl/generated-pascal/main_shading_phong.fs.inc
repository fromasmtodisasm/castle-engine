{ -*- buffer-read-only: t -*- }
{ DON'T EDIT -- this file was automatically generated from "source/main_shading_phong.fs" }
'/* Phong shading GLSL fragment shader.' + LineEnding +
'   Used by ../castlerendererinternalshader.pas to construct the final shader.' + LineEnding +
'   When you change this file, rerun `make'' and then recompile Pascal sources.' + LineEnding +
'*/' + LineEnding +
'' + LineEnding +
'#ifdef GL_ES' + LineEnding +
'precision mediump float;' + LineEnding +
'#endif' + LineEnding +
'' + LineEnding +
'/* PLUG-DECLARATIONS */' + LineEnding +
'' + LineEnding +
'#ifdef HAS_GEOMETRY_SHADER' + LineEnding +
'  #define castle_vertex_eye castle_vertex_eye_geoshader' + LineEnding +
'  #define castle_normal_eye castle_normal_eye_geoshader' + LineEnding +
'#endif' + LineEnding +
'' + LineEnding +
'varying vec4 castle_vertex_eye;' + LineEnding +
'varying vec3 castle_normal_eye;' + LineEnding +
'' + LineEnding +
'#ifdef COLOR_PER_VERTEX' + LineEnding +
'varying vec4 castle_ColorPerVertexFragment;' + LineEnding +
'#endif' + LineEnding +
'' + LineEnding +
'/* Include fragment shader utilities used by both Gouraud and Phong shading. */' + LineEnding +
'/* CASTLE-COMMON-CODE */' + LineEnding +
'' + LineEnding +
'void main_texture_apply(inout vec4 fragment_color,' + LineEnding +
'  const in vec3 normal_eye)' + LineEnding +
'{' + LineEnding +
'  /* PLUG: main_texture_apply (fragment_color, normal_eye) */' + LineEnding +
'  /* PLUG: texture_apply (fragment_color, normal_eye) */ // deprecated' + LineEnding +
'}' + LineEnding +
'' + LineEnding +
'/* CASTLE-LIGHTING-MODEL */' + LineEnding +
'' + LineEnding +
'void main(void)' + LineEnding +
'{' + LineEnding +
'  vec3 normal_eye_fragment = normalize(castle_normal_eye);' + LineEnding +
'' + LineEnding +
'#ifndef CASTLE_BUGGY_FRONT_FACING' + LineEnding +
'  if (gl_FrontFacing)' + LineEnding +
'    /* Avoid AMD bug http://forums.amd.com/devforum/messageview.cfm?catid=392&threadid=148827&enterthread=y' + LineEnding +
'       Observed on fglrx (proprietary ATI Linux driver),' + LineEnding +
'       with ATI Mobility Radeon HD 4300 (castle computer "czarny"),' + LineEnding +
'       since Ubuntu 11.4 (fglrx OpenGL version 3.3.10665).' + LineEnding +
'' + LineEnding +
'       It causes both (gl_FrontFacing) and (!gl_FrontFacing) to be true...' + LineEnding +
'       To minimize the number of problems, never use "if (!gl_FrontFacing)",' + LineEnding +
'       only "if (gl_FrontFacing)".' + LineEnding +
'' + LineEnding +
'       See also https://makc3d.wordpress.com/2015/09/17/alternative-to-gl_frontfacing/ ,' + LineEnding +
'       gl_FrontFacing seems unreliable sometimes.' + LineEnding +
'    */ ; else' + LineEnding +
'    normal_eye_fragment = -normal_eye_fragment;' + LineEnding +
'#endif' + LineEnding +
'' + LineEnding +
'  /* PLUG: fragment_eye_space (castle_vertex_eye, normal_eye_fragment) */' + LineEnding +
'' + LineEnding +
'  vec4 fragment_color;' + LineEnding +
'  calculate_lighting(fragment_color, castle_vertex_eye, normal_eye_fragment);' + LineEnding +
'' + LineEnding +
'  /* PLUG: lighting_apply (fragment_color, castle_vertex_eye, normal_eye_fragment) */' + LineEnding +
'  /* PLUG: steep_parallax_shadow_apply (fragment_color) */' + LineEnding +
'  /* PLUG: fog_apply (fragment_color, normal_eye_fragment) */' + LineEnding +
'' + LineEnding +
'  /* NVidia GeForce 450 GTS (kocury) fails to compile a shader when' + LineEnding +
'     we pass gl_FragColor as inout parameter to functions' + LineEnding +
'     (testcase even fresnel_and_toon.x3dv).' + LineEnding +
'     Although on Radeon X1600 (fglrx, chantal) it works OK.' + LineEnding +
'     So we just use fragment_color everywhere above, and only assign it' + LineEnding +
'     to gl_FragColor at the end. */' + LineEnding +
'  gl_FragColor = fragment_color;' + LineEnding +
'' + LineEnding +
'  /* PLUG: fragment_end (gl_FragColor) */' + LineEnding +
'}' + LineEnding +
''
