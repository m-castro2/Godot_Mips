#include "register_types.h"

//#include "GodotWrapper.h"
#include "PipelinedWrapper.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

static PipelinedWrapper *_pipelined_wrapper;

void initialize_pipelined_wrapper(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    //ClassDB::register_class<GodotWrapper>();
    ClassDB::register_class<PipelinedWrapper>();
    _pipelined_wrapper = memnew(PipelinedWrapper);
	Engine::get_singleton()->register_singleton("PipelinedWrapper", _pipelined_wrapper);
}

void uninitialize_pipelined_wrapper(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

extern "C" {
// Initialization.
GDExtensionBool GDE_EXPORT pipelined_wrapper_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
    godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

    init_obj.register_initializer(initialize_pipelined_wrapper);
    init_obj.register_terminator(uninitialize_pipelined_wrapper);
    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}
}