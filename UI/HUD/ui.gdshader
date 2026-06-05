shader_type canvas_item;

// Сила наклона рамки (можно крутить прямо в инспекторе)
uniform float skew_amount = -12.0; 

void vertex() {
	// Сдвигаем нижнюю часть панели по оси X
	VERTEX.x += UV.y * skew_amount;
}