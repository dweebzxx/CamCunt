//
//  AdvancedView.swift
//  CamCunt
//
//  Created by Itay Brenner on 7/24/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import SwiftUI

struct AdvancedView: View {
    @ObservedObject var controller: DeviceController

    var body: some View {
        VStack {
            PowerLineView(controller: controller)
            BacklightView(controller: controller)
            OrientationView(controller: controller)
            FocusView(controller: controller)
        }
    }
}

//struct AdvancedView_Previews: PreviewProvider {
//    static var previews: some View {
//        AdvancedView()
//    }
//}
