// --- header --
bool CheckHasAdminAccess();

// --- body ---
#if _WIN32
	//define our own version!
	struct __TOKEN_ELEVATION;
	struct __TOKEN_ELEVATION {
		DWORD TokenIsElevated;
	};
	
	#define _TokenElevation 20
	
	// --- body ---
	bool CheckHasAdminAccess() {
		// --- check result and pass it back to monkey in a simplified way ---
		//need this intermediate to handle passing pointer to api call
		BOOL result = false;
		HANDLE token = NULL;
		if(OpenProcessToken(GetCurrentProcess(),TOKEN_QUERY,&token)) {
			__TOKEN_ELEVATION elevation;
			
			DWORD size = sizeof(__TOKEN_ELEVATION);
			if(GetTokenInformation(token,(_TOKEN_INFORMATION_CLASS)_TokenElevation,&elevation,sizeof(elevation),&size)) {
				result = elevation.TokenIsElevated;
			}
		}
		if(token) { CloseHandle(token); }
		return result;
	}
#else
	bool CheckHasAdminAccess() {
		//fake it for unsupported platforms
		return true;
	}
#endif
