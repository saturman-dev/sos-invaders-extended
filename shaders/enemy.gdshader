shader_type canvas_item;

// --- УНИФОРМЫ ---
uniform bool enable_outline = true;
uniform float outline_thickness : hint_range(0.0, 10.0) = 2.0;
uniform vec4 color_solid : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform bool use_gradient = true;
uniform vec4 gradient_color1 : source_color = vec4(1.0, 0.9, 0.0, 1.0); // Желтый
uniform vec4 gradient_color2 : source_color = vec4(1.0, 0.4, 0.0, 1.0); // Оранжевый
uniform float gradient_speed : hint_range(0.0, 10.0) = 2.0;
uniform float gradient_scale : hint_range(0.1, 10.0) = 1.0;

// Новые параметры для Эффекта Разгневанности (Rage Mode)
uniform float rage_intensity : hint_range(0.0, 1.0) = 0.0; // От 0.0 (обычный) до 1.0 (УЛЬТРА-ЯРОСТЬ)
uniform vec4 rage_color : source_color = vec4(1.0, 0.0, 0.1, 1.0); // Багрово-красный

uniform float flash_brightness : hint_range(0.0, 1.0) = 0.0; // Получение урона

void fragment() {
 vec2 uv = UV;
 vec4 sprite_color = texture(TEXTURE, uv);
 vec2 ps = TEXTURE_PIXEL_SIZE;
	
 // 1. РАСЧЕТ МАСКИ ОБВОДКИ
 float outline_alpha = 0.0;
 outline_alpha += texture(TEXTURE, uv + vec2(-outline_thickness, -outline_thickness) * ps).a;
 outline_alpha += texture(TEXTURE, uv + vec2(outline_thickness, -outline_thickness) * ps).a;
 outline_alpha += texture(TEXTURE, uv + vec2(-outline_thickness, outline_thickness) * ps).a;
 outline_alpha += texture(TEXTURE, uv + vec2(outline_thickness, outline_thickness) * ps).a;
 outline_alpha += texture(TEXTURE, uv + vec2(-outline_thickness, 0.0) * ps).a;
 outline_alpha += texture(TEXTURE, uv + vec2(outline_thickness, 0.0) * ps).a;
 outline_alpha += texture(TEXTURE, uv + vec2(0.0, -outline_thickness) * ps).a;
 outline_alpha += texture(TEXTURE, uv + vec2(0.0, outline_thickness) * ps).a;
	
 outline_alpha = min(outline_alpha, 1.0);
 float final_outline_mask = clamp(outline_alpha - sprite_color.a, 0.0, 1.0);
	
 // 2. ДИАГОНАЛЬНЫЙ ПЕРЕЛИВ ОБВОДКИ
 vec4 final_outline_color = color_solid;
 if (use_gradient) {
  float movement = TIME * gradient_speed;
  float diagonal_pos = (uv.x + uv.y) * gradient_scale + movement;
  float t = sin(diagonal_pos) * 0.5 + 0.5;
  final_outline_color = mix(gradient_color1, gradient_color2, t);
 }
	
 // 3. МАСКА ЯРОСТИ (Интеллектуальное наложение красного)
 // Высчитываем общую яркость пикселя по стандарту Rec. 709 (чтобы сохранить тени пиксель-арта)
 float luminance = dot(sprite_color.rgb, vec3(0.2126, 0.7152, 0.0722));
	
 // Создаем сочный неоновый красный, подмешивая к цвету ярости свечение на основе яркости
 vec3 furious_red = rage_color.rgb * (luminance + 0.25);
	
 // Плавно переводим текстуру врага в режим ярости
 vec3 base_with_rage = mix(sprite_color.rgb, furious_red, rage_intensity);
	
 // Если враг в ярости, его обводка тоже слегка багровеет на максимальном уровне
 final_outline_color.rgb = mix(final_outline_color.rgb, vec3(1.0, 0.0, 0.0), rage_intensity * 0.5);
	
 // 4. ЭФФЕКТ СВЕЧЕНИЯ ПРИ УРОНЕ (Hit Flash)
 // Белый флеш идет ПОВЕРХ ярости, чтобы игрок понимал, что урон наносится
 vec3 flash_rgb = mix(base_with_rage, vec3(1.0, 1.0, 1.0), flash_brightness);
 vec4 final_sprite = vec4(flash_rgb, sprite_color.a);
	
 // 5. СБОРКА ФИНАЛЬНОГО ЦВЕТА
 vec4 final_color = mix(final_outline_color, final_sprite, final_sprite.a);
 final_color.a = max(final_sprite.a, final_outline_mask);
	
 if (!enable_outline) {
  final_color = final_sprite;
 }
	
 COLOR = final_color;
}