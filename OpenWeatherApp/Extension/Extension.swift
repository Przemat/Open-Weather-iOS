//
//  Extension.swift
//  OpenWeatherApp
//

import Foundation

extension Double{
    func round() -> String{
        String(format:"%.1f", self)
    }
    func roundz() -> String{
        String(format:"%.0f", self)
    }
}
