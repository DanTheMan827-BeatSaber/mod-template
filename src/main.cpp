#include "Logger.hpp"
#include "beatsaber-hook/shared/utils/il2cpp-functions.hpp"
#include "main.hpp"
#include "modInfo.hpp"
#include "scotland2/shared/modloader.h"

/// @brief Called at the early stages of game loading
/// @param info
/// @return
MOD_EXPORT_FUNC void setup(CModInfo& info) {
    info = modInfo.to_c();

    Logger.info("Completed setup!");
}

/// @brief Called later on in the game loading - a good time to install function hooks
/// @return
MOD_EXPORT_FUNC void late_load() {
    il2cpp_functions::Init();
}
