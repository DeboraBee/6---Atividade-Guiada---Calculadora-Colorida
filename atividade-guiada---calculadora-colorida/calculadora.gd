extends Control

var numero_atual: String = ""
var numero_anterior: float = 0.0
var operacao_atual: String = ""
var aguardando_segundo_numero: bool = false

# Dicionário ajustado para os símbolos que você usou no IF (teclado comum)
var cores = {
	"+": Color("#4CAF50"),  # verde
	"-": Color("#FFC107"),  # amarelo
	"*": Color("#F44336"),  # vermelho
	"/": Color("#2196F3"),  # azul
}

func _ready() -> void:
	for botao in get_tree().get_nodes_in_group("botoes"):
		botao.pressed.connect(
			_on_button_pressed.bind(botao.text)
		)	

func _on_button_pressed(valor: String) -> void:
	if valor.is_valid_float():
		digito_pressionado(valor)
	# IMPORTANTE: Garanta que o texto nos seus botões seja exatamente um desses:
	elif valor in ["+", "-", "*", "/", "x", "÷", "×", "−"]:
		operacao_pressionada(valor)
	elif valor == "=":
		calcular_resultado()
	elif valor == "C":
		resetar_calculadora()

func mudar_cor(cor: Color) -> void:
	var painel = $VBoxContainer/PanelContainer
	var estilo = painel.get_theme_stylebox("panel").duplicate()
	estilo.bg_color = cor
	painel.add_theme_stylebox_override("panel", estilo)

func digito_pressionado(valor: String) -> void:
	if aguardando_segundo_numero:
		numero_atual = ""
		aguardando_segundo_numero = false
	
	numero_atual += valor
	$VBoxContainer/PanelContainer/VBoxContainer/resultadolabel.text = numero_atual

func operacao_pressionada(valor: String) -> void:
	if numero_atual == "": return
	
	# Se já tinha uma operação pendente, ele calcula antes de seguir (opcional)
	numero_anterior = numero_atual.to_float()
	operacao_atual = valor
	aguardando_segundo_numero = true
	
	# MOSTRA A CONTA NO EXPRESSAOLABEL
	$VBoxContainer/PanelContainer/VBoxContainer/expressaolabel.text = str(numero_anterior) + " " + valor
	# LIMPA O RESULTADOLABEL PARA O PRÓXIMO NÚMERO
	$VBoxContainer/PanelContainer/VBoxContainer/resultadolabel.text = ""
	
	# Tenta mudar a cor (converte símbolos visuais para os do dicionário se necessário)
	var tecla_cor = valor
	if valor == "x" or valor == "×": tecla_cor = "*"
	if valor == "÷": tecla_cor = "/"
	if valor == "−": tecla_cor = "-"
	
	if cores.has(tecla_cor):
		mudar_cor(cores[tecla_cor])

func calcular_resultado() -> void:
	if operacao_atual == "" or numero_atual == "": return
	
	var num2 = numero_atual.to_float()
	
	# 5. 🚫 Trate a divisão por zero!
	if (operacao_atual == "/" or operacao_atual == "÷") and num2 == 0.0:
		$VBoxContainer/PanelContainer/VBoxContainer/resultadolabel.text = "Erro! 🚫"
		return

	var resultado = 0.0
	
	# Comparação robusta para aceitar qualquer tipo de caractere de operação
	if operacao_atual == "+": 
		resultado = numero_anterior + num2
	elif operacao_atual in ["-", "−"]: 
		resultado = numero_anterior - num2
	elif operacao_atual in ["*", "x", "×"]: 
		resultado = numero_anterior * num2
	elif operacao_atual in ["/", "÷"]: 
		resultado = numero_anterior / num2
	
	# MOSTRA O RESULTADO FINAL NO RESULTADOLABEL
	$VBoxContainer/PanelContainer/VBoxContainer/resultadolabel.text = str(resultado)
	# MANTÉM A CONTA COMPLETA NO EXPRESSAOLABEL
	$VBoxContainer/PanelContainer/VBoxContainer/expressaolabel.text = str(numero_anterior) + " " + operacao_atual + " " + str(num2) + " ="
	
	numero_atual = str(resultado)
	operacao_atual = ""

func resetar_calculadora() -> void:
	numero_atual = ""
	numero_anterior = 0.0
	operacao_atual = ""
	$VBoxContainer/PanelContainer/VBoxContainer/resultadolabel.text = "0"
	$VBoxContainer/PanelContainer/VBoxContainer/expressaolabel.text = ""
