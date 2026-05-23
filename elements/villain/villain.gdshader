shader_type canvas_item;

uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // 1. Получаем базовый цвет (в COLOR уже сидит текстура * modulate)
    vec4 base_color = COLOR;

    // 2. Считаем силу свечения, учитывая альфа-канал текстуры 
    // (чтобы пустые прозрачные места вокруг астероида не светились белым квадратом)
    vec3 added_glow = flash_color.rgb * flash_modifier * texture(TEXTURE, UV).a;

    // 3. Просто прибавляем свечение к нормальному цвету
    COLOR = vec4(base_color.rgb + added_glow, base_color.a);
}