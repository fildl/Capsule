//
//  ImageEditorView.swift
//  Capsule
//
//  Created by Filippo Di Ludovico on 05/12/25.
//

import SwiftUI

struct ImageEditorView: View {
    let inputImage: UIImage
    let initialScale: CGFloat
    let initialOffset: CGSize
    var onSave: (UIImage, CGFloat, CGSize) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.displayScale) private var displayScale
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Pinch to Zoom & Drag to Center")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                
                Spacer()
                
                // Crop Area
                GeometryReader { geometry in
                    ZStack {
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale *= delta
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                        if scale < 1.0 { withAnimation { scale = 1.0 } }
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width) // Square crop frame usually? or dynamic?
                    // Let's stick to the current view aspect or square. Capsule seems square-ish friendly for items.
                    // But for now let's use the screen width as the frame.
                    .clipped()
                    .background(Color.black.opacity(0.1))
                    .overlay(
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    // Save Logic
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { dismiss() }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let cropped = cropImage(geometry: geometry)
                                onSave(cropped, scale, offset)
                                dismiss()
                            }
                        }
                    }
                }
                .aspectRatio(3/4, contentMode: .fit)
                
                Spacer()
            }
            .navigationTitle("Edit Photo")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                scale = initialScale
                offset = initialOffset
                lastOffset = initialOffset // Important so drag starts correctly
            }
        }
    }
    
    @MainActor
    func cropImage(geometry: GeometryProxy) -> UIImage {
        // Render the view to a generic UIImage
        let renderer = ImageRenderer(content:
            ZStack {
                Color.clear // Transparent background
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        )
        
        // Ensure transparent background logic if possible, but ImageRenderer usually renders white or opaque.
        // To keep transparency, we need to ensure the hosting view is transparent.
        renderer.scale = displayScale
        renderer.isOpaque = false // Key for transparency
        
        return renderer.uiImage ?? inputImage
    }
}

#Preview {
    ImageEditorView(
        inputImage: UIImage(systemName: "tshirt")!,
        initialScale: 1.0,
        initialOffset: .zero
    ) { _, _, _ in }
}
