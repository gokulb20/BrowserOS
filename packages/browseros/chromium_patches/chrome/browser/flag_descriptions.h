diff --git a/chrome/browser/flag_descriptions.h b/chrome/browser/flag_descriptions.h
index d73e9a053eb63..5174931bde25d 100644
--- a/chrome/browser/flag_descriptions.h
+++ b/chrome/browser/flag_descriptions.h
@@ -284,6 +284,18 @@ inline constexpr char kBookmarksTreeViewName[] =
 inline constexpr char kBookmarksTreeViewDescription[] =
     "Show the bookmarks side panel in a tree view while in compact mode.";
 
+// BrowserOS: feature flags
+inline constexpr char kBrowserOsAlphaFeaturesName[] =
+    "Crewm8 Alpha Features";
+inline constexpr char kBrowserOsAlphaFeaturesDescription[] =
+    "Enables Crewm8 alpha features.";
+
+inline constexpr char kBrowserOsKeyboardShortcutsName[] =
+    "Crewm8 Keyboard Shortcuts";
+inline constexpr char kBrowserOsKeyboardShortcutsDescription[] =
+    "Enables Crewm8 keyboard shortcuts (Cmd+Shift+K, Cmd+Shift+L, "
+    "Option+A). Disable if these conflict with your keyboard layout.";
+
 inline constexpr char kBrowsingHistoryActorIntegrationM1Name[] =
     "Browsing History Actor Integration M1";
 inline constexpr char kBrowsingHistoryActorIntegrationM1Description[] =
