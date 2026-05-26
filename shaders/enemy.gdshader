shader_type canvas_item;

// --- УНИФОРМЫ (Настройки в Инспекторе) ---

// 1. Настройки Обводки
uniform float outline_thickness : hint_range(0.0, 10.0) = 5.0; // Толщина в пикселях
uniform vec4 color_solid : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Основной цвет (если не градиент)
uniform bool enable_outline = true; // Включить/выключить обводку вообще

// 2. Настройки Градиента
uniform bool use_gradient = true; // Включить/выключить градиент
uniform vec4 gradient_color1 : source_color = vec4(1.0, 0.9, 0.0, 1.0); // Желтый
uniform vec4 gradient_color2 : source_color = vec4(1.0, 0.4, 0.0, 1.0); // Оранжевый
uniform float gradient_speed : hint_range(0.0, 10.0) = 3.0; // Скорость перелива
uniform float gradient_scale : hint_range(0.1, 10.0) = 5.0; // Масштаб градиента

// 3. Настройки Урона (Hit Flash)
uniform float flash_brightness : hint_range(0.0, 1.0) = 0.0; // Сила побеления (от 0 до 1)


void fragment() {
	// Базовый пиксель текстуры
	vec2 uv = UV;
	vec4 sprite_color = texture(TEXTURE, uv);
	// Точный размер одного пикселя текстуры
	vec2 ps = TEXTURE_PIXEL_SIZE;
	// --- ЛОГИКА ОБВОДКИ (Алгоритм сглаживания по 8 точкам) ---
	// Проверяем прозрачность в 8 соседних пикселях
	float outline_alpha = 0.0;
	// Углы
	outline_alpha += texture(TEXTURE, uv + vec2(-outline_thickness, -outline_thickness) * ps).a;
	outline_alpha += texture(TEXTURE, uv + vec2(outline_thickness, -outline_thickness) * ps).a;
	outline_alpha += texture(TEXTURE, uv + vec2(-outline_thickness, outline_thickness) * ps).a;
	outline_alpha += texture(TEXTURE, uv + vec2(outline_thickness, outline_thickness) * ps).a;
	// Стороны
	outline_alpha += texture(TEXTURE, uv + vec2(-outline_thickness, 0.0) * ps).a;
	outline_alpha += texture(TEXTURE, uv + vec2(outline_thickness, 0.0) * ps).a;
	outline_alpha += texture(TEXTURE, uv + vec2(0.0, -outline_thickness) * ps).a;
	outline_alpha += texture(TEXTURE, uv + vec2(0.0, outline_thickness) * ps).a;
	// Ограничиваем альфу, чтобы она не была больше 1
	outline_alpha = min(outline_alpha, 1.0);
	// Вычитаем альфу самого спрайта, чтобы обводка была ТОЛЬКО снаружи
	float final_outline_mask = clamp(outline_alpha - sprite_color.a, 0.0, 1.0);
	// --- ЛОГИКА ДИАГОНАЛЬНОГО ПЕРЕЛИВА ---
	vec4 final_outline_color = color_solid;
	if (use_gradient) {
		// Магия диагонали: складываем U и V
		// Магия движения: прибавляем TIME * speed
		float movement = TIME * gradient_speed;
		float diagonal_pos = (uv.x + uv.y) * gradient_scale + movement;
		// Создаем бесконечный цикл от 0 до 1 через синус
		float formula = sin(diagonal_pos); // Синус дает плавную волну от -1 до 1
		float t = formula * 0.5 + 0.5; // Переводим волну в диапазон от 0 до 1
		// Смешиваем два цвета градиента по этой формуле
		final_outline_color = mix(gradient_color1, gradient_color2, t);
	}
	// --- ФИНАЛЬНАЯ СБОРКА ЦВЕТА ---
	// 1. Сначала применяем Hit Flash (побеление) к самому врагу
	// mix(исходный_цвет, белый, сила_флеша)
	vec3 flash_rgb = mix(sprite_color.rgb, vec3(1.0, 1.0, 1.0), flash_brightness);
	vec4 final_sprite = vec4(flash_rgb, sprite_color.a);
	// 2. Накладываем спрайт ПОВЕРХ обводки
	// Результат = mix(Цвет_обводки, Цвет_спрайта, Альфа_спрайта)
	vec4 final_color = mix(final_outline_color, final_sprite, final_sprite.a);
	// Применяем маску обводки, чтобы цвета не вылезали за пределы толщины
	// Итоговая прозрачность = Максимум из (Альфа спрайта, Альфа маски обводки)
	final_color.a = max(final_sprite.a, final_outline_mask);
	if (!enable_outline) {
		final_color = final_sprite;
	}
	COLOR = final_color;
}