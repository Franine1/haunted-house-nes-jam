shader_type canvas_item;

uniform vec4 grey1:source_color;
uniform vec4 col1:source_color;

uniform vec4 grey2:source_color;
uniform vec4 col2:source_color;

uniform vec4 grey3:source_color;
uniform vec4 col3:source_color;

uniform vec4 grey4:source_color;
uniform vec4 col4:source_color;

void fragment() {
	vec4 current_pixel = texture(TEXTURE, UV);
	

	
	if (current_pixel == grey1)
		COLOR = col1;
	else if (current_pixel == grey2)
		COLOR = col2;
	else if (current_pixel == grey3)
		COLOR = col3;
	else if (current_pixel == grey4)
		COLOR = col4;
	else
		COLOR = current_pixel;
		//COLOR = vec4(0.0,0.0,0.0,1.0);
}
