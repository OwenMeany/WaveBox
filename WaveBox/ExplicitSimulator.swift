//
//  ExplicitSimulator.swift
//  WaveBox
//
//  Created by Harri on 28/11/18.
//  Copyright © 2018 Harri. All rights reserved.
//

import Foundation
import UIKit

public class ExplicitSimulator {
    
    private var pixelData: Array<Int32>
    var image: UIImage
    
    var u: Array<Double>
    var u1: Array<Double>
    var u2: Array<Double>
    var v: Array<Double>
    
    let Nx: Int
    let Ny: Int
    
    let Lx: Double
    let Ly: Double
    
    let dx: Double
    let dy: Double
    
    let C: Double
    
    let dt: Double
    
    var currentimestep: Int
    
    init(Nx: Int, Ny: Int, Lx: Double, Ly: Double, C: Double, dt: Double) {
        self.Nx = Nx
        self.Ny = Ny
        self.Lx = Lx
        self.Ly = Ly
        self.C = C
        self.dt = dt
        self.u = Array(repeating: 0.0, count: Nx * Ny)
        self.u1 = Array(repeating: 0.0, count: Nx * Ny)
        self.u2 = Array(repeating: 0.0, count: Nx * Ny)
        self.v = Array(repeating: 0.0, count: Nx * Ny)
        
        self.dx = Lx / Double(Nx-1)
        self.dy = Ly / Double(Ny-1)
        self.currentimestep = 0
        
        image = UIImage()
        self.pixelData = Array(repeating: 0, count: Nx*Ny)
        debugPrint(C*dt*dt/dx/dx)
        InitializeValues()
    }
    
    func Evolve() {
                
        for II in 0 ..< self.v.count  {
            let ii = i(I: II)
            let jj = j(I: II)
            
            //boundary conditions
            if ii == 0 || ii == Nx-1 || jj == 0 || jj == Ny-1 {
                
                continue
            }

            u[II] = 2.0*u1[II] - u2[II]
                + dt*dt*C*(u1[I(i:ii+1,j:jj)] + u1[I(i:ii-1,j:jj)] - 2.0*u1[I(i:ii,j:jj)])/dx/dx/2.0
                + dt*dt*C*(u1[I(i:ii,j:jj+1)] + u1[I(i:ii,j:jj-1)] - 2.0*u1[I(i:ii,j:jj)])/dy/dy/2.0

            pixelData[II] = ToRGBA(input: u[II])

        }
        
        u2 = u1
        u1 = u
        currentimestep += 1

    }
    
    public func I(i: Int, j: Int) -> Int {
        return i*Nx+j
    }
    
    public func i(I: Int) -> Int {
        return I % Nx
    }
    
    public func j(I: Int) -> Int {
        return I / Nx
    }
    
    private func InitializeValues() {
        for II in 0 ..< self.u1.count  {
            let y = Double(j(I: II))*Ly/Double(Ny) - Ly / 2.0
            let x = Double(i(I: II))*Lx/Double(Nx) - Lx / 2.0
            u1[II] = exp(-(x*x + y*y) / 2.0 / ((Lx + Ly)*0.05))
        }
        
        for II in 0 ..< self.u.count  {
            let ii = i(I: II)
            let jj = j(I: II)
            
            if ii == 0 || ii == Nx-1 || jj == 0 || jj == Ny-1 {
                u[II] = 0.0
                continue
            }
            
            u[II] = u1[II]
                - dt*dt*C*(u1[I(i:ii+1,j:jj)] + u1[I(i:ii-1,j:jj)] - 2.0*u1[I(i:ii,j:jj)]) / dx / dx / 2.0
                - dt*dt*C*(u1[I(i:ii,j:jj+1)] + u1[I(i:ii,j:jj-1)] - 2.0*u1[I(i:ii,j:jj)]) / dy / dy / 2.0
                
            
 
            pixelData[II] = ToRGBA(input: u[II])
            
        }
        u2 = u1
        u1 = u
    }
    
    private func ToRGBA(input: Double) -> Int32 {
        let scaled: Double
        if input > 1.0 {
            scaled = 1.0
        }
        else if input < 0.0 {
            scaled = 0.0
        } else {
            scaled = input
        }
        
        return Int32(scaled * 255.0) * 0x00010000;
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
