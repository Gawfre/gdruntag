extends WindowDialog


const TT_PORT = "Le port du serveur à communiquer à vos amis. Port par défaut : %s." % gamestate.DEFAULT_PORT
const TT_INTERNALPORT = "Le port de votre PC."
const TT_EXTERNALPORT = "Le port de votre box. À communiquer à vos amis pour qu'ils puissent se connecter."
const SIMPLE_NAME = "Entrer le port"
const ADVANCED_NAME = "Entrer les ports"
const IPORT_SIMPLE_NAME = "Port :"
const IPORT_ADVANCED_NAME = "Internal Port :"
const BUTTON_SIMPLE_NAME = "Avancé"
const BUTTON_ADVANCED_NAME = "Simple"
#> const HELP_INFO = "Ecrire l'aide ici"

var internal_port = str(gamestate.DEFAULT_PORT)
var external_port = str(gamestate.DEFAULT_PORT)

var success = false
var poperror = null

signal config_success()

func _ready():
	$ExtPortLabel.set_tooltip(TT_EXTERNALPORT)
	$ExternalPort.set_tooltip(TT_EXTERNALPORT)
	$ExternalPort.text = external_port
	$ExtPortLabel.visible = false
	$ExternalPort.visible = false
	$InternalPort.text = internal_port
	switch_to_simple_texts()

func switch_to_advanced_texts():
	set_title(ADVANCED_NAME)
	$IntPortLabel.text = IPORT_ADVANCED_NAME
	$IntPortLabel.set_tooltip(TT_INTERNALPORT)
	$InternalPort.set_tooltip(TT_INTERNALPORT)
	$AdvancedButton.text = BUTTON_ADVANCED_NAME
	
func switch_to_simple_texts():
	set_title(SIMPLE_NAME)
	$IntPortLabel.text = IPORT_SIMPLE_NAME
	$IntPortLabel.set_tooltip(TT_PORT)
	$InternalPort.set_tooltip(TT_PORT)
	$AdvancedButton.text = BUTTON_SIMPLE_NAME

func toggle_mode():
	$ExtPortLabel.visible = not $ExtPortLabel.visible
	$ExternalPort.visible = not $ExternalPort.visible
	if $ExtPortLabel.visible:
		switch_to_advanced_texts()
	else:
		switch_to_simple_texts()


func _on_AdvancedButton_pressed():
	toggle_mode()

func _on_ConfirmPort_pressed():
	var iport = $InternalPort.text
	var eport = $ExternalPort.text if $ExternalPort.visible else $InternalPort.text
	var upnp_result = gamestate.launch_upnp(int(eport), int(iport))
	if upnp_result != UPNP.UPNP_RESULT_SUCCESS:
		poperror = AcceptDialog.new()
		poperror.dialog_text = "Impossible de lancer l'UPNP\n\nError : " + str(upnp_result)
		add_child(poperror)
		poperror.popup_centered_minsize(Vector2(100, 100))
		poperror.connect("popup_hide", self, "_on_poperror_hide")
	else:
		hide()
		emit_signal("config_success")
	
func _on_poperror_hide():
	poperror.queue_free()
	poperror = null

