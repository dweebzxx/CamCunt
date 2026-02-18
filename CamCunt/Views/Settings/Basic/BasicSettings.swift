//
//  BasicSettings.swift
//  CamCunt
//
//  Created by Itay Brenner on 7/21/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import SwiftUI

struct BasicSettings: View {
    @ObservedObject var controller: DeviceController

    var body: some View {
        VStack {
            ExposureView(controller: controller)
            ImageView(controller: controller)
            WhiteBalanceView(controller: controller)
        }
    }
}

//struct BasicSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        BasicSettings()
//    }
//}
