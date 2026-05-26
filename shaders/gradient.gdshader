shader_type canvas_item;

// --- НАСТРОЙКИ ГРАДИЕНТА ---
uniform vec4 gradient_color1 : source_color = vec4(1.0, 0.9, 0.0, 1.0); // Желтый
uniform vec4 gradient_color2 : source_color = vec4(1.0, 0.4, 0.0, 1.0); // Оранжевый
uniform float gradient_speed : hint_range(0.0, 10.0) = 2.5; 
uniform float gradient_scale : hint_range(0.1, 10.0) = 1.5; 

// --- НАСТРОЙКИ СМЕШИВАНИЯ ---
uniform float blend_strength : hint_range(0.0, 1.0) = 0.6; 
uniform float flash_brightness : hint_range(0.0, 1.0) = 0.0; 

void fragment() {
 // Вытаскиваем ТОЛЬКО альфа-канал модулейта (управление прозрачностью из Твинов/Инспектора)
 float node_alpha = COLOR.a;

 // 1. Берем чистый базовый пиксель текстуры (без сторонних искажений цвета)
 vec4 sprite_color = texture(TEXTURE, UV);
	
 // 2. Логика движения градиента
 float movement = TIME * gradient_speed;
 float diagonal_pos = (UV.x + UV.y) * gradient_scale + movement;
 float t = sin(diagonal_pos) * 0.5 + 0.5; 
	
 vec3 grad_rgb = mix(gradient_color1.rgb, gradient_color2.rgb, t);
	
 // 3. Смешивание с сохранением теней арта
 vec3 tinted_rgb = sprite_color.rgb * grad_rgb * 1.4;
 vec3 final_rgb = mix(sprite_color.rgb, tinted_rgb, blend_strength);
	
 // 4. Эффект вспышки урона
 final_rgb = mix(final_rgb, vec3(1.0, 1.0, 1.0), flash_brightness);
	
 // 5. СБОРКА ИТОГОВОГО ПИКСЕЛЯ
 // RGB берем чистый, а итоговую прозрачность умножаем на node_alpha
 COLOR = vec4(final_rgb, sprite_color.a * node_alpha);
}