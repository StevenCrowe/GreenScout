#!/bin/bash

# Color replacements script for GreenScout
# Replaces system colors with AppColors equivalents

echo "Starting color replacement..."

# Skip backup to avoid recursive copy issues

# SwiftUI Color replacements
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/Color\.primary/AppColors.textPrimary/g' \
    -e 's/Color(\.systemBackground)/AppColors.backgroundLight/g' \
    -e 's/Color(\.systemGray6)/AppColors.backgroundLight/g' \
    -e 's/Color(\.systemGray5)/AppColors.greyLine/g' \
    -e 's/Color(\.systemGroupedBackground)/AppColors.backgroundLight/g' \
    {} \;

# UIKit UIColor replacements
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/UIColor\.systemBackground/UIColor(AppColors.backgroundLight)/g' \
    -e 's/UIColor\.label/UIColor(AppColors.textPrimary)/g' \
    -e 's/UIColor\.secondaryLabel/UIColor(AppColors.textSecondary)/g' \
    {} \;

# Replace .foregroundColor(.secondary) with .foregroundColor(AppColors.textSecondary)
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/\.foregroundColor(\.secondary)/\.foregroundColor(AppColors.textSecondary)/g' \
    {} \;

# Replace standalone .secondary color references
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/color: \.secondary/color: AppColors.textSecondary/g' \
    {} \;

# Replace Color.blue with AppColors.secondary (for our blue theme)
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/Color\.blue/AppColors.secondary/g' \
    {} \;

# Replace .gray color references with AppColors.textSecondary
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/\.foregroundColor(\.gray)/\.foregroundColor(AppColors.textSecondary)/g' \
    {} \;

# Replace Color.green with AppColors.success
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/Color\.green/AppColors.success/g' \
    {} \;

# Replace .orange with AppColors.warning
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/\.orange/AppColors.warning/g' \
    {} \;

# Replace .yellow with AppColors.warning
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/\.yellow/AppColors.warning/g' \
    {} \;

# Replace .cyan with AppColors.secondary
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/\.cyan/AppColors.secondary/g' \
    {} \;

# Replace standalone .green with AppColors.success
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/\.green/AppColors.success/g' \
    {} \;

# Replace standalone .red with AppColors.error
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/\.red/AppColors.error/g' \
    {} \;

# Replace Color.red with AppColors.error  
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/Color\.red/AppColors.error/g' \
    {} \;

# Replace Color.gray with AppColors.textSecondary
find ./GreenScout -name "*.swift" -type f -exec sed -i '' \
    -e 's/Color\.gray/AppColors.textSecondary/g' \
    {} \;

echo "Color replacement completed!"
echo ""
echo "Summary of replacements:"
echo "- Color.primary → AppColors.textPrimary"
echo "- Color(.systemBackground) → AppColors.backgroundLight"
echo "- UIColor.systemBackground → UIColor(AppColors.backgroundLight)"
echo "- Color(.systemGray6) → AppColors.backgroundLight"
echo "- Color(.systemGray5) → AppColors.greyLine"
echo "- Color(.systemGroupedBackground) → AppColors.backgroundLight"
echo "- .secondary → AppColors.textSecondary"
echo "- Color.blue → AppColors.secondary"
echo "- Color.green → AppColors.success"
echo "- .orange → AppColors.warning"
echo "- .yellow → AppColors.warning"
echo "- .cyan → AppColors.secondary"
echo "- .green → AppColors.success"
echo "- .red → AppColors.error"
echo "- Color.red → AppColors.error"
echo "- Color.gray → AppColors.textSecondary"
