# System Color to AppColors Mapping

This document provides a comprehensive mapping of system-dependent colors found in the GreenScout project to their corresponding AppColors equivalents.

## Mapping Table

| System Color | AppColors Equivalent | Notes |
|--------------|---------------------|-------|
| `.secondary` | `AppColors.textSecondary` | Used for secondary text elements |
| `.primary` | `AppColors.textPrimary` | Used for primary text elements |
| `Color(.systemGray6)` | `AppColors.backgroundLight` | Light gray background |
| `Color(.systemBackground)` | `AppColors.backgroundLight` | Main background color |
| `Color(.systemGroupedBackground)` | `AppColors.backgroundLight` | Grouped background color |
| `UIColor.systemGreen` | `AppColors.success` | Success/green indicators |
| `.green` | `AppColors.success` | SwiftUI green color |
| `.orange` | `AppColors.warning` | Warning indicators |
| `.red` | `AppColors.error` | Error/critical indicators |
| `.yellow` | `AppColors.warning` | Warning/caution indicators |
| `.blue` | `AppColors.secondary` | Secondary/informational color |
| `.cyan` | `AppColors.secondary` | Alternative secondary color |
| `.gray` | `AppColors.textSecondary` | Gray text/elements |
| `Color.gray.opacity(0.1)` | `AppColors.backgroundLight` | Light gray backgrounds |
| `Color.green.opacity(0.1)` | `AppColors.greenLight` | Light green backgrounds |
| `.white` | Keep as `.white` | Pure white (no change needed) |
| `.black` | Keep as `.black` | Pure black (no change needed) |

## Color Usage by File

### ContentView.swift
- **Line 63, 88, 92, 96, 100**: `.secondary` → `AppColors.textSecondary`
- **Line 138, 223, 266**: `.secondary` → `AppColors.textSecondary`

### SafetyWarningsView.swift
- **Line 61, 78**: `.secondary` → `AppColors.textSecondary`

### ComplianceDashboardView.swift
- **Line 63, 67, 75, 80, 106, 110, 116, 142, 162, 179, 190**: Various system colors
  - `.secondary` → `AppColors.textSecondary`
  - `Color(.systemGray6)` → `AppColors.backgroundLight`
  - `Color(.systemBackground)` → `AppColors.backgroundLight`

### ResultsView.swift
- **Line 71, 85, 372, 431, 455**: `.secondary` → `AppColors.textSecondary`
- **Line 278**: `UIColor.systemGreen` → `AppColors.success`

### ChemicalProductRow.swift
- **Line 21, 25**: `.secondary` → `AppColors.textSecondary`
- **Line 40**: `Color(.systemBackground)` → `AppColors.backgroundLight`

### CalculationResultView.swift
- **Line 141, 173, 203, 211, 247, 283, 308, 315**: Various system colors
  - `.secondary` → `AppColors.textSecondary`
  - `Color(.systemGray6)` → `AppColors.backgroundLight`

### ChemicalCalculatorView.swift
- **Line 73, 86, 90, 95, 100, 122, 126, 140**: Various system colors
  - `.secondary` → `AppColors.textSecondary`
  - `Color(.systemGray6)` → `AppColors.backgroundLight`

### FieldDataInputView.swift
- **Line 91, 101, 112, 116, 126, 137, 141, 156, 172**: `.secondary` → `AppColors.textSecondary`

### ChemicalProductListView.swift
- **Line 29, 33, 67, 77, 93, 124, 158, 162, 196, 206, 220**: Various system colors
  - `.secondary` → `AppColors.textSecondary`
  - `Color(.systemGray6)` → `AppColors.backgroundLight`
  - `Color(.systemGroupedBackground)` → `AppColors.backgroundLight`
  - `Color(.systemGray5)` → `AppColors.backgroundLight`

## Implementation Guidelines

1. **Text Colors**:
   - Replace `.secondary` with `AppColors.textSecondary` for secondary text
   - Replace `.primary` with `AppColors.textPrimary` for primary text

2. **Background Colors**:
   - Replace `Color(.systemGray6)`, `Color(.systemBackground)`, and `Color(.systemGroupedBackground)` with `AppColors.backgroundLight`
   - For dark mode support, consider using `AppColors.backgroundDark` with appropriate checks

3. **Status Colors**:
   - Replace `.green` and `UIColor.systemGreen` with `AppColors.success`
   - Replace `.orange` and `.yellow` with `AppColors.warning`
   - Replace `.red` with `AppColors.error`

4. **Accent Colors**:
   - Replace `.blue` and `.cyan` with `AppColors.secondary` or `AppColors.accent` depending on context

5. **Special Cases**:
   - Keep `.white` and `.black` as-is for maximum contrast
   - For opacity variations, apply opacity to the AppColors equivalent

## Maintenance Notes

- When adding new features, always use AppColors instead of system colors
- Update this mapping document when new system colors are discovered
- Consider creating additional AppColors for specific use cases if needed
- Test all color changes in both light and dark modes

## Migration Priority

1. **High Priority**: Colors in main navigation and primary UI elements
2. **Medium Priority**: Colors in secondary views and detail screens
3. **Low Priority**: Colors in rarely-used features or debug screens

Last Updated: January 2025
