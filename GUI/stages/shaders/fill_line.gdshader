shader_type canvas_item;

uniform float draw_min : hint_range(0.0, 1.0) = 0.0;
uniform float draw_max : hint_range(0.0, 1.0) = 0.0;
uniform float draw_feather : hint_range(0.0, 1.0) = 0.0;
uniform vec3 color : source_color;

void fragment() {
    float t = COLOR.r;
    COLOR.rgb = color;
    float dt = draw_feather + fwidth(t);
    float v = smoothstep(draw_max + dt, draw_max, t);
    v -=  smoothstep(draw_min, draw_min - dt, t);
    COLOR.a = v;
}