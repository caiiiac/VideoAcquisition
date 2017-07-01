//
//  ViewController.swift
//  VideoAcquisition
//
//  Created by 唐三彩 on 2017/6/30.
//  Copyright © 2017年 唐三彩. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    fileprivate lazy var session : AVCaptureSession = AVCaptureSession()
    fileprivate var videoOutput :AVCaptureVideoDataOutput?
    fileprivate var preViewLayer : AVCaptureVideoPreviewLayer?
    fileprivate var videoInput : AVCaptureDeviceInput?
    fileprivate var moviewOutput : AVCaptureMovieFileOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupVideoInputOutput()
        setupAudioInputOutput()

    }

    

   
}

extension ViewController {
    //开始录制
    @IBAction func startCapturing(_ sender: UIButton) {
        session.startRunning()
        
        setupPreviewLayer()
    }
    
    //结束录制
    @IBAction func stopCapturing(_ sender: UIButton) {
        
        session.stopRunning()
        preViewLayer?.removeFromSuperlayer()
    }
    
    //切换镜头
    @IBAction func rotateCamera(_ sender: UIButton) {
        
        //取出之前的镜头
        guard let videoInput = videoInput else {
            return
        }
        
        let postion : AVCaptureDevicePosition = videoInput.device.position == .front ? .back : .front
        guard let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] else {
            return
        }
        guard let device = devices.filter({ $0.position == postion}).first else {
            return
        }
        guard let newInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        //移除之前的input,添加新的input
        session.beginConfiguration()
        session.removeInput(videoInput)
        if session.canAddInput(newInput) {
            session.addInput(newInput)
        }
        session.commitConfiguration()
        
        //更新在使用的input
        self.videoInput = newInput
    }
    
}

extension ViewController {
    fileprivate func setupVideoInputOutput() {
        //添加视频的输入
        guard let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] else {
            return
        }
        guard let device = devices.filter({ $0.position == .front }).first else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        self.videoInput = input
        
        //添加视频的输出
        let output = AVCaptureVideoDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        self.videoOutput = output
        
        //添加输入&输出
        addInputOutputToSesssion(input, output)
        
    }
    
    fileprivate func setupAudioInputOutput() {
        //音频输入
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) else {
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        //音频输出
        let output = AVCaptureAudioDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        
        addInputOutputToSesssion(input, output)
        
    }
    
    fileprivate func setupPreviewLayer() {
        //创建预览图层
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: session) else {
            return
        }
        previewLayer.frame = view.bounds
        
        view.layer.insertSublayer(previewLayer, at: 0)
        self.preViewLayer = previewLayer
    }
    
    private func addInputOutputToSesssion(_ input: AVCaptureInput, _ output: AVCaptureOutput) {
        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.commitConfiguration()
    }
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate{
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if videoOutput?.connection(withMediaType: AVMediaTypeVideo) == connection {
            print("视频数据")
        } else {
            print("音频数据")
        }
    }
}
