# GreenScout

GreenScout is an iOS application for agricultural chemical management and compliance.

## Brand Color Guidelines

All colors used throughout the GreenScout application are defined in `AppColors.swift`. This centralized approach ensures consistency across the entire app and makes it easy to maintain our brand identity.

### Color Palette

Our brand colors are:
- **Primary Green**: `#4CAF50` - Used for primary actions and brand identity
- **Secondary Green**: `#81C784` - Used for secondary elements and accents
- **Dark Green**: `#388E3C` - Used for emphasis and important information
- **Background**: `#F5F5F5` - Light gray background for content areas
- **Surface**: `#FFFFFF` - White surface color for cards and containers
- **Text Primary**: `#212121` - Main text color
- **Text Secondary**: `#757575` - Secondary text and labels
- **Warning**: `#FFC107` - Warning indicators
- **Error**: `#F44336` - Error states and critical warnings

### Usage Guidelines

1. **Always use colors from `AppColors.swift`** - Never hardcode color values directly in views
2. **No dark mode variants** - The app uses a fixed color palette that remains consistent regardless of system appearance
3. **Color naming convention** - Colors are named by their purpose (e.g., `primaryGreen`, `textSecondary`) rather than their appearance

### Example Usage

```swift
import SwiftUI

struct ExampleView: View {
    var body: some View {
        VStack {
            Text("Primary Text")
                .foregroundColor(AppColors.textPrimary)
            
            Button("Action") {
                // Action
            }
            .foregroundColor(.white)
            .background(AppColors.primaryGreen)
        }
        .background(AppColors.background)
    }
}
```

### Adding New Colors

If you need to add a new color:
1. Add it to `AppColors.swift` with a semantic name
2. Document its intended usage
3. Get design team approval before implementation

For any questions about color usage, refer to `AppColors.swift` or contact the design team.
