import SwiftUI

extension Color {
    // MARK: - Brand Colors
    
    /// Primary brand blue - #009FC7
    static let brandPrimary = Color(red: 0/255, green: 159/255, blue: 199/255)
    
    /// Brand red - #D7001F
    static let brandRed = Color(red: 215/255, green: 0/255, blue: 31/255)
    
    /// Brand dark blue - #000F9F
    static let brandDarkBlue = Color(red: 0/255, green: 15/255, blue: 159/255)
    
    /// Brand black - #000
    static let brandBlack = Color(red: 0/255, green: 0/255, blue: 0/255)
    
    /// Brand light gray - #F4F5F0
    static let brandLight = Color(red: 244/255, green: 245/255, blue: 240/255)
    
    // MARK: - Semantic Brand Colors
    
    /// Primary action color (brand blue)
    static let brandAction = brandPrimary
    
    /// Destructive action color (brand red)
    static let brandDestructive = brandRed
    
    /// Secondary action color (brand dark blue)
    static let brandSecondary = brandDarkBlue
    
    /// Background color (brand light)
    static let brandBackground = brandLight
    
    /// Text color (brand black)
    static let brandText = brandBlack
    
    // MARK: - Status Colors
    
    /// Success color (brand primary)
    static let brandSuccess = brandPrimary
    
    /// Warning color (brand red)
    static let brandWarning = brandRed
    
    /// Info color (brand dark blue)
    static let brandInfo = brandDarkBlue
}
