shader_type spatial;
render_mode unshaded;

render_mode blend_mul;
uniform vec4 color : source_color = vec4(0.0);
uniform sampler2D t ;

void fragment() {
	
	vec2 uvOffset = UV + vec2(TIME*0.05,TIME*0.5);
	
	vec4 noise = texture(t,uvOffset);
	
	noise.a = 1.0 - noise.r;
	noise.rgb = color.rgb;
	
	if(noise.a > 0.55){
		noise.rgb = color.rgb;
	}else{
		noise.rgb = vec3(1.0);
	}
	
	ALBEDO = noise.rgb;
}
