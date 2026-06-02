shader_type canvas_item;

// --- НАСТРОЙКИ ГРАДИЕНТА ---
uniform vec4 gradient_color1 : source_color = vec4(1.0, 0.9, 0.0, 1.0); // Желтый
uniform vec4 gradient_color2 : source_color = vec4(1.0, 0.4, 0.0, 1.0); // Оранжевый
uniform float gradient_speed : hint_range(0.0, 10.0) = 2.5; 
// Для экранных координат масштаб нужно сделать поменьше (например, от 0.01 до 0.5),
// так как мы считаем в реальных пикселях экрана (1920, 1080 и т.д.)
uniform float gradient_scale : hint_range(0.001, 0.1) = 0.015; 

// --- НАСТРОЙКИ СМЕШИВАНИЯ ---
uniform float blend_strength : hint_range(0.0, 1.0) = 0.6; 
uniform float flash_brightness : hint_range(0.0, 1.0) = 0.0; 

varying vec4 modulate_color;

void vertex() {
    modulate_color = COLOR;
}

void fragment() {
    // 1. Текстуру мы ВСЁ ЕЩЁ читаем по обычному UV, 
    // чтобы сохранить форму врага и его анимацию (альфа-маску и тени)
    vec4 sprite_color = texture(TEXTURE, UV);
    
    // 2. ЛОГИКА ДВИЖЕНИЯ ГРАДИЕНТА (ПЕРЕПИСАНА НА ЭКРАННЫЕ ПИКСЕЛИ)
    float movement = TIME * gradient_speed;
    
    // FRAGCOORD.xy возвращает точные координаты пикселя на экране (например, x=540, y=320).
    // Они монолитны, не зависят от текстур и никогда не трясутся.
    float diagonal_pos = (FRAGCOORD.x + FRAGCOORD.y) * gradient_scale + movement;
    float t = sin(diagonal_pos) * 0.5 + 0.5; 
    
    vec3 grad_rgb = mix(gradient_color1.rgb, gradient_color2.rgb, t);
    
    // 3. Смешивание с сохранением текстуры врага
    vec3 tinted_rgb = sprite_color.rgb * grad_rgb * 1.4;
    vec3 final_rgb = mix(sprite_color.rgb, tinted_rgb, blend_strength);
    
    // 4. Эффект вспышки урона
    final_rgb = mix(final_rgb, vec3(1.0, 1.0, 1.0), flash_brightness);
    
    // 5. Итоговый пиксель
    vec4 final_color = vec4(final_rgb, sprite_color.a);
    COLOR = final_color * modulate_color;
}