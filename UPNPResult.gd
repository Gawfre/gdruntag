# Coder handling des erreur ici ? Et après l'importer ailleurs ?
func get_error(error):
	match error:
		UPNP_RESULT_NOT_AUTHORIZED:
			return STR_UPNP_RESULT_NOT_AUTHORIZED + "\nError code: " + error
		UPNP_RESULT_PORT_MAPPING_NOT_FOUND:
			return STR_UPNP_RESULT_PORT_MAPPING_NOT_FOUND + "\nError code: " + error
		UPNP_RESULT_INCONSISTENT_PARAMETERS:
			return STR_UPNP_RESULT_INCONSISTENT_PARAMETERS + "\nError code: " + error
		UPNP_RESULT_NO_SUCH_ENTRY_IN_ARRAY:
			return STR_UPNP_RESULT_NO_SUCH_ENTRY_IN_ARRAY + "\nError code: " + error
		UPNP_RESULT_ACTION_FAILED:
			return STR_UPNP_RESULT_ACTION_FAILED + "\nError code: " + error
		UPNP_RESULT_SRC_IP_WILDCARD_NOT_PERMITTED:
			return STR_UPNP_RESULT_SRC_IP_WILDCARD_NOT_PERMITTED + "\nError code: " + error
		UPNP_RESULT_EXT_PORT_WILDCARD_NOT_PERMITTED:
			return STR_UPNP_RESULT_EXT_PORT_WILDCARD_NOT_PERMITTED + "\nError code: " + error
		UPNP_RESULT_INT_PORT_WILDCARD_NOT_PERMITTED:
			return STR_UPNP_RESULT_INT_PORT_WILDCARD_NOT_PERMITTED + "\nError code: " + error
		UPNP_RESULT_REMOTE_HOST_MUST_BE_WILDCARD:
			return STR_UPNP_RESULT_REMOTE_HOST_MUST_BE_WILDCARD + "\nError code: " + error
		UPNP_RESULT_EXT_PORT_MUST_BE_WILDCARD:
			return STR_UPNP_RESULT_EXT_PORT_MUST_BE_WILDCARD + "\nError code: " + error
		UPNP_RESULT_NO_PORT_MAPS_AVAILABLE:
			return STR_UPNP_RESULT_NO_PORT_MAPS_AVAILABLE + "\nError code: " + error
		UPNP_RESULT_CONFLICT_WITH_OTHER_MECHANISM:
			return STR_UPNP_RESULT_CONFLICT_WITH_OTHER_MECHANISM + "\nError code: " + error
		UPNP_RESULT_CONFLICT_WITH_OTHER_MAPPING:
			return STR_UPNP_RESULT_CONFLICT_WITH_OTHER_MAPPING + "\nError code: " + error
		UPNP_RESULT_SAME_PORT_VALUES_REQUIRED:
			return STR_UPNP_RESULT_SAME_PORT_VALUES_REQUIRED + "\nError code: " + error
		UPNP_RESULT_ONLY_PERMANENT_LEASE_SUPPORTED:
			return STR_UPNP_RESULT_ONLY_PERMANENT_LEASE_SUPPORTED + "\nError code: " + error
		UPNP_RESULT_INVALID_GATEWAY:
			return STR_UPNP_RESULT_INVALID_GATEWAY + "\nError code: " + error
		UPNP_RESULT_INVALID_PORT:
			return STR_UPNP_RESULT_INVALID_PORT + "\nError code: " + error
		UPNP_RESULT_INVALID_PROTOCOL:
			return STR_UPNP_RESULT_INVALID_PROTOCOL + "\nError code: " + error
		UPNP_RESULT_INVALID_DURATION:
			return STR_UPNP_RESULT_INVALID_DURATION + "\nError code: " + error
		UPNP_RESULT_INVALID_ARGS:
			return STR_UPNP_RESULT_INVALID_ARGS + "\nError code: " + error
		UPNP_RESULT_INVALID_RESPONSE:
			return STR_UPNP_RESULT_INVALID_RESPONSE + "\nError code: " + error
		UPNP_RESULT_INVALID_PARAM:
			return STR_UPNP_RESULT_INVALID_PARAM + "\nError code: " + error
		UPNP_RESULT_HTTP_ERROR:
			return STR_UPNP_RESULT_HTTP_ERROR + "\nError code: " + error
		UPNP_RESULT_SOCKET_ERROR:
			return STR_UPNP_RESULT_SOCKET_ERROR + "\nError code: " + error
		UPNP_RESULT_MEM_ALLOC_ERROR:
			return STR_UPNP_RESULT_MEM_ALLOC_ERROR + "\nError code: " + error
		UPNP_RESULT_NO_GATEWAY:
			return STR_UPNP_RESULT_NO_GATEWAY + "\nError code: " + error
		UPNP_RESULT_NO_DEVICES:
			return STR_UPNP_RESULT_NO_DEVICES + "\nError code: " + error
		UPNP_RESULT_UNKNOWN_ERROR:
			return STR_UPNP_RESULT_UNKNOWN_ERROR + "\nError code: " + error
		var err:
			return "Unknown error\nError code: " + err


const STR_UPNP_RESULT_NOT_AUTHORIZED = "Not authorized to use the command on the UPNPDevice. May be returned when the user disabled UPNP on their router."
const STR_UPNP_RESULT_PORT_MAPPING_NOT_FOUND = "No port mapping was found for the given port, protocol combination on the given UPNPDevice."
const STR_UPNP_RESULT_INCONSISTENT_PARAMETERS = "Inconsistent parameters."
const STR_UPNP_RESULT_NO_SUCH_ENTRY_IN_ARRAY = "No such entry in array. May be returned if a given port, protocol combination is not found on an UPNPDevice."
const STR_UPNP_RESULT_ACTION_FAILED = "The action failed."
const STR_UPNP_RESULT_SRC_IP_WILDCARD_NOT_PERMITTED = "The UPNPDevice does not allow wildcard values for the source IP address."
const STR_UPNP_RESULT_EXT_PORT_WILDCARD_NOT_PERMITTED = "The UPNPDevice does not allow wildcard values for the external port."
const STR_UPNP_RESULT_INT_PORT_WILDCARD_NOT_PERMITTED = "The UPNPDevice does not allow wildcard values for the internal port."
const STR_UPNP_RESULT_REMOTE_HOST_MUST_BE_WILDCARD = "The remote host value must be a wildcard."
const STR_UPNP_RESULT_EXT_PORT_MUST_BE_WILDCARD = "The external port value must be a wildcard."
const STR_UPNP_RESULT_NO_PORT_MAPS_AVAILABLE = "No port maps are available. May also be returned if port mapping functionality is not available."
const STR_UPNP_RESULT_CONFLICT_WITH_OTHER_MECHANISM = "Conflict with other mechanism. May be returned instead of UPNP_RESULT_CONFLICT_WITH_OTHER_MAPPING if a port mapping conflicts with an existing one."
const STR_UPNP_RESULT_CONFLICT_WITH_OTHER_MAPPING = "Conflict with an existing port mapping."
const STR_UPNP_RESULT_SAME_PORT_VALUES_REQUIRED = "External and internal port values must be the same."
const STR_UPNP_RESULT_ONLY_PERMANENT_LEASE_SUPPORTED = "Only permanent leases are supported. Do not use the duration parameter when adding port mappings."
const STR_UPNP_RESULT_INVALID_GATEWAY = "Invalid gateway."
const STR_UPNP_RESULT_INVALID_PORT = "Invalid port."
const STR_UPNP_RESULT_INVALID_PROTOCOL = "Invalid protocol."
const STR_UPNP_RESULT_INVALID_DURATION = "Invalid duration."
const STR_UPNP_RESULT_INVALID_ARGS = "Invalid arguments."
const STR_UPNP_RESULT_INVALID_RESPONSE = "Invalid response."
const STR_UPNP_RESULT_INVALID_PARAM = "Invalid parameter."
const STR_UPNP_RESULT_HTTP_ERROR = "HTTP error."
const STR_UPNP_RESULT_SOCKET_ERROR = "Socket error."
const STR_UPNP_RESULT_MEM_ALLOC_ERROR = "Error allocating memory."
const STR_UPNP_RESULT_NO_GATEWAY = "No gateway available. You may need to call discover first, or discovery didn’t detect any valid IGDs (InternetGatewayDevices)."
const STR_UPNP_RESULT_NO_DEVICES = "No devices available. You may need to call discover first, or discovery didn’t detect any valid UPNPDevices."
const STR_UPNP_RESULT_UNKNOWN_ERROR = "Unknown error."
