shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.0);

void fragment() {
	
	vec2 uvOffset = UV + vec2(TIME*0.05,TIME*0.04);
	
	vec4 noise = texture(TEXTURE,uvOffset);

	
	COLOR = noise;
}
