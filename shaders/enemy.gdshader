shader_type canvas_item;

// --- УНИФОРМЫ ---
uniform bool enable_outline = true;
uniform float outline_thickness : hint_range(0.0, 10.0) = 2.0; // Теперь честно работает до 10.0!
uniform vec4 color_solid : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform bool use_gradient = true;
uniform vec4 gradient_color1 : source_color = vec4(1.0, 0.9, 0.0, 1.0); // Желтый
uniform vec4 gradient_color2 : source_color = vec4(1.0, 0.4, 0.0, 1.0); // Оранжевый
uniform float gradient_speed : hint_range(0.0, 10.0) = 5.0;
uniform float gradient_scale : hint_range(0.1, 10.0) = 5.0;

// --- НАСТРОЙКА ДЛЯ НЕО-СТАТУСА ---
uniform float blend_strength : hint_range(0.0, 1.0) = 0.0; // 0.0 - нет градиента, 1.0 - полный градиент

// Параметры для Эффекта Разгневанности (Rage Mode)
uniform float rage_intensity : hint_range(0.0, 1.0) = 0.0; 
uniform vec4 rage_color : source_color = vec4(1.0, 0.0, 0.1, 1.0); 

// --- НАСТРОЙКА ВСПЫШКИ УРОНА (Hit Flash) ---
uniform float flash_brightness : hint_range(0.0, 1.0) = 0.0; // Сила вспышки урона
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // ЦВЕТ ВСПЫШКИ (По дефолту белый)

void fragment() {
	vec2 uv = UV;
	vec4 sprite_color = texture(TEXTURE, uv);
	vec2 ps = TEXTURE_PIXEL_SIZE;
	
	// 1. УМНЫЙ РАСЧЕТ МАСКИ ОБВОДКИ (С пошаговым заполнением без дыр)
	float outline_alpha = 0.0;
	
	// Цикл всегда ограничен константой 10.0 — это гарантирует стабильность на любых видеокартах
	for (float i = 1.0; i <= 10.0; i += 1.0) {
		// Берем минимальное значение между текущим шагом и лимитом из инспектора
		float d = min(i, outline_thickness);
		
		// Накапливаем альфу со всех промежуточных пикселей, убирая пустоты
		outline_alpha += texture(TEXTURE, uv + vec2(-d, -d) * ps).a;
		outline_alpha += texture(TEXTURE, uv + vec2(d, -d) * ps).a;
		outline_alpha += texture(TEXTURE, uv + vec2(-d, d) * ps).a;
		outline_alpha += texture(TEXTURE, uv + vec2(d, d) * ps).a;
		outline_alpha += texture(TEXTURE, uv + vec2(-d, 0.0) * ps).a;
		outline_alpha += texture(TEXTURE, uv + vec2(d, 0.0) * ps).a;
		outline_alpha += texture(TEXTURE, uv + vec2(0.0, -d) * ps).a;
		outline_alpha += texture(TEXTURE, uv + vec2(0.0, d) * ps).a;
		
		// Если мы полностью покрыли толщину из инспектора (даже дробную, например 2.5) — выходим
		if (i >= outline_thickness) {
			break;
		}
	}
	
	outline_alpha = min(outline_alpha, 1.0);
	float final_outline_mask = clamp(outline_alpha - sprite_color.a, 0.0, 1.0);
	
	// 2. ДИАГОНАЛЬНЫЙ ПЕРЕЛИВ
	float movement = TIME * gradient_speed;
	float diagonal_pos = (uv.x + uv.y) * gradient_scale + movement;
	float t = sin(diagonal_pos) * 0.5 + 0.5;
	
	vec4 final_outline_color = color_solid;
	if (use_gradient) {
		final_outline_color = mix(gradient_color1, gradient_color2, t);
	}
	
	// --- ВНУТРЕННИЙ ГРАДИЕНТ НЕО-СТАТУСА ---
	vec3 neon_rgb = mix(gradient_color1.rgb, gradient_color2.rgb, t);
	vec3 blended_sprite_rgb = mix(sprite_color.rgb, sprite_color.rgb * neon_rgb * 1.4, blend_strength);
	
	// 3. МАСКА ЯРОСТИ
	float luminance = dot(blended_sprite_rgb, vec3(0.2126, 0.7152, 0.0722));
	vec3 furious_red = rage_color.rgb * (luminance + 0.25);
	vec3 base_with_rage = mix(blended_sprite_rgb, furious_red, rage_intensity);
	
	// Если враг в ярости, обводка тоже багровеет
	final_outline_color.rgb = mix(final_outline_color.rgb, vec3(1.0, 0.0, 0.0), rage_intensity * 0.5);
	
	// 4. ЭФФЕКТ СВЕЧЕНИЯ ПРИ УРОНЕ (Hit Flash)
	// Заменили vec3(1.0, 1.0, 1.0) на flash_color.rgb
	vec3 flash_rgb = mix(base_with_rage, flash_color.rgb, flash_brightness);
	vec4 final_sprite = vec4(flash_rgb, sprite_color.a);
	
	// 5. СБОРКА ФИНАЛЬНОГО ЦВЕТА
	vec4 final_color = mix(final_outline_color, final_sprite, final_sprite.a);
	final_color.a = max(final_sprite.a, final_outline_mask);
	if (!enable_outline) {
		final_color = final_sprite;
	}
	
	COLOR = final_color;
}