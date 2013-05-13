#define MAX_NUM_MODES 400

//header
class graphicsModeNative;
static Array<graphicsModeNative* > GetGraphicsModesNative();

//classes
class graphicsModeNative : public Object{
public:
	int width;
	int height;
	int depth;
	
	graphicsModeNative(int width,int height,int depth);
};

graphicsModeNative::graphicsModeNative(int width,int height,int depth):width(width),height(height),depth(depth){}

//functions
static void SetGraphicsNative(int width, int height, int depth, bool fullScreen) {
	/*
	// --- change the graphics resolution ---
	int x,y;
	int redBits,greenBits,blueBits,alphaBits,stencilBits;

	//work out the bits
	switch(depth) {
		case 0:
			//use desktop settings
			fullScreen = false;
			redBits = 0;
			greenBits = 0;
			blueBits = 0;
			alphaBits = 0;
			break;
		case 16:
			//16bit mode we give priority to green bit
			redBits = 5;
			greenBits = 6;
			blueBits = 5;
			alphaBits = 0;
			break;
		case 24:
		case 32:
			//fix 24bits for potential later cross compatability (faking alpha bits)
			redBits = 8;
			greenBits = 8;
			blueBits = 8;
			alphaBits = 0;
			break;
	}

	//get position of new window based on mode
	if (fullScreen == false) {
		//windowed mode
		GLFWvidmode desktopMode;
		glfwGetDesktopMode(&desktopMode);
		x = (desktopMode.Width-width)/2;
		y = (desktopMode.Height-height)/2;
	} else {
		//desktop mode
		x = 0;
		y = 0;
	}

	//close old window
	glfwCloseWindow();

	//open new window
	glfwOpenWindowHint(GLFW_WINDOW_NO_RESIZE,GL_TRUE);
	if(!glfwOpenWindow(width,height,redBits,greenBits,blueBits,alphaBits,CFG_OPENGL_DEPTH_BUFFER_ENABLED ? 32 : 0,stencilBits,fullScreen ? GLFW_FULLSCREEN : GLFW_WINDOW)){ //width,height,redbits,greenbits,bluebits,alphabits,depthbits,stencilbits,mode
		Error("glfwOpenWindow failed");
	}

	//put window position
	glfwSetWindowPos(x,y);
		
	//enable the cursor
	glfwEnable(GLFW_MOUSE_CURSOR);

	//modify the dimensions of the app
	app->graphics->width = width;
	app->graphics->height = height;

	//setup new window
	glfwSetWindowTitle(_STRINGIZE(CFG_GLFW_WINDOW_TITLE));

	//setup glfw
	glfwEnable(GLFW_KEY_REPEAT);
	glfwDisable(GLFW_AUTO_POLL_EVENTS);
	glfwSetKeyCallback(BBGlfwGame::OnKey);
	glfwSetCharCallback(BBGlfwGame::OnChar);
	//glfwSetWindowSizeCallback(BBGlfwGame::OnWindowSize);
	//glfwSetWindowRefreshCallback(BBGlfwGame::OnWindowRefresh);
	glfwSetMouseButtonCallback(BBGlfwGame::GlfwGame()->OnMouseButton);
	glfwSetMousePosCallback( BBGlfwGame::GlfwGame()->OnMousePos );
	*/
}

static bool GraphicsModeExistsNative(int width,int height, int depth) {
	// --- return true if a certain graphics mode exists ---
	GLFWvidmode glfwModes[MAX_NUM_MODES];
	int modeCount,index;

	//fix 32 graphics mode so it matches glfw color bits
	if (depth == 32) { depth = 24; }

	//look for matching graphics mode
	modeCount = glfwGetVideoModes(glfwModes,MAX_NUM_MODES);
	for(index=0;index<modeCount;index++) {
		if (glfwModes[index].Width == width && glfwModes[index].Height == height && glfwModes[index].RedBits + glfwModes[index].GreenBits + glfwModes[index].BlueBits == depth) {
			return true;
		}
	}

	//nope!
	return false;
}

static Array<graphicsModeNative* > GetGraphicsModesNative() {
	// --- get the available graphics resolutions ---
	GLFWvidmode glfwModes[MAX_NUM_MODES];
	int modeCount,index;

	//get the video modes from glfw
	modeCount = glfwGetVideoModes(glfwModes,MAX_NUM_MODES);

	//convert into a format monkey can understand
	Array<graphicsModeNative* > modes=Array<graphicsModeNative* >(modeCount);

	//create all instance of native and assign to garbage collector
	for(index=0;index<modeCount;index++) {
		gc_assign(modes[index],new graphicsModeNative(glfwModes[index].Width,glfwModes[index].Height,glfwModes[index].RedBits + glfwModes[index].GreenBits + glfwModes[index].BlueBits));

		//fix 24bits for potential later cross compatability (faking alpha bits)
		if (modes[index]->depth == 24) { modes[index]->depth = 32; }
	}

	//return result
	return modes;
}