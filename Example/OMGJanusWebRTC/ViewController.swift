//
//  ViewController.swift
//  OMGJanusWebRTC
//
//  Created by Hyde Guo on 10/15/2018.
//  Copyright (c) 2018 Hyde Guo. All rights reserved.
//

import UIKit
import OMGJanusWebRTC
import Starscream
import WebRTC

class ViewController: UIViewController ,OMGRTCClientDelegate,RTCEAGLVideoViewDelegate{
    
    
    @IBOutlet var localView:UIView!
    @IBOutlet var removeView:UIView!
    @IBOutlet var removeView2:UIView!
    var rtcLocalView:RTCEAGLVideoView?
    //    var rtcLocalView:RTCCameraPreviewView?
    var rtcRemoveView:RTCEAGLVideoView?
    var rtcRemoveView2:RTCEAGLVideoView?
    var rtcRemoveViews:[RTCEAGLVideoView] = []
    var localVideoTrack:RTCVideoTrack?
    var removeVideoTrack:RTCVideoTrack?
    var removeVideoTrack2:RTCVideoTrack?
    var removeVideoTracks:[RTCVideoTrack] = []
    
    var rtcManager:RTCClient?
    var clientServer: RTCVideoServer?
    var rtcOperator: WebRTCOperator?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        rtcLocalView = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: localView.frame.width, height: localView.frame.height))
        rtcRemoveView = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: removeView.frame.width, height: removeView.frame.height))
        rtcRemoveView2 = RTCEAGLVideoView(frame: CGRect(x: 0, y: 0, width: removeView.frame.width, height: removeView.frame.height))
        
        localView.addSubview(rtcLocalView!)
        
        var iceServers = [RTCIceServer]()
        //            iceServers.append(RTCIceServer(urlStrings: iceServerdata.urls, username: iceServerdata.username, credential: iceServerdata.credential))
        iceServers.append(RTCIceServer(urlStrings:["stun:69.30.225.195:3478"], username: "bleakas", credential: "dajtpd" ))
        iceServers.append(RTCIceServer(urlStrings: ["turn:69.30.225.195:3478?transport=udp"], username: "bleakas", credential: "dajtpd"))
//        iceServers.append(RTCIceServer(urlStrings:["stun:us-turn4.xirsys.com"]))
//               iceServers.append(RTCIceServer(urlStrings: [ "turn:us-turn4.xirsys.com:80?transport=udp",
//                     "turn:us-turn4.xirsys.com:3478?transport=udp",
//                     "turn:us-turn4.xirsys.com:80?transport=tcp",
//                     "turn:us-turn4.xirsys.com:3478?transport=tcp",
//                     "turns:us-turn4.xirsys.com:443?transport=tcp",
//                     "turns:us-turn4.xirsys.com:5349?transport=tcp"], username: "KMEy-VTAukFCxTjhQwXp0q0HncJgaPR1RlBpRCQYGl-gfHYnEJEPtgL18VbSq3s3AAAAAF7KhI5ibGVha2Fz", credential: "d737cbc6-9dca-11ea-816a-0242ac140004"))
        let n = Int(arc4random_uniform(11142))
        let myId = String(n)
        rtcManager = RTCClient(videoCall: true)
        rtcManager?.defaultIceServer = iceServers
        clientServer = RTCVideoServer(url: "ws://69.30.225.195:8188/", client: rtcManager!)
        clientServer?.display = myId
//        clientServer?.initPublish = false
        rtcOperator = WebRTCOperator(delegate: self,omgSocket: clientServer!)
        rtcManager?.delegate = rtcOperator
        clientServer?.registerMeetRoom(1234)
        
        
        
        //        _=setTimeout(delay: 15, block: switchCanera)
    }
    
    func switchCanera()
    {
        if(localVideoTrack != nil && (localVideoTrack!.source as? RTCAVFoundationVideoSource)?.canUseBackCamera == true){
            (localVideoTrack!.source as! RTCAVFoundationVideoSource).useBackCamera = !(localVideoTrack!.source as! RTCAVFoundationVideoSource).useBackCamera
        }
    }
    
    
    @IBAction public func unpublishMyself()
    {
        clientServer?.unpublishMyself()
        rtcLocalView?.removeFromSuperview()
    }
    @IBAction public func publishMyself()
    {
        clientServer?.publishMyself()
        localView.addSubview(rtcLocalView!)
    }
    
    
    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
        //        rtcRemoveView?.renderFrame(RTCVideoFrame(buffer: <#T##RTCVideoFrameBuffer#>, rotation: <#T##RTCVideoRotation#>, timeStampNs: <#T##Int64#>))
        //        print("......videoView...\(videoView==rtcRemoveView)")
        //        rtcRemoveView?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
    }
    
    
    func rtcClient(_ id: String, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
        //        rtcLocalView?.captureSession=(localVideoTrack.source as! RTCAVFoundationVideoSource).captureSession
        self.localVideoTrack = localVideoTrack
        localVideoTrack.add(self.rtcLocalView!)
    }
    
    func rtcClient(_ id: String, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        print("[didReceive RemoteVideo Track..]")
        
        DispatchQueue.main.async{
            if(self.rtcRemoveView?.tag==0){
                self.removeVideoTrack = remoteVideoTrack
                self.rtcRemoveView?.delegate = self
                self.rtcRemoveView?.tag = Int(id)!
                self.removeView.addSubview(self.rtcRemoveView!)
                remoteVideoTrack.add(self.rtcRemoveView!)
            }else if (self.rtcRemoveView2?.tag==0){
                self.removeVideoTrack2 = remoteVideoTrack
                self.rtcRemoveView2?.delegate = self
                self.rtcRemoveView2?.tag = Int(id)!
                self.removeView2.addSubview(self.rtcRemoveView2!)
                remoteVideoTrack.add(self.rtcRemoveView2!)
                
            }
        }
        
    }
    
    func rtcClient(_ id: String, didReceiveError error: Error) {
        print("[Error]:\(error)")
    }
    
    func rtcClient(_ id: String, didChangeConnectionState connectionState: RTCIceConnectionState) {
        if(connectionState == .checking){
            print("[didChangeConnectionState]:checking)")
        }
        if(connectionState == .closed){
            print("[didChangeConnectionState]:closed)")
            DispatchQueue.main.async{
                if(self.rtcRemoveView?.tag==Int(id)){
                    self.removeVideoTrack?.remove(self.rtcRemoveView!)
                    self.rtcRemoveView?.removeFromSuperview()
                    self.rtcRemoveView?.tag = 0
                }else if (self.rtcRemoveView2?.tag==Int(id)){
                    self.removeVideoTrack2?.remove(self.rtcRemoveView2!)
                    self.rtcRemoveView2?.removeFromSuperview()
                    self.rtcRemoveView2?.tag = 0
                }
            }
        }
        if(connectionState == .completed){
            print("[didChangeConnectionState]:completed)")
        }
        if(connectionState == .connected){
            print("[didChangeConnectionState]:connected)")
        }
        if(connectionState == .disconnected){
            print("[didChangeConnectionState]:disconnected)")
        }
        if(connectionState == .failed){
            print("[didChangeConnectionState]:failed)")
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

