# 🖥️ **VS Code Terminal Configuration Guide**

This document explains the optimized terminal settings for the server-config-repo project.

## 🎯 **Key Terminal Settings Explained**

### 📝 **Terminal Title Configuration**
```json
"terminal.integrated.tabs.title": "${process}${separator}${cwdFolder}${separator}${shellCommand}"
```
**What it shows**: `PowerShell - server-config-repo - git status`
- `${process}`: Shows "PowerShell", "cmd", etc.
- `${cwdFolder}`: Shows current folder name
- `${shellCommand}`: Shows currently running command (requires shell integration)

### 🚀 **Shell Integration Features**
```json
"terminal.integrated.shellIntegration.enabled": true,
"terminal.integrated.shellIntegration.decorationsEnabled": "both"
```
**Benefits**:
- ✅ Command start/end detection
- ✅ Visual command success/failure indicators
- ✅ Better navigation with Ctrl+Up/Down
- ✅ Enhanced IntelliSense

### 🎨 **Visual Enhancements**
```json
"terminal.integrated.fontSize": 14,
"terminal.integrated.fontFamily": "Cascadia Code, Consolas, 'Courier New', monospace"
```
**Features**:
- 📊 Optimal font size for readability
- 🔤 Cascadia Code with ligatures (if installed)
- 📱 Fallback fonts for compatibility

### 🔧 **PowerShell Profile Settings**
```json
"terminal.integrated.profiles.windows": {
  "PowerShell": {
    "args": ["-NoLogo"]
  }
}
```
**Benefits**:
- 🚀 Faster startup (no PowerShell logo)
- 🎯 Clean terminal appearance
- ⚡ Better performance

## 🛠️ **How to Apply These Settings**

### Method 1: Workspace Settings (Recommended)
The settings are already configured in `.vscode/settings.json` and will apply automatically to this project.

### Method 2: Global Settings
1. Press `Ctrl+,` to open Settings
2. Search for each setting name
3. Apply the values manually

### Method 3: Settings JSON
1. Press `Ctrl+Shift+P`
2. Type "Preferences: Open Settings (JSON)"
3. Add the settings from `.vscode/settings.json`

## 🎯 **Customization Options**

### 📝 **Terminal Title Variations**
```json
// Simple: Just folder name
"terminal.integrated.tabs.title": "${cwdFolder}"

// Detailed: Process + folder + git branch
"terminal.integrated.tabs.title": "${process} - ${cwdFolder} - ${sequence}"

// Minimal: Just the running command
"terminal.integrated.tabs.title": "${shellCommand}"
```

### 🎨 **Font Options**
```json
// For developers with Fira Code
"terminal.integrated.fontFamily": "Fira Code, Consolas, monospace"

// For JetBrains Mono users
"terminal.integrated.fontFamily": "JetBrains Mono, Cascadia Code, monospace"

// Default system fonts
"terminal.integrated.fontFamily": "Consolas, 'Courier New', monospace"
```

### 📊 **Word Separators for Your Workflow**
```json
// Default (good for general use)
"terminal.integrated.wordSeparators": " ()[]{}',\"`─''\"\"| \\/:;<>&"

// Path-friendly (better for file operations)
"terminal.integrated.wordSeparators": " ()[]{}',\"`─''\"\"|\;<>&"

// Git-friendly (excludes : for file:line:column)
"terminal.integrated.wordSeparators": " ()[]{}',\"`─''\"\"| \\;<>&"
```

## 🚀 **Advanced Features**

### 🎯 **Command Navigation**
With shell integration enabled:
- `Ctrl+Up/Down`: Navigate between commands
- `Ctrl+Shift+Up/Down`: Select command output
- Click on command decorations for quick actions

### 📋 **Copy/Paste Improvements**
```json
"terminal.integrated.rightClickBehavior": "copyPaste"
```
- Right-click automatically copies selection or pastes
- Streamlined workflow for command-line operations

### 🔧 **Source Control Integration**
```json
"terminal.sourceControlRepositoriesKind": "integrated"
```
- Terminals opened from Source Control view use integrated terminal
- Better context awareness for git operations

## 📊 **Performance Tips**

1. **Scrollback Limit**: Set to 10,000 lines for good performance
2. **Disable Bell**: Prevents audio notifications
3. **ConPTY**: Enabled for better Windows performance
4. **No Logo**: PowerShell starts faster without copyright notice

## 🎨 **Visual Indicators**

With these settings, you'll see:
- 🟢 **Green checkmarks** for successful commands
- 🔴 **Red X marks** for failed commands
- 📁 **Folder context** in terminal tabs
- ⚡ **Command progress** indicators
- 🎯 **Current command** in tab titles

These settings optimize your terminal experience for server configuration management! 🚀