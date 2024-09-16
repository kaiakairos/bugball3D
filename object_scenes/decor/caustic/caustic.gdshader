shader_type canvas_item;

uniform vec4 color : source_color = vec4(0.0);
uniform vec4 outline : source_color = vec4(0.0);
uniform sampler2D screen : hint_screen_texture;

void fragment() {
	
	vec2 uvOffset = UV + vec2(TIME*0.005,TIME*-0.002);
	
	vec4 noise = texture(TEXTURE,uvOffset);
	
	vec4 brown = abs((noise * vec4(2)) - vec4(1));
	brown.rgb *= 3.6;
	brown.rgb = vec3(1) - brown.rgb;
	
	
	
	vec4 poop = texture(screen,SCREEN_UV);
	
	vec4 crap = outline;
	crap.a *= brown.r;
	vec4 shit = color;
	shit.rgb += vec3(crap.a) - vec3(1);
	COLOR = crap;
}
