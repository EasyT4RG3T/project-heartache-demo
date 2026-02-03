shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
;
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float dot2(vec2 x) {
	return dot(x, x);
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
float param_rndi(float minimum, float maximum, float seed) {
	return floor(param_rnd(minimum, maximum + 1.0, seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
const vec4 p_o19544835896082_albedo_color = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
const float p_o19544835896082_metallic = 0.600000000;
const float p_o19544835896082_roughness = 0.600000000;
const float p_o19544835896082_emission_energy = 1.000000000;
const float p_o19544835896082_normal = 1.000000000;
const float p_o19544835896082_ao = 1.000000000;
const float p_o19544835896082_depth_scale = 0.500000000;
const float p_o19544953334984_amount = 1.490000000;
const float p_o36204628162553_x = 64.000000000;
const float p_o36204628162553_y = 64.000000000;
const float p_o36204628162553_c = 32.000000000;
const float p_o36204628162553_d = 0.500000000;
const float p_o19545775418924_gradient_pos[4] = float[]( 0.000000000, 0.236641228, 0.549618304, 1.000000000 );
const vec4 p_o19545775418924_gradient_col[4] = vec4[]( vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000), vec4(0.568702281, 0.568702281, 0.568702281, 1.000000000), vec4(0.843654573, 0.843654573, 0.843654573, 1.000000000), vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000) );
const float seed_o19544852673381 = 0.039562000;
const float p_o19544852673381_scale_x = 1.000000000;
const float p_o19544852673381_scale_y = 1.000000000;
const float p_o19544852673381_iterations = 4.000000000;
const float p_o19544852673381_persistence = 0.550000000;
const float p_o19544852673381_frequency = 2.000000000;
const float p_o19545725087263_x = 64.000000000;
const float p_o19545725087263_y = 64.000000000;
const float p_o19545725087263_c = 32.000000000;
const float p_o19545725087263_d = 0.500000000;
const float p_o19545758640341_amount1 = 0.500000000;
const vec4 p_o19545741864374_color = vec4(1.000000000, 0.000000000, 0.093750000, 1.000000000);
// #globals: invert (o31959220764832)
// #globals: pixelize_3 (o36204628162553)
float bayer_matrix(vec2 uv, int rounds) {
	ivec2 iuv = ivec2(uv);
	int b[4] = int[4]( 0, 2, 3, 1 );
	float divisor = 1.0;
	int rv = 0;
	for (int i = 0; i < rounds; ++i) {
		rv *= 4;
		divisor *= 4.0;
		rv += b[(iuv.x%2)+2*(iuv.y%2)];
		iuv >>= 1;
	}
	return float(rv)/divisor;
}
// #globals: wavelet_noise2 (o19544852673381)
float wavelet(vec2 uv, vec2 size, float s, float frequency, float offset) {
	uv = mod(uv, size);
	vec2 seed = fract(floor(uv)*0.1236754+vec2(s));
	uv = fract(uv);
	vec2 ruv = uv-0.5;
	float a = rand(seed)*6.28;
	float ca = cos(a);
	float sa = sin(a);
	ruv = vec2(ca*ruv.x + sa*ruv.y, -sa*ruv.x + ca*ruv.y);
	return (0.5*sin(ruv.x*6.28*frequency+offset)+0.5)*max(0.0, 1.0-2.0*length(uv-vec2(0.5)));
}
float wavelet_noise(vec2 uv, vec2 size, int iterations, float persistence, float seed, float frequency, float offset, float type) {
	float rv = 0.0;
	float acc = 0.0;
	vec2 seed2 = rand2(vec2(seed));
	vec2 local_uv = uv * size;
	float q = 1.0;
	for (int i = 0; i < iterations; ++i) {
		rv += q*wavelet(local_uv, size, seed, frequency, offset * 6.28318530718);
		rv += q*wavelet(local_uv+vec2(0.5), size, seed+0.1, frequency, offset * 6.28318530718);
		acc += q;
		if (type > 0.0) {
			local_uv += type*uv;
			size += vec2(type);
		} else {
			local_uv *= -type;
			size *= -type;
		}
		local_uv += seed2; 
		seed2 = rand2(seed2);
		q *= persistence;
		seed += 0.1;
	}
	return rv / acc;
}
// #globals: blend
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
// #globals: adjust_hsv
vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv_to_rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
// #globals: blend2 (o19545758640341)
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
vec3 blend_linear_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
vec3 blend_vivid_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
vec3 blend_pin_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_mix_f(float c1, float c2) {
	return floor(c1 + c2);
}
vec3 blend_hard_mix(vec2 uv, vec3 c1, vec3 c2, float opacity) {
		return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
vec3 blend_exclusion(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hue(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	vec3 outcol = c2;
	vec3 hsv, hsv2, tmp;
	hsv2 = rgb_to_hsv(c1);
	if (hsv2.y != 0.0) {
		hsv = rgb_to_hsv(outcol);
		hsv.x = hsv2.x;
		tmp = hsv_to_rgb(hsv);
		outcol = mix(outcol, tmp, opacity);
	}
	return outcol;
}
vec3 blend_saturation(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	float facm = 1.0 - opacity;
	vec3 outcol = c2;
	vec3 hsv, hsv2;
	hsv = rgb_to_hsv(outcol);
	if (hsv.y != 0.0) {
		hsv2 = rgb_to_hsv(c1);
		hsv.y = facm * hsv.y + opacity * hsv2.y;
		outcol = hsv_to_rgb(hsv);
	}
	return outcol;
}
vec3 blend_color(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	float facm = 1.0 - opacity;
	vec3 outcol = c2;
	vec3 hsv, hsv2, tmp;
	hsv2 = rgb_to_hsv(c1);
	if (hsv2.y != 0.0) {
		hsv = rgb_to_hsv(outcol);
		hsv.x = hsv2.x;
		hsv.y = hsv2.y;
		tmp = hsv_to_rgb(hsv);
		outcol = mix(outcol, tmp, opacity);
	}
	return outcol;
}
vec3 blend_value(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	float facm = 1.0 - opacity;
	vec3 hsv, hsv2;
	hsv = rgb_to_hsv(c2);
	hsv2 = rgb_to_hsv(c1);
	hsv.z = facm * hsv.z + opacity * hsv2.z;
	return hsv_to_rgb(hsv);
}
vec4 o19545775418924_gradient_gradient_fct(float x) {
  if (x < p_o19545775418924_gradient_pos[0]) {
    return p_o19545775418924_gradient_col[0];
  } else if (x < p_o19545775418924_gradient_pos[1]) {
    return mix(p_o19545775418924_gradient_col[0], p_o19545775418924_gradient_col[1], ((x-p_o19545775418924_gradient_pos[0])/(p_o19545775418924_gradient_pos[1]-p_o19545775418924_gradient_pos[0])));
  } else if (x < p_o19545775418924_gradient_pos[2]) {
    return mix(p_o19545775418924_gradient_col[1], p_o19545775418924_gradient_col[2], ((x-p_o19545775418924_gradient_pos[1])/(p_o19545775418924_gradient_pos[2]-p_o19545775418924_gradient_pos[1])));
  } else if (x < p_o19545775418924_gradient_pos[3]) {
    return mix(p_o19545775418924_gradient_col[2], p_o19545775418924_gradient_col[3], ((x-p_o19545775418924_gradient_pos[2])/(p_o19545775418924_gradient_pos[3]-p_o19545775418924_gradient_pos[2])));
  }
  return p_o19545775418924_gradient_col[3];
}
float o19544953334984_input_in(vec2 uv, float _seed_variation_) {
// #code: pixelize_3 (o36204628162553)
vec2 o36204628162553_0_uv = floor(((uv)*vec2(p_o36204628162553_x, p_o36204628162553_y)))+vec2(0.5);
vec3 o36204628162553_0_dither = fract(vec3(dot(vec2(171.0, 231.0), o36204628162553_0_uv))/vec3(103.0, 71.0, 97.0));
// #output0: wavelet_noise2 (o19544852673381)
float o19544852673381_0_1_f = wavelet_noise((o36204628162553_0_uv/vec2(p_o36204628162553_x, p_o36204628162553_y)), vec2(p_o19544852673381_scale_x, p_o19544852673381_scale_y), int(p_o19544852673381_iterations), p_o19544852673381_persistence, (seed_o19544852673381+fract(_seed_variation_)), p_o19544852673381_frequency, (elapsed_time * 0.05), 1);
// #output0: colorize (o19545775418924)
vec4 o19545775418924_0_1_rgba = o19545775418924_gradient_gradient_fct(o19544852673381_0_1_f);
// #output0: pixelize_3 (o36204628162553)
vec3 o36204628162553_0_1_rgb = floor(((o19545775418924_0_1_rgba).rgb)*p_o36204628162553_c+p_o36204628162553_d*(o36204628162553_0_dither))/p_o36204628162553_c;
// #output0: invert (o31959220764832)
vec4 o31959220764832_0_1_rgba = vec4(vec3(1.0)-vec4(o36204628162553_0_1_rgb, 1.0).rgb, vec4(o36204628162553_0_1_rgb, 1.0).a);
return (dot((o31959220764832_0_1_rgba).rgb, vec3(1.0))/3.0);
}
// #instance: normal_map2/edge_detect_1 (o19544953334984)
vec3 nm_o19544953334984(vec2 uv, float amount, float size, float _seed_variation_) {
	vec3 e = vec3(1.0/size, -1.0/size, 0);
	vec2 rv;
	if (3 == 0) {
		rv = vec2(1.0, -1.0)*o19544953334984_input_in((uv+e.xy), _seed_variation_);
		rv += vec2(-1.0, 1.0)*o19544953334984_input_in((uv-e.xy), _seed_variation_);
		rv += vec2(1.0, 1.0)*o19544953334984_input_in((uv+e.xx), _seed_variation_);
		rv += vec2(-1.0, -1.0)*o19544953334984_input_in((uv-e.xx), _seed_variation_);
		rv += vec2(2.0, 0.0)*o19544953334984_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(-2.0, 0.0)*o19544953334984_input_in((uv-e.xz), _seed_variation_);
		rv += vec2(0.0, 2.0)*o19544953334984_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(0.0, -2.0)*o19544953334984_input_in((uv-e.zx), _seed_variation_);
		rv *= size*amount/128.0;
	} else if (3 == 1) {
		rv = vec2(3.0, -3.0)*o19544953334984_input_in((uv+e.xy), _seed_variation_);
		rv += vec2(-3.0, 3.0)*o19544953334984_input_in((uv-e.xy), _seed_variation_);
		rv += vec2(3.0, 3.0)*o19544953334984_input_in((uv+e.xx), _seed_variation_);
		rv += vec2(-3.0, -3.0)*o19544953334984_input_in((uv-e.xx), _seed_variation_);
		rv += vec2(10.0, 0.0)*o19544953334984_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(-10.0, 0.0)*o19544953334984_input_in((uv-e.xz), _seed_variation_);
		rv += vec2(0.0, 10.0)*o19544953334984_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(0.0, -10.0)*o19544953334984_input_in((uv-e.zx), _seed_variation_);
		rv *= size*amount/512.0;
	} else if (3 == 2) {
		rv = vec2(2.0, 0.0)*o19544953334984_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(-2.0, 0.0)*o19544953334984_input_in((uv-e.xz), _seed_variation_);
		rv += vec2(0.0, 2.0)*o19544953334984_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(0.0, -2.0)*o19544953334984_input_in((uv-e.zx), _seed_variation_);
		rv *= size*amount/64.0;
	} else {
		rv = vec2(1.0, 0.0)*o19544953334984_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(0.0, 1.0)*o19544953334984_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(-1.0, -1.0)*o19544953334984_input_in((uv), _seed_variation_);
		rv *= size*amount/20.0;
	}
	return vec3(0.5)+0.5*normalize(vec3(rv, -1.0));
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);

// #output0: normal_map2/edge_detect_1 (o19544953334984)
vec3 o19544953334984_0_1_rgb = nm_o19544953334984((uv), p_o19544953334984_amount, 64.0, _seed_variation_);

// #code: pixelize (o19545725087263)
vec2 o19545725087263_0_uv = floor(((uv)*vec2(p_o19545725087263_x, p_o19545725087263_y)))+vec2(0.5);
vec3 o19545725087263_0_dither = fract(vec3(dot(vec2(171.0, 231.0), o19545725087263_0_uv))/vec3(103.0, 71.0, 97.0));

// #output0: uniform (o19545741864374)
vec4 o19545741864374_0_1_rgba = p_o19545741864374_color;

// #output0: wavelet_noise2 (o19544852673381)
float o19544852673381_0_1_f = wavelet_noise((o19545725087263_0_uv/vec2(p_o19545725087263_x, p_o19545725087263_y)), vec2(p_o19544852673381_scale_x, p_o19544852673381_scale_y), int(p_o19544852673381_iterations), p_o19544852673381_persistence, (seed_o19544852673381+fract(_seed_variation_)), p_o19544852673381_frequency, (elapsed_time * 0.05), 1);

// #output0: colorize (o19545775418924)
vec4 o19545775418924_0_1_rgba = o19545775418924_gradient_gradient_fct(o19544852673381_0_1_f);

// #code: blend2 (o19545758640341)
vec4 o19545758640341_0_b = o19545775418924_0_1_rgba;
vec4 o19545758640341_0_l;
float o19545758640341_0_a;

o19545758640341_0_l = o19545741864374_0_1_rgba;
o19545758640341_0_a = p_o19545758640341_amount1*1.0;
o19545758640341_0_b = vec4(blend_normal((o19545725087263_0_uv/vec2(p_o19545725087263_x, p_o19545725087263_y)), o19545758640341_0_l.rgb, o19545758640341_0_b.rgb, o19545758640341_0_a*o19545758640341_0_l.a), min(1.0, o19545758640341_0_b.a+o19545758640341_0_a*o19545758640341_0_l.a));
// #output0: blend2 (o19545758640341)
vec4 o19545758640341_0_1_rgba = o19545758640341_0_b;

// #output0: pixelize (o19545725087263)
vec3 o19545725087263_0_1_rgb = floor(((o19545758640341_0_1_rgba).rgb)*p_o19545725087263_c+p_o19545725087263_d*(o19545725087263_0_dither))/p_o19545725087263_c;

	vec3 albedo_tex = o19545725087263_0_1_rgb.rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o19544835896082_albedo_color.rgb;
	METALLIC = 1.0*p_o19544835896082_metallic;
	ROUGHNESS = 1.0*p_o19544835896082_roughness;
	NORMAL_MAP = o19544953334984_0_1_rgb;
	NORMAL_MAP_DEPTH = p_o19544835896082_normal;
	EMISSION = vec3(0.0)*p_o19544835896082_emission_energy;
}



