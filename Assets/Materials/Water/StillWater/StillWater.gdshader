shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
,depth_draw_opaque
;
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5);
}
const vec4 p_o634061335912_albedo_color = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
const float p_o634061335912_metallic = 0.000000000;
const float p_o634061335912_roughness = 0.200000000;
const float p_o634061335912_emission_energy = 1.000000000;
const float p_o634061335912_normal = 1.000000000;
const float p_o6655253165027_gradient_pos[2] = float[]( 0.000000000, 1.000000000 );
const vec4 p_o6655253165027_gradient_col[2] = vec4[]( vec4(0.850000024, 0.850000024, 0.850000024, 1.000000000), vec4(0.500000000, 0.500000000, 0.500000000, 1.000000000) );
const float p_o634094887035_x = 64.000000000;
const float p_o634094887035_y = 64.000000000;
const float p_o634094887035_c = 32.000000000;
const float p_o634094887035_d = 0.500000000;
const float p_o634128443605_amount1 = 0.500000000;
const vec4 p_o634111664281_color = vec4(0.496000022, 0.683466613, 0.800000012, 1.000000000);
const float p_o635218963811_gradient_pos[2] = float[]( 0.000000000, 1.000000000 );
const vec4 p_o635218963811_gradient_col[2] = vec4[]( vec4(0.699999988, 0.699999988, 0.699999988, 1.000000000), vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000) );
const float seed_o635437067591 = 0.000000000;
const float p_o635437067591_scale_x = 2.000000000;
const float p_o635437067591_scale_y = 2.000000000;
const float p_o635437067591_folds = 0.000000000;
const float p_o635437067591_iterations = 5.000000000;
const float p_o635437067591_persistence = 0.790000000;
const float p_o634229108071_amount = 0.250000000;
const float p_o635000859985_gradient_pos[2] = float[]( 0.008771930, 0.629288495 );
const vec4 p_o635000859985_gradient_col[2] = vec4[]( vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000), vec4(0.300000012, 0.300000012, 0.300000012, 1.000000000) );
// #globals: colorize_3 (o6655253165027)
// #globals: pixelize (o634094887035)
// #globals: blend
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
// #globals: blend2 (o634128443605)
// #globals: fbm3 (o635437067591)
float fbm_2d_mod289(float x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
float fbm_2d_permute(float x) {
	return fbm_2d_mod289(((x * 34.0) + 1.0) * x);
}
vec2 fbm_2d_rgrad2(vec2 p, float rot, float seed) {
	float u = fbm_2d_permute(fbm_2d_permute(p.x) + p.y) * 0.0243902439 + rot; // Rotate by shift
	u = fract(u+seed) * 6.28318530718; // 2*pi
	return vec2(cos(u), sin(u));
}
float simplex_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	coord *= 2.0; // needed for it to tile
	coord += rand2(vec2(seed, 1.0-seed)) + size;
	size *= 2.0; // needed for it to tile
	coord.y += 0.001;
	vec2 uv = vec2(coord.x + coord.y*0.5, coord.y);
	vec2 i0 = floor(uv);
	vec2 f0 = fract(uv);
	vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
	vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
	vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
	i1 = i0 + i1;
	vec2 d0 = coord - p0;
	vec2 d1 = coord - p1;
	vec2 d2 = coord - p2;
	vec3 xw = mod(vec3(p0.x, p1.x, p2.x), size.x);
	vec3 yw = mod(vec3(p0.y, p1.y, p2.y), size.y);
	vec3 iuw = xw + 0.5 * yw;
	vec3 ivw = yw;
	vec2 g0 = fbm_2d_rgrad2(vec2(iuw.x, ivw.x), offset, seed);
	vec2 g1 = fbm_2d_rgrad2(vec2(iuw.y, ivw.y), offset, seed);
	vec2 g2 = fbm_2d_rgrad2(vec2(iuw.z, ivw.z), offset, seed);
	vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
	vec3 t = 0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2));
	t = max(t, vec3(0.0));
	vec3 t2 = t * t;
	vec3 t4 = t2 * t2;
	float n = dot(t4, w);
	return 0.5 + 5.5 * n;
}
float fbm_2d_simplex(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = simplex_noise_2d(coord*size, size, offset, seed+float(i));
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
vec4 o6655253165027_gradient_gradient_fct(float x) {
  if (x < p_o6655253165027_gradient_pos[0]) {
    return p_o6655253165027_gradient_col[0];
  } else if (x < p_o6655253165027_gradient_pos[1]) {
    return mix(p_o6655253165027_gradient_col[0], p_o6655253165027_gradient_col[1], ((x-p_o6655253165027_gradient_pos[0])/(p_o6655253165027_gradient_pos[1]-p_o6655253165027_gradient_pos[0])));
  }
  return p_o6655253165027_gradient_col[1];
}
vec4 o635218963811_gradient_gradient_fct(float x) {
  if (x < p_o635218963811_gradient_pos[0]) {
    return p_o635218963811_gradient_col[0];
  } else if (x < p_o635218963811_gradient_pos[1]) {
    return mix(p_o635218963811_gradient_col[0], p_o635218963811_gradient_col[1], ((x-p_o635218963811_gradient_pos[0])/(p_o635218963811_gradient_pos[1]-p_o635218963811_gradient_pos[0])));
  }
  return p_o635218963811_gradient_col[1];
}
float o634229108071_input_in(vec2 uv, float _seed_variation_) {
// #code: pixelize (o634094887035)
vec2 o634094887035_0_uv = floor((uv*vec2(p_o634094887035_x, p_o634094887035_y)))+vec2(0.5);
vec3 o634094887035_0_dither = fract(vec3(dot(vec2(171.0, 231.0), o634094887035_0_uv))/vec3(103.0, 71.0, 97.0));
// #output0: uniform (o634111664281)
vec4 o634111664281_0_1_rgba = p_o634111664281_color;
// #output0: fbm3 (o635437067591)
float o635437067591_0_1_f = fbm_2d_simplex((o634094887035_0_uv/vec2(p_o634094887035_x, p_o634094887035_y)), vec2(p_o635437067591_scale_x, p_o635437067591_scale_y), int(p_o635437067591_folds), int(p_o635437067591_iterations), p_o635437067591_persistence, (elapsed_time * 0.3), (seed_o635437067591+fract(_seed_variation_)));
// #output0: colorize_2 (o635218963811)
vec4 o635218963811_0_1_rgba = o635218963811_gradient_gradient_fct(o635437067591_0_1_f);
// #code: blend2 (o634128443605)
vec4 o634128443605_0_b = o635218963811_0_1_rgba;
vec4 o634128443605_0_l;
float o634128443605_0_a;
o634128443605_0_l = o634111664281_0_1_rgba;
o634128443605_0_a = p_o634128443605_amount1*1.0;
o634128443605_0_b = vec4(blend_normal((o634094887035_0_uv/vec2(p_o634094887035_x, p_o634094887035_y)), o634128443605_0_l.rgb, o634128443605_0_b.rgb, o634128443605_0_a*o634128443605_0_l.a), min(1.0, o634128443605_0_b.a+o634128443605_0_a*o634128443605_0_l.a));
// #output0: blend2 (o634128443605)
vec4 o634128443605_0_1_rgba = o634128443605_0_b;
// #output0: pixelize (o634094887035)
vec3 o634094887035_0_1_rgb = floor(((o634128443605_0_1_rgba).rgb)*p_o634094887035_c+p_o634094887035_d*(o634094887035_0_dither))/p_o634094887035_c;
return (dot(o634094887035_0_1_rgb, vec3(1.0))/3.0);
}
// #instance: normal_map2/edge_detect_1 (o634229108071)
vec3 nm_o634229108071(vec2 uv, float amount, float size, float _seed_variation_) {
	vec3 e = vec3(1.0/size, -1.0/size, 0);
	vec2 rv;
	if (3 == 0) {
		rv = vec2(1.0, -1.0)*o634229108071_input_in((uv+e.xy), _seed_variation_);
		rv += vec2(-1.0, 1.0)*o634229108071_input_in((uv-e.xy), _seed_variation_);
		rv += vec2(1.0, 1.0)*o634229108071_input_in((uv+e.xx), _seed_variation_);
		rv += vec2(-1.0, -1.0)*o634229108071_input_in((uv-e.xx), _seed_variation_);
		rv += vec2(2.0, 0.0)*o634229108071_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(-2.0, 0.0)*o634229108071_input_in((uv-e.xz), _seed_variation_);
		rv += vec2(0.0, 2.0)*o634229108071_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(0.0, -2.0)*o634229108071_input_in((uv-e.zx), _seed_variation_);
		rv *= size*amount/128.0;
	} else if (3 == 1) {
		rv = vec2(3.0, -3.0)*o634229108071_input_in((uv+e.xy), _seed_variation_);
		rv += vec2(-3.0, 3.0)*o634229108071_input_in((uv-e.xy), _seed_variation_);
		rv += vec2(3.0, 3.0)*o634229108071_input_in((uv+e.xx), _seed_variation_);
		rv += vec2(-3.0, -3.0)*o634229108071_input_in((uv-e.xx), _seed_variation_);
		rv += vec2(10.0, 0.0)*o634229108071_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(-10.0, 0.0)*o634229108071_input_in((uv-e.xz), _seed_variation_);
		rv += vec2(0.0, 10.0)*o634229108071_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(0.0, -10.0)*o634229108071_input_in((uv-e.zx), _seed_variation_);
		rv *= size*amount/512.0;
	} else if (3 == 2) {
		rv = vec2(2.0, 0.0)*o634229108071_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(-2.0, 0.0)*o634229108071_input_in((uv-e.xz), _seed_variation_);
		rv += vec2(0.0, 2.0)*o634229108071_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(0.0, -2.0)*o634229108071_input_in((uv-e.zx), _seed_variation_);
		rv *= size*amount/64.0;
	} else {
		rv = vec2(1.0, 0.0)*o634229108071_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(0.0, 1.0)*o634229108071_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(-1.0, -1.0)*o634229108071_input_in((uv), _seed_variation_);
		rv *= size*amount/20.0;
	}
	return vec3(0.5)+0.5*normalize(vec3(rv, -1.0));
}
vec4 o635000859985_gradient_gradient_fct(float x) {
  if (x < p_o635000859985_gradient_pos[0]) {
    return p_o635000859985_gradient_col[0];
  } else if (x < p_o635000859985_gradient_pos[1]) {
    return mix(p_o635000859985_gradient_col[0], p_o635000859985_gradient_col[1], ((x-p_o635000859985_gradient_pos[0])/(p_o635000859985_gradient_pos[1]-p_o635000859985_gradient_pos[0])));
  }
  return p_o635000859985_gradient_col[1];
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);

// #code: pixelize (o634094887035)
vec2 o634094887035_0_uv = floor(((uv)*vec2(p_o634094887035_x, p_o634094887035_y)))+vec2(0.5);
vec3 o634094887035_0_dither = fract(vec3(dot(vec2(171.0, 231.0), o634094887035_0_uv))/vec3(103.0, 71.0, 97.0));

// #output0: uniform (o634111664281)
vec4 o634111664281_0_1_rgba = p_o634111664281_color;

// #output0: fbm3 (o635437067591)
float o635437067591_0_1_f = fbm_2d_simplex((o634094887035_0_uv/vec2(p_o634094887035_x, p_o634094887035_y)), vec2(p_o635437067591_scale_x, p_o635437067591_scale_y), int(p_o635437067591_folds), int(p_o635437067591_iterations), p_o635437067591_persistence, (elapsed_time * 0.3), (seed_o635437067591+fract(_seed_variation_)));

// #output0: colorize_2 (o635218963811)
vec4 o635218963811_0_1_rgba = o635218963811_gradient_gradient_fct(o635437067591_0_1_f);

// #code: blend2 (o634128443605)
vec4 o634128443605_0_b = o635218963811_0_1_rgba;
vec4 o634128443605_0_l;
float o634128443605_0_a;

o634128443605_0_l = o634111664281_0_1_rgba;
o634128443605_0_a = p_o634128443605_amount1*1.0;
o634128443605_0_b = vec4(blend_normal((o634094887035_0_uv/vec2(p_o634094887035_x, p_o634094887035_y)), o634128443605_0_l.rgb, o634128443605_0_b.rgb, o634128443605_0_a*o634128443605_0_l.a), min(1.0, o634128443605_0_b.a+o634128443605_0_a*o634128443605_0_l.a));
// #output0: blend2 (o634128443605)
vec4 o634128443605_0_1_rgba = o634128443605_0_b;

// #output0: pixelize (o634094887035)
vec3 o634094887035_0_1_rgb = floor(((o634128443605_0_1_rgba).rgb)*p_o634094887035_c+p_o634094887035_d*(o634094887035_0_dither))/p_o634094887035_c;

// #output0: colorize_3 (o6655253165027)
vec4 o6655253165027_0_1_rgba = o6655253165027_gradient_gradient_fct((dot(o634094887035_0_1_rgb, vec3(1.0))/3.0));

// #output0: normal_map2/edge_detect_1 (o634229108071)
vec3 o634229108071_0_1_rgb = nm_o634229108071((uv), p_o634229108071_amount, 64.0, _seed_variation_);

// #output0: colorize (o635000859985)
vec4 o635000859985_0_1_rgba = o635000859985_gradient_gradient_fct((dot(o634094887035_0_1_rgb, vec3(1.0))/3.0));

	vec3 albedo_tex = o634094887035_0_1_rgb.rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o634061335912_albedo_color.rgb;
	METALLIC = 1.0*p_o634061335912_metallic;
	ROUGHNESS = (dot((o635000859985_0_1_rgba).rgb, vec3(1.0))/3.0)*p_o634061335912_roughness;
	NORMAL_MAP = o634229108071_0_1_rgb;
	NORMAL_MAP_DEPTH = p_o634061335912_normal;
	EMISSION = vec3(0.0)*p_o634061335912_emission_energy;
	ALPHA = (dot((o6655253165027_0_1_rgba).rgb, vec3(0.5))/3.0);
}



