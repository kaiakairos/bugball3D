// CC0 licence
// Credit Bramwell Williams

shader_type canvas_item;

uniform float circle_size : hint_range(0,1) = 0.5;
uniform vec2 retard = vec2(0.5,0.5);

void fragment(){
	if (distance(retard, UV) < circle_size){
		COLOR.a = 0.0;
	}
}