shader_type canvas_item;
render_mode unshaded;

uniform float phase = 0.0;
uniform float movement = 0.0;
uniform float strike = 0.0;
uniform float stride = 0.045;
uniform float spectral = 0.0;
uniform float facing = 1.0;
uniform float leg_split = 0.5;
uniform float leg_root = 0.6;
uniform vec4 body_bounds = vec4(0.0, 0.0, 1.0, 1.0);
varying vec4 vertex_tint;

void vertex() {
	vertex_tint = COLOR;
}

void fragment() {
	vec2 extent = max(body_bounds.zw, vec2(0.001));
	vec2 body = (UV - body_bounds.xy) / extent;
	float lower = smoothstep(leg_root, 0.88, UV.y);
	float leg_side = smoothstep(leg_split - 0.025, leg_split + 0.025, UV.x);
	float step_phase = phase + leg_side * 3.14159265;
	vec2 displacement;
	displacement.x = sin(step_phase) * stride * lower * movement;
	displacement.y = -max(0.0, cos(step_phase)) * stride * 0.42 * lower * movement;
	displacement.x = mix(displacement.x, sin(phase + body.y * 4.0) * 0.027 * lower * movement, spectral);
	displacement.y *= 1.0 - spectral;
	float front = facing > 0.0 ? body.x : 1.0 - body.x;
	float arm = smoothstep(0.52, 0.88, front) * smoothstep(0.18, 0.32, body.y) * (1.0 - smoothstep(0.68, 0.82, body.y));
	displacement.x += facing * arm * strike * 0.026;
	displacement.y -= arm * strike * 0.012;
	vec2 sample_uv = UV - displacement * extent;
	vec4 pixel = texture(TEXTURE, sample_uv);
	if (sample_uv.x < 0.0 || sample_uv.x > 1.0 || sample_uv.y < 0.0 || sample_uv.y > 1.0) {
		pixel = vec4(0.0);
	}
	COLOR = pixel * vertex_tint;
}
