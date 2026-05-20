shader_type canvas_item;

void fragment() {
    // Зацикливаем UV-координаты по вертикали (ось Y)
    vec2 uv = UV;
    uv.y = fract(uv.y * 150.0); // Вместо 5.0 можно поставить число повторений

    COLOR = texture(TEXTURE, uv);
}