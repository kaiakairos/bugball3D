shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.0);

void fragment() {
	
	vec2 uvOffset = UV + vec2(TIME*0.005,TIME*-0.002);
	
	vec4 noise = texture(TEXTURE,uvOffset);
	
	noise.a = 1.0 - noise.r;
	noise.rgb = color.rgb;
	
	if(noise.a > 0.55){
		noise.a = color.a;
	}else{
		noise.a = 0.0;
	}
	
	COLOR = noise;
}
