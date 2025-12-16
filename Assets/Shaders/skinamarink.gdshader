shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

uniform float threshold : hint_range(0.0, 1.0) = 0.4;
uniform float blur_size : hint_range(0.0, 0.02) = 0.002;
uniform float grain_intensity : hint_range(0.0, 0.5) = 0.2;
uniform float grain_blur_size : hint_range(0.0, 100.0) = 5.0;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);

	float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));

	if (brightness < threshold) {
		float darkness_factor = 1.0 - (brightness / threshold);
		float scaled_blur_size = blur_size * darkness_factor;

		vec4 blur_sum = vec4(0.0);
		int count = 0;

		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				vec2 sample_uv = UV + vec2(float(x), float(y)) * scaled_blur_size;

				vec4 sample_color = texture(SCREEN_TEXTURE, sample_uv);

				float sample_brightness = dot(sample_color.rgb, vec3(0.299, 0.587, 0.114));

				if (sample_brightness < threshold) {
					blur_sum += sample_color;
					count++;
				}
			}
		}
		vec4 final_color = (count > 0) ? (blur_sum / float(count)) : color;

		float breath = sin(TIME * 0.6) * 0.008 * darkness_factor;
		final_color.rgb += breath;

		float grain_blur = 0.0;
		int grain_samples = 0;

		float grain_scale = 1.0 + hash(UV * 0.5) * 4.0;

		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				vec2 grain_uv = UV + vec2(float(x), float(y)) * grain_blur_size * grain_scale;
				grain_blur += hash(grain_uv * TIME);
				grain_samples++;
			}
		}

		float grain = (grain_blur / float(grain_samples)) * 2.0 - 1.0;
		float grain_scaled = grain_intensity * pow(darkness_factor, 4.0);

		final_color.rgb += grain * grain_scaled;

		COLOR = final_color;
	}
}