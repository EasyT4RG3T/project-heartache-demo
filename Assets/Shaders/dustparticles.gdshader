shader_type spatial;
render_mode cull_back, blend_mix, shadows_disabled, vertex_lighting;


void fragment() {
	ALPHA = COLOR.a * 0.75;
}


//void light() {
//	DIFFUSE_LIGHT += ATTENUATION;
//	if (length(DIFFUSE_LIGHT) <= 0.0) {
//		ALPHA = 0.0;
//	}
//	else {
//		DIFFUSE_LIGHT = vec3(1, 1, 1);
//		ALPHA *= 0.75;
//	}
//}