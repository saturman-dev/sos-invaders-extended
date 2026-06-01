shader_type canvas_item;

uniform float hue_offset : hint_range(0, 1) = 0;

// Создаем переменную-мост для передачи цвета из vertex в fragment
varying vec4 modulate_color;

// Функция для конвертации
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Функция для конвертации обратно
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void vertex() {
    // В Godot 4 внутри vertex() переменная COLOR хранит чистый цвет Modulate ноды.
    // Запоминаем его в нашу переменную.
    modulate_color = COLOR;
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec3 hsv = rgb2hsv(color.rgb);
    hsv.x = mod(hsv.x + hue_offset, 1.0); // Сдвигаем только оттенок
    
    vec4 shifted_color = vec4(hsv2rgb(hsv), color.a);
    
    // Умножаем итоговый пиксель на сохраненный цвет модуляции.
    // Теперь твины прозрачности (modulate.a) и цвета будут работать идеально!
    COLOR = shifted_color * modulate_color;
}