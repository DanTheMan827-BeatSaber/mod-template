// This file demonstrates how to hook the DidActivate method
// of the MainFlowCoordinator class.

#include "GlobalNamespace/MainFlowCoordinator.hpp"

#include "autohooks/shared/hooks.hpp"
#include "logger.hpp"

using namespace GlobalNamespace;

/// This hook does nothing but log a debug message.
/// It serves as a basic example of how to hook a method.
///
/// The original method is called after this hook with no changes.
///
/// MainFlowCoordinator::DidActivate is a method that is called when the MainFlowCoordinator is activated as the main menu is shown.
MAKE_LATE_HOOK_MATCH(
    MainFlowCoordinator_DidActivate,
    &MainFlowCoordinator::DidActivate,
    void,
    MainFlowCoordinator* self,
    bool firstActivation,
    bool addedToHierarchy,
    bool screenSystemEnabling
) {
    Logger.debug(
        "MainFlowCoordinator::DidActivate called with firstActivation={}, addedToHierarchy={}, screenSystemEnabling={}",
        firstActivation,
        addedToHierarchy,
        screenSystemEnabling
    );

    MainFlowCoordinator_DidActivate(self, firstActivation, addedToHierarchy, screenSystemEnabling);
}
