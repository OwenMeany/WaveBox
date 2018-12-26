//
//  LeapFrogSimulator.swift
//  WaveBox
//
//  Created by Harri on 02/12/18.
//  Copyright © 2018 Harri. All rights reserved.
//

import Foundation
import Accelerate
import UIKit

public class LeapFrogSimulator {
    
    private var pixelData: Array<Int32>
    var image: UIImage
    
    var u: [Float]
    var v: [Float]
    var A: [Float]

    let Nx: Int
    let Ny: Int
    let N: Int
    let N2: Int
    
    let Lx: Float
    let Ly: Float
    
    let dx: Float
    let dy: Float
    
    let C: Float
    
    let dt: Float
    
    var currentimestep: Int
    
    init(Nx: Int, Ny: Int, Lx: Float, Ly: Float, C: Float, dt: Float) {
        self.Nx = Nx
        self.Ny = Ny
        self.Lx = Lx
        self.Ly = Ly
        self.C = C
        self.dt = dt
        self.N = Nx*Ny
        self.N2 = N*N
        self.u = Array(repeating: 0.0, count: N)
        self.v = Array(repeating: 0.0, count: N)
        self.A = Array(repeating: 0.0, count: N2)
        
        self.dx = Lx / Float(Nx-1)
        self.dy = Ly / Float(Ny-1)
        self.currentimestep = 0
        
        image = UIImage()
        self.pixelData = Array(repeating: 0, count: N)

        ConstructLaplacian()
        
    }
    
    func Evolve() {
        
        //u <-- u + dt * v;
        cblas_saxpy(Int32(N), dt, &v, 1, &u, 1)
        
        // v <-- v - dt * A * u
        cblas_sgemv(CBLAS_ORDER(rawValue: 101), CBLAS_TRANSPOSE(rawValue: 111), Int32(N), Int32(N), -C*dt, &A, Int32(N), &u, 1, 1.0, &v, 1)

        for II in 0..<N {
            pixelData[II] = ToRGBA(input: u[II])
        }
        
        currentimestep += 1

    }
    
    func Reset() {
        
        for II in 0..<N {
            u[II] = 0.0
            v[II] = 0.0
        }
        
    }
    
    func SetWave(x: Int, y: Int) {
        
        var ix : Int = x
        var iy : Int = y
        let magnitude : Float = 10.0
        
        //handle the touches near the boundaries
        if ix < 1 {
            ix = 1
        }
        if ix > Nx-2 {
            ix = Nx-2
        }
        if iy < 1 {
            iy = 1
        }
        if iy > Ny-2 {
            iy = Ny-2
        }
        
        u[I(i: ix,   j: iy  )] = magnitude
        u[I(i: ix+1, j: iy  )] = magnitude / 2.0
        u[I(i: ix-1, j: iy  )] = magnitude / 2.0
        u[I(i: ix,   j: iy+1)] = magnitude / 2.0
        u[I(i: ix,   j: iy-1)] = magnitude / 2.0
        u[I(i: ix+1, j: iy+1)] = magnitude / 4.0
        u[I(i: ix-1, j: iy-1)] = magnitude / 4.0
        u[I(i: ix+1, j: iy-1)] = magnitude / 4.0
        u[I(i: ix-1, j: iy+1)] = magnitude / 4.0
    }

    func SetBigWave() {
        
        var x : Float
        var y : Float
        
        for II in 0..<N {
            x = Float(i(I: II))*Lx/Float(Nx) - Lx / 2.0
            y = Float(j(I: II))*Ly/Float(Ny) - Ly / 2.0
            u[II] = 2.0*exp(-(x*x + y*y) / 2.0 / ((Lx + Ly)*0.005))
            v[II] = 0.0
        }
    }
    
    private func ConstructLaplacian() {
        
        for ii in 1..<Nx-1 {
            for jj in 1..<Ny-1 {
                let II = I(i: ii, j:jj)
                A[II*N + I(i: ii-1, j:jj)] = -1.0/dx/dx
                A[II*N + I(i: ii+1, j:jj)] = -1.0/dx/dx
                A[II*N + I(i: ii, j:jj-1)] = -1.0/dy/dy
                A[II*N + I(i: ii, j:jj+1)] = -1.0/dy/dy
                A[II*N + II] = 2.0/dx/dx + 2.0/dy/dy
                
            }
        }
        
    }
    
    func I(i: Int, j: Int) -> Int {
        return i*Ny+j
    }
    
    func i(I: Int) -> Int {
        return I % Nx
    }
    
    func j(I: Int) -> Int {
        return I / Nx
    }
        
    private func ToRGBA(input: Float) -> Int32 {
        let scaled: Float
        if input > 1.0 {
            scaled = 1.0
        }
        else if input < -1.0 {
            scaled = -1.0
        } else {
            scaled = input
        }
        if scaled < 0 {
            //return blue channel only
            return Int32(-scaled * 255.0) * 0x00000001;
        } else {
            //return red channel only
            return Int32(scaled * 255.0) * 0x00010000;
        }
        
    }
    
    func UpdateImage() -> UIImage {
        
        let bmpInfo = CGImageAlphaInfo.noneSkipFirst.rawValue|CGImageByteOrderInfo.order32Little.rawValue
        
        let colorSpace =  CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Nx, height: Ny,
                                bitsPerComponent: 8, bytesPerRow: Nx*4, space: colorSpace,
                                bitmapInfo: bmpInfo)!
        
        image = UIImage(cgImage: context.makeImage()!)
        return image
    }
    
}
