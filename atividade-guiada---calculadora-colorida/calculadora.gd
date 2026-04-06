extends Control

var numero_atual: String = ""
var numero_anterior: float = 0.0
var operacao_atual: String = ""
var aguardando_segundo_numero: bool = false


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

# Tratando o número que aparece na tela
func digito_pressionado(valor: String) -> void:
	if aguardando_segundo_numero:
		numero_atual = ""
		aguardando_segundo_numero = false
	
	numero_atual += valor
	$VBoxContainer/PanelContainer/VBoxContainer/resultadolabel.text = numero_atual

# Tratando primeiro e segundo número, e cor da tecla
func operacao_pressionada(valor: String) -> void:
	if numero_atual == "": return
	
	numero_anterior = numero_atual.to_float()
	operacao_atual = valor
	aguardando_segundo_numero = true
	
	# MOSTRA A CONTA NO EXPRESSAOLABEL
	$VBoxContainer/PanelContainer/VBoxContainer/expressaolabel.text = str(numero_anterior) + " " + valor
	# LIMPA O RESULTADOLABEL PARA O PRÓXIMO NÚMERO
	$VBoxContainer/PanelContainer/VBoxContainer/resultadolabel.text = ""
	
	var tecla_cor = valor
	if valor == "x" or valor == "×": tecla_cor = "*"
	if valor == "÷": tecla_cor = "/"
	if valor == "−": tecla_cor = "-"
	
	if cores.has(tecla_cor):
		mudar_cor(cores[tecla_cor])

# Trata nenhum número, transforma número em float, trata divisão por zero
func calcular_resultado() -> void:
	if operacao_atual == "" or numero_atual == "": return
	
	var num2 = numero_atual.to_float()
	
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

# Tratar a tecla C, reinicar todas as variáveis
func resetar_calculadora() -> void:
	numero_atual = ""
	numero_anterior = 0.0
	operacao_atual = ""
	$VBoxContainer/PanelContainer/VBoxContainer/resultadolabel.text = "0"
	$VBoxContainer/PanelContainer/VBoxContainer/expressaolabel.text = ""
